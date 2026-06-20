# Project Analysis Scope

Current contract for discovering and selecting Python project files for analysis.

```spec-meta
id: python_ontology.project_analysis_scope
kind: component
status: active
summary: Python project discovery, include/exclude policy, and file traversal scope.
surface:
  - .spec/decisions/python_ontology.decision.project_analysis_scope.md
  - lib/python_ontology/analyzer/**/*.ex
  - lib/python_ontology/project*.ex
  - test/python_ontology/**/*project*_test.exs
decisions:
  - python_ontology.decision.project_analysis_scope
```

## Requirements

```spec-requirements
- id: python_ontology.project_analysis_scope.single_file_and_project_modes
  statement: The analyzer shall support both single-file analysis and project-root analysis.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.root_detection
  statement: Project roots shall be detected from explicit paths, pyproject.toml, setup.cfg, setup.py, or git roots.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.include_python_sources
  statement: Project analysis shall include .py files by default.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.include_stub_files
  statement: Project analysis shall include .pyi stub files by default.
  priority: should
  stability: evolving

- id: python_ontology.project_analysis_scope.exclude_environment_dirs
  statement: Project analysis shall exclude common virtualenv, cache, build, distribution, dependency, and VCS directories by default.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.package_detection
  statement: Project analysis shall recognize regular Python packages that contain __init__.py files.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.namespace_package_detection
  statement: Project analysis shall represent namespace package directories that lack __init__.py but belong to importable package trees.
  priority: should
  stability: evolving

- id: python_ontology.project_analysis_scope.test_scope_marking
  statement: Test files shall be included by default and marked as test scope.
  priority: should
  stability: evolving

- id: python_ontology.project_analysis_scope.configurable_globs
  statement: Include and exclude file selection shall be configurable with glob patterns.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.no_dependency_traversal_default
  statement: Project analysis shall not traverse installed dependencies by default.
  priority: must
  stability: stable

- id: python_ontology.project_analysis_scope.deterministic_order
  statement: File traversal order shall be deterministic.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.project_analysis_scope.default_project_flow
  given:
    - a repository contains pyproject.toml, src/my_pkg/__init__.py, src/my_pkg/app.py, and .venv/lib/site-packages/pkg.py
  when:
    - project analysis runs with default options
  then:
    - the analyzer includes src/my_pkg files and excludes .venv files
  covers:
    - python_ontology.project_analysis_scope.root_detection
    - python_ontology.project_analysis_scope.include_python_sources
    - python_ontology.project_analysis_scope.exclude_environment_dirs
    - python_ontology.project_analysis_scope.no_dependency_traversal_default

- id: python_ontology.project_analysis_scope_stub_flow
  given:
    - a project contains package interface stubs in .pyi files
  when:
    - project analysis runs with default options
  then:
    - the analyzer includes the stub files and marks them as source artifacts
  covers:
    - python_ontology.project_analysis_scope.include_stub_files
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.project_analysis_scope.md
  covers:
    - python_ontology.project_analysis_scope.single_file_and_project_modes
    - python_ontology.project_analysis_scope.root_detection
    - python_ontology.project_analysis_scope.include_python_sources
    - python_ontology.project_analysis_scope.include_stub_files
    - python_ontology.project_analysis_scope.exclude_environment_dirs
    - python_ontology.project_analysis_scope.package_detection
    - python_ontology.project_analysis_scope.namespace_package_detection
    - python_ontology.project_analysis_scope.test_scope_marking
    - python_ontology.project_analysis_scope.configurable_globs
    - python_ontology.project_analysis_scope.no_dependency_traversal_default
    - python_ontology.project_analysis_scope.deterministic_order

- kind: source_file
  target: lib/python_ontology/project.ex
  covers:
    - python_ontology.project_analysis_scope.single_file_and_project_modes

- kind: source_file
  target: lib/python_ontology/project/input.ex
  covers:
    - python_ontology.project_analysis_scope.single_file_and_project_modes

- kind: source_file
  target: lib/python_ontology/project/diagnostic.ex
  covers:
    - python_ontology.project_analysis_scope.single_file_and_project_modes

- kind: source_file
  target: test/python_ontology/project/input_test.exs
  covers:
    - python_ontology.project_analysis_scope.single_file_and_project_modes
```
