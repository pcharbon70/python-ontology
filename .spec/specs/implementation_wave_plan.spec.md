# Implementation Wave Plans

Current contract for ADR-specific phased implementation waves derived from PythonOntology ADRs and subject specs.

```spec-meta
id: python_ontology.implementation_wave_plan
kind: planning
status: active
summary: ADR-specific phased implementation waves for parser, normalization, identity, confidence, project scope, builders, validation, and the first analysis slice.
surface:
  - .spec/planning/w*/*.md
decisions:
  - python_ontology.decision.parser_bridge_boundary
  - python_ontology.decision.normalized_syntax_model
  - python_ontology.decision.iri_identity_strategy
  - python_ontology.decision.fact_confidence_model
  - python_ontology.decision.project_analysis_scope
  - python_ontology.decision.extractor_builder_boundary
  - python_ontology.decision.validation_strategy
  - python_ontology.decision.initial_analysis_slice
```

## Requirements

```spec-requirements
- id: python_ontology.implementation_wave_plan.wave_index
  statement: Each implementation wave shall include an index that explains phase order, dependencies, and parallel work lanes for its ADR-backed area.
  priority: must
  stability: stable

- id: python_ontology.implementation_wave_plan.phase_files
  statement: Each implementation wave shall include multiple phase files for its ADR-backed implementation area.
  priority: must
  stability: stable

- id: python_ontology.implementation_wave_plan.phase_hierarchy
  statement: Each phase file shall use phase, section, task, and subtask hierarchy with a description at each phase, section, and task level.
  priority: must
  stability: stable

- id: python_ontology.implementation_wave_plan.integration_test_sections
  statement: Each phase file shall end with a dedicated integration test section.
  priority: must
  stability: stable

- id: python_ontology.implementation_wave_plan.adr_traceability
  statement: Each phase file shall list the ADRs, specs, and implementation surfaces it is intended to advance.
  priority: must
  stability: stable

- id: python_ontology.implementation_wave_plan.wave_per_adr_area
  statement: Parser, normalization, IRI identity, fact confidence, project scope, extractor/builder, validation, and initial slice planning shall each have a dedicated wave.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/planning/w1/README.md
  covers:
    - python_ontology.implementation_wave_plan.wave_index
    - python_ontology.implementation_wave_plan.phase_files
    - python_ontology.implementation_wave_plan.phase_hierarchy
    - python_ontology.implementation_wave_plan.integration_test_sections
    - python_ontology.implementation_wave_plan.adr_traceability
    - python_ontology.implementation_wave_plan.wave_per_adr_area
```
