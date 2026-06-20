# Phase 1 - Confidence Categories and Evidence Model

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.fact_confidence_model.md`
- `.spec/specs/fact_confidence_model.spec.md`
- `lib/python_ontology/extractors/**/*.ex`
- `lib/python_ontology/builders/**/*.ex`

## Relevant Assumptions / Defaults

- Direct syntax extraction defaults to source-declared confidence.
- Static inference requires evidence.
- Runtime-dependent behavior is not promoted to static truth.

[x] 1 Phase 1 - Confidence Categories and Evidence Model
  Define internal confidence and evidence data structures.

  [x] 1.1 Section - Category Model
    Implement the finite confidence category set.

    [x] 1.1.1 Task - Define category values
      Provide stable category atoms or structs.

      [x] 1.1.1.1 Subtask - Define `source_declared`, `statically_inferred`, `unresolved`, and `runtime_dependent`.
      [x] 1.1.1.2 Subtask - Add validation for unknown category values.
      [x] 1.1.1.3 Subtask - Define default category selection for direct syntax facts.

  [x] 1.2 Section - Evidence Model
    Represent why a fact has its confidence category.

    [x] 1.2.1 Task - Define source evidence
      Point facts at syntax and source spans.

      [x] 1.2.1.1 Subtask - Define source file and span evidence references.
      [x] 1.2.1.2 Subtask - Define syntax node evidence references.
      [x] 1.2.1.3 Subtask - Define evidence lists for facts with multiple source contributors.

    [x] 1.2.2 Task - Define inferred and dynamic evidence
      Preserve reasons for inferred, unresolved, and runtime-dependent facts.

      [x] 1.2.2.1 Subtask - Define static-inference evidence that references source-declared inputs.
      [x] 1.2.2.2 Subtask - Define unresolved reasons for unknown names and dynamic targets.
      [x] 1.2.2.3 Subtask - Define runtime-dependent reasons for imports, decorators, metaclasses, monkey patching, and reflection.

  [x] 1.3 Section - Phase 1 Integration Tests
    Validate category and evidence construction before extractors use the model.

    [x] 1.3.1 Task - Run confidence model checks
      Prove categories and evidence references are valid and deterministic.

      [x] 1.3.1.1 Subtask - Add tests for category validation and defaults.
      [x] 1.3.1.2 Subtask - Add tests for source, inferred, unresolved, and runtime-dependent evidence records.
      [x] 1.3.1.3 Subtask - Run focused confidence tests, full `mix test`, and `mix spec.check`.
