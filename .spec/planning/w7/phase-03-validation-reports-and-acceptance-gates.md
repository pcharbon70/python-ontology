# Phase 3 - Validation Reports and Acceptance Gates

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.validation_strategy.md`
- `.spec/specs/validation_strategy.spec.md`
- `lib/python_ontology/validator*.ex`
- `lib/python_ontology/shacl/**/*.ex`
- `test/python_ontology/**/*validation*_test.exs`

## Relevant Assumptions / Defaults

- Validation reports must be useful for CLI output and tests.
- Parser, extractor, builder, and validation diagnostics remain distinct.
- Validation does not execute analyzed Python code.

[x] 3 Phase 3 - Validation Reports and Acceptance Gates
  Finalize validation reporting and local acceptance behavior.

  [x] 3.1 Section - Report Model
    Define structured validation report data.

    [x] 3.1.1 Task - Implement report fields
      Preserve enough detail for humans and automation.

      [x] 3.1.1.1 Subtask - Include status, severity counts, target node, shape, path, message, and source context fields.
      [x] 3.1.1.2 Subtask - Include validation stage and source graph metadata.
      [x] 3.1.1.3 Subtask - Keep report serialization deterministic.

  [x] 3.2 Section - Acceptance Command Integration
    Wire validation into local gates and user-facing commands.

    [x] 3.2.1 Task - Add command behavior
      Make validation usable from tests and future Mix tasks.

      [x] 3.2.1.1 Subtask - Add human-readable report formatting.
      [x] 3.2.1.2 Subtask - Add machine-readable report formatting.
      [x] 3.2.1.3 Subtask - Define non-zero exit behavior for validation failures in future CLI flows.

  [x] 3.3 Section - Phase 3 Integration Tests
    Prove validation reports and gates are stable.

    [x] 3.3.1 Task - Run validation acceptance
      Validate report shape, serialization, and acceptance commands.

      [x] 3.3.1.1 Subtask - Add tests for report fields and deterministic serialization.
      [x] 3.3.1.2 Subtask - Add tests that validation diagnostics remain separate from parser/extractor diagnostics.
      [x] 3.3.1.3 Subtask - Run validation tests, full `mix test`, Turtle parse checks, and `mix spec.check`.
