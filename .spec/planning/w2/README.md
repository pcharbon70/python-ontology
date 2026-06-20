# W2 - Normalized Syntax Model

This wave implements the stable Elixir syntax model that sits between Tree-sitter parser output and semantic extractors. It prevents extractors from depending on parser binding internals while preserving CST provenance and source spans.

## Phase Order

1. [Phase 1 - Core Syntax Structs and Shared Fields](./phase-01-core-syntax-structs-and-shared-fields.md)
2. [Phase 2 - Tree-sitter To Syntax Mapping](./phase-02-tree-sitter-to-syntax-mapping.md)
3. [Phase 3 - Unknown Nodes, Diagnostics, and Normalization Acceptance](./phase-03-unknown-nodes-diagnostics-and-normalization-acceptance.md)

## Implementation Sequence

Start by defining shared structs and typed first-slice nodes. Then map Tree-sitter output into those nodes. Finish by preserving unsupported/error nodes and proving determinism with fixtures from W1.

## Parallel Work Lanes

- W2 depends on W1 parser fixture output.
- W3 and W4 can begin once W2 defines source identity, evidence, and span shapes.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.normalized_syntax_model.md`
- `.spec/specs/normalized_syntax_model.spec.md`
