# Phase 1 - Core Syntax Structs and Shared Fields

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.normalized_syntax_model.md`
- `.spec/specs/normalized_syntax_model.spec.md`
- `lib/python_ontology/syntax*.ex`
- `lib/python_ontology/syntax/*.ex`

## Relevant Assumptions / Defaults

- Raw Tree-sitter nodes are not extractor-facing API.
- Normalized nodes preserve source identity, source spans, and raw parser provenance.
- Typed nodes cover the initial analysis slice without hiding unsupported syntax.

[x] 1 Phase 1 - Core Syntax Structs and Shared Fields
  Define the normalized syntax structs and shared metadata fields.

  [x] 1.1 Section - Shared Node Fields
    Establish the common shape every normalized syntax node carries.

    [x] 1.1.1 Task - Define provenance and identity fields
      Make raw parser origin and source identity explicit.

      [x] 1.1.1.1 Subtask - Define source file identity and parser metadata fields.
      [x] 1.1.1.2 Subtask - Define raw Tree-sitter type, named status, field name, child order, and parent path fields.
      [x] 1.1.1.3 Subtask - Define stable node IDs for normalized nodes within a file.

    [x] 1.1.2 Task - Define source span fields
      Preserve byte and row/column positions for syntax nodes.

      [x] 1.1.2.1 Subtask - Define byte span struct or field convention.
      [x] 1.1.2.2 Subtask - Define row/column span struct or field convention.
      [x] 1.1.2.3 Subtask - Define behavior when span data is unavailable.

  [x] 1.2 Section - First-Slice Typed Nodes
    Define typed normalized nodes for constructs required by initial extraction.

    [x] 1.2.1 Task - Define structural syntax nodes
      Add node types for Python source organization.

      [x] 1.2.1.1 Subtask - Define module, import, alias, class, function, method candidate, and parameter nodes.
      [x] 1.2.1.2 Subtask - Define decorator, annotation, base-class, and docstring nodes.
      [x] 1.2.1.3 Subtask - Define assignment and source-location carrier nodes.

    [x] 1.2.2 Task - Define expression syntax nodes
      Add node types for minimal expression analysis.

      [x] 1.2.2.1 Subtask - Define call, attribute, subscript, literal, and identifier nodes.
      [x] 1.2.2.2 Subtask - Define control-flow and comprehension preservation nodes.
      [x] 1.2.2.3 Subtask - Define generic node type for unsupported syntax.

  [x] 1.3 Section - Phase 1 Integration Tests
    Prove syntax structs compile and can represent first-slice fixture shapes.

    [x] 1.3.1 Task - Run syntax struct checks
      Validate construction, defaults, and required field behavior.

      [x] 1.3.1.1 Subtask - Add tests for shared node and span construction.
      [x] 1.3.1.2 Subtask - Add tests for representative typed node construction.
      [x] 1.3.1.3 Subtask - Run `mix format --check-formatted`, focused syntax struct tests, full `mix test`, and `mix spec.check`.
