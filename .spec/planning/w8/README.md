# W8 - Initial Analysis Slice

This wave implements the first useful end-to-end PythonOntology slice. It connects project discovery, parsing, normalization, extraction, RDF building, validation, and Turtle output for ordinary Python source structure.

## Phase Order

1. [Phase 1 - Public API and Mix Task Surface](./phase-01-public-api-and-mix-task-surface.md)
2. [Phase 2 - First Slice Source Construct Coverage](./phase-02-first-slice-source-construct-coverage.md)
3. [Phase 3 - End-to-End Turtle Output and Acceptance](./phase-03-end-to-end-turtle-output-and-acceptance.md)

## Implementation Sequence

Start with public API and command surface. Then ensure the first-slice constructs are wired across the full pipeline. Finish with validated Turtle output and acceptance fixtures.

## Parallel Work Lanes

- W8 depends on W1-W7.
- W8 is the final W1-W8 integration milestone.

## ADR And Spec Coverage

- `.spec/decisions/python_ontology.decision.initial_analysis_slice.md`
- `.spec/specs/initial_analysis_slice.spec.md`
