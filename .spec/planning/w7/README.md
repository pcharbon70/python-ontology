# W7 - Validation Strategy

This wave implements layered validation for authored ontologies, generated graphs, tests, and SpecLed current truth. It starts early with Turtle parse gates and finishes after builders produce RDF graphs that SHACL can validate.

## Phase Order

1. [Phase 1 - Authored Ontology and Spec Gates](./phase-01-authored-ontology-and-spec-gates.md)
2. [Phase 2 - Generated Graph SHACL Validation](./phase-02-generated-graph-shacl-validation.md)
3. [Phase 3 - Validation Reports and Acceptance Gates](./phase-03-validation-reports-and-acceptance-gates.md)

## Implementation Sequence

Add Turtle parse validation first. Then add SHACL graph validation when builders exist. Finish with structured reports and CLI/test integration.

## Local Gates

<!-- covers: python_ontology.validation_strategy.specled_current_truth python_ontology.validation_strategy.command_verification -->

Each W7 section should finish with:

- `mix format --check-formatted`
- focused validation tests for the changed section
- `mix test`
- `mix spec.check`

Start from a clean branch. If unrelated local changes or baseline findings are present, record them separately before staging W7 work.

## Parallel Work Lanes

- Phase 1 can run immediately.
- Phases 2 and 3 depend on W6 builder output.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.validation_strategy.md`
- `.spec/specs/validation_strategy.spec.md`
