# covers: python_ontology.iri_identity_strategy.expression_span_identity python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.SpanBoundIdentityTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Fragment

  setup do
    {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")
    {:ok, module_iri} = IRI.module(context, name: "pkg.module", source_path: "src/pkg/module.py")
    %{context: context, module_iri: module_iri, span: %{start_byte: 40, end_byte: 64}}
  end

  test "generates import assignment expression and source location IRIs from containing entity and span",
       %{
         context: context,
         module_iri: module_iri,
         span: span
       } do
    assert {:ok, import_iri} =
             IRI.import_statement(context, container_iri: module_iri, span: span)

    assert {:ok, assignment_iri} = IRI.assignment(context, container_iri: module_iri, span: span)

    assert {:ok, expression_iri} =
             IRI.expression(context, container_iri: module_iri, kind: "literal", span: span)

    assert {:ok, location_iri} =
             IRI.source_location(context, container_iri: module_iri, span: span)

    assert import_iri == module_iri <> "/import/b40-64"
    assert assignment_iri == module_iri <> "/assignment/b40-64"
    assert expression_iri == module_iri <> "/expression/literal/b40-64"
    assert location_iri == module_iri <> "/location/b40-64"
  end

  test "generates call attribute and subscript IRIs from expression spans", %{
    context: context,
    module_iri: module_iri
  } do
    assert {:ok, call_iri} =
             IRI.call(context, container_iri: module_iri, span: %{start_byte: 70, end_byte: 90})

    assert {:ok, attribute_iri} =
             IRI.attribute(context,
               container_iri: module_iri,
               span: %{start_byte: 91, end_byte: 103}
             )

    assert {:ok, subscript_iri} =
             IRI.subscript(context,
               container_iri: module_iri,
               span: %{start_byte: 104, end_byte: 111}
             )

    assert call_iri == module_iri <> "/call/b70-90"
    assert attribute_iri == module_iri <> "/attribute/b91-103"
    assert subscript_iri == module_iri <> "/subscript/b104-111"
  end

  test "hashes unsafe or long fragments from canonical inputs" do
    unsafe = "contains whitespace and / slash"
    long = String.duplicate("a", 120)

    assert Fragment.encode("safe-name_1.2") == "safe-name_1.2"

    assert Fragment.encode(unsafe) ==
             "h-" <> Fragment.hash(Fragment.canonical_input(:segment, unsafe))

    assert Fragment.encode(long) ==
             "h-" <> Fragment.hash(Fragment.canonical_input(:segment, long))
  end

  test "diagnoses missing span-bound identity inputs", %{context: context, module_iri: module_iri} do
    assert {:error, %Diagnostic{stage: :identity, details: %{field: :container_iri}}} =
             IRI.call(context, span: %{start_byte: 1, end_byte: 2})

    assert {:error, %Diagnostic{stage: :identity, details: %{field: :span}}} =
             IRI.call(context, container_iri: module_iri)
  end
end
