---
id: python_ontology.decision.initial_python_ontology_architecture
status: accepted
date: 2026-06-20
affects:
  - package.python_ontology
---

# Initial Python Ontology Architecture

## Context

PythonOntology exists to create an ontology and analyzer for Python project source code, similar in purpose to `elixir-ontologies`: transform source code into semantic RDF knowledge graphs that can support analysis, validation, querying, and LLM-oriented code understanding.

The project should reuse the successful shape of the Elixir system where that shape is language-neutral: parser, normalized AST model, extractors, RDF builders, SHACL validation, ontology files, and command-line analysis workflows.

Python is not Elixir. Its syntax, runtime model, type system, module/package system, object model, decorators, metaclasses, dynamic imports, monkey patching, and gradual typing ecosystem require Python-native ontology content and parser behavior. Treating the Elixir ontology as a direct port would encode the wrong language semantics.

## Decision

Build PythonOntology as a Python-native source ontology and analyzer implemented as an Elixir Mix project.

Use this broad architecture until more focused subject specs replace it:

- Model the pipeline as `Python source -> Tree-sitter parser adapter -> normalized Python syntax structs -> extractors -> RDF builders -> SHACL validation -> serialized knowledge graph`.
- Use `elixir-ontologies` as an architectural precedent, not as a direct ontology template.
- Start with Tree-sitter's Python grammar through an Elixir-owned adapter so parsing does not require an external Python runtime or executing analyzed project code.
- Treat CPython `ast`, LibCST, or Pythonx as optional future comparison or compatibility adapters only when a use case explicitly accepts their Python runtime dependency.
- Split ontology files into Python-native layers:
  - `python-core.ttl` for source files, locations, AST nodes, expressions, statements, literals, scopes, bindings, imports, calls, assignments, attributes, subscripts, control flow, and comprehensions.
  - `python-structure.ttl` for modules, packages, classes, functions, methods, decorators, dataclasses, properties, protocols, metaclasses, parameters, defaults, docstrings, and naming conventions.
  - `python-typing.ttl` for annotations, generics, unions, `typing` constructs, `Protocol`, `TypedDict`, `Literal`, `Callable`, `ParamSpec`, and type variables.
  - `python-runtime.ttl` for async, await, generators, context managers, exceptions, dynamic import boundaries, and runtime-dependent behavior.
  - `python-evolution.ttl` for git provenance, commits, file history, versioned entities, and semantic change tracking.
  - `python-shapes.ttl` for SHACL constraints over generated Python code graphs.
- Distinguish facts directly declared in source, statically inferred facts, unresolved dynamic facts, and facts that would require runtime execution.
- Avoid executing analyzed Python project code during normal static analysis.
- Begin implementation with a narrow useful slice: modules, imports, classes, functions, arguments, decorators, annotations, calls, source locations, RDF serialization, and a Mix analysis task.
- Refine each major layer and pipeline component into its own `.spec/specs/*.spec.md` subject before or alongside implementation.

## Consequences

The first version can move quickly by delegating grammar maintenance to Tree-sitter while keeping parser orchestration, normalization, ontology construction, and project tooling in Elixir.

The ontology will be broader than the initial implementation. Specs for parser bridging, normalized AST structs, ontology layers, extractors, builders, validation, and CLI workflows should be split out as the work begins.

Dynamic Python behavior must be represented honestly as dynamic or unresolved unless the analyzer has deterministic static evidence. Framework-specific semantics such as Django, FastAPI, SQLAlchemy, and Pydantic should be added later as extension subjects instead of being baked into the core ontology.

<!-- covers: package.python_ontology.product_direction -->
