# Phase 1 - Public API and Mix Task Surface

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.initial_analysis_slice.md`
- `.spec/specs/initial_analysis_slice.spec.md`
- `lib/python_ontology.ex`
- `lib/python_ontology/**/*.ex`
- `lib/mix/tasks/python_ontology*.ex`

## Relevant Assumptions / Defaults

- Parser, normalization, project discovery, extractors, builders, and validation are available.
- Public APIs return graph output plus structured diagnostics.
- Mix task behavior is suitable for local use and tests.

[x] 1 Phase 1 - Public API and Mix Task Surface
  Expose the first end-to-end analysis path to callers.

  [x] 1.1 Section - Public API
    Add stable file and project analysis functions.

    [x] 1.1.1 Task - Implement file analysis API
      Analyze one Python source file through the full pipeline.

      [x] 1.1.1.1 Subtask - Add `analyze_file/2` or equivalent.
      [x] 1.1.1.2 Subtask - Return graph, diagnostics, selected options, and validation status.
      [x] 1.1.1.3 Subtask - Support base IRI and validation options.

    [x] 1.1.2 Task - Implement project analysis API
      Analyze selected project files through the full pipeline.

      [x] 1.1.2.1 Subtask - Add `analyze_project/2` or equivalent.
      [x] 1.1.2.2 Subtask - Use W5 project discovery for file selection.
      [x] 1.1.2.3 Subtask - Merge per-file graphs and diagnostics deterministically.

  [x] 1.2 Section - Mix Task Surface
    Add a command-line analysis path.

    [x] 1.2.1 Task - Implement analysis Mix task
      Provide a user-facing command for file or project analysis.

      [x] 1.2.1.1 Subtask - Accept file or project path.
      [x] 1.2.1.2 Subtask - Support output path, base IRI, include/exclude globs, and validation flags.
      [x] 1.2.1.3 Subtask - Define non-zero exit behavior for unreadable paths and validation failures.

  [x] 1.3 Section - Phase 1 Integration Tests
    Prove the public API and Mix task can run the pipeline on minimal input.

    [x] 1.3.1 Task - Run API and command checks
      Validate caller-facing behavior before broad fixture acceptance.

      [x] 1.3.1.1 Subtask - Add tests for `analyze_file/2` or equivalent on a tiny source fixture.
      [x] 1.3.1.2 Subtask - Add tests for the Mix task writing Turtle output.
      [x] 1.3.1.3 Subtask - Run focused API/task tests, full `mix test`, and `mix spec.check`.
