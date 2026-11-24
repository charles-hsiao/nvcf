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
Legacy task diagnostics used explicitly authorized helper substitutions and retain the artifact limits below.

## Other boundaries

The [SIS inspection](service-migrations.md) now covers actual image 0.7.7.
It does not prove completion of a scheduled backfill or the final paused data check.

The actual source NATS binaries report 2.14.6 for legacy 1.0.1 and 2.14.9 for umbrella 1.0.4.
The second route's server regression is therefore not covered by the historical equal-binary finding.
NATS reload, storage and recovery compatibility and cert-manager fix retention remain separate gates.

Source workloads and component restores do not establish a consistent full-stack recovery point.
Mixed-fleet acceptance, the actual hops, interruption and migration-failure recovery need matching evidence.
Legacy task diagnostics also retain the unresolved canonical helper access and ESS byte-identity limits.
