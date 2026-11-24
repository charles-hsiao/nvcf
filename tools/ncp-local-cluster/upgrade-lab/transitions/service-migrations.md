# Service data prerequisites

Stack, Helm chart and service image versions are separate identities. Compare
the selected service release trees and actual images before choosing a data
migration window. Schema migration Job completion does not prove completion
of a service's scheduled backfill.

## Selected SIS images

| Self-Managed stack | SIS image | Service source commit | Instance lookup task |
| --- | --- | --- | --- |
| 1.0.1 | icms-service-oss:0.7.2 | 8be83249379f4ec9c3ab59bba260eca6399ea1b1 | Absent from the service release tree |
| 1.0.4 | icms-service-oss:0.7.6 | 1a7b76ebf8ac048fbb38e6e95da96edf9c7a239a | Present; disabled by default |
| 1.1.5 | icms-service-oss:0.8.5 | 976d8f6e86d9edf43fa723f54a36c677f2570ea6 | Absent |

The service tags use the prefix
`src/control-plane-services/instance-cluster-management/v`. The actual
linux/amd64 images were extracted by repository-qualified platform digest:

| SIS image | Platform digest | Application JAR SHA-256 |
| --- | --- | --- |
| 0.7.6 | 154955af193a2fa4f68c771dad621ef8a911afe542596430c39b83bfd57b3eca | 52dbdeae4fa22c4a7a3265cad558fc74dfbc444dbcb5c31e9fb47f9e03cb9449 |
| 0.8.5 | fabd53f8c3c758ae34f0ed6cddb5514332636a9fdb44b9e6c8474a4db2fd5e80 | c8985711887c37438b37b7f7e9e2e257f78aefd640d410b7adcccbd3b3c53a9b |

The first JAR contains `InstanceLookupBackfillTask.class`; the second does
not. This verifies class availability in the selected images. The source
semantics below come from the pinned service release tree; this inspection
does not establish reproducible source-to-image byte identity.

## Instance lookup completion gate

The [source task](https://github.com/dsx-ai-factory/nvcf/blob/1a7b76ebf8ac048fbb38e6e95da96edf9c7a239a/src/control-plane-services/instance-cluster-management/icms-core/src/main/java/com/nvidia/icms/service/scheduled/InstanceLookupBackfillTask.java)
compares each `sis_api.instances` row's `deployment_id` and
`gpu_specification_id` with the corresponding instance request. `MIGRATE`
fills null fields from that request. It does not repair conflicting non-null
fields. A missing request is accepted only for a terminated instance.

1. Preserve instance, request and workload identities. Record
   the source runtime image digest, pod UID and installation history.
2. Pause affected source writers for the final comparison. Do not delete
   instances or requests to make the check pass.
3. Identify the retained instances that require target lookups. Require a
   non-null deployment ID in each authoritative request used for deployment
   lookup. Apply the same check to GPU-spec IDs where that lookup is required.
   Missing authoritative IDs require a reviewed repair before proceeding.
4. On SIS 0.7.6, set `ICMS_INSTANCE_LOOKUP_BACKFILL_TASK_MODE` through the
   native `sis.env` values. Use `MIGRATE` only when null fields need repair.
   Follow the partial-run recovery rules below if that scan fails.
   Then use `VALIDATE` and wait for a completed scan from the expected pod.
5. Independently compare the required lookup IDs in instances and requests.
   Require non-null, matching IDs for each required lookup. Record the count
   of required rows with null IDs and require zero. `VALIDATE` uses null-safe
   equality, so two null values can count as current. Zero native error
   counters alone do not satisfy this check. Record any excluded terminal
   rows and why the target does not require their lookup.
6. Require `missingRequest=0`, `mismatched=0` and `failed=0`. Save all counters,
   including `scanned`, `current` and `skippedTerminated`. Reconcile the scan
   with the retained workload cohort. An empty scan does not exercise legacy
   data migration.
7. Bind the result to task mode, image digest, pod UID, scan timestamps and
   the data epoch. Restore, a changed pod or subsequent inconsistent writes
   require a new matching result. Keep the writer pause until the backup
   captures that verified state.

## Partial MIGRATE recovery

The selected SIS 0.7.6 task commits each repaired row independently. A failed
scan can leave completed repairs. There is no transaction-wide rollback.
Preserve row and workload identities and existing non-null values. The repair
intentionally replaces null lookup fields with authoritative request values.

After a partial or failed scan, set the native task mode to `DISABLED`.
Wait for the previous execution to stop. Keep other affected writers paused.
Save available summaries and compare the current instance/request cohort.
Permit another `MIGRATE` run only when all these conditions hold:

- The same released SIS 0.7.6 task remains selected.
- Authoritative requests remain unchanged from the recorded pre-repair cohort.
- Each remaining null field has a non-null authoritative request value.
- No non-null value conflicts with its request, no live request is missing,
  and no unexpected data changes occurred.

Under these conditions, repeat the same null-only `MIGRATE`, then `VALIDATE`.
Repeat the independent null checks and cohort comparison. Existing completed
repairs remain in place. Failed reads, changed requests, conflicts or unknown
writes block a rerun until the migration owner defines a reviewed repair.
Do not delete rows or recreate workloads to clear that block.

Create the consistent backup only after every source-data check passes.
That backup captures the repaired state. It cannot restore the pre-repair null
values. A restore or changed data epoch invalidates earlier completion evidence.

## Route boundaries

For stack 1.0.4 to 1.1.5, this is a source prerequisite: finish it before the
backup and before replacing SIS 0.7.6. The source already has the capability;
its removal does not by itself require another version hop.

For stack 1.0.1 to 1.0.4, SIS 0.7.2 has no such task. Compare source rows with
their requests directly. Unresolved null legacy fields, missing live requests
or conflicts block this candidate until a reviewed repair procedure exists.
After the hop, validate again with target SIS 0.7.6. Any target repair is a
during-hop migration, with its own recovery boundary.

The task appears in service release trees 0.7.5 through 0.7.7, is absent from
0.8.0 through 0.8.5 and appears again in maintenance release 0.8.6. Release
snapshots and backports are not a linear history. Filter tags by their owning
component and check file presence in each selected tree. Do not infer task
availability from an unrelated component's monorepo snapshot or from
`git tag --contains` alone.

Other tasks, including `GpusV5PopulationTask`, need separate data checks when
installation history makes them relevant. This lookup review is not a claim
that all historical service migrations are complete.
