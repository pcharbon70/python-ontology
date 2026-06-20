# Wave 1 Adapter Evaluation

Implementation notes for W1 section 1.1, Candidate Binding Evaluation.

<!-- covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.adapter_boundary python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract -->

## Selected Adapter

PythonOntology will use a project-owned Rustler NIF as the initial Tree-sitter adapter.

This path wraps the Rust `tree-sitter` and `tree-sitter-python` crates directly and exposes only normalized Elixir maps from the project-local parser boundary.

The selected NIF exposes the APIs needed for W1:

- Python grammar loading through `tree-sitter-python`
- parsing of UTF-8 source strings
- root-node and recursive child-node data
- node kind, byte offsets, row/column points, child counts, and named child counts
- cursor traversal with child order and field-name reporting
- error, missing, extra, and descendant error checks
- adapter, grammar, grammar ABI, and Tree-sitter language compatibility metadata

This satisfies the first implementation slice without introducing external Python, embedded CPython, Pythonx, or project-code imports.

## Candidate Summary

| Candidate | Result | Notes |
| --- | --- | --- |
| Project-owned Rustler NIF | Selected | Directly wraps `tree-sitter` and `tree-sitter-python`, exposes concrete syntax tree maps, and keeps all parser details behind PythonOntology modules. |
| `tree_sitter_language_pack` | Not selected | Its high-level `process/2` API works for Python, but version 1.9.1 has stubbed raw parser functions (`parser_set_language`, `parser_parse`, and `parser_parse_bytes`), so it cannot satisfy the concrete syntax tree boundary. |
| `ex_tree_sitter` | Not selected | Low-level binding, but does not package Python grammar access for this project. It would require project-owned grammar build and asset handling earlier than needed. |
| `elixir_tree_sitter` | Not selected | Development-version package. It appears oriented around converting native parser trees to Elixir data after building grammar assets separately. |
| `tree_sitter` | Not selected | Provides Mix tasks for installing/invoking Tree-sitter rather than the runtime parser boundary required by PythonOntology. |
| `lumis` | Not selected | Syntax-highlighting package built on Tree-sitter. It is too high level for PythonOntology's parser contract. |

## Capability Notes

- Named nodes: represented by the `named` boolean and `named_child_count` value.
- Field names: captured while traversing children with `TreeCursor.field_name`.
- Child order: preserved by recursively traversing each node's children in parser order.
- Byte spans: represented as `start_byte` and `end_byte`.
- Point spans: represented as `start_point` and `end_point` maps with zero-based `row` and `column`.
- Error nodes: represented by `error`, `missing`, `extra`, and `has_error` booleans.
- Parser version reporting: represented by adapter metadata, grammar name, grammar ABI version, Tree-sitter language compatibility range, and Python grammar crate version.

## Fallback Options

If the project-owned Rustler NIF cannot satisfy a later parser requirement, the fallback is a narrower Rust NIF surface over additional Tree-sitter APIs, still behind the same project-local adapter behavior so extractor and normalization code do not change.
