# W1 - Tree-sitter Parser Boundary

This wave implements the Tree-sitter parser boundary for PythonOntology. It proves that Python source can be parsed from Elixir without an external Python runtime, embedded CPython, Pythonx, or analyzed project imports.

The output of this wave is parser result data and diagnostics that the normalized syntax wave can consume.

<!-- covers: python_ontology.implementation_wave_plan.wave_index python_ontology.implementation_wave_plan.phase_files python_ontology.implementation_wave_plan.phase_hierarchy python_ontology.implementation_wave_plan.integration_test_sections python_ontology.implementation_wave_plan.adr_traceability python_ontology.implementation_wave_plan.wave_per_adr_area -->

## Phase Order

1. [Phase 1 - Adapter Choice and Dependency Baseline](./phase-01-adapter-choice-and-dependency-baseline.md)
2. [Phase 2 - Parser API, Metadata, and Source Spans](./phase-02-parser-api-metadata-and-source-spans.md)
3. [Phase 3 - Error Nodes, Fixtures, and Parser Acceptance](./phase-03-error-nodes-fixtures-and-parser-acceptance.md)

## Implementation Sequence

Start by selecting and compiling the Tree-sitter binding. Then expose parser APIs and metadata. Finish by proving valid and invalid syntax behavior against fixtures.

## Parallel Work Lanes

- W1 can run in parallel with W5 project file discovery.
- W2 normalized syntax should start after W1 has representative parser output.

## ADR And Spec Coverage

This wave implements the contracts in:

- `.spec/decisions/python_ontology.decision.parser_bridge_boundary.md`
- `.spec/specs/parser.spec.md`
