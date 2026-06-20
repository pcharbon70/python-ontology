# Phase 1 - Base IRI and Path Canonicalization

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.iri_identity_strategy.md`
- `.spec/specs/iri_identity_strategy.spec.md`
- `lib/python_ontology/iri*.ex`
- `priv/ontologies/*.ttl`

## Relevant Assumptions / Defaults

- Ontology namespace IRIs stay rooted at `https://w3id.org/python-code/`.
- Generated analyzed-code resources use a configurable base IRI.
- Source paths are repository-relative POSIX paths.

[ ] 1 Phase 1 - Base IRI and Path Canonicalization
  Implement base IRI configuration and source path normalization.

  [x] 1.1 Section - Base IRI Configuration
    Define how generated resources choose their IRI root.

    [x] 1.1.1 Task - Implement base IRI config
      Add a shared configuration path for generated resource IRIs.

      [x] 1.1.1.1 Subtask - Add default base IRI behavior for tests and local analysis.
      [x] 1.1.1.2 Subtask - Add validation for missing, malformed, or unsafe base IRIs.
      [x] 1.1.1.3 Subtask - Keep ontology namespace helpers separate from generated-resource helpers.

  [ ] 1.2 Section - Source Path Canonicalization
    Normalize source file paths before resource identity is built.

    [ ] 1.2.1 Task - Implement path normalization
      Convert paths into deterministic repository-relative identity components.

      [ ] 1.2.1.1 Subtask - Convert path separators to POSIX form.
      [ ] 1.2.1.2 Subtask - Normalize `.` and `..` segments without escaping analysis root.
      [ ] 1.2.1.3 Subtask - Diagnose absolute or out-of-root paths when a repository root is required.

  [ ] 1.3 Section - Phase 1 Integration Tests
    Validate base IRI and path canonicalization before entity-specific helpers depend on them.

    [ ] 1.3.1 Task - Run base identity checks
      Prove generated resource roots and path fragments are deterministic.

      [ ] 1.3.1.1 Subtask - Add tests for valid and invalid base IRIs.
      [ ] 1.3.1.2 Subtask - Add tests for POSIX path normalization and out-of-root diagnostics.
      [ ] 1.3.1.3 Subtask - Run focused IRI tests, full `mix test`, and `mix spec.check`.
