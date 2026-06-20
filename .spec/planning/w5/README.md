# W5 - Project Analysis Scope

This wave implements deterministic Python project discovery and file selection. It can run in parallel with parser work because it selects files and metadata before extraction or RDF building.

## Phase Order

1. [Phase 1 - Root Detection and File Traversal](./phase-01-root-detection-and-file-traversal.md)
2. [Phase 2 - Include Exclude Policy and Package Classification](./phase-02-include-exclude-policy-and-package-classification.md)
3. [Phase 3 - Project Fixtures and Discovery Acceptance](./phase-03-project-fixtures-and-discovery-acceptance.md)

## Implementation Sequence

Start with root detection and deterministic traversal. Then add default include/exclude behavior and package/test classification. Finish with realistic fixture projects.

## Parallel Work Lanes

- W5 can run in parallel with W1 and W2.
- W8 project-level analysis depends on W5.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.project_analysis_scope.md`
- `.spec/specs/project_analysis_scope.spec.md`
