# Phase 1 - Adapter Choice and Dependency Baseline

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.parser_bridge_boundary.md`
- `.spec/specs/parser.spec.md`
- `mix.exs`
- `native/*`
- `priv/tree_sitter/*`

## Relevant Assumptions / Defaults

- Tree-sitter Python is the default syntax authority.
- The parser does not depend on Pythonx, CPython, or project imports.
- The adapter must expose enough data for normalization to avoid raw parser cursor coupling.

[ ] 1 Phase 1 - Adapter Choice and Dependency Baseline
  Select and install the first Tree-sitter access path for Python source parsing from Elixir.

  [ ] 1.1 Section - Candidate Binding Evaluation
    Compare available Tree-sitter integration options before taking a dependency.

    [ ] 1.1.1 Task - Evaluate Elixir Tree-sitter packages
      Confirm which packages can parse Python and expose the data PythonOntology needs.

      [ ] 1.1.1.1 Subtask - Check `ex_tree_sitter`, `elixir_tree_sitter`, and language-pack packages for Python grammar support.
      [ ] 1.1.1.2 Subtask - Verify access to named nodes, field names, child order, byte spans, point spans, and error nodes.
      [ ] 1.1.1.3 Subtask - Record unsupported capabilities and fallback options in implementation notes or ADR follow-up comments.

    [ ] 1.1.2 Task - Select the initial adapter path
      Pick the binding or project-owned NIF approach that best satisfies the parser spec.

      [ ] 1.1.2.1 Subtask - Prefer a maintained package when it exposes required parser data.
      [ ] 1.1.2.2 Subtask - Choose a project-owned NIF only if package bindings cannot satisfy required data access.
      [ ] 1.1.2.3 Subtask - Keep the selected adapter behind a project-local behavior or module boundary.

  [ ] 1.2 Section - Dependency And Build Integration
    Add the selected dependency and prove the project still builds reproducibly.

    [ ] 1.2.1 Task - Add dependency and assets
      Introduce the selected parser dependency without adding a Python runtime dependency.

      [ ] 1.2.1.1 Subtask - Update `mix.exs` and lockfile with the selected dependency.
      [ ] 1.2.1.2 Subtask - Add native or grammar assets under `native/` or `priv/tree_sitter/` only when needed.
      [ ] 1.2.1.3 Subtask - Ensure generated build artifacts remain ignored and do not enter source control.

    [ ] 1.2.2 Task - Verify clean build behavior
      Prove the dependency compiles in the local environment.

      [ ] 1.2.2.1 Subtask - Run `mix deps.get` from a clean dependency state.
      [ ] 1.2.2.2 Subtask - Run `mix compile` and capture native build failures as bounded diagnostics.
      [ ] 1.2.2.3 Subtask - Document any required system packages or compiler prerequisites.

  [ ] 1.3 Section - Phase 1 Integration Tests
    Validate the selected Tree-sitter adapter can be loaded and does not require Python runtime execution.

    [ ] 1.3.1 Task - Run adapter smoke checks
      Prove the parser dependency is usable before building higher-level APIs.

      [ ] 1.3.1.1 Subtask - Add a smoke test that loads the adapter and Python grammar.
      [ ] 1.3.1.2 Subtask - Add a smoke test that parses a one-line Python module without invoking Python.
      [ ] 1.3.1.3 Subtask - Run `mix format --check-formatted`, focused adapter tests, full `mix test`, and `mix spec.check`.
