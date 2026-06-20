# Initial Analysis Slice

Current contract for the first useful end-to-end PythonOntology analysis slice.

```spec-meta
id: python_ontology.initial_analysis_slice
kind: milestone
status: active
summary: First implementation slice for ordinary Python modules, classes, functions, imports, calls, and source locations.
surface:
  - .spec/decisions/python_ontology.decision.initial_analysis_slice.md
  - lib/python_ontology/**/*.ex
  - lib/mix/tasks/python_ontology*.ex
  - test/python_ontology/**/*_test.exs
decisions:
  - python_ontology.decision.initial_python_ontology_architecture
  - python_ontology.decision.initial_analysis_slice
```

## Requirements

```spec-requirements
- id: python_ontology.initial_analysis_slice.modules_packages
  statement: The first analysis slice shall extract modules and packages.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.imports_aliases
  statement: The first analysis slice shall extract imports and aliases.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.classes_bases
  statement: The first analysis slice shall extract classes and base class syntax.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.functions_methods
  statement: The first analysis slice shall extract functions and methods.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.parameters_defaults
  statement: The first analysis slice shall extract parameters, defaults, varargs, kwargs, and keyword-only parameters.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.decorators_annotations
  statement: The first analysis slice shall extract decorators and annotations as syntax-level facts.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.calls_attributes
  statement: The first analysis slice shall extract calls, attributes, and simple call target syntax.
  priority: must
  stability: evolving

- id: python_ontology.initial_analysis_slice.source_locations
  statement: The first analysis slice shall preserve source files and source locations for extracted entities.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.first_cli_output
  statement: The first analysis slice shall expose a public API or Mix task that writes Turtle output for a file or project.
  priority: must
  stability: evolving

- id: python_ontology.initial_analysis_slice.out_of_scope_runtime
  statement: Runtime-dependent behavior, full type reasoning, framework semantics, dataflow, and dynamic import resolution shall remain out of scope for the first slice.
  priority: must
  stability: stable

- id: python_ontology.initial_analysis_slice.tests_for_slice
  statement: The first analysis slice shall include tests for parser, extractor, builder, and output behavior.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: python_ontology.initial_analysis_slice_simple_module_flow
  given:
    - a Python module defines imports, a class, and a function
  when:
    - the first analysis slice processes the module
  then:
    - the output graph includes module, import, class, function, parameter, and source location resources
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.source_locations

- id: python_ontology.initial_analysis_slice_runtime_boundary_flow
  given:
    - a Python module uses dynamic import or decorator behavior that cannot be resolved statically
  when:
    - the first analysis slice processes the module
  then:
    - the behavior remains unresolved or runtime-dependent instead of being over-inferred
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/decisions/python_ontology.decision.initial_analysis_slice.md
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/parser/native.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/parser/tree_sitter.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/parser.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/parser/node.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/parser/span.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: test/python_ontology/parser/tree_sitter_smoke_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/parser_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/parser_fixture_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/syntax/source.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/provenance.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/node_id.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/node_info.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/span.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/byte_span.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/point.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/syntax/point_span.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: test/python_ontology/syntax/shared_fields_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/syntax/nodes.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: test/python_ontology/syntax/typed_nodes_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/syntax.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/syntax/normalizer.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/syntax/traversal.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/syntax/structural_mapping_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/syntax/expression_mapping_test.exs
  covers:
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/syntax/normalization_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/syntax/unknown_preservation_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/syntax/traversal_test.exs
  covers:
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/syntax/normalization_acceptance_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/iri.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/iri/context.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/iri/diagnostic.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output

- kind: source_file
  target: lib/python_ontology/iri/path.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output

- kind: source_file
  target: lib/python_ontology/iri/fragment.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output

- kind: source_file
  target: lib/python_ontology/iri/builder.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/iri/identity.ex
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/iri/base_iri_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/path_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/phase1_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/structural_container_identity_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/structural_declaration_identity_test.exs
  covers:
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/phase2_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/span_bound_identity_test.exs
  covers:
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/builder_contract_test.exs
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/iri/phase3_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/confidence.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/confidence/category.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/confidence/evidence.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/confidence/category_test.exs
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/evidence_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/phase1_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/builders/confidence.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/builders/confidence_test.exs
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/phase2_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/fixtures/python_confidence/direct_and_inferred.py
  covers:
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/fixtures/python_confidence/dynamic_boundaries.py
  covers:
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/source_fixture_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/fixtures/python_confidence/side_effect_guard.py
  covers:
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/no_execution_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/confidence/phase3_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/project.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/project/input.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/project/discovery.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/project/result.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/project/source_file.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations

- kind: source_file
  target: lib/python_ontology/project/diagnostic.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/project/input_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/discovery_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/phase1_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/selection_policy_test.exs
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/classifier_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/phase2_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/parser_input_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/project/phase3_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/extractors/context.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/builders/context.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/pipeline/diagnostic.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/extractors/context_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/builders/context_test.exs
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/facts/fact.ex
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/facts/result.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/facts.ex
  covers:
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/facts/fact_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: test/python_ontology/extractors/phase1_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/extractors/structural.ex
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/extractors/structural_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/extractors/expressions.ex
  covers:
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/extractors/expressions_test.exs
  covers:
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/extractors.ex
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/extractors/phase2_integration_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/builders/result.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/builders/rdf.ex
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/builders/rdf_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice

- kind: source_file
  target: lib/python_ontology/pipeline/result.ex
  covers:
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: lib/python_ontology/pipeline.ex
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime

- kind: source_file
  target: test/python_ontology/pipeline_test.exs
  covers:
    - python_ontology.initial_analysis_slice.modules_packages
    - python_ontology.initial_analysis_slice.imports_aliases
    - python_ontology.initial_analysis_slice.classes_bases
    - python_ontology.initial_analysis_slice.functions_methods
    - python_ontology.initial_analysis_slice.parameters_defaults
    - python_ontology.initial_analysis_slice.decorators_annotations
    - python_ontology.initial_analysis_slice.calls_attributes
    - python_ontology.initial_analysis_slice.source_locations
    - python_ontology.initial_analysis_slice.first_cli_output
    - python_ontology.initial_analysis_slice.out_of_scope_runtime
    - python_ontology.initial_analysis_slice.tests_for_slice
```
