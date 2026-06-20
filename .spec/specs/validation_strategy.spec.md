# Validation Strategy

Current contract for validating ontology files, parser/extractor behavior, generated RDF graphs, and SpecLed current truth.

```spec-meta
id: python_ontology.validation_strategy
kind: policy
status: active
summary: Layered validation strategy for PythonOntology artifacts and generated graphs.
surface:
  - .spec/decisions/python_ontology.decision.validation_strategy.md
  - priv/ontologies/*.ttl
  - lib/python_ontology/validator*.ex
  - lib/python_ontology/shacl/**/*.ex
  - test/python_ontology/**/*validation*_test.exs
decisions:
  - python_ontology.decision.ontology_turtle_file_layers
  - python_ontology.decision.validation_strategy
```

## Requirements

```spec-requirements
- id: python_ontology.validation_strategy.turtle_parse_gate
  statement: Authored Turtle ontology files shall be parseable RDF/Turtle.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.owl_open_world
  statement: OWL ontology declarations shall define vocabulary and semantic relationships without replacing local closed-world checks.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.shacl_closed_world
  statement: SHACL shall validate generated RDF graphs for closed-world completeness and consistency.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.parser_unit_tests
  statement: Parser and normalization behavior shall be covered by focused tests.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.extractor_builder_tests
  statement: Extractor and builder behavior shall be covered by focused tests and integration tests.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.specled_current_truth
  statement: SpecLed shall validate current-truth specs, ADRs, and branch coverage.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.command_verification
  statement: User-facing gates shall have command verifications once implementation exists.
  priority: should
  stability: evolving

- id: python_ontology.validation_strategy.validation_reports
  statement: Validation shall produce structured reports suitable for CLI output and tests.
  priority: should
  stability: evolving

- id: python_ontology.validation_strategy.no_validation_by_execution
  statement: Validation shall not execute analyzed Python project code.
  priority: must
  stability: stable

- id: python_ontology.validation_strategy.validation_after_graph_build
  statement: Generated graph validation shall run after RDF graph building.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.validation_strategy_generated_graph_flow
  given:
    - a generated RDF graph contains a function resource without a qualified name
  when:
    - SHACL validation runs
  then:
    - the validation report identifies the missing required property
  covers:
    - python_ontology.validation_strategy.shacl_closed_world
    - python_ontology.validation_strategy.validation_reports

- id: python_ontology.validation_strategy_turtle_flow
  given:
    - an authored ontology Turtle file contains invalid Turtle syntax
  when:
    - the ontology validation gate runs
  then:
    - the gate fails before graph analysis proceeds
  covers:
    - python_ontology.validation_strategy.turtle_parse_gate
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.validation_strategy.md
  covers:
    - python_ontology.validation_strategy.turtle_parse_gate
    - python_ontology.validation_strategy.owl_open_world
    - python_ontology.validation_strategy.shacl_closed_world
    - python_ontology.validation_strategy.parser_unit_tests
    - python_ontology.validation_strategy.extractor_builder_tests
    - python_ontology.validation_strategy.specled_current_truth
    - python_ontology.validation_strategy.command_verification
    - python_ontology.validation_strategy.validation_reports
    - python_ontology.validation_strategy.no_validation_by_execution
    - python_ontology.validation_strategy.validation_after_graph_build

- kind: source_file
  target: test/python_ontology/ontology/confidence_vocabulary_test.exs
  covers:
    - python_ontology.validation_strategy.command_verification
```
