# Phase 2 - Generated Graph SHACL Validation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.validation_strategy.md`
- `.spec/specs/validation_strategy.spec.md`
- `priv/ontologies/python-shapes.ttl`
- `lib/python_ontology/validator*.ex`
- `lib/python_ontology/shacl/**/*.ex`

## Relevant Assumptions / Defaults

- OWL vocabulary and SHACL closed-world validation have separate responsibilities.
- Generated graph validation runs after RDF building.
- Validation failures return structured reports.

[ ] 2 Phase 2 - Generated Graph SHACL Validation
  Validate generated RDF graphs against PythonOntology SHACL shapes.

  [x] 2.1 Section - SHACL Entrypoint
    Load data graphs and shapes graphs for validation.

    [x] 2.1.1 Task - Implement validation API
      Add a public validator entrypoint for generated RDF graphs.

      [x] 2.1.1.1 Subtask - Load or accept an RDF data graph.
      [x] 2.1.1.2 Subtask - Load `python-shapes.ttl` as the shapes graph.
      [x] 2.1.1.3 Subtask - Return pass/fail status and structured results.

  [ ] 2.2 Section - First SHACL Shape Coverage
    Validate first-slice generated resources.

    [ ] 2.2.1 Task - Implement first closed-world checks
      Check required first-slice resource properties.

      [ ] 2.2.1.1 Subtask - Validate module names and source file links.
      [ ] 2.2.1.2 Subtask - Validate function qualified names and parameter structure.
      [ ] 2.2.1.3 Subtask - Validate source location line/column datatypes.

  [ ] 2.3 Section - Phase 2 Integration Tests
    Prove generated graph validation catches malformed graph output.

    [ ] 2.3.1 Task - Run SHACL validation checks
      Validate passing and failing graph fixtures.

      [ ] 2.3.1.1 Subtask - Add a passing generated graph fixture for first-slice resources.
      [ ] 2.3.1.2 Subtask - Add a failing fixture with missing required properties.
      [ ] 2.3.1.3 Subtask - Run focused SHACL tests, full `mix test`, and `mix spec.check`.
