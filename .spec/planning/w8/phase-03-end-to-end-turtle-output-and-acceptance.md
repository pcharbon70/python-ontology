# Phase 3 - End-to-End Turtle Output and Acceptance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.initial_analysis_slice.md`
- `.spec/specs/initial_analysis_slice.spec.md`
- `lib/python_ontology/**/*.ex`
- `lib/mix/tasks/python_ontology*.ex`
- `priv/ontologies/*.ttl`
- `test/fixtures/python_initial_slice/*`

## Relevant Assumptions / Defaults

- The first slice can produce RDF graphs for files and projects.
- Turtle serialization is parseable.
- SHACL validation runs after graph building.

[ ] 3 Phase 3 - End-to-End Turtle Output and Acceptance
  Prove the first slice works from Python source input to validated Turtle output.

  [x] 3.1 Section - Turtle Serialization
    Serialize generated graphs in a stable format.

    [x] 3.1.1 Task - Implement Turtle output
      Write generated graphs to strings and files.

      [x] 3.1.1.1 Subtask - Serialize RDF graph output to Turtle.
      [x] 3.1.1.2 Subtask - Preserve stable prefixes for PythonOntology namespaces.
      [x] 3.1.1.3 Subtask - Ensure serialized output parses back as Turtle.

  [ ] 3.2 Section - End-To-End Project Fixture
    Validate file and project analysis on a realistic small project.

    [ ] 3.2.1 Task - Build acceptance fixture project
      Create a representative source project for end-to-end testing.

      [ ] 3.2.1.1 Subtask - Include package metadata, modules, tests, stubs, imports, classes, functions, annotations, decorators, and calls.
      [ ] 3.2.1.2 Subtask - Include dynamic constructs that should remain unresolved or runtime-dependent.
      [ ] 3.2.1.3 Subtask - Include excluded directories to prove project scope behavior.

    [ ] 3.2.2 Task - Run full pipeline acceptance
      Validate generated output and diagnostics.

      [ ] 3.2.2.1 Subtask - Analyze the fixture project through the public API.
      [ ] 3.2.2.2 Subtask - Analyze the fixture project through the Mix task.
      [ ] 3.2.2.3 Subtask - Assert output graph, Turtle serialization, validation status, and diagnostics.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Run final first-slice acceptance across formatting, tests, generated output, validation, and SpecLed.

    [ ] 3.3.1 Task - Run final W8 acceptance
      Prove the first analysis slice is ready as the implementation foundation.

      [ ] 3.3.1.1 Subtask - Run `mix format --check-formatted`.
      [ ] 3.3.1.2 Subtask - Run full `mix test`, Turtle parse validation, and generated graph SHACL validation.
      [ ] 3.3.1.3 Subtask - Run `mix spec.check` and confirm `mix spec.status --no-run-commands` has no warnings or uncovered files.
