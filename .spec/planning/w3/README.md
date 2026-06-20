# W3 - IRI Identity Strategy

This wave implements deterministic IRI generation for analyzed Python resources. It separates ontology vocabulary IRIs from generated code-resource IRIs and establishes identity helpers that builders can share.

## Phase Order

1. [Phase 1 - Base IRI and Path Canonicalization](./phase-01-base-iri-and-path-canonicalization.md)
2. [Phase 2 - Structural Entity Identity Helpers](./phase-02-structural-entity-identity-helpers.md)
3. [Phase 3 - Span-Bound Identity and Builder Adoption](./phase-03-span-bound-identity-and-builder-adoption.md)

## Implementation Sequence

Implement base IRI and path normalization first. Then define package, module, class, function, and nested-scope identity. Finish with source-span identities for expressions and builder adoption.

## Parallel Work Lanes

- W3 can run in parallel with W4 after W2 defines spans and syntax identity.
- W6 builders should wait for W3 helpers before generating graph resources.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.iri_identity_strategy.md`
- `.spec/specs/iri_identity_strategy.spec.md`
