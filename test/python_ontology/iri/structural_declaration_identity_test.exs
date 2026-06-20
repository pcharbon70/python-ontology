# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.class_function_identity python_ontology.iri_identity_strategy.nested_scope_identity python_ontology.iri_identity_strategy.occurrence_disambiguation python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.StructuralDeclarationIdentityTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.Syntax.ByteSpan

  setup do
    {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")
    {:ok, module_iri} = IRI.module(context, name: "pkg.module", source_path: "src/pkg/module.py")
    %{context: context, module_iri: module_iri}
  end

  test "generates top-level and nested class IRIs from lexical paths", %{
    context: context,
    module_iri: module_iri
  } do
    assert {:ok, top_level} = IRI.class(context, module_iri: module_iri, name: "Example")

    assert {:ok, nested} =
             IRI.class(context, module_iri: module_iri, lexical_path: ["Example", "Nested"])

    assert top_level ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/class/Example"

    assert nested ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/class/Example/Nested"
  end

  test "generates top-level function method and nested function IRIs without arity", %{
    context: context,
    module_iri: module_iri
  } do
    assert {:ok, first} =
             IRI.function(context, module_iri: module_iri, lexical_path: ["parse"], arity: 1)

    assert {:ok, second} =
             IRI.function(context, module_iri: module_iri, lexical_path: ["parse"], arity: 3)

    assert first == second

    assert first ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/function/parse"

    assert {:ok, method} =
             IRI.function(context,
               module_iri: module_iri,
               lexical_path: ["Example", "parse"],
               method?: true
             )

    assert method ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/method/Example/parse"

    assert {:ok, nested} =
             IRI.function(context, module_iri: module_iri, lexical_path: ["outer", "inner"])

    assert nested ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/function/outer/inner"
  end

  test "disambiguates repeated declarations with occurrence and span data", %{
    context: context,
    module_iri: module_iri
  } do
    span = %{byte: %ByteSpan{start: 120, end: 180}}

    assert {:ok, repeated_class} =
             IRI.class(context,
               module_iri: module_iri,
               name: "Example",
               occurrence: 2,
               span: span
             )

    assert repeated_class ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/class/Example/occurrence/2/span/b120-180"

    assert {:ok, repeated_function} =
             IRI.function(context,
               module_iri: module_iri,
               name: "parse",
               occurrence: 3,
               span: %{start_byte: 220, end_byte: 260}
             )

    assert repeated_function ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py/function/parse/occurrence/3/span/b220-260"
  end
end
