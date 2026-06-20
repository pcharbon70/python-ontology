# Parser

Current parser contract for turning Python source files into normalized data for PythonOntology extractors and builders.

```spec-meta
id: python_ontology.parser
kind: component
status: active
summary: Tree-sitter parser boundary from Python source text to normalized Elixir data.
surface:
  - .spec/decisions/python_ontology.decision.parser_bridge_boundary.md
  - lib/python_ontology/parser*.ex
  - lib/python_ontology/parser/*.ex
  - native/**/*
  - priv/tree_sitter/*
  - test/python_ontology/parser*_test.exs
  - test/python_ontology/parser/**/*_test.exs
decisions:
  - python_ontology.decision.initial_python_ontology_architecture
  - python_ontology.decision.parser_bridge_boundary
```

## Requirements

```spec-requirements
- id: python_ontology.parser.tree_sitter_python_authority
  statement: The first parser implementation shall use Tree-sitter's Python grammar as the syntax authority.
  priority: must
  stability: stable

- id: python_ontology.parser.elixir_owned_adapter
  statement: The default parser adapter shall be owned by the Elixir project through a Tree-sitter binding or project-owned NIF.
  priority: must
  stability: stable

- id: python_ontology.parser.no_python_runtime_dependency
  statement: The default parser path shall not require an external Python process, embedded CPython, Pythonx, or analyzed project imports.
  priority: must
  stability: stable

- id: python_ontology.parser.no_project_code_execution
  statement: The parser shall parse Python source without importing or executing the analyzed project code.
  priority: must
  stability: stable

- id: python_ontology.parser.adapter_boundary
  statement: Parser implementations shall conform to an explicit adapter boundary so alternate adapters can be introduced without changing extractors.
  priority: must
  stability: stable

- id: python_ontology.parser.normalized_output
  statement: Parser output shall be normalized into Elixir data structures before extractor logic consumes it.
  priority: must
  stability: stable

- id: python_ontology.parser.concrete_syntax_tree_output
  statement: Parser output shall preserve Tree-sitter concrete syntax tree structure and node type names before semantic extraction.
  priority: must
  stability: stable

- id: python_ontology.parser.source_locations
  statement: Parser output shall preserve source file identity and available line and column span information.
  priority: must
  stability: stable

- id: python_ontology.parser.error_contract
  statement: Parser failures and Tree-sitter error nodes shall be represented as structured parse errors instead of unclassified runtime failures.
  priority: must
  stability: stable

- id: python_ontology.parser.parser_version_reporting
  statement: Parser output shall report Tree-sitter grammar or parser version information when available.
  priority: should
  stability: evolving

- id: python_ontology.parser.python_runtime_optional_adapter
  statement: CPython ast, LibCST, or Pythonx may be introduced only as optional parser adapters that conform to the same parser contract and are not the default bridge.
  priority: should
  stability: evolving

- id: python_ontology.parser.no_direct_rdf_output
  statement: The parser layer shall not emit RDF triples directly; RDF generation belongs to extractors and builders.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.parser.syntax_success_flow
  given:
    - a Python source file can be parsed by Tree-sitter's Python grammar
  when:
    - the default parser adapter analyzes the file
  then:
    - Elixir receives a successful normalized parse payload with source identity, parser version data when available, and Tree-sitter node data
  covers:
    - python_ontology.parser.tree_sitter_python_authority
    - python_ontology.parser.elixir_owned_adapter
    - python_ontology.parser.no_python_runtime_dependency
    - python_ontology.parser.normalized_output
    - python_ontology.parser.concrete_syntax_tree_output
    - python_ontology.parser.source_locations
    - python_ontology.parser.parser_version_reporting

- id: python_ontology.parser.syntax_error_flow
  given:
    - a Python source file contains invalid syntax
  when:
    - the default parser adapter analyzes the file
  then:
    - Elixir receives structured Tree-sitter error information with location information when available
  covers:
    - python_ontology.parser.error_contract
    - python_ontology.parser.source_locations

- id: python_ontology.parser.no_execution_flow
  given:
    - a Python source file contains imports or top-level code with side effects
  when:
    - the parser analyzes the file
  then:
    - the parser reads syntax through Tree-sitter without importing or executing the analyzed project code
  covers:
    - python_ontology.parser.no_project_code_execution
    - python_ontology.parser.no_python_runtime_dependency
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.parser_bridge_boundary.md
  covers:
    - python_ontology.parser.tree_sitter_python_authority
    - python_ontology.parser.elixir_owned_adapter
    - python_ontology.parser.no_python_runtime_dependency
    - python_ontology.parser.no_project_code_execution
    - python_ontology.parser.adapter_boundary
    - python_ontology.parser.normalized_output
    - python_ontology.parser.concrete_syntax_tree_output
    - python_ontology.parser.source_locations
    - python_ontology.parser.error_contract
    - python_ontology.parser.parser_version_reporting
    - python_ontology.parser.python_runtime_optional_adapter
    - python_ontology.parser.no_direct_rdf_output

- kind: source_file
  target: lib/python_ontology/parser/native.ex
  covers:
    - python_ontology.parser.elixir_owned_adapter
    - python_ontology.parser.adapter_boundary
    - python_ontology.parser.no_python_runtime_dependency

- kind: source_file
  target: native/python_ontology_parser/src/lib.rs
  covers:
    - python_ontology.parser.tree_sitter_python_authority
    - python_ontology.parser.elixir_owned_adapter
    - python_ontology.parser.no_python_runtime_dependency
    - python_ontology.parser.no_project_code_execution
    - python_ontology.parser.concrete_syntax_tree_output
    - python_ontology.parser.source_locations
    - python_ontology.parser.error_contract
    - python_ontology.parser.parser_version_reporting
    - python_ontology.parser.no_direct_rdf_output

- kind: source_file
  target: native/python_ontology_parser/Cargo.toml
  covers:
    - python_ontology.parser.tree_sitter_python_authority
    - python_ontology.parser.elixir_owned_adapter
    - python_ontology.parser.no_python_runtime_dependency
```
