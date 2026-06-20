# IRI Identity Strategy

Current contract for stable identity and IRI generation in PythonOntology RDF output.

```spec-meta
id: python_ontology.iri_identity_strategy
kind: component
status: active
summary: Deterministic IRI strategy for analyzed Python code resources.
surface:
  - .spec/decisions/python_ontology.decision.iri_identity_strategy.md
  - lib/python_ontology/iri*.ex
  - lib/python_ontology/builders/**/*.ex
  - test/python_ontology/iri*_test.exs
decisions:
  - python_ontology.decision.ontology_turtle_file_layers
  - python_ontology.decision.iri_identity_strategy
```

## Requirements

```spec-requirements
- id: python_ontology.iri_identity_strategy.namespace_resource_separation
  statement: Ontology vocabulary IRIs shall remain separate from generated analyzed-code resource IRIs.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.configurable_base_iri
  statement: Generated analyzed-code resource IRIs shall use a configurable base IRI.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.stable_path_normalization
  statement: Source file identities shall use normalized repository-relative POSIX paths.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.module_package_identity
  statement: Package and module identities shall be derived from discovered package roots, dotted names, and source file paths when needed.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.class_function_identity
  statement: Class, function, and method identities shall use lexical qualified names rather than runtime object identity or function arity.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.nested_scope_identity
  statement: Nested classes and nested functions shall include their lexical parent path in generated identities.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.occurrence_disambiguation
  statement: Ambiguous or repeated source definitions shall be disambiguated by occurrence index and source span.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.expression_span_identity
  statement: Expressions, calls, imports, assignments, and source locations shall be identified by containing entity and source span.
  priority: must
  stability: evolving

- id: python_ontology.iri_identity_strategy.hash_canonicalization
  statement: Hash-based IRI fragments shall use documented canonical inputs.
  priority: should
  stability: stable

- id: python_ontology.iri_identity_strategy.no_runtime_identity_claims
  statement: Static IRI generation shall not claim Python runtime object identity without runtime-specific evidence.
  priority: must
  stability: stable

- id: python_ontology.iri_identity_strategy.shared_iri_helper
  statement: Builders shall use a shared IRI helper instead of ad hoc string construction.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.iri_identity_strategy.function_identity_flow
  given:
    - a function named parse exists in package/module analyzer/parser.py
  when:
    - builders generate RDF resources for the function
  then:
    - the function IRI is derived from the configured base IRI, normalized path or module identity, and lexical function path
  covers:
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.class_function_identity

- id: python_ontology.iri_identity_strategy_redefinition_flow
  given:
    - a Python module defines the same class name twice
  when:
    - builders generate resources for both definitions
  then:
    - occurrence and source span data disambiguate the generated IRIs
  covers:
    - python_ontology.iri_identity_strategy.occurrence_disambiguation
    - python_ontology.iri_identity_strategy.no_runtime_identity_claims
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.iri_identity_strategy.md
  covers:
    - python_ontology.iri_identity_strategy.namespace_resource_separation
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.module_package_identity
    - python_ontology.iri_identity_strategy.class_function_identity
    - python_ontology.iri_identity_strategy.nested_scope_identity
    - python_ontology.iri_identity_strategy.occurrence_disambiguation
    - python_ontology.iri_identity_strategy.expression_span_identity
    - python_ontology.iri_identity_strategy.hash_canonicalization
    - python_ontology.iri_identity_strategy.no_runtime_identity_claims
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: lib/python_ontology/iri.ex
  covers:
    - python_ontology.iri_identity_strategy.namespace_resource_separation
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.no_runtime_identity_claims
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: lib/python_ontology/iri/context.ex
  covers:
    - python_ontology.iri_identity_strategy.namespace_resource_separation
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.no_runtime_identity_claims
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: lib/python_ontology/iri/diagnostic.ex
  covers:
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.hash_canonicalization
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: lib/python_ontology/iri/path.ex
  covers:
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: test/python_ontology/iri/base_iri_test.exs
  covers:
    - python_ontology.iri_identity_strategy.namespace_resource_separation
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.no_runtime_identity_claims
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: test/python_ontology/iri/path_test.exs
  covers:
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.shared_iri_helper

- kind: source_file
  target: test/python_ontology/iri/phase1_integration_test.exs
  covers:
    - python_ontology.iri_identity_strategy.namespace_resource_separation
    - python_ontology.iri_identity_strategy.configurable_base_iri
    - python_ontology.iri_identity_strategy.stable_path_normalization
    - python_ontology.iri_identity_strategy.shared_iri_helper
```
