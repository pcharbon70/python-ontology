# Phase 3 - Dynamic Boundary Fixtures and Confidence Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.fact_confidence_model.md`
- `.spec/specs/fact_confidence_model.spec.md`
- `test/fixtures/python_confidence/*`
- `test/python_ontology/**/*confidence*_test.exs`

## Relevant Assumptions / Defaults

- Dynamic Python constructs remain unresolved or runtime-dependent when static evidence is insufficient.
- The analyzer does not execute project code to increase confidence.
- Confidence categories are queryable in generated RDF.

[x] 3 Phase 3 - Dynamic Boundary Fixtures and Confidence Acceptance
  Prove confidence behavior with source fixtures that include dynamic Python constructs.

  [x] 3.1 Section - Source Fixtures For Confidence
    Create representative examples of direct, inferred, unresolved, and runtime-dependent facts.

    [x] 3.1.1 Task - Add direct and inferred fixtures
      Cover facts that should be source-declared or statically inferred.

      [x] 3.1.1.1 Subtask - Add fixture for direct imports, class definitions, and function definitions.
      [x] 3.1.1.2 Subtask - Add fixture for a bounded static inference such as simple alias resolution when supported.
      [x] 3.1.1.3 Subtask - Assert evidence points back to source syntax.

    [x] 3.1.2 Task - Add dynamic fixtures
      Cover facts that should not be over-inferred.

      [x] 3.1.2.1 Subtask - Add fixture for `importlib.import_module(name)`.
      [x] 3.1.2.2 Subtask - Add fixtures for `getattr`, `setattr`, decorators, metaclasses, and monkey patching boundaries.
      [x] 3.1.2.3 Subtask - Assert unresolved/runtime-dependent facts remain queryable.

  [x] 3.2 Section - Acceptance Behavior
    Validate confidence categories across parser, extraction, and builder boundaries.

    [x] 3.2.1 Task - Verify no execution for confidence
      Ensure dynamic fixtures are not evaluated.

      [x] 3.2.1.1 Subtask - Add fixture with top-level side effect that would fail if executed.
      [x] 3.2.1.2 Subtask - Assert analysis completes without executing the side effect.
      [x] 3.2.1.3 Subtask - Assert confidence remains unresolved or runtime-dependent where appropriate.

  [x] 3.3 Section - Phase 3 Integration Tests
    Prove confidence policy holds across representative dynamic source cases.

    [x] 3.3.1 Task - Run confidence acceptance
      Validate direct, inferred, unresolved, and runtime-dependent confidence output.

      [x] 3.3.1.1 Subtask - Run focused dynamic-boundary fixture tests.
      [x] 3.3.1.2 Subtask - Run generated RDF confidence query or graph assertion tests when builders exist.
      [x] 3.3.1.3 Subtask - Run full `mix test` and `mix spec.check`.
