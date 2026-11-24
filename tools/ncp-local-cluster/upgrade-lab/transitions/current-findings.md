# Current umbrella artifact findings

These observations use the selected umbrella artifacts from the
[artifact lock](artifact-lock.json).
Both routes remain unqualified. Supported execution remains disabled.
They do not replace the published restriction on upgrades from umbrella 1.0.4 to 1.1.0.

## OpenBao blocks umbrella 1.0.4 to 1.1.0

The source selects server `2.6.3-nv-1.3.9` and migrations `0.19.11`.
The target selects server `2.6.3-nv-1.3.7` and migrations `0.23.1`.
The inspected linux/amd64 platform digests are:

| Image | Platform digest |
| --- | --- |
| nvcf-openbao:2.6.3-nv-1.3.9 | 4668ac0de8a899b7ece2c4dad068db184f211b6255701576dea3c90d9ccbaa7e |
| nvcf-openbao:2.6.3-nv-1.3.7 | b7cf48a0aabed67877319feeb605e930a81c5a10c832e9f5e9696bcf6759bf82 |
| nvcf-openbao-migrations:0.19.11 | 9df1ef5810291d059e575003dcc432524ae97e25dca108a803c18505ca4890bc |
| nvcf-openbao-migrations:0.23.1 | 2cc88872e75d988bc029324d60c87af8f302c8eb562b790b42003cda4bd5682d |

These images use the repository prefix `nvcr.io/nvidia/nvcf/`.
Resolve the platform manifest separately from a multi-platform index or image configuration digest.

The source contains three plugin paths:

| Path under /openbao/plugins/ | SHA-256 |
| --- | --- |
| vault-plugin-secrets-jwt | 6d27a973989fbb66a7d8232c379c038198c4a17ab823859bc98a742859d471d0 |
| vault-plugin-secrets-jwt-v1.3.7 | 6d27a973989fbb66a7d8232c379c038198c4a17ab823859bc98a742859d471d0 |
| vault-plugin-secrets-jwt-v1.4.1 | d9b4fcc75fdeb8db3a7c88b8e0bf8c27208709dad37a40d88ed39130c49517d5 |

The target retains only the unversioned legacy executable with the first hash.
It lacks both versioned paths and the `jwt-plugin-lifecycle` driver.
Source migrations contain `migrations/utils/jwt_plugin_version.sh`.
Target migrations omit that helper.
Equal unversioned plugin hashes do not establish compatibility with versioned source mounts.

A fresh source installation selected `v1.4.1` for eight service JWT mounts.
Its three-member, same-image component restore preserved mount identities, JWKS and JWT issuance.
An isolated diagnostic restored a source snapshot onto three members using the exact target server image.
OpenBao could not load the stored plugin command because its executable was absent.
The JWT backends did not initialize, and the API Keys JWKS endpoint returned HTTP 404.
The original source remained running throughout this diagnostic.
This result does not test the target chart hooks or a full-stack upgrade.

Restoring that same diagnostic snapshot onto the original source image and new storage recovered three voters, original mount identities and JWKS.
JWT issuance also recovered. This component recovery does not establish a consistent full-stack restore or recovery from a failed migration.

Keep the OpenBao action blocked.
Do not tune mounts, replace keys or edit released images to bypass the failure.
The existing [successor release proposal](https://github.com/dsx-ai-factory/nvcf/issues/3428)
plans to preserve the versioned lifecycle and address the NATS and cert-manager regressions.
That proposal needs artifact publication and qualification.
It does not change this contract's 1.1.0 endpoint or qualify another route.

## Source diagnostics

Both fresh source combinations passed native control, compute and Observability installation and twelve preparation renders each.
Each source retained two compute registrations, four HTTP/gRPC functions and four naturally completed tasks with and without secrets.
Actual calls used the retained credentials and checked original response markers and HTTP secret hashes.

Each source passed planned, sequential replacement of one Cassandra member, one NATS member and the OpenBao leader.
Checks preserved StatefulSet specifications, PVC identities, JWT mounts, JWKS, stream/consumer configurations and workload identities.
Cassandra recovered three UN members. OpenBao recovered three voters and issued JWTs.
The OpenBao replacement phases recorded 130 and 136 HTTP observations without an observed failure.
HTTP/gRPC calls passed again after replacement.

These are bounded observations from fake-GPU, single-host environments with three stateful members on distinct Kubernetes nodes.
They do not qualify physical GPUs or host loss.
The invocation service and gRPC proxy each used one replica.
Legacy task diagnostics used explicitly authorized mirror references and retain the access limits below.

## First-route source restore

The legacy source passed a consistent cold restore on the same host.
The backup paused callers, control-plane writers and both compute clusters.
It checked the required SIS lookup fields, drained NATS and flushed Cassandra before stopping the control plane.
The restore used 43 new volumes and 13 new runtime containers.
Archive comparisons and paused data checks passed before consumers resumed.
The original containers and volumes remained stopped and available for recovery.

Postchecks preserved the original API keys, compute registrations, Kubernetes trust and PVC identities.
They verified native cluster records, JWT mounts, JWKS and new JWT issuance.
All four original HTTP/gRPC calls passed, including the HTTP secret checks.
The four original task records remained COMPLETED.

Four new functions served HTTP/gRPC calls across both compute clusters.
Four new tasks completed across both clusters with and without secrets.
The HTTP calls checked secret hashes.
The harness restored the original deployment minimums and repeated all four original calls successfully.
An earlier capacity refusal and worker-connection timeout remain in the diagnostic records.
The retries retained the same workload records and waited for native admission capacity and worker readiness.
These results cover the source cohort and do not establish target compatibility, host-loss recovery or route qualification.

## Legacy helper identity and access

The two worker image platform digests match original producer records.
The ESS index digest matches a historical original staging runtime image ID.
SHA-256 checks verified its raw OCI index and linux/amd64 child manifest.

| Helper | Identity checked | SHA-256 |
| --- | --- | --- |
| nvcf_worker_init:2.107.0 | linux/amd64 manifest | e8c3c3fe3a7a408becd9c99986c304b9a49d92ce00538de78c88c6d137a4375a |
| nvcf_worker_task:2.107.0 | linux/amd64 manifest | 483795e654d2caa90dd0adb99c3012a9a9ec3a4ca05ffc568518f7bd521a553f |
| ess-agent:1.1.0 | OCI index | 1852e5c8e1760a9d1f32db569b1cd78ddc11183d86cf95e88b4a7937a0e72c3f |
| ess-agent:1.1.0 | linux/amd64 child manifest | 5988683a3b9b215565a86c32e65a00489709785202ad9d39e609971bb28970f1 |

Canonical source pulls still fail for all three helpers.
The [published known issue](https://github.com/dsx-ai-factory/nvcf/pull/3346)
records the legacy catalog gap.
The [source-task prerequisite follow-up](https://github.com/dsx-ai-factory/nvcf/issues/3667)
tracks the public access decision and its required qualification.
Keep customer pullability separate from the matching-byte evidence.
The source references, released artifacts and supported-execution settings remain unchanged.

## First-route OpenBao bridge prerequisite

The legacy server `2.6.2-nv-1.3.4` platform digest is
`2187e4cb40298ab006189b5ec7ec221201fd2fc8b48ba8a504a27239648c508c`.
Its unversioned JWT plugin has SHA-256
`6d27a973989fbb66a7d8232c379c038198c4a17ab823859bc98a742859d471d0`.
That hash matches both the bridge image's unversioned path and its explicit `v1.3.7` path.

Chart `0.32.9` defaults to versioned mode for fresh installations.
An existing legacy installation must first use its bridge mode, with hooks enabled and migrations deferred.
Complete the chart's staged JWT procedure, member rotations and canaries before persisting versioned mode and resuming migrations.
The matching legacy bytes satisfy one prerequisite.
Runtime preflight and lifecycle checks remain required.

## Cassandra migration payloads

The inspected linux/amd64 images are:

| nvcf-cassandra-migrations version | Platform digest |
| --- | --- |
| 0.17.6 | 227061dcbd3516963cb7dccb04f17029723b4dd77a61e5b474c0001285fd740e |
| 0.17.8 | d34dd4875d1cc4e76acdcf7ba062584db4815d9e4858fc2ea29ffff50fa38f09 |
| 0.19.4 | 88f64da2fd977e26c8365921330244bc90769e8c4b1b9415af0b1d54242cf097 |

The 44 selected files under `app/keyspaces/` plus `app/execute_sqls.sh` are identical between 0.17.6 and 0.17.8.
Version 0.19.4 adds three SQL files and changes two initialization SQL files from 0.17.8.
It removes no selected file. All three images contain the same entry script.

The added upgrade SQL files are:

- `event_ledger/04_add_nca_id_function_id.up.sql`
- `sis_api/11_add_creation_bucket.up.sql`
- `sis_api/12_add_creation_bucket_indexes.up.sql`

The Event Ledger migration adds optional columns without a backfill.
The SIS migrations add `creation_bucket` columns and indexes.
The selected SIS 0.7.7 and 0.8.5 source trees do not reference that column.
Do not infer a required service backfill from the added schema alone.
Do not replay changed initialization SQL against an existing migration ledger.
Runtime migration Job completion, clean ledgers, retained data and RF/DC checks remain required.

## Other boundaries

The [SIS inspection](service-migrations.md) now covers actual image 0.7.7.
A native source `VALIDATE` diagnostic scanned eight rows and reported eight current rows.
Its migrated, skippedTerminated, missingRequest, mismatched and failed counters were zero.
The test used the selected SIS chart's environment ConfigMap and restored the original Deployment template afterward.
All four original HTTP/gRPC calls passed again, and the four original task records remained COMPLETED.
Writers remained active during this diagnostic.
A later scan ran with other writers and both compute clusters paused.
It reported 16 current rows and zero error counters.
Independent required-lookup checks found no null or conflicting IDs.
SIS stopped after that scan, before the matching cold backup.
The scan does not establish a completed restore or qualify a later data epoch.

The actual source NATS binaries report 2.14.6 for legacy 1.0.1 and 2.14.9 for umbrella 1.0.4.
The second route's server regression is therefore not covered by the historical equal-binary finding.
NATS reload, storage and recovery compatibility and cert-manager fix retention remain separate gates.

The first-route source restore does not establish recovery for the second route or either target.
Mixed-fleet acceptance, the actual hops, interruption and migration-failure recovery need matching evidence.
Legacy task diagnostics retain the unresolved canonical helper access limit.

Later source-only rehearsal updates are tracked in [the defining issue](https://github.com/dsx-ai-factory/nvcf/issues/3558).
They do not enable either upgrade route.
