# Wave 1 Build Integration Notes

Implementation notes for W1 section 1.2, Dependency And Build Integration.

<!-- covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency -->

## Dependency

`rustler` `~> 0.38.0` is the selected Mix dependency for the project-owned parser NIF.

The native crate dependencies are:

- `rustler` 0.38.0
- `tree-sitter` 0.26.9
- `tree-sitter-python` 0.25.0

## Assets

The project-owned native crate lives under `native/python_ontology_parser`.

No `priv/tree_sitter/` grammar assets are required for the initial adapter because the Rust crate depends on the published `tree-sitter-python` grammar crate. Compiled NIF artifacts are generated under ignored build paths.

## Build Prerequisites

The local build succeeded with the system Rust toolchain:

- `rustc` 1.92.0
- `cargo` 1.92.0

Build environments need Rust, Cargo, and a C compiler toolchain because `tree-sitter-python` compiles C parser sources. Generated artifacts under `_build/`, `native/*/target/`, and `priv/native/` are ignored.
