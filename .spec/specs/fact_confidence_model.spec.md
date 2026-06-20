# Fact Confidence Model

Current contract for representing certainty, evidence, and dynamic boundaries in extracted Python facts.

```spec-meta
id: python_ontology.fact_confidence_model
kind: policy
status: active
summary: Confidence categories for source-declared, inferred, unresolved, and runtime-dependent Python facts.
surface:
  - .spec/decisions/python_ontology.decision.fact_confidence_model.md
  - priv/ontologies/python-core.ttl
  - lib/python_ontology/extractors/**/*.ex
  - lib/python_ontology/builders/**/*.ex
  - test/python_ontology/**/*confidence*_test.exs
decisions:
  - python_ontology.decision.ontology_turtle_file_layers
  - python_ontology.decision.fact_confidence_model
```

## Requirements

```spec-requirements
- id: python_ontology.fact_confidence_model.categories
  statement: Generated facts shall support source_declared, statically_inferred, unresolved, and runtime_dependent confidence categories.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.source_declared_default
  statement: Facts extracted directly from parsed syntax shall default to source_declared confidence.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.static_inference_evidence
  statement: Statically inferred facts shall carry deterministic evidence references.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.unresolved_queryable
  statement: Relevant but unresolved facts shall be represented in the graph as queryable unresolved facts.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.runtime_dependent_boundary
  statement: Facts requiring Python runtime execution shall be marked runtime_dependent rather than source_declared or statically_inferred.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.dynamic_construct_marking
  statement: Dynamic constructs such as dynamic imports, getattr, setattr, monkey patching, decorators, and metaclasses shall preserve their uncertainty boundary.
  priority: must
  stability: evolving

- id: python_ontology.fact_confidence_model.builder_propagation
  statement: RDF builders shall propagate fact confidence into generated triples using ontology classes or properties.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.queryable_confidence
  statement: Confidence categories shall be queryable in generated RDF graphs.
  priority: must
  stability: stable

- id: python_ontology.fact_confidence_model.no_execution_for_confidence
  statement: The analyzer shall not execute analyzed Python code to increase confidence.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.fact_confidence_model.direct_import_flow
  given:
    - source text contains import pathlib
  when:
    - extractors produce an import fact
  then:
    - the fact is source_declared and carries source evidence
  covers:
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.static_inference_evidence

- id: python_ontology.fact_confidence_model.dynamic_import_flow
  given:
    - source text calls importlib.import_module(name)
  when:
    - extractors cannot resolve name statically
  then:
    - the generated fact remains unresolved or runtime_dependent and queryable
  covers:
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.fact_confidence_model.md
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.static_inference_evidence
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.builder_propagation
    - python_ontology.fact_confidence_model.queryable_confidence
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: lib/python_ontology/confidence.ex
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: lib/python_ontology/confidence/category.ex
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: lib/python_ontology/confidence/evidence.ex
  covers:
    - python_ontology.fact_confidence_model.static_inference_evidence
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: test/python_ontology/confidence/category_test.exs
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: test/python_ontology/confidence/evidence_test.exs
  covers:
    - python_ontology.fact_confidence_model.static_inference_evidence
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: test/python_ontology/confidence/phase1_integration_test.exs
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.source_declared_default
    - python_ontology.fact_confidence_model.static_inference_evidence
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.no_execution_for_confidence

- kind: source_file
  target: priv/ontologies/python-core.ttl
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.builder_propagation
    - python_ontology.fact_confidence_model.queryable_confidence

- kind: source_file
  target: priv/ontologies/python-runtime.ttl
  covers:
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.queryable_confidence

- kind: source_file
  target: test/python_ontology/ontology/confidence_vocabulary_test.exs
  covers:
    - python_ontology.fact_confidence_model.categories
    - python_ontology.fact_confidence_model.unresolved_queryable
    - python_ontology.fact_confidence_model.runtime_dependent_boundary
    - python_ontology.fact_confidence_model.dynamic_construct_marking
    - python_ontology.fact_confidence_model.builder_propagation
    - python_ontology.fact_confidence_model.queryable_confidence
```
