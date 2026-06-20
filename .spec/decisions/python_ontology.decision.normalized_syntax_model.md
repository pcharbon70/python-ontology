---
id: python_ontology.decision.normalized_syntax_model
status: accepted
date: 2026-06-20
affects:
  - python_ontology.parser
  - python_ontology.normalized_syntax_model
---

# Normalized Syntax Model

## Context

Tree-sitter gives PythonOntology a maintained Python concrete syntax tree, but Tree-sitter node shapes are a parser output format, not the stable internal semantic boundary for ontology extraction.

Extractors need a predictable Elixir model that is independent of the specific Tree-sitter binding used by the parser adapter. Builders need source spans and original syntax provenance to create stable RDF resources later, but they should not have to understand raw parser cursor APIs.

## Decision

Introduce a normalized syntax model between the parser adapter and extractors.

The Tree-sitter adapter may expose raw parse nodes internally, but parser output consumed by extractors shall be normalized into Elixir structs or maps with stable fields.

The normalized model shall preserve raw parser provenance: original Tree-sitter node type, whether the node is named, source byte spans, row/column spans, child order, field names when available, and the source file identity.

The normalized model shall provide typed nodes for the first implementation slice: modules, imports, classes, functions, parameters, decorators, annotations, assignments, calls, attributes, subscripts, literals, identifiers, control-flow statements, and comprehensions.

Unknown or unsupported Tree-sitter nodes shall remain visible as generic normalized nodes rather than being dropped.

Normalization shall be deterministic and shall not execute analyzed project code.

Normalization shall not perform RDF generation or high-level ontology extraction. It only converts parser output into stable syntax data for later stages.

## Consequences

Parser binding changes should not force extractor rewrites as long as the normalized syntax contract remains stable.

The project must maintain a mapping layer from Tree-sitter Python node names and fields into PythonOntology syntax structs.

Some Python semantics will remain unresolved at normalization time. Those should be represented as syntax facts for extractors to interpret later rather than inferred too early.

<!-- covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation -->
