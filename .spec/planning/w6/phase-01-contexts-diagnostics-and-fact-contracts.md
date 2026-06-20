# Phase 1 - Contexts, Diagnostics, and Fact Contracts

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.extractor_builder_boundary.md`
- `.spec/specs/extractor_builder_boundary.spec.md`
- `lib/python_ontology/extractors/**/*.ex`
- `lib/python_ontology/builders/**/*.ex`
- `lib/python_ontology/pipeline*.ex`

## Relevant Assumptions / Defaults

- Extractors emit facts, not RDF.
- Builders emit RDF, not parser traversal.
- Context and diagnostics are explicit data, not process-global state.

[x] 1 Phase 1 - Contexts, Diagnostics, and Fact Contracts
  Define shared contracts for extraction, building, and pipeline diagnostics.

  [x] 1.1 Section - Context Models
    Define explicit context data for extractors and builders.

    [x] 1.1.1 Task - Define analysis context
      Carry project, parser, syntax, and option metadata through the pipeline.

      [x] 1.1.1.1 Subtask - Include project root, source file, package hints, parser metadata, and analysis options.
      [x] 1.1.1.2 Subtask - Include base IRI and namespace configuration.
      [x] 1.1.1.3 Subtask - Include diagnostic accumulator fields.

    [x] 1.1.2 Task - Define builder context
      Carry graph-building configuration and helper access.

      [x] 1.1.2.1 Subtask - Include IRI helper configuration.
      [x] 1.1.2.2 Subtask - Include namespace/vocabulary helpers.
      [x] 1.1.2.3 Subtask - Include confidence propagation options.

  [x] 1.2 Section - Fact Contracts
    Define first-slice fact structs shared by extractors and builders.

    [x] 1.2.1 Task - Define structural facts
      Add facts for source organization.

      [x] 1.2.1.1 Subtask - Define source file, package, module, import, class, function, and method facts.
      [x] 1.2.1.2 Subtask - Define parameter, decorator, annotation, and base-class facts.
      [x] 1.2.1.3 Subtask - Include identity hints, source evidence, confidence, and diagnostics.

    [x] 1.2.2 Task - Define expression facts
      Add minimal facts for source navigation.

      [x] 1.2.2.1 Subtask - Define call, attribute, subscript, literal, and source-location facts.
      [x] 1.2.2.2 Subtask - Include unresolved/runtime-dependent markers.
      [x] 1.2.2.3 Subtask - Keep fact contracts independent from RDF triples.

  [x] 1.3 Section - Phase 1 Integration Tests
    Validate context and fact contracts before extractor logic depends on them.

    [x] 1.3.1 Task - Run contract checks
      Prove contexts and facts enforce required metadata.

      [x] 1.3.1.1 Subtask - Add tests for analysis and builder context construction.
      [x] 1.3.1.2 Subtask - Add tests for required fact fields, source evidence, and confidence metadata.
      [x] 1.3.1.3 Subtask - Run focused contract tests, full `mix test`, and `mix spec.check`.
