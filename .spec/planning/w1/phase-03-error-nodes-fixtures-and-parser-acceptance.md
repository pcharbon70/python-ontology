# Phase 3 - Error Nodes, Fixtures, and Parser Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.parser_bridge_boundary.md`
- `.spec/specs/parser.spec.md`
- `lib/python_ontology/parser*.ex`
- `test/python_ontology/parser*_test.exs`
- `test/fixtures/python_parser/*`

## Relevant Assumptions / Defaults

- Tree-sitter can return tolerant parse output with error nodes.
- Parser failures and syntax errors are structured diagnostics.
- Parser acceptance should produce stable fixtures for the normalized syntax wave.

[ ] 3 Phase 3 - Error Nodes, Fixtures, and Parser Acceptance
  Prove parser behavior for valid source, invalid source, and reusable fixtures.

  [x] 3.1 Section - Error Node Handling
    Preserve invalid syntax information without unclassified failures.

    [x] 3.1.1 Task - Detect parser errors
      Surface Tree-sitter error state in parser results.

      [x] 3.1.1.1 Subtask - Detect root-level parse errors.
      [x] 3.1.1.2 Subtask - Detect nested `ERROR` nodes when the binding exposes them.
      [x] 3.1.1.3 Subtask - Detect missing nodes or incomplete constructs when the binding exposes them.

    [x] 3.1.2 Task - Return structured diagnostics
      Convert parser error information into stable Elixir diagnostics.

      [x] 3.1.2.1 Subtask - Include severity, message, raw node type, source file, and span fields.
      [x] 3.1.2.2 Subtask - Keep parser diagnostics separate from file-read and future extractor diagnostics.
      [x] 3.1.2.3 Subtask - Preserve partial parse trees when available.

  [ ] 3.2 Section - Parser Fixtures
    Create reusable parser fixtures that drive normalization and extractor work.

    [ ] 3.2.1 Task - Add valid syntax fixtures
      Cover representative Python constructs needed by the first analysis slice.

      [ ] 3.2.1.1 Subtask - Add fixtures for imports, aliases, classes, functions, decorators, annotations, parameters, calls, and attributes.
      [ ] 3.2.1.2 Subtask - Add fixtures for async, context managers, exceptions, and comprehensions as preservation cases.
      [ ] 3.2.1.3 Subtask - Add fixture assertions for stable root node and child node shapes.

    [ ] 3.2.2 Task - Add invalid syntax fixtures
      Cover parser error behavior needed by downstream diagnostics.

      [ ] 3.2.2.1 Subtask - Add fixtures for incomplete function, invalid indentation, and malformed expression syntax.
      [ ] 3.2.2.2 Subtask - Assert error diagnostics include source spans where available.
      [ ] 3.2.2.3 Subtask - Assert no Python runtime is invoked for invalid syntax.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Validate parser acceptance criteria before normalization work depends on parser output.

    [ ] 3.3.1 Task - Run parser acceptance
      Prove parser success, error handling, fixture coverage, and local gates.

      [ ] 3.3.1.1 Subtask - Run valid and invalid parser fixture tests.
      [ ] 3.3.1.2 Subtask - Run `mix format --check-formatted` and full `mix test`.
      [ ] 3.3.1.3 Subtask - Run `mix spec.check` and update parser specs only if implementation materially changes the contract.
