# Phase 2 - First Slice Source Construct Coverage

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.initial_analysis_slice.md`
- `.spec/specs/initial_analysis_slice.spec.md`
- `lib/python_ontology/**/*.ex`
- `priv/ontologies/*.ttl`
- `test/fixtures/python_initial_slice/*`

## Relevant Assumptions / Defaults

- The first slice is source-structure focused.
- Runtime-dependent behavior remains unresolved or runtime-dependent.
- Full type reasoning, dataflow, and framework semantics remain out of scope.

[x] 2 Phase 2 - First Slice Source Construct Coverage
  Ensure the end-to-end pipeline covers the first committed Python source constructs.

  [x] 2.1 Section - Structural Construct Coverage
    Validate graph output for ordinary Python declarations.

    [x] 2.1.1 Task - Cover modules, packages, imports, classes, and functions
      Prove the most common source structure appears in generated RDF.

      [x] 2.1.1.1 Subtask - Assert module, package, source file, and source location resources.
      [x] 2.1.1.2 Subtask - Assert import, alias, class, and base class resources.
      [x] 2.1.1.3 Subtask - Assert function, method, parameter, default, vararg, kwarg, and keyword-only resources.

    [x] 2.1.2 Task - Cover decorators and annotations
      Preserve syntax-level type and decorator information.

      [x] 2.1.2.1 Subtask - Assert decorator resources on classes and functions.
      [x] 2.1.2.2 Subtask - Assert annotation resources on parameters, returns, and variables where supported.
      [x] 2.1.2.3 Subtask - Keep annotation facts syntax-level without full type reasoning.

  [x] 2.2 Section - Expression Construct Coverage
    Validate minimal expression resources needed for code navigation.

    [x] 2.2.1 Task - Cover calls, attributes, and subscripts
      Add RDF output for navigable expression syntax.

      [x] 2.2.1.1 Subtask - Assert call resources and simple call target syntax.
      [x] 2.2.1.2 Subtask - Assert attribute and subscript resources.
      [x] 2.2.1.3 Subtask - Assert unresolved/runtime-dependent confidence for dynamic targets.

  [x] 2.3 Section - Phase 2 Integration Tests
    Prove first-slice source construct coverage across representative fixtures.

    [x] 2.3.1 Task - Run first-slice coverage checks
      Validate expected graph resources and out-of-scope boundaries.

      [x] 2.3.1.1 Subtask - Add a Python fixture module with all first-slice constructs.
      [x] 2.3.1.2 Subtask - Add graph assertions for each first-slice requirement.
      [x] 2.3.1.3 Subtask - Run focused first-slice tests, full `mix test`, and `mix spec.check`.
