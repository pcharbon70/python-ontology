# Phase 1 - Root Detection and File Traversal

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.project_analysis_scope.md`
- `.spec/specs/project_analysis_scope.spec.md`
- `lib/python_ontology/analyzer/**/*.ex`
- `lib/python_ontology/project*.ex`

## Relevant Assumptions / Defaults

- Analysis supports single-file and project-root modes.
- Project roots can be explicit or inferred from Python metadata and Git.
- Traversal order is deterministic.

[ ] 1 Phase 1 - Root Detection and File Traversal
  Implement the basic project boundary and deterministic file traversal behavior.

  [x] 1.1 Section - Analysis Mode Detection
    Identify whether the caller requested file or project analysis.

    [x] 1.1.1 Task - Implement path classification
      Distinguish source files, directories, and invalid paths.

      [x] 1.1.1.1 Subtask - Detect explicit `.py` and `.pyi` file paths.
      [x] 1.1.1.2 Subtask - Detect explicit directory paths.
      [x] 1.1.1.3 Subtask - Return structured diagnostics for missing, unreadable, or unsupported paths.

  [x] 1.2 Section - Root Detection
    Infer project roots when the caller passes a nested path.

    [x] 1.2.1 Task - Implement metadata root discovery
      Find roots from common Python project metadata.

      [x] 1.2.1.1 Subtask - Detect `pyproject.toml`.
      [x] 1.2.1.2 Subtask - Detect `setup.cfg` and `setup.py`.
      [x] 1.2.1.3 Subtask - Fall back to `.git` or explicit path roots when metadata is absent.

    [x] 1.2.2 Task - Implement deterministic file traversal
      Walk selected files in stable order.

      [x] 1.2.2.1 Subtask - Include `.py` files by default.
      [x] 1.2.2.2 Subtask - Include `.pyi` files by default.
      [x] 1.2.2.3 Subtask - Sort files by normalized repository-relative POSIX path.

  [ ] 1.3 Section - Phase 1 Integration Tests
    Validate root detection and traversal before exclusion and package classification are added.

    [ ] 1.3.1 Task - Run root/traversal checks
      Prove file and project analysis inputs produce deterministic file lists.

      [ ] 1.3.1.1 Subtask - Add tests for explicit file, explicit directory, metadata root, and Git fallback detection.
      [ ] 1.3.1.2 Subtask - Add tests for deterministic `.py` and `.pyi` ordering.
      [ ] 1.3.1.3 Subtask - Run focused project tests, full `mix test`, and `mix spec.check`.
