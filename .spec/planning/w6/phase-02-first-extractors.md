# Phase 2 - First Extractors

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.extractor_builder_boundary.md`
- `.spec/specs/extractor_builder_boundary.spec.md`
- `lib/python_ontology/extractors/**/*.ex`
- `lib/python_ontology/syntax/*.ex`
- `test/python_ontology/**/*extractor*_test.exs`

## Relevant Assumptions / Defaults

- Extractors consume normalized syntax only.
- Extractors emit structured facts with evidence and confidence.
- Unsupported syntax records diagnostics instead of disappearing.

[x] 2 Phase 2 - First Extractors
  Implement the first extractor set for source structure and call navigation.

  [x] 2.1 Section - Structural Extractors
    Extract source files, modules, imports, classes, and functions.

    [x] 2.1.1 Task - Implement module and import extraction
      Convert normalized module/import syntax into facts.

      [x] 2.1.1.1 Subtask - Extract source file and module facts.
      [x] 2.1.1.2 Subtask - Extract `import` and `from ... import ...` facts with aliases.
      [x] 2.1.1.3 Subtask - Preserve unresolved relative or dynamic import details.

    [x] 2.1.2 Task - Implement class and function extraction
      Convert declarations into structural facts.

      [x] 2.1.2.1 Subtask - Extract class facts with base class syntax and decorators.
      [x] 2.1.2.2 Subtask - Extract function and method facts with decorators and annotations.
      [x] 2.1.2.3 Subtask - Extract parameter, default, vararg, kwarg, and keyword-only facts.

  [x] 2.2 Section - Expression Extractors
    Extract minimal expression facts required by the first analysis slice.

    [x] 2.2.1 Task - Implement call and attribute extraction
      Convert normalized expressions into navigation facts.

      [x] 2.2.1.1 Subtask - Extract call facts and simple call target syntax.
      [x] 2.2.1.2 Subtask - Extract attribute and subscript facts.
      [x] 2.2.1.3 Subtask - Mark dynamic or unresolved call targets with confidence metadata.

    [x] 2.2.2 Task - Preserve diagnostics
      Accumulate recoverable extraction diagnostics.

      [x] 2.2.2.1 Subtask - Record unsupported syntax diagnostics.
      [x] 2.2.2.2 Subtask - Record unresolved dynamic construct diagnostics.
      [x] 2.2.2.3 Subtask - Keep diagnostics structured and source-linked.

  [x] 2.3 Section - Phase 2 Integration Tests
    Prove first extractors emit facts and do not emit RDF.

    [x] 2.3.1 Task - Run extractor checks
      Validate first-slice facts from normalized syntax fixtures.

      [x] 2.3.1.1 Subtask - Add tests for modules, imports, classes, functions, parameters, decorators, annotations, calls, and attributes.
      [x] 2.3.1.2 Subtask - Add tests that extractors emit no RDF triples.
      [x] 2.3.1.3 Subtask - Run focused extractor tests, full `mix test`, and `mix spec.check`.
