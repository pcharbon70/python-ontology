# PythonOntology Package

Current package contract for the PythonOntology Mix project.

```spec-meta
id: package.python_ontology
kind: package
status: active
summary: Python-native source ontology and analyzer for Python projects.
surface:
  - README.md
  - mix.exs
  - lib/python_ontology.ex
  - test/test_helper.exs
  - test/python_ontology_test.exs
decisions:
  - python_ontology.decision.initial_python_ontology_architecture
```

## Requirements

```spec-requirements
- id: package.python_ontology.mix_project
  statement: The repository shall define a Mix project named PythonOntology with OTP application :python_ontology.
  priority: must
  stability: stable

- id: package.python_ontology.specled_dependency
  statement: The Mix project shall include spec_led_ex as a dev/test-only dependency pinned to the shared repository ref.
  priority: must
  stability: stable

- id: package.python_ontology.tree_sitter_parser_dependency
  statement: The Mix project shall include Rustler support for the project-owned Tree-sitter parser NIF.
  priority: must
  stability: evolving

- id: package.python_ontology.public_namespace
  statement: The PythonOntology module shall expose the OTP application name through app_name/0.
  priority: must
  stability: stable

- id: package.python_ontology.test_baseline
  statement: The project shall include an ExUnit baseline that verifies the public namespace behavior.
  priority: must
  stability: stable

- id: package.python_ontology.product_direction
  statement: The project shall build a Python-native source ontology and analyzer that follows the broad architecture accepted in python_ontology.decision.initial_python_ontology_architecture.
  priority: must
  stability: evolving
```

## Verification

```spec-verification
- kind: source_file
  target: mix.exs
  covers:
    - package.python_ontology.mix_project
    - package.python_ontology.specled_dependency
    - package.python_ontology.tree_sitter_parser_dependency

- kind: source_file
  target: lib/python_ontology.ex
  covers:
    - package.python_ontology.public_namespace

- kind: source_file
  target: test/test_helper.exs
  covers:
    - package.python_ontology.test_baseline

- kind: source_file
  target: test/python_ontology_test.exs
  covers:
    - package.python_ontology.test_baseline

- kind: command
  target: mix test
  covers:
    - package.python_ontology.mix_project
    - package.python_ontology.public_namespace
    - package.python_ontology.test_baseline

- kind: command
  target: mix format --check-formatted
  covers:
    - package.python_ontology.mix_project

- kind: source_file
  target: .spec/decisions/python_ontology.decision.initial_python_ontology_architecture.md
  covers:
    - package.python_ontology.product_direction
```
