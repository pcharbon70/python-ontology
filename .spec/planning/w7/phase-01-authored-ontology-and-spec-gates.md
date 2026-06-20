# Phase 1 - Authored Ontology and Spec Gates

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.validation_strategy.md`
- `.spec/specs/validation_strategy.spec.md`
- `priv/ontologies/*.ttl`
- `.spec/specs/*.spec.md`

## Relevant Assumptions / Defaults

- Authored Turtle files must parse before generated graph validation matters.
- SpecLed remains the current-truth gate.
- Validation does not execute analyzed Python code.

[x] 1 Phase 1 - Authored Ontology and Spec Gates
  Add fail-fast checks for authored ontology and SpecLed artifacts.

  [x] 1.1 Section - Turtle Parse Gate
    Parse all authored ontology files deterministically.

    [x] 1.1.1 Task - Implement Turtle parse check
      Provide a reusable test helper or Mix task.

      [x] 1.1.1.1 Subtask - Load each `priv/ontologies/*.ttl` file.
      [x] 1.1.1.2 Subtask - Report file path and parse error details for malformed Turtle.
      [x] 1.1.1.3 Subtask - Keep parse validation independent from generated graph validation.

  [x] 1.2 Section - SpecLed Gate Integration
    Keep current truth aligned with implementation changes.

    [x] 1.2.1 Task - Preserve SpecLed local gate behavior
      Make `mix spec.check` part of acceptance.

      [x] 1.2.1.1 Subtask - Document `mix spec.check` as a local gate in relevant planning or README material.
      [x] 1.2.1.2 Subtask - Add command verification to specs once command surfaces stabilize.
      [x] 1.2.1.3 Subtask - Record unrelated baseline findings separately if a branch starts dirty.

  [x] 1.3 Section - Phase 1 Integration Tests
    Validate authored ontology and SpecLed checks before generated graph validation exists.

    [x] 1.3.1 Task - Run authored artifact gates
      Prove ontology and spec gates are working.

      [x] 1.3.1.1 Subtask - Add tests that all Turtle files parse successfully.
      [x] 1.3.1.2 Subtask - Run `mix spec.check` and capture status.
      [x] 1.3.1.3 Subtask - Run `mix format --check-formatted`, full `mix test`, and `mix spec.check`.
