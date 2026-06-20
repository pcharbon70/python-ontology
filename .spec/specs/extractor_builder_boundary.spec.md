# Extractor And Builder Boundary

Current contract for parser, extractor, builder, and validation responsibilities.

```spec-meta
id: python_ontology.extractor_builder_boundary
kind: component
status: active
summary: Separation of normalized syntax, extracted facts, RDF builders, and validation.
surface:
  - .spec/decisions/python_ontology.decision.extractor_builder_boundary.md
  - lib/python_ontology/extractors/**/*.ex
  - lib/python_ontology/builders/**/*.ex
  - lib/python_ontology/pipeline*.ex
  - test/python_ontology/**/*extractor*_test.exs
  - test/python_ontology/**/*builder*_test.exs
decisions:
  - python_ontology.decision.normalized_syntax_model
  - python_ontology.decision.iri_identity_strategy
  - python_ontology.decision.fact_confidence_model
  - python_ontology.decision.extractor_builder_boundary
```

## Requirements

```spec-requirements
- id: python_ontology.extractor_builder_boundary.parser_syntax_only
  statement: Parser stages shall output normalized syntax data rather than extracted semantic facts or RDF triples.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.extractors_emit_facts
  statement: Extractors shall produce structured Python facts from normalized syntax and analysis context.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.builders_emit_rdf
  statement: Builders shall produce RDF triples from extracted facts and builder context.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.shared_context
  statement: Extractors and builders shall receive explicit context objects instead of relying on process-global state.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.shared_iri_helper
  statement: Builders shall use shared IRI generation helpers.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.no_rdf_in_extractors
  statement: Extractors shall not emit RDF triples directly.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.no_parsing_in_builders
  statement: Builders shall not parse source files or traverse raw Tree-sitter cursors.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.source_evidence_required
  statement: Extracted facts shall carry source evidence and confidence metadata.
  priority: must
  stability: stable

- id: python_ontology.extractor_builder_boundary.diagnostic_accumulation
  statement: Pipeline stages shall accumulate structured diagnostics for recoverable issues.
  priority: should
  stability: evolving

- id: python_ontology.extractor_builder_boundary.validation_after_build
  statement: Validation shall run after RDF graph building rather than inside parser or extractor stages.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.extractor_builder_boundary.import_flow
  given:
    - normalized syntax contains an import statement
  when:
    - the import extractor runs
  then:
    - it emits an import fact with source evidence, and a builder later turns that fact into RDF
  covers:
    - python_ontology.extractor_builder_boundary.extractors_emit_facts
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.source_evidence_required

- id: python_ontology.extractor_builder_boundary_error_flow
  given:
    - normalization preserves an unsupported node
  when:
    - extractors process the node
  then:
    - the pipeline records a diagnostic without forcing builders to parse source text
  covers:
    - python_ontology.extractor_builder_boundary.no_parsing_in_builders
    - python_ontology.extractor_builder_boundary.diagnostic_accumulation
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.extractor_builder_boundary.md
  covers:
    - python_ontology.extractor_builder_boundary.parser_syntax_only
    - python_ontology.extractor_builder_boundary.extractors_emit_facts
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.shared_context
    - python_ontology.extractor_builder_boundary.shared_iri_helper
    - python_ontology.extractor_builder_boundary.no_rdf_in_extractors
    - python_ontology.extractor_builder_boundary.no_parsing_in_builders
    - python_ontology.extractor_builder_boundary.source_evidence_required
    - python_ontology.extractor_builder_boundary.diagnostic_accumulation
    - python_ontology.extractor_builder_boundary.validation_after_build

- kind: source_file
  target: lib/python_ontology/iri/builder.ex
  covers:
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.shared_iri_helper

- kind: source_file
  target: test/python_ontology/iri/builder_contract_test.exs
  covers:
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.shared_iri_helper

- kind: source_file
  target: test/python_ontology/iri/phase3_integration_test.exs
  covers:
    - python_ontology.extractor_builder_boundary.shared_iri_helper

- kind: source_file
  target: lib/python_ontology/builders/confidence.ex
  covers:
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.shared_iri_helper

- kind: source_file
  target: test/python_ontology/builders/confidence_test.exs
  covers:
    - python_ontology.extractor_builder_boundary.builders_emit_rdf
    - python_ontology.extractor_builder_boundary.shared_iri_helper
```
