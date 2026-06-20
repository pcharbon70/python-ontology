# Phase 3 - Span-Bound Identity and Builder Adoption

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.iri_identity_strategy.md`
- `.spec/specs/iri_identity_strategy.spec.md`
- `lib/python_ontology/iri*.ex`
- `lib/python_ontology/builders/**/*.ex`

## Relevant Assumptions / Defaults

- Expressions and source locations are identified by containing entity and source span.
- Hash-based fragments use documented canonical inputs.
- Builders use shared IRI helpers.

[ ] 3 Phase 3 - Span-Bound Identity and Builder Adoption
  Add identity helpers for span-bound resources and prepare builders to use the shared strategy.

  [x] 3.1 Section - Span-Bound Resource Identity
    Generate identities for imports, calls, assignments, expressions, and locations.

    [x] 3.1.1 Task - Implement expression and statement IDs
      Use containing entity and source span as identity inputs.

      [x] 3.1.1.1 Subtask - Generate import and assignment IDs.
      [x] 3.1.1.2 Subtask - Generate call, attribute, subscript, and expression IDs.
      [x] 3.1.1.3 Subtask - Generate source-location IDs.

    [x] 3.1.2 Task - Implement fragment escaping and hashing
      Keep generated IRIs valid and deterministic.

      [x] 3.1.2.1 Subtask - Escape safe short fragments consistently.
      [x] 3.1.2.2 Subtask - Hash long or unsafe fragments from documented canonical inputs.
      [x] 3.1.2.3 Subtask - Add diagnostics for missing identity inputs.

  [x] 3.2 Section - Builder Adoption Contract
    Prepare RDF builders to use the shared identity helpers.

    [x] 3.2.1 Task - Add builder helper API
      Expose helper functions expected by future builders.

      [x] 3.2.1.1 Subtask - Add helpers for vocabulary IRIs versus generated resource IRIs.
      [x] 3.2.1.2 Subtask - Add helpers for fact resource IRIs.
      [x] 3.2.1.3 Subtask - Add tests that builders do not use ad hoc string construction once builders exist.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Prove span-bound identity works and is ready for builder integration.

    [ ] 3.3.1 Task - Run span-bound identity checks
      Validate expression and source-location identity behavior.

      [ ] 3.3.1.1 Subtask - Add tests for import, call, assignment, expression, and source-location IRIs.
      [ ] 3.3.1.2 Subtask - Add tests for canonical hash inputs and deterministic output.
      [ ] 3.3.1.3 Subtask - Run focused IRI tests, full `mix test`, and `mix spec.check`.
