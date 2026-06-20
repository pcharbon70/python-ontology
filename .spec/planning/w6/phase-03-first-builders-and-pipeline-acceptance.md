# Phase 3 - First Builders and Pipeline Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.extractor_builder_boundary.md`
- `.spec/specs/extractor_builder_boundary.spec.md`
- `priv/ontologies/*.ttl`
- `lib/python_ontology/builders/**/*.ex`
- `lib/python_ontology/pipeline*.ex`
- `test/python_ontology/**/*builder*_test.exs`

## Relevant Assumptions / Defaults

- Builders consume facts and context only.
- Builders use shared IRI and confidence helpers.
- Validation runs after graph building.

[x] 3 Phase 3 - First Builders and Pipeline Acceptance
  Implement RDF builders for first-slice facts and compose parser-to-builder pipeline stages.

  [x] 3.1 Section - RDF Builder Implementation
    Convert first-slice facts into RDF triples.

    [x] 3.1.1 Task - Implement structural builders
      Build RDF for source files, modules, packages, imports, classes, and functions.

      [x] 3.1.1.1 Subtask - Emit source file and source location triples.
      [x] 3.1.1.2 Subtask - Emit package, module, import, alias, class, base, function, and method triples.
      [x] 3.1.1.3 Subtask - Emit parameter, decorator, annotation, and docstring triples.

    [x] 3.1.2 Task - Implement expression builders
      Build RDF for minimal expression facts.

      [x] 3.1.2.1 Subtask - Emit call, call target, attribute, and subscript triples.
      [x] 3.1.2.2 Subtask - Emit confidence and evidence triples consistently.
      [x] 3.1.2.3 Subtask - Ensure builders do not parse source text or traverse raw parser nodes.

  [x] 3.2 Section - Pipeline Composition
    Wire normalization, extraction, building, and diagnostics together.

    [x] 3.2.1 Task - Compose file pipeline
      Create a single-file path through parser, normalization, extraction, and builders.

      [x] 3.2.1.1 Subtask - Accept parser result and normalized syntax.
      [x] 3.2.1.2 Subtask - Run extractors and collect facts/diagnostics.
      [x] 3.2.1.3 Subtask - Run builders and return RDF graph plus diagnostics.

  [x] 3.3 Section - Phase 3 Integration Tests
    Prove builders and pipeline produce RDF from extracted facts while preserving stage boundaries.

    [x] 3.3.1 Task - Run builder and pipeline acceptance
      Validate RDF output, stage separation, and local gates.

      [x] 3.3.1.1 Subtask - Add tests that builders emit expected RDF triples for first-slice facts.
      [x] 3.3.1.2 Subtask - Add tests that builders use shared IRI and confidence helpers.
      [x] 3.3.1.3 Subtask - Run focused builder/pipeline tests, Turtle parse checks, full `mix test`, and `mix spec.check`.
