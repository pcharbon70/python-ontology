# Phase 3 - Project Fixtures and Discovery Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.project_analysis_scope.md`
- `.spec/specs/project_analysis_scope.spec.md`
- `test/fixtures/python_projects/*`
- `test/python_ontology/**/*project*_test.exs`

## Relevant Assumptions / Defaults

- Project discovery feeds parser and project analysis.
- Traversal must be deterministic across repeated runs.
- Installed dependencies are skipped unless explicitly configured.

[ ] 3 Phase 3 - Project Fixtures and Discovery Acceptance
  Build realistic fixture projects and prove discovery behavior end to end.

  [x] 3.1 Section - Fixture Project Corpus
    Add representative project layouts for file selection tests.

    [x] 3.1.1 Task - Add source layout fixtures
      Cover common Python package layouts.

      [x] 3.1.1.1 Subtask - Add `pyproject.toml` with `src/` layout fixture.
      [x] 3.1.1.2 Subtask - Add flat package layout fixture.
      [x] 3.1.1.3 Subtask - Add namespace package fixture.

    [x] 3.1.2 Task - Add exclusion and role fixtures
      Cover files that should be skipped or specially marked.

      [x] 3.1.2.1 Subtask - Add virtualenv/cache/build/site-packages fixture directories.
      [x] 3.1.2.2 Subtask - Add test files and directories.
      [x] 3.1.2.3 Subtask - Add `.pyi` stub files.

  [x] 3.2 Section - Discovery Acceptance Behavior
    Prove selected project files can feed parser work.

    [x] 3.2.1 Task - Connect discovery to parser inputs
      Ensure file selection result shape is ready for later analysis APIs.

      [x] 3.2.1.1 Subtask - Return selected file records with path, role, package hints, and diagnostics.
      [x] 3.2.1.2 Subtask - Ensure results can be passed to parser APIs without additional path normalization.
      [x] 3.2.1.3 Subtask - Add summary metadata for selected, skipped, test, stub, and package counts.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Prove project discovery acceptance across realistic layouts.

    [ ] 3.3.1 Task - Run project discovery acceptance
      Validate fixture project traversal and parser handoff readiness.

      [ ] 3.3.1.1 Subtask - Add fixture project acceptance tests.
      [ ] 3.3.1.2 Subtask - Add determinism tests for repeated traversal.
      [ ] 3.3.1.3 Subtask - Run focused project tests, full `mix test`, and `mix spec.check`.
