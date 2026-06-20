# Phase 2 - Tree-sitter To Syntax Mapping

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.normalized_syntax_model.md`
- `.spec/specs/normalized_syntax_model.spec.md`
- `lib/python_ontology/parser*.ex`
- `lib/python_ontology/syntax/*.ex`
- `test/fixtures/python_parser/*`

## Relevant Assumptions / Defaults

- Parser fixtures from W1 provide representative Tree-sitter output.
- Normalization is deterministic for the same source and parser version.
- Mapping preserves child order and field names when available.

[ ] 2 Phase 2 - Tree-sitter To Syntax Mapping
  Convert Tree-sitter parse output into normalized syntax nodes.

  [x] 2.1 Section - Structural Mapping
    Map Python source organization constructs into typed syntax nodes.

    [x] 2.1.1 Task - Map module and import syntax
      Normalize root modules and import statements.

      [x] 2.1.1.1 Subtask - Map module root and top-level statement order.
      [x] 2.1.1.2 Subtask - Map `import` statements with aliases.
      [x] 2.1.1.3 Subtask - Map `from ... import ...` statements with relative import level when available.

    [x] 2.1.2 Task - Map class and function syntax
      Normalize declarations and their child syntax.

      [x] 2.1.2.1 Subtask - Map class names, base class syntax, decorators, and body children.
      [x] 2.1.2.2 Subtask - Map function names, decorators, parameters, annotations, defaults, and body children.
      [x] 2.1.2.3 Subtask - Map async function syntax as a function variant or marker.

  [ ] 2.2 Section - Expression Mapping
    Map first-slice expression constructs into normalized syntax.

    [ ] 2.2.1 Task - Map call and access syntax
      Normalize expression nodes needed by initial call extraction.

      [ ] 2.2.1.1 Subtask - Map call expressions and argument lists.
      [ ] 2.2.1.2 Subtask - Map attribute access chains.
      [ ] 2.2.1.3 Subtask - Map subscript expressions.

    [ ] 2.2.2 Task - Map literals and identifiers
      Preserve basic expression leaves.

      [ ] 2.2.2.1 Subtask - Map identifiers and dotted names.
      [ ] 2.2.2.2 Subtask - Map string, numeric, boolean, `None`, list, tuple, dict, and set literals.
      [ ] 2.2.2.3 Subtask - Preserve raw text where needed for annotations and decorator expressions.

  [ ] 2.3 Section - Phase 2 Integration Tests
    Prove representative Python fixtures normalize into stable typed nodes.

    [ ] 2.3.1 Task - Run mapping checks
      Validate mapping for all first-slice structural and expression constructs.

      [ ] 2.3.1.1 Subtask - Add fixture tests for imports, classes, functions, decorators, annotations, parameters, calls, attributes, and literals.
      [ ] 2.3.1.2 Subtask - Add determinism tests for repeated normalization of the same parser result.
      [ ] 2.3.1.3 Subtask - Run focused mapping tests, full `mix test`, and `mix spec.check`.
