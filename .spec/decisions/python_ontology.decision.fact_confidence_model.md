---
id: python_ontology.decision.fact_confidence_model
status: accepted
date: 2026-06-20
affects:
  - python_ontology.fact_confidence_model
  - python_ontology.ontology_turtle_files
---

# Fact Confidence Model

## Context

Python's static source code does not always determine runtime behavior. Imports can be dynamic, attributes can be monkey patched, decorators can rewrite objects, metaclasses can change class creation, and `getattr`, `setattr`, or module-level side effects can make facts unknowable without execution.

PythonOntology should still produce useful graphs without overstating certainty. Queries and downstream tools need to distinguish direct source facts from bounded static inferences and unresolved runtime-dependent behavior.

## Decision

Represent confidence and evidence category explicitly for generated facts.

Use these initial categories:

- `source_declared`: directly present in parsed source syntax
- `statically_inferred`: derived by deterministic static analysis from source-declared facts
- `unresolved`: recognized as relevant but not statically resolved
- `runtime_dependent`: depends on executing Python code or observing runtime state

Source-declared facts are the default for direct syntax extraction. Statically inferred facts require explicit evidence references. Unresolved facts and runtime-dependent facts must remain queryable instead of being hidden or upgraded to certainty.

Builders shall propagate fact confidence into RDF output through ontology classes or properties defined in `python-core.ttl`.

The analyzer shall not execute analyzed Python code to improve confidence.

## Consequences

Graph consumers can filter by confidence category and avoid treating dynamic Python behavior as static truth.

Extractors must return evidence metadata, not just bare facts.

Some facts that other tools might infer optimistically will remain unresolved until the project has deterministic evidence.

<!-- covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.fact_confidence_model.no_execution_for_confidence -->
