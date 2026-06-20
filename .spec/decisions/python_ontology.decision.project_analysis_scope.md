---
id: python_ontology.decision.project_analysis_scope
status: accepted
date: 2026-06-20
affects:
  - python_ontology.project_analysis_scope
---

# Project Analysis Scope

## Context

Python projects vary widely. They may use `pyproject.toml`, `setup.py`, namespace packages, regular packages with `__init__.py`, stub files, generated sources, virtual environments, vendored dependencies, and framework-specific directories.

PythonOntology needs deterministic project discovery that avoids analyzing dependencies or generated environments by accident.

## Decision

Support both single-file and project-root analysis.

For project analysis, detect Python project roots from `pyproject.toml`, `setup.cfg`, `setup.py`, `.git`, or an explicit user path. Include `.py` source files and `.pyi` stub files by default.

Exclude dependency and generated/runtime directories by default, including `.git`, `.venv`, `venv`, `env`, `__pycache__`, `.mypy_cache`, `.pytest_cache`, `build`, `dist`, `site-packages`, `.tox`, `.nox`, and `node_modules`.

Recognize both regular packages and namespace packages. Treat tests as included by default but mark them as test scope so callers can filter or exclude them.

Project file traversal shall be deterministic and configurable through include and exclude globs.

The analyzer shall not import the project or traverse installed dependencies unless explicitly configured.

## Consequences

Initial analysis is predictable and safe for arbitrary repositories.

Some generated or vendored Python files may be skipped until a caller opts into them.

Project metadata extraction can later enrich package identity without changing parser behavior.

## Implementation Notes

Wave 5 introduces `PythonOntology.Project` as the project discovery boundary. The initial slice starts with caller input classification so source-file and project-root entry points can be validated before parser handoff without importing or executing target Python code.

<!-- covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.configurable_globs python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order -->
