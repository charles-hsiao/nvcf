# Recovery prerequisites

Keep source recovery requirements separate from a successful chart apply,
component snapshot or Pod restart. Both transitions remain unqualified.

## Pause before the backup

The action order is baseline, caller pause and drain, affected-writer pause,
source data validation, then consistent backup and isolated restore. Preserve
the verified data epoch until the backup is complete. Every disruptive hop
action depends on that recovery gate.

Do not purge requests, cancel tasks or remove workloads to satisfy the drain.
Record failed fixtures and their native terminal states. A task still waiting
for its native timeout blocks the affected drain.

## NATS memory storage

Both selected source servers run NATS 2.14.6. CLI 0.4.0 rejects memory-stream
backup. A separate native snapshot API request also returns error 10064,
`snapshot failed: no impl`. The matching upstream
[memory-store implementation](https://github.com/nats-io/nats-server/blob/v2.14.6/server/memstore.go)
does not implement snapshots. A filesystem archive does not capture messages
held in process memory.

The candidate recovery mode is `drained-memory-cold-restore`. It covers a
fully drained cohort. Recovery of nonempty or in-flight state is unsupported.
This restriction is explicit; it does not claim a general memory export/replay
solution or waive data preservation.

| Stream family | Application state | Required recovery checkpoint |
| --- | --- | --- |
| `rq_<region>_<version>` | Function invocation work | Empty stream and no pending, unacknowledged or redelivered consumer work |
| `requestToFunctionVersion_<region>` | Asynchronous result lookup | No outstanding result lookup records |
| `stateful_session_lookup_<region>` | Active session/reconnect lookup | No active session lookup records |
| `CreateNvcaFunctionTaskStream` | Compute creation commands | Empty stream and no pending consumer work |
| `TerminateNvcaStream` | Compute termination commands | Empty stream and no pending consumer work |

The source contains three-replica streams and single-replica management
streams. Preserve each actual configuration. Cold-copy testing with the
selected server image showed that a drained stream and its durable consumer
retain their configurations and can deliver and acknowledge new messages.
Their memory stream sequences and delivery/ack counters reset to zero. Do not
report those historical counters as preserved.

Before a planned NATS member replacement, also wait for both single-replica
management streams to have no messages, bytes or pending consumer work. Keep
their original replication settings. The member-replacement rehearsal uses
controlled invocation traffic and no new management submissions during that
step. It does not establish tolerance of an unplanned member loss with pending
single-replica management work.

1. Freeze the complete source stream and durable-consumer inventory. Unknown
   stream families or missing consumers require review.
2. Pause callers, finish native tasks and drain invocations and sessions.
   Then pause affected writers. Never purge, cancel or delete work to pass.
3. Capture two complete native observations after the pause. Require zero
   messages/bytes, zero consumer pending/acknowledgement/redelivery counts,
   unchanged configurations and stable last sequences. A failed read is not
   an empty stream. File storage needs a separately reviewed recovery mode.
4. Run `check-recovery` against the frozen baseline and private checkpoint.
   Bind the checkpoint to current contract/lock/baseline hashes, the server
   image digest and pause record. The tool rejects stale or incomplete data.
5. Make a consistent cohort backup, including Kubernetes trust/configuration,
   native stream metadata and the other data stores. Restore into new storage
   while the original identity cohort is stopped. Keep originals and backups.
6. Verify stream names, full configurations, storage, replicas and durable
   names/configurations. Record the expected native sequence/counter reset.
   Resume the same application identities and prove original/new invocation,
   secret and task behavior before accepting the recovery method.

`check-recovery` validates supplied observations and pause declarations. It
cannot prove that writers are stopped and does not execute or qualify restore.
Independent phase records and live full-stack acceptance are still required.
The isolated NATS test alone does not clear that final gate.

Keep nonempty memory streams and active invocations, asynchronous results,
sessions and tasks blocked. Do not convert storage, reset consumers manually,
or replay messages to obtain an empty checkpoint. An operator abandoning the
hop must verify source health before resuming its writers and callers.

## Component restore boundaries

An isolated OpenBao Raft restore can test original unseal material, cluster
identity, JWT mount accessors, plugin catalog and signing keys. Bind its result
to the snapshot checksum, server image digest and actual restored peers.

That result does not establish a consistent Cassandra, NATS, OpenBao and
Kubernetes recovery point. Full-stack recovery must also preserve source
configuration, Kubernetes trust material, credentials, registrations, workload
identities and cross-service data. Recheck source data validation after restore;
previous Pod UIDs, migration receipts and scan timestamps are stale.
