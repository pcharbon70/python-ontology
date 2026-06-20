---
id: python_ontology.decision.ontology_turtle_file_layers
status: accepted
date: 2026-06-20
affects:
  - package.python_ontology
  - python_ontology.ontology_turtle_files
---

# Ontology Turtle File Layers

## Context

PythonOntology needs durable OWL/RDF vocabulary files before parser, extractor, and builder work can converge on stable output.

The sibling `elixir-ontologies` project uses layered Turtle files for core syntax, language structure, OTP/runtime concepts, evolution, and SHACL shapes. Python needs the same architectural separation, but not the same language concepts. Python has modules and packages instead of Elixir modules, classes and metaclasses instead of protocols/behaviours, decorators, gradual typing, async constructs, generators, context managers, dynamic imports, and source-level constructs whose meaning may depend on runtime execution.

If all Python concepts are placed in one ontology file, early implementation will be simpler but later evolution will be harder. If the layers are too fine-grained, the first builder work will spend more time on ontology plumbing than useful source-code facts.

## Decision

Keep the Python ontology Turtle files in `priv/ontologies/` as a small, explicit layer set:

- `python-core.ttl` for language-neutral source artifacts and Python AST-level constructs: source files, locations, statements, expressions, literals, scopes, imports, bindings, calls, assignments, control flow, comprehensions, and fact confidence boundaries.
- `python-structure.ttl` for Python code organization: packages, modules, classes, functions, methods, decorators, parameters, docstrings, properties, dataclasses, metaclasses, and protocol-like class contracts.
- `python-typing.ttl` for gradual typing and annotation constructs: annotations, generics, unions, type variables, parameter specs, `TypedDict`, `Protocol`, `Literal`, and callable types.
- `python-runtime.ttl` for source-visible runtime patterns and uncertainty boundaries: async, await, generators, context managers, exceptions, dynamic imports, monkey-patching boundaries, and runtime-dependent behavior.
- `python-evolution.ttl` for provenance and code history: repositories, commits, snapshots, versioned entities, changesets, and development activities.
- `python-shapes.ttl` for SHACL validation rules over the generated Python knowledge graph.

Use stable namespace IRIs rooted at `https://w3id.org/python-code/`, with one namespace per ontology layer.

Use explicit import direction:

- core imports no PythonOntology layer
- structure imports core
- typing imports structure
- runtime imports structure
- evolution imports structure and PROV-O
- shapes references all layers for validation

Keep Python-specific semantics in PythonOntology. The Elixir ontology remains architectural precedent only.

Represent Python dynamic behavior explicitly. Source-declared facts, statically inferred facts, unresolved facts, and runtime-dependent facts must remain distinguishable in the ontology.

## Consequences

Parser and builder work can target stable ontology modules from the start.

Early Turtle files may contain only bootstrap classes and properties, but they must remain parseable RDF/Turtle and carry enough metadata to define their layer boundary.

Later subject specs should refine each layer independently. Framework-specific vocabularies such as Django, FastAPI, SQLAlchemy, and Pydantic should be added as extension ontologies or separate subjects instead of expanding the core layer prematurely.

<!-- covers: python_ontology.ontology_turtle_files.layered_files python_ontology.ontology_turtle_files.namespace_stability python_ontology.ontology_turtle_files.import_direction python_ontology.ontology_turtle_files.dynamic_fact_boundary -->
