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

[ ] 3 Phase 3 - First Builders and Pipeline Acceptance
  Implement RDF builders for first-slice facts and compose parser-to-builder pipeline stages.

  [ ] 3.1 Section - RDF Builder Implementation
    Convert first-slice facts into RDF triples.

    [ ] 3.1.1 Task - Implement structural builders
      Build RDF for source files, modules, packages, imports, classes, and functions.

      [ ] 3.1.1.1 Subtask - Emit source file and source location triples.
      [ ] 3.1.1.2 Subtask - Emit package, module, import, alias, class, base, function, and method triples.
      [ ] 3.1.1.3 Subtask - Emit parameter, decorator, annotation, and docstring triples.

    [ ] 3.1.2 Task - Implement expression builders
      Build RDF for minimal expression facts.

      [ ] 3.1.2.1 Subtask - Emit call, call target, attribute, and subscript triples.
      [ ] 3.1.2.2 Subtask - Emit confidence and evidence triples consistently.
      [ ] 3.1.2.3 Subtask - Ensure builders do not parse source text or traverse raw parser nodes.

  [ ] 3.2 Section - Pipeline Composition
    Wire normalization, extraction, building, and diagnostics together.

    [ ] 3.2.1 Task - Compose file pipeline
      Create a single-file path through parser, normalization, extraction, and builders.

      [ ] 3.2.1.1 Subtask - Accept parser result and normalized syntax.
      [ ] 3.2.1.2 Subtask - Run extractors and collect facts/diagnostics.
      [ ] 3.2.1.3 Subtask - Run builders and return RDF graph plus diagnostics.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Prove builders and pipeline produce RDF from extracted facts while preserving stage boundaries.

    [ ] 3.3.1 Task - Run builder and pipeline acceptance
      Validate RDF output, stage separation, and local gates.

      [ ] 3.3.1.1 Subtask - Add tests that builders emit expected RDF triples for first-slice facts.
      [ ] 3.3.1.2 Subtask - Add tests that builders use shared IRI and confidence helpers.
      [ ] 3.3.1.3 Subtask - Run focused builder/pipeline tests, Turtle parse checks, full `mix test`, and `mix spec.check`.
