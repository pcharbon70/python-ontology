---
id: python_ontology.decision.parser_bridge_boundary
status: accepted
date: 2026-06-20
affects:
  - package.python_ontology
  - python_ontology.parser
---

# Tree-sitter Parser Boundary

## Context

PythonOntology needs a parser layer that turns Python project source files into deterministic Elixir data suitable for extractors and RDF builders.

The parser must understand Python syntax and source locations accurately without requiring PythonOntology to run an external Python interpreter. This project is an Elixir project; parser orchestration, normalization, and downstream analysis should stay in Elixir.

Tree-sitter was reviewed as the parser foundation. Tree-sitter is a parser generator and incremental parsing library that builds concrete syntax trees for source files, and `tree-sitter-python` provides the Python grammar. Elixir access can come through Tree-sitter bindings such as `ex_tree_sitter`, `elixir_tree_sitter`, `tree_sitter_language_pack`, or a project-owned NIF if those bindings are insufficient. Sources: https://tree-sitter.github.io/, https://github.com/tree-sitter/tree-sitter-python, https://hex.pm/packages/ex_tree_sitter, https://hexdocs.pm/elixir_tree_sitter/

Pythonx HexDocs were also reviewed before this decision. Pythonx embeds a Python interpreter in the same OS process as the Elixir application, supports `Pythonx.eval/3`, `Pythonx.decode/1`, and `Pythonx.uv_init/2`, and can install Python plus dependencies through `uv`. Its documentation warns that the embedded interpreter runs under Python's GIL and that calling Pythonx from multiple Elixir processes does not provide expected concurrency. Source: https://hexdocs.pm/pythonx/Pythonx.html

No current HexDocs package named `pythonex` or `python_ex` was found during the package/documentation search.

The parser is expected to analyze arbitrary third-party Python projects. Running analyzed project code during parsing would be unsafe and would blur the line between source-declared facts and runtime-dependent facts.

## Decision

Use Tree-sitter's Python grammar as the default parser engine.

The default parser adapter shall be Elixir-owned. It may call an existing Tree-sitter Elixir binding or a project-owned NIF, but it shall not depend on an external Python process, embedded CPython, Pythonx, or analyzed project imports.

The parser shall parse source text without importing or executing the analyzed project.

The parser output shall preserve:

- source file identity
- Tree-sitter grammar or parser version information when available
- parse success, error nodes, or structured parse failures
- concrete syntax tree structure
- node type names
- byte and row/column source spans where Tree-sitter exposes them
- a normalized Elixir representation suitable for extractor structs

Pythonx is not the default parser bridge because the project does not need CPython to parse Python source and should avoid embedded interpreter and GIL constraints for project-wide analysis. CPython `ast`, LibCST, or Pythonx may be added later only as optional comparison or compatibility adapters, and they must conform to the same parser adapter and normalization contracts.

The parser layer shall not encode ontology triples directly. It produces normalized syntax data; extractors and builders remain responsible for semantic modeling and RDF generation.

## Consequences

The parser remains part of the Elixir project while relying on a maintained Python grammar instead of building a full Python grammar by hand.

Tree-sitter returns concrete syntax trees, not CPython ASTs. The project must own a normalization layer that converts Tree-sitter node shapes into stable Elixir structs for extractors.

Tree-sitter is tolerant and can return error nodes for invalid or incomplete syntax. The parser contract should preserve those errors instead of collapsing them into unclassified failures.

Future specs should split this broad parser contract into Tree-sitter adapter selection, parser protocol, normalized syntax structs, error model, source span handling, and parser tests.

If Pythonx, CPython `ast`, or LibCST is adopted later, it should be introduced by a separate ADR or a revision to this one that explains why a Python runtime dependency is appropriate for that use case.

<!-- covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.normalized_output python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.python_runtime_optional_adapter python_ontology.parser.no_direct_rdf_output -->
