# Runtime prerequisites and historical findings

The profile-specific observations below come from the previous stack-only rehearsals.
They compare control stacks 1.0.1, 1.0.4 and 1.1.5.
They do not establish behavior for umbrella 1.0.4, which selects control stack 1.0.10.
Recheck actual source/target configuration, images and renders for both current contracts.
The previous equal NATS binary finding does not cover the new server regression.
The previous receipt helper and ingress ordering also require a new review.
See the [current selections and findings](README.md).

An inventory comparison covers the original inventory entries. It does not
discover every image selected by application defaults, operator-created Pods
or inline Helmfile charts. Record those effective references and immutable
platform digests separately before qualification.

## Source task helper gap

The actual stack 1.0.1 NVCT remote configuration selects these helpers:

| Consumer | Helper | Version |
| --- | --- | --- |
| NVCT task initialization | nvcf_worker_init | 2.107.0 |
| NVCT task lifecycle | nvcf_worker_task | 2.107.0 |
| NVCT task secrets | ess-agent | 1.1.0 |

Its original inventory does not list these NVCT helper entries. A live task
failed while pulling the selected initialization image from the original
repository. Artifact access, selected bytes and their provenance remain
separate requirements. An operator-selected repository allows scoped
diagnostics when explicitly authorized, but does not prove equivalence to an
inaccessible original artifact. Keep the published route unqualified until
its identity, access and runtime requirements pass. The
[current findings](current-findings.md#legacy-helper-identity-and-access)
record later original-record digest matches and the remaining canonical access limit.
Do not replace original inventory assets,
rewrite released charts or infer helper versions from a newer service image.

Inline receipt charts also need inspection. The source receipt helper selects
`alpine-k8s:1.33.1`; its absence from an inventory does not waive its access
check. A `VERSION` value in a Git source export can differ from its stack tag.
Keep tag, commit and inventory identities as separate evidence. Inspect a
distributed archive separately before drawing conclusions about its receipt.
The historical stack 1.0.4 and 1.1.5 receipt charts instead default to
`docker.io/alpine/k8s:1.33.1`. Check each endpoint's actual chart and effective
values; a failed legacy reference does not establish target-image failure.

## NATS storage permissions

The selected 1.0.1 profile renders no NATS security context. The 1.0.4
profile sets Pod and container UID/GID 1000 and Pod `fsGroup: 1000`, without
a permissions init container. The 1.1.5 profile also sets
`fsGroupChangePolicy: OnRootMismatch`. Record these configuration changes
separately from server binary identity.

The first source's local PVCs contain root-owned directories with mode 0700.
Check the actual volume plugin and its ownership handling before rollout.
The selected Kubernetes
[local volume plugin](https://github.com/kubernetes/kubernetes/blob/v1.30.2/pkg/volume/local/local.go#L570)
applies `fsGroup` ownership handling on the first writable mount.
[Ownership policy](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods)
depends on volume support; CSI drivers can implement it themselves. Do not
assume identical behavior for another driver or rewrite source permissions
to make a baseline pass. Verify target startup, persistent metadata writes,
stream configurations and actual ownership after the native rollout.

The selected linux/amd64 source and target NATS images have matching server
binary hashes and the same versions of 18 Alpine packages. Their root
filesystem layers differ. This bounded comparison is not a vulnerability scan
or evidence for another platform digest.

## Split-cluster networking

Verify each path independently with the selected source and target values:

| Path | Required behavior |
| --- | --- |
| Control API gRPC, port 9090 | Internal API authority reaches the control API artifact and worker services |
| NVCT gRPC, port 9090 | Internal task API authority reaches NVCT initialization, heartbeat and result services |
| Invocation callback HTTP, port 8080 | Encoded Pod callback names resolve and reach the serving invocation process |
| gRPC proxy worker callback, port 10086 | Advertised worker address is reachable from both compute clusters |
| NATS, port 4222 | Workers retain authenticated access to the same accounts and streams |

An accepted external HTTP route does not validate internal gRPC routes.
Check each GRPCRoute's parent gateway, listener, authority and backend. A
running inference container and an HTTP 200 in worker logs do not prove that
its response attachment reached the caller.

The inspected historical stacks support `grpcproxy.workerConnectBaseURL`. A fixed TCP
callback URL needs one gRPC proxy replica to preserve worker affinity. The
current laboratory site also routes invocation callbacks through one
invocation-service replica. This does not qualify callback affinity with
multiple invocation replicas. Preserve those baseline replica counts and
record this scope alongside the three-member Cassandra, OpenBao and NATS
topology. Physical host failure remains outside this laboratory topology.

## Native task completion

Use the task sample's documented progress protocol. The task writes JSON to
`NVCT_PROGRESS_FILE_PATH`, with its `NVCT_TASK_ID`, a valid result name,
`percentComplete` and `lastUpdatedAt`. Write the file atomically. A normal
completion reports 100 percent and reaches NVCT status `COMPLETED`.
Let the native worker create and set permissions on its results directory
before writing progress. A root task that creates the directory first can
prevent the non-root worker from changing its permissions. Keep that failure
as a failed fixture; use a new ordinary task with the correct initialization
sequence.

Exit code zero alone does not complete a task. Keep failed or incomplete
fixtures in the retained cohort and diagnose them. Do not inject completion
or cancel/delete a task to satisfy the drain gate. A task still initializing
blocks that gate until its native lifecycle reaches a terminal state.

## Workload recovery readiness

A replacement inference Pod can become Ready while the function API still
reports a degraded version. Wait for native reconciliation and an `ACTIVE`
version, then verify invocation and the original secret digest through the
retained credentials. Keep transient failed calls in the availability record.
Do not delete the replacement again or recreate the function to hide that
interval. Record this planned function Pod replacement separately from
control-plane member failover and compute upgrade probes.

## Ingress admission before consumers

The first route changes gateway-routes from 1.18.2 to 1.18.3. The source
hostname policy rejects an update to the existing admin issuer HTTPRoute,
even though its `/v1/admin/keys` path is more specific than the API Keys root
route. In a whole-core sync, that rejection can prevent the later ingress
release from installing the target policy fix.

After the data/OpenBao gates, compare native source/target Gateway and route
specifications and the existing backend services. In the reviewed profile
these specifications are unchanged. Order the exact target ingress first
within the core action, then verify server-side dry-run acceptance of the
admin route update and continued denial of a conflicting root route. Keep
admission enabled and preserve original route UIDs/specifications. Do not
change a released chart or remove the policy to make the apply pass.

The manual reference records the bounded native selector command. A partial
core failure requires retained Helm state and fresh data/quorum checks before
continuation. This does not authorize replaying an unknown migration outcome.

## Intermediate Observability selection

For the second route, final target preparation includes Observability 1.1.0.
Do not apply that final sibling directory during earlier control or compute
actions. Create a new stage workspace containing the unchanged target
control and compute directories and the unchanged source Observability 1.0.0
directory. Record all three source identities and the effective renders.
Use the explicit `control` or `compute` profile for each cluster. Apply
Observability 1.1.0 only at its declared final action.
