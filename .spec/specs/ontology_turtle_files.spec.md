# Ontology Turtle Files

Current contract for PythonOntology's authored OWL/RDF Turtle ontology files.

```spec-meta
id: python_ontology.ontology_turtle_files
kind: ontology
status: active
summary: Layered Turtle ontology files for Python source-code knowledge graphs.
surface:
  - priv/ontologies/*.ttl
decisions:
  - python_ontology.decision.initial_python_ontology_architecture
  - python_ontology.decision.ontology_turtle_file_layers
```

## Requirements

```spec-requirements
- id: python_ontology.ontology_turtle_files.files_present
  statement: The repository shall store authored Python ontology Turtle files under priv/ontologies.
  priority: must
  stability: stable

- id: python_ontology.ontology_turtle_files.layered_files
  statement: The ontology shall be split into python-core, python-structure, python-typing, python-runtime, python-evolution, and python-shapes Turtle files.
  priority: must
  stability: stable

- id: python_ontology.ontology_turtle_files.namespace_stability
  statement: Each Turtle ontology layer shall use a stable namespace rooted at https://w3id.org/python-code/.
  priority: must
  stability: stable

- id: python_ontology.ontology_turtle_files.import_direction
  statement: Ontology layer imports shall flow from foundational source concepts toward structure, typing, runtime, evolution, and shapes without circular imports.
  priority: must
  stability: stable

- id: python_ontology.ontology_turtle_files.python_native_boundaries
  statement: The ontology layers shall model Python-native source concepts rather than directly copying Elixir ontology concepts.
  priority: must
  stability: stable

- id: python_ontology.ontology_turtle_files.dynamic_fact_boundary
  statement: The ontology shall distinguish source-declared facts, statically inferred facts, unresolved facts, and runtime-dependent dynamic facts.
  priority: must
  stability: evolving

- id: python_ontology.ontology_turtle_files.bootstrap_validity
  statement: Initial Turtle files shall contain parseable ontology declarations, metadata, and representative starter classes or properties for their layer.
  priority: must
  stability: evolving

- id: python_ontology.ontology_turtle_files.starter_shacl_shapes
  statement: The shapes ontology shall declare starter SHACL shapes for first-slice modules, functions, parameters, and source locations.
  priority: must
  stability: evolving
```

## Verification

```spec-verification
- kind: source_file
  target: priv/ontologies/python-core.ttl
  covers:
    - python_ontology.ontology_turtle_files.files_present
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.python_native_boundaries
    - python_ontology.ontology_turtle_files.dynamic_fact_boundary
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: priv/ontologies/python-structure.ttl
  covers:
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.import_direction
    - python_ontology.ontology_turtle_files.python_native_boundaries
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: priv/ontologies/python-typing.ttl
  covers:
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.import_direction
    - python_ontology.ontology_turtle_files.python_native_boundaries
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: priv/ontologies/python-runtime.ttl
  covers:
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.import_direction
    - python_ontology.ontology_turtle_files.python_native_boundaries
    - python_ontology.ontology_turtle_files.dynamic_fact_boundary
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: priv/ontologies/python-evolution.ttl
  covers:
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.import_direction
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: priv/ontologies/python-shapes.ttl
  covers:
    - python_ontology.ontology_turtle_files.layered_files
    - python_ontology.ontology_turtle_files.namespace_stability
    - python_ontology.ontology_turtle_files.import_direction
    - python_ontology.ontology_turtle_files.bootstrap_validity
    - python_ontology.ontology_turtle_files.starter_shacl_shapes

- kind: source_file
  target: test/python_ontology/ontology/confidence_vocabulary_test.exs
  covers:
    - python_ontology.ontology_turtle_files.dynamic_fact_boundary
    - python_ontology.ontology_turtle_files.bootstrap_validity

- kind: source_file
  target: test/python_ontology/confidence/phase2_integration_test.exs
  covers:
    - python_ontology.ontology_turtle_files.dynamic_fact_boundary
    - python_ontology.ontology_turtle_files.bootstrap_validity
```
