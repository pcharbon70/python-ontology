---
id: python_ontology.decision.extractor_builder_boundary
status: accepted
date: 2026-06-20
affects:
  - python_ontology.extractor_builder_boundary
---

# Extractor And Builder Boundary

## Context

PythonOntology needs clear boundaries between parsing, extraction, RDF building, and validation. Without that separation, parser code may start emitting ontology triples, extractors may invent IRIs, or builders may re-parse source text.

The sibling Elixir project uses extractors and builders as separate stages. PythonOntology should keep that pattern while adapting the extracted fact model to Python.

## Decision

Keep the pipeline stages separate:

- parser adapter returns normalized syntax data
- extractors read normalized syntax plus analysis context and produce structured Python facts
- builders read structured facts plus builder context and produce RDF triples
- validation checks generated graphs against SHACL and other project gates

Extractors shall not emit RDF triples. Builders shall not parse source files or traverse raw Tree-sitter cursors. Builders may use normalized source references and a shared IRI helper.

Extractor output shall include source evidence, confidence category, and enough identity hints for builders to generate stable IRIs.

Pipeline stages shall accumulate structured diagnostics instead of collapsing all errors into exceptions.

## Consequences

Each stage can be tested independently.

Extractors can evolve Python-specific semantic logic without coupling to Turtle serialization.

Builders can enforce consistent IRI generation and namespace use across all extracted facts.

<!-- covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.extractor_builder_boundary.validation_after_build -->
