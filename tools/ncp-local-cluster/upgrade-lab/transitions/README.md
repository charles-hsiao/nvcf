# Self-Managed stack transition candidates

These lab inputs and reports cover [issue #3558](https://github.com/dsx-ai-factory/nvcf/issues/3558).
They are not required deployment files or a published upgrade catalog.
Both routes remain unqualified and disabled for supported execution.

## Exact comparison scope

| Route | Source control / compute / observability | Target control / compute / observability | Contract | Component report |
| --- | --- | --- | --- | --- |
| Stack 1.0.1 to 1.0.4 | 1.0.1 / 1.0.0 / 1.0.0 | 1.0.4 / 1.0.5 / 1.0.0 | [Contract](1.0.1-to-1.0.4.json) | [Report](1.0.1-to-1.0.4-components.md) |
| Stack 1.0.4 to 1.1.5 | 1.0.4 / 1.0.5 / 1.0.0 | 1.1.5 / 1.1.0 / 1.1.0 | [Contract](1.0.4-to-1.1.5.json) | [Report](1.0.4-to-1.1.5-components.md) |

Route numbers identify `deploy/stacks/self-managed/vX.Y.Z` releases.
Compute Plane and Observability follow each endpoint's referenced matrix.
Their inventories and the control-plane inventories are compared together.
Final endpoint selection does not qualify intermediate or mixed-fleet states.

## Read each documentation matrix separately

| Documentation matrix | Documented Self-Managed | Compute Plane | Observability |
| --- | --- | --- | --- |
| [Docs 1.0.1](https://docs.nvidia.com/nvcf/1.0.1/release-notes/compatibility-matrix) | 1.0.1 | 1.0.0 | 1.0.0 |
| [Docs 1.0.4](https://docs.nvidia.com/nvcf/1.0.4/release-notes/compatibility-matrix) | 1.0.10 | 1.0.5 | 1.0.0 |
| [Docs 1.1.0](https://docs.nvidia.com/nvcf/1.1.0/release-notes/compatibility-matrix) | 1.1.5 | 1.1.0 | 1.1.0 |

These are different edition selections. Docs 1.0.4 does not document stack
1.0.4 as its selected control plane. Its peer versions are used here by explicit
selection. Scoped route-specific compatibility checks passed in the recorded
laboratory profile; broader support remains unqualified. The final
1.1.5 / 1.1.0 / 1.1.0 selection matches docs 1.1.0.
Do not replace an issue endpoint with an edition's selected control plane or
infer peer versions from the endpoint number.

## Identities and evidence

[artifact-lock.json](artifact-lock.json) binds eight unique original stack
inventories to exact release tags, source commits, asset IDs and SHA-256
values. No umbrella bundle or synthetic product manifest defines these
stack-only endpoints. Candidate manifests are not selected in this scope.

The generated reports include endpoint selections, provenance, lock/contract
digests, component differences and continuing execution requirements.
[artifact-provenance.json](artifact-provenance.json) records selected chart
hashes, image platform digests, migration/plugin comparisons and current report
identities. It separates frozen manual-rehearsal inputs from current contract
revisions. Source tree hashes do not prove distributed image/archive contents.

Raw command output, recovery material, private configuration and historical
run records belong in test artifacts outside this source tree.

## Scoped rehearsal results

The following manual checks ran on 2026-11-24. Each route used one physical
host, fake GPUs, three critical stateful members on separate Kubernetes
workers, one stateless callback replica and two retained compute clusters.
These results do not qualify cross-host or stateless-replica HA.

Both routes passed source-cohort restore, both compute updates, mixed-fleet
acceptance, a separate action-boundary resume, final old/new HTTP/gRPC and task
acceptance, fresh original-secret injection, and retained JWT/registration/data
checks. The second route applied Observability last and checked native metric
flow on all three clusters and new Event Ledger account-scoped reads.

| Scoped acceptance | Stack 1.0.1 to 1.0.4 | Stack 1.0.4 to 1.1.5 |
| --- | --- | --- |
| Source member replacement probes | 176 passed, 0 failed | 184 passed, 0 failed |
| Compute-one / compute-two probes | 44 / 44 passed, 0 failed | 36 / 36 passed, 0 failed |
| Target member replacement probes | 172 passed, 0 failed | 180 passed, 0 failed |
| Retained function versions / terminal tasks | 16 / 9 | 24 / 15 |
| Retained failed source tasks within that task count | 1 | 3 |

Each member rehearsal replaced one OpenBao leader, Cassandra member and NATS
member, then checked data and identities. Single-replica management streams
were drained before planned NATS replacement. These samples do not qualify
unplanned loss with pending management work. Separate secret-Pod replacement
on the second route recorded one transient unavailable call before recovery.

The first source used diagnostic task helpers with assumed payload equivalence.
Their original-reference byte identity remains unverified. These results do not
satisfy that provenance gate or enable supported execution.

Recovery covers drained memory streams. Historical sequence/cursor counters
can reset. Each source restore used 48 archived data volumes and three fresh
derived cache volumes. A later fresh pre-hop backup was not itself restored.
Interruption inside a command and restore after a migration failure were not
tested. Hands-on effort and a matched manual baseline remain unmeasured.
Caller pauses and intervals without probes do not establish service uptime.

Receipt text from a Git source export can differ from its stack tag. Keep the
original receipt value separate from tag, commit, inventory and runtime image
identities. This observation does not establish distributed archive contents.

## Findings and remaining work

The [runtime prerequisite report](runtime-prerequisites.md) covers effective
NVCT helper images omitted from the source inventory, callback routing,
native task completion and intermediate Observability selection. The
[service data checks](service-migrations.md) define the SIS source backfill
completion gate. The [recovery checks](recovery-prerequisites.md) record the
selected NATS server's unsupported memory snapshots. Read these reports with
the scoped rehearsal results and their qualification limits.

- Cassandra migrations change from 0.17.6 to 0.17.7 to 0.19.4. The first
  two images contain identical migration files. All 44, 44 and 47 extracted
  files match their corresponding source commits. The last adds explicit Event
  Ledger and SIS upgrade migrations and changes historical init SQL. Different
  image build/runtime libraries and live data behavior still require review.
- OpenBao migration consumers must remain separate. The enabled server hook
  selects 0.19.5, 0.19.9 and 0.23.1 across the three stack inventories. The
  downloaded chart 0.32.7 defaults to 0.19.5. Stack 1.0.4 base values explicitly
  override it to 0.19.9, confirmed by actual hook renders.
- The second route changes the OpenBao server image. The selected linux/amd64
  images contain byte-identical JWT plugins, so the suspected old/new plugin
  SHA mismatch does not apply to those digests. The catalog-refresh hook still
  precedes migrations. Scoped checks passed for the live catalog, Raft/member
  rotation, retained issuer/key/mount identities and old/new JWT behavior.
  Broader profiles still require qualification. Do not import a later
  versioned-plugin bridge procedure or rewrite catalog hashes as a workaround.
- NATS server/reloader and cert-manager image versions do not numerically
  decrease across the selected control-plane endpoints. Location and chart
  changes still require artifact and compatibility checks.
- The selected NATS server rejects native snapshots of memory streams.
  The drained-memory profile has scoped source recovery evidence. Nonempty
  memory recovery remains unsupported. Preserve per-stream storage, replication
  and consumer semantics; record native historical sequence/cursor resets
  explicitly. Failure recovery across a hop's data boundary remains untested.
- Resolve applicable blockers before each upgrade action. Source checks do
  not replace the separate target workload, mixed-compute, availability and
  interruption/recovery evidence required for the selected profile.
- Compute Plane 1.0.5 to 1.1.0 selects the optional Dynamo operator's
  `nats-server-config-reloader` backward from 0.25.0 to 0.24.0. Both releases
  disable Dynamo by default through `addons.dynamoOperator.enabled`.
  The second contract records this as a conditional check. If Dynamo is
  disabled at both endpoints and absent from both renders, retain the finding
  without blocking that profile. If the effective renders show the downgrade,
  verify compatibility, fix retention and configuration reload before the
  affected compute action. Unknown applicability requires values/render review;
  optional status or default settings alone do not establish absence. The lab
  does not evaluate applicability. Preserve the matrix-selected endpoints.

The [manual reference draft](../../../../docs/dev/upgrade-transitions.md)
separates prerequisites, hop actions, acceptance and recovery boundaries.
The [measurement procedure](manual-measurement.md) defines equivalent inputs,
operator activity records and availability measurements.
The lab implements artifact input checks and isolated source/render preparation.
Cluster and upgrade orchestration remain manual.
No third-party dependency or published release artifact was changed.
