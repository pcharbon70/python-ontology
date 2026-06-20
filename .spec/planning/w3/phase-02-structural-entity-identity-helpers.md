# Phase 2 - Structural Entity Identity Helpers

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.iri_identity_strategy.md`
- `.spec/specs/iri_identity_strategy.spec.md`
- `lib/python_ontology/iri*.ex`
- `lib/python_ontology/syntax/*.ex`

## Relevant Assumptions / Defaults

- Python function identity is lexical, not arity-based.
- Nested classes and functions include lexical parent paths.
- Static identity does not claim runtime object identity.

[x] 2 Phase 2 - Structural Entity Identity Helpers
  Implement package, module, class, function, and nested entity identity helpers.

  [x] 2.1 Section - Package And Module Identity
    Generate stable identities for project source containers.

    [x] 2.1.1 Task - Implement package identity
      Derive package identity from project discovery and path context.

      [x] 2.1.1.1 Subtask - Generate regular package IDs from package roots and `__init__.py` paths.
      [x] 2.1.1.2 Subtask - Generate namespace package IDs from discovered namespace roots.
      [x] 2.1.1.3 Subtask - Include source path fallback for ambiguous package names.

    [x] 2.1.2 Task - Implement module identity
      Derive module identity from dotted name and file identity.

      [x] 2.1.2.1 Subtask - Generate module IDs for ordinary `.py` modules.
      [x] 2.1.2.2 Subtask - Generate module IDs for `.pyi` stub modules.
      [x] 2.1.2.3 Subtask - Include source path fallback for duplicate or ambiguous modules.

  [x] 2.2 Section - Class And Function Identity
    Generate stable lexical identities for Python declarations.

    [x] 2.2.1 Task - Implement class identity
      Build class IDs from module identity and lexical class path.

      [x] 2.2.1.1 Subtask - Generate top-level class IDs.
      [x] 2.2.1.2 Subtask - Generate nested class IDs.
      [x] 2.2.1.3 Subtask - Disambiguate repeated class names with occurrence and span data.

    [x] 2.2.2 Task - Implement function and method identity
      Build function IDs from lexical path without using arity.

      [x] 2.2.2.1 Subtask - Generate top-level function IDs.
      [x] 2.2.2.2 Subtask - Generate method and nested function IDs.
      [x] 2.2.2.3 Subtask - Disambiguate repeated function names with occurrence and span data.

  [x] 2.3 Section - Phase 2 Integration Tests
    Validate structural identity across ordinary, nested, repeated, and ambiguous definitions.

    [x] 2.3.1 Task - Run structural identity checks
      Prove structural IRIs are deterministic and lexical.

      [x] 2.3.1.1 Subtask - Add tests for package, module, class, function, method, and nested identities.
      [x] 2.3.1.2 Subtask - Add tests that arity changes do not define Python function identity.
      [x] 2.3.1.3 Subtask - Run focused IRI tests, full `mix test`, and `mix spec.check`.
