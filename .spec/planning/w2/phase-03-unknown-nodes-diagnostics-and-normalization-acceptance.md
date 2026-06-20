# Phase 3 - Unknown Nodes, Diagnostics, and Normalization Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.normalized_syntax_model.md`
- `.spec/specs/normalized_syntax_model.spec.md`
- `lib/python_ontology/syntax/*.ex`
- `test/python_ontology/syntax*_test.exs`

## Relevant Assumptions / Defaults

- Unsupported syntax remains visible as generic normalized nodes.
- Parser error nodes are preserved as diagnostics and partial syntax when possible.
- Normalization does not emit RDF.

[ ] 3 Phase 3 - Unknown Nodes, Diagnostics, and Normalization Acceptance
  Complete normalization behavior for unsupported syntax, parser errors, and local acceptance.

  [x] 3.1 Section - Unknown Node Preservation
    Ensure unsupported Tree-sitter nodes are not silently lost.

    [x] 3.1.1 Task - Implement generic normalized nodes
      Preserve raw node data for unsupported syntax.

      [x] 3.1.1.1 Subtask - Store raw node type, field name, named status, spans, and children.
      [x] 3.1.1.2 Subtask - Preserve relative order among known and generic child nodes.
      [x] 3.1.1.3 Subtask - Add diagnostics only when unsupported syntax affects required first-slice extraction.

    [x] 3.1.2 Task - Preserve parser diagnostics
      Carry Tree-sitter errors through normalization.

      [x] 3.1.2.1 Subtask - Attach parser diagnostics to normalized root nodes.
      [x] 3.1.2.2 Subtask - Preserve partial syntax trees for invalid source when available.
      [x] 3.1.2.3 Subtask - Keep parser diagnostics separate from future extractor diagnostics.

  [ ] 3.2 Section - Normalization Contract Cleanup
    Make the normalized model ready for extractors.

    [ ] 3.2.1 Task - Review extractor-facing API shape
      Ensure extractors can traverse syntax without parser binding knowledge.

      [ ] 3.2.1.1 Subtask - Add traversal helpers for children, descendants, and source text slices when needed.
      [ ] 3.2.1.2 Subtask - Hide raw Tree-sitter cursor APIs from extractor modules.
      [ ] 3.2.1.3 Subtask - Document which normalized node types are stable for W6 extractors.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Prove normalization acceptance before extractor implementation begins.

    [ ] 3.3.1 Task - Run normalization acceptance
      Validate known, unknown, and error-node behavior against parser fixtures.

      [ ] 3.3.1.1 Subtask - Add tests that unsupported nodes are preserved as generic nodes.
      [ ] 3.3.1.2 Subtask - Add tests that invalid syntax preserves diagnostics and partial trees.
      [ ] 3.3.1.3 Subtask - Run focused normalization tests, full `mix test`, and `mix spec.check`.
