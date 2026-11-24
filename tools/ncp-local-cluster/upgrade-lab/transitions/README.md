# Umbrella upgrade candidates

These lab inputs cover [issue #3558](https://github.com/dsx-ai-factory/nvcf/issues/3558).
Both routes remain unqualified. Supported execution remains disabled.
These files are lab inputs, not required deployment files or a published catalog.

## Version identities

| Endpoint | Kind | Control / compute / observability |
| --- | --- | --- |
| NVCF 1.0.1 | Legacy baseline without an umbrella manifest | 1.0.1 / 1.0.0 / 1.0.0 |
| Umbrella 1.0.4 | Released manifest | 1.0.10 / 1.0.5 / 1.0.0 |
| Umbrella 1.1.0 | Released manifest | 1.1.5 / 1.1.0 / 1.1.0 |

| Route ID | Contract | Inventory comparison |
| --- | --- | --- |
| `umbrella-1.0.1-to-1.0.4` | [Contract](umbrella-1.0.1-to-1.0.4.json) | [Report](umbrella-1.0.1-to-1.0.4-components.md) |
| `umbrella-1.0.4-to-1.1.0` | [Contract](umbrella-1.0.4-to-1.1.0.json) | [Report](umbrella-1.0.4-to-1.1.0-components.md) |

The first route's source is an explicit legacy exception.
Do not create an umbrella manifest for that baseline.
The prefix identifies the route namespace. It does not change the source kind.
Final endpoint compatibility does not qualify intermediate or mixed-fleet states.

## Immutable inputs

[artifact-lock.json](artifact-lock.json) binds each manifest to a repository commit and SHA-256.
The [1.0.4](manifests/1.0.4.json) and [1.1.0](manifests/1.1.0.json) copies retain their released bytes.
Each manifest selects three stack tags, source commits and inventory digests.
The lock adds original release asset IDs and hashes for the manifest, asset
index and bundle. It also records original inventory asset IDs.
The loader verifies all three selections against the manifest and frozen documentation matrix.
The legacy baseline uses only its frozen matrix and original inventories.

Fetch verifies the remote manifest at its locked commit before downloading release assets and inventories.
Each asset index must bind the same manifest, bundle and three inventories.
Audit verifies local manifest bytes, original release assets and inventory identities before comparison.
Neither operation changes released assets or establishes runtime compatibility.
Old stack-only route IDs fail validation. Their checkpoints cannot resume these routes.
The new contract and lock digests also invalidate evidence from the previous scope.

[artifact-provenance.json](artifact-provenance.json) records current report identities.
It keeps historical inspections separate from current qualification requirements.
Store raw output, private configuration, credentials and backups outside this repository.

## Findings that require new review

The first comparison has 55 changed entries, 9 added entries and no backward entries.
The second has 69 changed entries, 2 added entries, 2 removed entries and 12 backward entries.
Counts describe inventory entries, including optional releases. They do not establish deployed behavior.

| Area | Required review for the new selections |
| --- | --- |
| Cassandra | Inspect 0.17.6 to 0.17.8, then 0.17.8 to 0.19.4. Compare actual files, upgrade ledgers and data. Earlier 0.17.7 inspections do not cover 0.17.8. |
| SIS | Inspect actual 0.7.2, 0.7.7 and 0.8.5 images. Verify source backfill availability and required lookup IDs before backup. Preserve null-only repair safeguards. |
| OpenBao | Compare server 2.6.2-nv-1.3.4, 2.6.3-nv-1.3.9 and 2.6.3-nv-1.3.7. Review bridge availability, hooks, plugin bytes, catalog, Raft identity and JWT behavior. |
| NATS | The second route selects server 2.14.9 to 2.14.6 and reloader 0.25.0 to 0.24.0. Review enabled use, retained fixes, storage formats, configuration reload and recovery. |
| cert-manager | The second route selects chart 0.2.0 to 0.1.0 and images v1.20.5 to v1.20.2. Review CRDs, webhook behavior, retained fixes and certificates. |
| Other consumers | Review removed migration consumers, the UI migration helper and receipt helper regression against effective renders. |
| Optional Dynamo | Preserve the conditional 0.25.0 to 0.24.0 reloader check. Disabled defaults alone do not establish absence. |

Resolve applicability with effective values and rendered manifests.
An applicable backward selection blocks its action until compatibility and retained fixes pass review and required runtime checks.
Unknown applicability also blocks that action.
Do not silently change a released manifest to remove a finding.

The [current artifact findings](current-findings.md) record an isolated OpenBao failure with the selected second-route server image.
Source JWT mounts select a versioned plugin that the target image does not contain.
The OpenBao action remains blocked. The selected SIS 0.7.7 image has also been inspected.
These observations do not establish a successful upgrade or full-stack restore.

## Historical stack-only evidence

The previous candidates compared control stacks 1.0.1 to 1.0.4 and 1.0.4 to 1.1.5.
They used different control artifacts from these umbrella candidates.
Their manual checks do not qualify either current route.
Keep their run records bound to their original route IDs, lock and contract digests.

Read the [frozen rehearsal summary](https://github.com/dsx-ai-factory/nvcf/blob/aa1270cdbe356845d9d873d9424231b17be84c5b/tools/ncp-local-cluster/upgrade-lab/transitions/README.md#scoped-rehearsal-results)
and [frozen contracts and reports](https://github.com/dsx-ai-factory/nvcf/tree/aa1270cdbe356845d9d873d9424231b17be84c5b/tools/ncp-local-cluster/upgrade-lab/transitions).
The [original artifact inspections](historical/stack-only-artifact-provenance.json) retain their original bytes.
Those inspections cover only the named artifacts and platform digests.
Reused artifacts still require current profile, lifecycle and runtime evidence.
The previous findings about equal plugin bytes and forward NATS versions do not cover stack 1.0.10.

## Execution and qualification

The [manual reference](../../../../docs/dev/upgrade-transitions.md) describes candidate action boundaries.
The [runtime checks](runtime-prerequisites.md), [service checks](service-migrations.md)
and [recovery checks](recovery-prerequisites.md) remain prerequisites.
The [measurement procedure](manual-measurement.md) requires equivalent inputs and measured operator activity.

The lab implements artifact checks and isolated source/render preparation.
It does not execute upgrades, evaluate runtime postconditions or automate recovery.
The released 1.1.0 notes prohibit upgrades from 1.0.4 until qualification is complete.
Declaring this candidate does not remove that restriction.
Both routes need new artifact review, configuration review and action-order review.
They also need matching source/target workloads, HA, mixed-fleet, restore and interruption evidence.
No current umbrella route has live qualification from this scope change.
