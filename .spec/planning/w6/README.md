# W6 - Extractor and Builder Boundary

This wave implements the fact extraction and RDF builder boundary. It connects normalized syntax, IRI helpers, confidence metadata, and ontology vocabularies without letting parser code emit RDF or builders parse source.

## Phase Order

1. [Phase 1 - Contexts, Diagnostics, and Fact Contracts](./phase-01-contexts-diagnostics-and-fact-contracts.md)
2. [Phase 2 - First Extractors](./phase-02-first-extractors.md)
3. [Phase 3 - First Builders and Pipeline Acceptance](./phase-03-first-builders-and-pipeline-acceptance.md)

## Implementation Sequence

Define contexts and facts first. Then implement first-slice extractors over normalized syntax. Finish with RDF builders and pipeline acceptance.

## Parallel Work Lanes

- W6 depends on W2 normalized syntax, W3 IRI helpers, and W4 confidence model.
- W7 generated-graph validation can finish after W6 builders exist.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.extractor_builder_boundary.md`
- `.spec/specs/extractor_builder_boundary.spec.md`
