#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

stack_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

fail() {
  echo "state-metrics-network-policy: $*" >&2
  exit 1
}

# Model the published chart's same-namespace ingress and existing egress.
# A non-default port verifies that the patch preserves the chart's port.
cat >"$work_dir/policy.yaml" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: state-metrics
  namespace: nvcf
  labels:
    app.kubernetes.io/instance: state-metrics
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/instance: state-metrics
  policyTypes: [Ingress, Egress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: prometheus
      ports:
        - port: 19464
          protocol: TCP
  egress:
    - ports:
        - port: 53
          protocol: UDP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: unrelated
  labels:
    app.kubernetes.io/instance: unrelated
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress: []
YAML

# Frozen identity labels from a released operator's collector Pod. The chart
# overrides app.kubernetes.io/name, so use the operator-owned identity labels.
cat >"$work_dir/collector-pod.yaml" <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  namespace: monitoring
  labels:
    app.kubernetes.io/name: nvcf-otel-collector
    app.kubernetes.io/component: opentelemetry-collector
    app.kubernetes.io/instance: monitoring.nvcf-observability
YAML

fixture_chart="$work_dir/chart"
test_stack_dir="$work_dir/self-managed"
mkdir -p "$fixture_chart/templates" "$test_stack_dir/helmfile.d" \
  "$test_stack_dir/environments" "$test_stack_dir/secrets"
mv "$work_dir/policy.yaml" "$fixture_chart/templates/policy.yaml"
printf 'apiVersion: v2\nname: policy-fixture\nversion: 0.1.0\n' >"$fixture_chart/Chart.yaml"
cp "$stack_dir/environments/base.yaml" "$test_stack_dir/environments/base.yaml"
printf '{}\n' >"$test_stack_dir/global.yaml.gotmpl"
printf '{}\n' >"$test_stack_dir/secrets/base-secrets.yaml"
# Keep chart rendering offline while exercising Helmfile's real patch path.
awk -v chart="$fixture_chart" '
  /^[[:space:]]+chart: nvcf\/helm-nvcf-/ { $0 = "    chart: " chart }
  { print }
' "$stack_dir/helmfile.d/03-observability.yaml.gotmpl" \
  >"$test_stack_dir/helmfile.d/03-observability.yaml.gotmpl"

render_policy() {
  local profile="$1"
  shift
  HELMFILE_ENV=base helmfile --log-level error \
    --file "$test_stack_dir/helmfile.d/03-observability.yaml.gotmpl" \
    --environment default --selector name=state-metrics \
    --state-values-set "observability.profile=$profile" \
    "$@" template --skip-deps >"$work_dir/rendered.yaml"
  yq 'select(.metadata.name == "state-metrics")' \
    "$work_dir/rendered.yaml" >"$work_dir/state-metrics.yaml"
}

for profile in control all disabled compute; do
  render_policy "$profile"
  policy="$work_dir/state-metrics.yaml"
  yq -e '.spec.ingress[0].from[0].podSelector.matchLabels.app == "prometheus"' "$policy" >/dev/null ||
    fail "$profile removed the existing same-namespace peer"
  yq -e '.spec.ingress[0].ports[0].port == 19464' "$policy" >/dev/null ||
    fail "$profile changed the metrics port"
  yq -e '.spec.egress[0].ports[0].port == 53' "$policy" >/dev/null ||
    fail "$profile changed egress"
  yq -e 'select(.metadata.name == "unrelated") | (.spec.ingress | length) == 0' \
    "$work_dir/rendered.yaml" >/dev/null || fail "$profile changed another policy"
  expected_peers=1
  if [[ "$profile" == control || "$profile" == all ]]; then
    expected_peers=2
    yq -e '.spec.ingress[0].from[1].namespaceSelector.matchLabels."kubernetes.io/metadata.name" == "monitoring"' "$policy" >/dev/null ||
      fail "$profile did not select the collector namespace"
    for key in app.kubernetes.io/component app.kubernetes.io/instance; do
      expected="$(LABEL_KEY="$key" yq '.metadata.labels[strenv(LABEL_KEY)]' "$work_dir/collector-pod.yaml")"
      actual="$(LABEL_KEY="$key" yq '.spec.ingress[0].from[1].podSelector.matchLabels[strenv(LABEL_KEY)]' "$policy")"
      test "$actual" = "$expected" || fail "$profile selector does not match the released collector Pod: $key"
    done
  fi
  test "$(yq '.spec.ingress[0].from | length' "$policy")" = "$expected_peers" ||
    fail "$profile rendered unexpected ingress peers"
done

render_policy all \
  --state-values-set observability.namespace=custom-metrics \
  --state-values-set collector.collectorName=custom-collector
yq -e '.spec.ingress[0].from[1].namespaceSelector.matchLabels."kubernetes.io/metadata.name" == "custom-metrics"' \
  "$work_dir/state-metrics.yaml" >/dev/null || fail "custom namespace was ignored"
yq -e '.spec.ingress[0].from[1].podSelector.matchLabels."app.kubernetes.io/instance" == "custom-metrics.custom-collector"' \
  "$work_dir/state-metrics.yaml" >/dev/null || fail "custom collector name was ignored"

# A chart with NetworkPolicy disabled must still render successfully.
printf 'apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: no-policy\n' >"$fixture_chart/templates/policy.yaml"
render_policy control
yq -e '.kind == "ConfigMap"' "$work_dir/rendered.yaml" >/dev/null ||
  fail "the patch requires a policy when the chart omits it"

echo "state-metrics-network-policy: all checks passed"
