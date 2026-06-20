# W4 - Fact Confidence Model

This wave implements source-declared, statically-inferred, unresolved, and runtime-dependent confidence categories. It ensures PythonOntology can represent dynamic Python behavior honestly instead of overstating static certainty.

## Phase Order

1. [Phase 1 - Confidence Categories and Evidence Model](./phase-01-confidence-categories-and-evidence-model.md)
2. [Phase 2 - Ontology Alignment and Builder Propagation](./phase-02-ontology-alignment-and-builder-propagation.md)
3. [Phase 3 - Dynamic Boundary Fixtures and Confidence Acceptance](./phase-03-dynamic-boundary-fixtures-and-confidence-acceptance.md)

## Implementation Sequence

Define categories and evidence first. Then align Turtle vocabulary and builder behavior. Finish with dynamic Python fixtures that prove unresolved/runtime-dependent behavior stays queryable.

## Parallel Work Lanes

- W4 can run in parallel with W3 after W2 provides source evidence shapes.
- W6 extractors should use W4 confidence categories from the start.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.fact_confidence_model.md`
- `.spec/specs/fact_confidence_model.spec.md`
