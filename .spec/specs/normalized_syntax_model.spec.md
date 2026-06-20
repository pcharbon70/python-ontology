# Normalized Syntax Model

Current contract for the stable Elixir syntax model produced after Tree-sitter parsing and before extraction.

```spec-meta
id: python_ontology.normalized_syntax_model
kind: component
status: active
summary: Stable normalized Elixir representation of parsed Python syntax.
surface:
  - .spec/decisions/python_ontology.decision.normalized_syntax_model.md
  - lib/python_ontology/syntax*.ex
  - lib/python_ontology/syntax/*.ex
  - test/python_ontology/syntax*_test.exs
  - test/python_ontology/syntax/**/*_test.exs
decisions:
  - python_ontology.decision.parser_bridge_boundary
  - python_ontology.decision.normalized_syntax_model
```

## Requirements

```spec-requirements
- id: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
  statement: Raw Tree-sitter nodes shall not be the stable internal model consumed by extractors.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.elixir_struct_boundary
  statement: Parser output consumed by extractors shall be represented as stable Elixir structs or maps.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.raw_cst_provenance
  statement: Normalized nodes shall retain raw Tree-sitter provenance including node type, named status, child order, and field names when available.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.typed_core_nodes
  statement: The normalized model shall provide typed nodes for modules, imports, classes, functions, parameters, decorators, annotations, assignments, calls, attributes, subscripts, literals, identifiers, control flow, and comprehensions.
  priority: must
  stability: evolving

- id: python_ontology.normalized_syntax_model.unknown_node_preservation
  statement: Unknown or unsupported parser nodes shall be preserved as generic normalized nodes instead of being silently discarded.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.deterministic_normalization
  statement: Normalization shall produce deterministic output for the same source text, parser version, and options.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.no_code_execution
  statement: Normalization shall not import or execute analyzed Python project code.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.no_rdf_generation
  statement: Normalization shall not emit RDF triples directly.
  priority: must
  stability: stable

- id: python_ontology.normalized_syntax_model.source_span_preservation
  statement: Normalized nodes shall preserve source file identity and available byte, line, and column spans.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.normalized_syntax_model.known_node_flow
  given:
    - Tree-sitter returns a Python function definition node
  when:
    - the normalization layer processes the parse tree
  then:
    - the output contains a typed function node with parser provenance and source spans
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.source_span_preservation

- id: python_ontology.normalized_syntax_model.unknown_node_flow
  given:
    - Tree-sitter returns a node not yet understood by PythonOntology
  when:
    - the normalization layer processes the parse tree
  then:
    - the output keeps the node as a generic normalized node with its raw type and children
  covers:
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.raw_cst_provenance
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.normalized_syntax_model.md
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: lib/python_ontology/syntax/source.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/provenance.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/node_id.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/node_info.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/span.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/byte_span.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/point.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/point_span.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax/nodes.ex
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: lib/python_ontology/syntax.ex
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: lib/python_ontology/syntax/normalizer.ex
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: lib/python_ontology/syntax/traversal.ex
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/shared_fields_test.exs
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation

- kind: source_file
  target: test/python_ontology/syntax/structural_mapping_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/expression_mapping_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/normalization_integration_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/unknown_preservation_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/traversal_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/normalization_acceptance_test.exs
  covers:
    - python_ontology.normalized_syntax_model.tree_sitter_not_internal_model
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.raw_cst_provenance
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.deterministic_normalization
    - python_ontology.normalized_syntax_model.no_code_execution
    - python_ontology.normalized_syntax_model.no_rdf_generation
    - python_ontology.normalized_syntax_model.source_span_preservation

- kind: source_file
  target: test/python_ontology/syntax/typed_nodes_test.exs
  covers:
    - python_ontology.normalized_syntax_model.elixir_struct_boundary
    - python_ontology.normalized_syntax_model.typed_core_nodes
    - python_ontology.normalized_syntax_model.unknown_node_preservation
    - python_ontology.normalized_syntax_model.source_span_preservation
    - python_ontology.normalized_syntax_model.no_rdf_generation
```
