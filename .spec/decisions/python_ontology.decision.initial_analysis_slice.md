---
id: python_ontology.decision.initial_analysis_slice
status: accepted
date: 2026-06-20
affects:
  - python_ontology.initial_analysis_slice
---

# Initial Analysis Slice

## Context

Python is too large and dynamic to model completely in the first implementation. The project needs a useful first vertical slice that exercises parsing, normalization, extraction, building, validation, and CLI output without committing to all Python semantics.

The first slice should produce enough RDF to inspect ordinary Python packages and guide future ontology refinement.

## Decision

Implement the first analysis slice around common source structure:

- modules and packages
- imports and aliases
- classes and base class syntax
- functions and methods
- parameters, defaults, varargs, kwargs, and keyword-only parameters
- decorators
- annotations as syntax-level type references
- calls, attributes, and simple call targets
- source files and source locations
- a Mix task or public API that can analyze a file or project and write Turtle output

Keep these areas out of the first slice unless needed for the vertical path:

- full type-system reasoning
- dataflow and control-flow graphs beyond source structure
- framework-specific semantics
- executing analyzed Python code
- runtime object identity
- full dynamic import resolution

## Consequences

The first implementation can deliver useful graphs without trying to solve Python's entire runtime model.

The initial slice creates pressure to build the full pipeline end to end rather than over-investing in one layer.

Out-of-scope features should be represented as unresolved or runtime-dependent facts when encountered, not ignored silently.

## Implementation Notes

W8 exposes the first public analysis facade through `PythonOntology.analyze_file/2` and
`PythonOntology.analyze_project/2`. These entrypoints use project discovery for source
selection, run each selected file through the existing parser/pipeline/builder path, merge
graphs in deterministic discovery order, and attach validation status without executing
analyzed Python code.

The initial command surface is `mix python_ontology.analyze`, which accepts a file or project
path, selection options, base IRI configuration, validation options, and an optional output
path. The task exits non-zero for invalid input and failed validation.

<!-- covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice -->
