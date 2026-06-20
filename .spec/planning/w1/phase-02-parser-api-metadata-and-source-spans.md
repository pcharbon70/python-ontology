# Phase 2 - Parser API, Metadata, and Source Spans

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.parser_bridge_boundary.md`
- `.spec/specs/parser.spec.md`
- `lib/python_ontology/parser*.ex`
- `lib/python_ontology/parser/*.ex`
- `test/python_ontology/parser*_test.exs`

## Relevant Assumptions / Defaults

- The adapter dependency from Phase 1 is available.
- Parser APIs return tagged results instead of raising for parse errors.
- Source identity and spans must be preserved before normalization.

[x] 2 Phase 2 - Parser API, Metadata, and Source Spans
  Expose the Elixir parser API that callers and normalization will use.

  [x] 2.1 Section - Parser Entry Points
    Define source-string and file-based parsing functions.

    [x] 2.1.1 Task - Implement source parsing
      Parse Python source text with explicit source identity.

      [x] 2.1.1.1 Subtask - Add `parse_string/2` or equivalent with source text, source identity, and options.
      [x] 2.1.1.2 Subtask - Return parser result structs or maps with root node, metadata, and diagnostics.
      [x] 2.1.1.3 Subtask - Ensure parsing does not import or execute analyzed Python code.

    [x] 2.1.2 Task - Implement file parsing
      Parse Python source files while separating file-read failures from parser failures.

      [x] 2.1.2.1 Subtask - Add `parse_file/2` or equivalent.
      [x] 2.1.2.2 Subtask - Return structured file-read diagnostics for missing or unreadable files.
      [x] 2.1.2.3 Subtask - Preserve normalized file path identity in parser results.

  [x] 2.2 Section - Metadata And Spans
    Preserve parser metadata and location data for every downstream stage.

    [x] 2.2.1 Task - Capture parser metadata
      Make adapter and grammar information available when exposed by the binding.

      [x] 2.2.1.1 Subtask - Capture adapter module/name and selected options.
      [x] 2.2.1.2 Subtask - Capture Tree-sitter library version when available.
      [x] 2.2.1.3 Subtask - Capture Python grammar version or grammar identifier when available.

    [x] 2.2.2 Task - Capture source spans
      Expose location data for root and child nodes.

      [x] 2.2.2.1 Subtask - Extract byte start/end offsets for representative nodes.
      [x] 2.2.2.2 Subtask - Extract row/column start/end positions for representative nodes.
      [x] 2.2.2.3 Subtask - Preserve child order and field names when available.

  [x] 2.3 Section - Phase 2 Integration Tests
    Validate parser API behavior and span preservation against representative source.

    [x] 2.3.1 Task - Run parser API checks
      Prove source parsing and file parsing produce deterministic metadata and spans.

      [x] 2.3.1.1 Subtask - Add tests for `parse_string/2` with imports, class, function, and call syntax.
      [x] 2.3.1.2 Subtask - Add tests for `parse_file/2` success and file-read diagnostics.
      [x] 2.3.1.3 Subtask - Run focused parser API tests, full `mix test`, and `mix spec.check`.
