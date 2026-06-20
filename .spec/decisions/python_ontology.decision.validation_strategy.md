---
id: python_ontology.decision.validation_strategy
status: accepted
date: 2026-06-20
affects:
  - python_ontology.validation_strategy
  - python_ontology.ontology_turtle_files
---

# Validation Strategy

## Context

PythonOntology needs multiple validation layers. Turtle files need to parse. Parser and extractor behavior needs tests. Generated RDF graphs need closed-world validation for completeness and consistency. SpecLed current truth needs to stay aligned with implementation files.

OWL provides ontology semantics, but OWL's open-world model is not enough to catch missing generated properties. SHACL is a better fit for local graph validation.

## Decision

Use layered validation:

- Turtle ontology files must parse as RDF/Turtle
- unit and integration tests validate parser, normalization, extractor, and builder behavior
- SHACL validates generated RDF graphs as closed-world output checks
- SpecLed validates current-truth specs, decisions, and branch coverage
- command verifications provide executed evidence for user-facing gates

Keep OWL and SHACL responsibilities separate. OWL defines vocabulary and semantic relationships. SHACL checks graph completeness, datatypes, cardinality, naming patterns, and cross-entity consistency.

Validation shall not execute analyzed Python project code.

Validation reports shall be structured enough for CLI output and tests.

## Consequences

Early tests can focus on parser/extractor behavior while SHACL coverage grows with RDF builders.

The project can fail fast on malformed Turtle or malformed specs before running broader analysis.

Generated graph validation remains explicit rather than hidden inside builders.

## Implementation Notes

Wave 7 starts the validation layer with RDF.ex-backed Turtle parsing for authored ontology files. This parse gate is independent from generated graph validation: it verifies local ontology artifacts before SHACL checks run against RDF emitted by builders.

<!-- covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.owl_open_world python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.parser_unit_tests python_ontology.validation_strategy.extractor_builder_tests python_ontology.validation_strategy.specled_current_truth python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build -->
