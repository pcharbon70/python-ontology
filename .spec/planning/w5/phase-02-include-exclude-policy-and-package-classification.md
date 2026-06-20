# Phase 2 - Include Exclude Policy and Package Classification

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.project_analysis_scope.md`
- `.spec/specs/project_analysis_scope.spec.md`
- `lib/python_ontology/project*.ex`
- `test/python_ontology/**/*project*_test.exs`

## Relevant Assumptions / Defaults

- Dependency, cache, build, and environment directories are excluded by default.
- Regular and namespace packages are represented.
- Tests are included by default and marked as test scope.

[ ] 2 Phase 2 - Include Exclude Policy and Package Classification
  Implement selection policy and source classification for Python project files.

  [x] 2.1 Section - Include And Exclude Globs
    Make file selection configurable while keeping safe defaults.

    [x] 2.1.1 Task - Implement default exclusions
      Avoid accidental dependency and generated file analysis.

      [x] 2.1.1.1 Subtask - Exclude `.git`, `.venv`, `venv`, `env`, `__pycache__`, `.mypy_cache`, `.pytest_cache`, `.tox`, `.nox`, `build`, `dist`, `site-packages`, and `node_modules`.
      [x] 2.1.1.2 Subtask - Exclude generated output directories configured by callers.
      [x] 2.1.1.3 Subtask - Report selected and skipped counts in project analysis metadata.

    [x] 2.1.2 Task - Implement configurable globs
      Allow callers to tune source selection.

      [x] 2.1.2.1 Subtask - Add include glob options.
      [x] 2.1.2.2 Subtask - Add exclude glob options.
      [x] 2.1.2.3 Subtask - Define precedence when include and exclude patterns overlap.

  [ ] 2.2 Section - Package And Test Classification
    Add classification needed by IRI identity and caller filtering.

    [ ] 2.2.1 Task - Detect package forms
      Classify regular and namespace packages.

      [ ] 2.2.1.1 Subtask - Detect regular packages from `__init__.py`.
      [ ] 2.2.1.2 Subtask - Detect namespace package candidates without `__init__.py`.
      [ ] 2.2.1.3 Subtask - Preserve package root and dotted name hints for IRI generation.

    [ ] 2.2.2 Task - Mark tests and stubs
      Preserve source role information for filters and graph consumers.

      [ ] 2.2.2.1 Subtask - Mark likely test files and test directories.
      [ ] 2.2.2.2 Subtask - Mark `.pyi` stub files separately from `.py` implementation files.
      [ ] 2.2.2.3 Subtask - Keep test files included by default.

  [ ] 2.3 Section - Phase 2 Integration Tests
    Validate selection policy, package classification, and configurable globs.

    [ ] 2.3.1 Task - Run selection/classification checks
      Prove default and configured traversal behavior.

      [ ] 2.3.1.1 Subtask - Add tests for excluded directories and selected source files.
      [ ] 2.3.1.2 Subtask - Add tests for regular packages, namespace packages, tests, and stubs.
      [ ] 2.3.1.3 Subtask - Run focused project tests, full `mix test`, and `mix spec.check`.
