@upgrade-transition-audit
Feature: Audit the immutable inputs for one upgrade hop
  As an operator preparing an HA upgrade,
  I want to reject changed inputs before any workload changes,
  so that a component report cannot be mistaken for runtime qualification.

  Background:
    Given these environment variables are set:
      | name                 |
      | UPGRADE_LAB          |
      | TRANSITION_CONTRACTS |
      | TRANSITION_INPUTS    |
      | TRANSITION_OUTPUT    |

  Scenario: Compare both exact routes without qualifying either
    When I successfully run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_CONTRACTS}" --route 1.0.1-to-1.0.4 --inputs "${TRANSITION_INPUTS}" --out "${TRANSITION_OUTPUT}/101-104"
      """
    Then yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "summary.qualification" should equal "unqualified"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "comparison_scope" should equal "release-inventories"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "runtime_artifact_checks[0]" should not be empty
    # These literals test the requested endpoint and matrix peer selections.
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[0].stacks.control-plane.version" should equal "1.0.1"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[1].stacks.control-plane.version" should equal "1.0.4"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[0].stacks.compute-plane.version" should equal "1.0.0"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[0].stacks.observability.version" should equal "1.0.0"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[1].stacks.compute-plane.version" should equal "1.0.5"
    And yaml file "${TRANSITION_OUTPUT}/101-104/audit.json" key "selections[1].stacks.observability.version" should equal "1.0.0"
    When I successfully run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_CONTRACTS}" --route 1.0.4-to-1.1.5 --inputs "${TRANSITION_INPUTS}" --out "${TRANSITION_OUTPUT}/104-115"
      """
    Then yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "summary.qualification" should equal "unqualified"
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "selections[1].stacks.control-plane.version" should equal "1.1.5"
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "selections[1].stacks.compute-plane.version" should equal "1.1.0"
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "selections[1].stacks.observability.version" should equal "1.1.0"
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "conditional_checks[0].id" should equal "dynamo-nats-reloader-downgrade"
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "conditional_checks[0].when_applicable" should not be empty
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "conditional_checks[0].when_not_applicable" should not be empty
    And yaml file "${TRANSITION_OUTPUT}/104-115/audit.json" key "conditional_checks[0].when_unknown" should not be empty

  Scenario: Reject peers selected from another endpoint matrix
    Given I copy the file "${TRANSITION_CONTRACTS}/artifact-lock.json" to "${TRANSITION_OUTPUT}/wrong-matrix-contracts/artifact-lock.json"
    And I substitute a block in file "${TRANSITION_OUTPUT}/wrong-matrix-contracts/artifact-lock.json":
      """
      "peer_matrix_edition": "1.0.4"
      ---
      "peer_matrix_edition": "1.0.1"
      """
    When I run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_OUTPUT}/wrong-matrix-contracts" --route 1.0.1-to-1.0.4 --inputs "${TRANSITION_INPUTS}" --out "${TRANSITION_OUTPUT}/wrong-matrix-rejected"
      """
    Then the command exit code should be 1
    And the command output should contain "differs from docs matrix"

  Scenario: Reject a product selection for a stack endpoint
    Given I copy the file "${TRANSITION_CONTRACTS}/artifact-lock.json" to "${TRANSITION_OUTPUT}/product-contracts/artifact-lock.json"
    And I substitute a block in file "${TRANSITION_OUTPUT}/product-contracts/artifact-lock.json":
      """
      "version": "1.0.4",
            "kind": "self-managed-stack"
      ---
      "version": "1.0.4",
            "kind": "product-manifest"
      """
    When I run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_OUTPUT}/product-contracts" --route 1.0.1-to-1.0.4 --inputs "${TRANSITION_INPUTS}" --out "${TRANSITION_OUTPUT}/product-rejected"
      """
    Then the command exit code should be 1
    And the command output should contain "selection must name its exact Self-Managed stack version"

  Scenario: Reject a changed source inventory before comparison
    Given I write yaml file "${TRANSITION_OUTPUT}/changed-inputs/control-plane-1.0.1.json" with values:
      | source.version | changed |
    When I run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_CONTRACTS}" --route 1.0.1-to-1.0.4 --inputs "${TRANSITION_OUTPUT}/changed-inputs" --out "${TRANSITION_OUTPUT}/rejected"
      """
    Then the command exit code should be 1
    And the command output should contain "inventory digest mismatch"

  Scenario: Reject an undeclared direct hop
    When I run command:
      """
      "${UPGRADE_LAB}" audit --contracts "${TRANSITION_CONTRACTS}" --route 1.0.1-to-1.1.5 --inputs "${TRANSITION_INPUTS}" --out "${TRANSITION_OUTPUT}/direct-hop"
      """
    Then the command exit code should be 1

  Scenario: Refuse an unimplemented mutation phase before reading credentials
    When I run command:
      """
      "${UPGRADE_LAB}" rehearse --route 1.0.4-to-1.1.5 --run-config "${TRANSITION_OUTPUT}/absent-private-config.json" --run-dir "${TRANSITION_OUTPUT}/must-not-apply" --phase apply
      """
    Then the command exit code should be 1
    And the command output should contain "only prepare is implemented"

  Scenario: Reject recovery evidence that is not bound to immutable inputs
    When I successfully run command:
      """
      /bin/sh -c 'printf "{}\n" > "$1"' _ "${TRANSITION_OUTPUT}/empty-recovery.json"
      """
    When I run command:
      """
      "${UPGRADE_LAB}" check-recovery --contracts "${TRANSITION_CONTRACTS}" --route 1.0.4-to-1.1.5 --baseline "${TRANSITION_OUTPUT}/empty-recovery.json" --checkpoint "${TRANSITION_OUTPUT}/empty-recovery.json" --out "${TRANSITION_OUTPUT}/must-not-recover"
      """
    Then the command exit code should be 1
    And the command output should contain "recovery checkpoint does not match"
