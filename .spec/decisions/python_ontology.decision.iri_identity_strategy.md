---
id: python_ontology.decision.iri_identity_strategy
status: accepted
date: 2026-06-20
affects:
  - python_ontology.iri_identity_strategy
  - python_ontology.ontology_turtle_files
---

# IRI Identity Strategy

## Context

PythonOntology will generate RDF resources for source files, packages, modules, classes, functions, imports, expressions, and source locations. Those resources need deterministic IRIs so analysis output can be compared across runs and updated incrementally.

Python differs from Elixir in important ways: functions are not identified by arity, nested functions and classes are common, names can be rebound, class bodies execute at runtime, and dynamic imports or monkey patching can affect runtime identity. The IRI strategy must model source identity, not runtime object identity.

## Decision

Keep ontology namespace IRIs separate from analyzed-code resource IRIs.

Ontology vocabulary remains rooted at `https://w3id.org/python-code/{layer}#`. Generated resources for analyzed code shall use a configurable base IRI, defaulting to a project-scoped base chosen by the analyzer.

Use deterministic source identities:

- source files are identified by normalized repository-relative POSIX paths
- modules are identified by package/module dotted names plus source file path when needed
- packages are identified by discovered package roots and package names
- classes are identified by module identity plus lexical qualified name
- functions and methods are identified by module/class lexical path plus function name, not arity
- nested functions and nested classes include their lexical parent path
- repeated definitions or ambiguous rebinding sites are disambiguated by occurrence index and source span
- expressions, calls, imports, assignments, and source locations are identified by containing entity plus source span

All generated IRI path segments shall be canonicalized and escaped consistently. Hashes may be used for long or unsafe fragments, but the hash input must be canonical and documented.

The strategy shall not claim runtime object identity unless a later runtime-specific analyzer has evidence for it.

## Consequences

Generated graphs can be compared across runs when source paths and spans are stable.

Renaming, moving, or reformatting source can intentionally change some resource IRIs. Evolution analysis can later relate old and new resources through change tracking rather than forcing unstable runtime-style identity.

Builders need a shared IRI helper rather than each builder inventing local string construction.

<!-- covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.module_package_identity python_ontology.iri_identity_strategy.class_function_identity python_ontology.iri_identity_strategy.nested_scope_identity python_ontology.iri_identity_strategy.occurrence_disambiguation python_ontology.iri_identity_strategy.expression_span_identity python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper -->
