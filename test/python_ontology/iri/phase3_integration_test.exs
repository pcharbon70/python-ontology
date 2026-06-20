# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.expression_span_identity python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.Phase3IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Fragment
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @repository_root Path.expand("../../fixtures", __DIR__)

  test "generates span-bound IRIs from normalized first-slice syntax" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, syntax} = Syntax.normalize(parsed)

    assert {:ok, context} =
             IRI.context(
               base_iri: "https://analysis.example/python/",
               repository_root: @repository_root
             )

    assert {:ok, module_iri} =
             IRI.module(context,
               name: "python_parser.valid.first_slice",
               source_path: @fixture
             )

    import = Enum.find(syntax.body, &match?(%Syntax.Import{}, &1))
    assignment = syntax |> Syntax.descendants() |> Enum.find(&match?(%Syntax.Assignment{}, &1))
    call = syntax |> Syntax.descendants() |> Enum.find(&match?(%Syntax.Call{}, &1))
    attribute = syntax |> Syntax.descendants() |> Enum.find(&match?(%Syntax.Attribute{}, &1))

    assert {:ok, import_iri} =
             IRI.import_statement(context, container_iri: module_iri, span: import.info.span)

    assert {:ok, assignment_iri} =
             IRI.assignment(context, container_iri: module_iri, span: assignment.info.span)

    assert {:ok, call_iri} =
             IRI.call(context, container_iri: module_iri, span: call.info.span)

    assert {:ok, attribute_iri} =
             IRI.attribute(context, container_iri: module_iri, span: attribute.info.span)

    assert {:ok, location_iri} =
             IRI.source_location(context, container_iri: module_iri, span: call.info.span)

    assert import_iri =~ "/import/b"
    assert assignment_iri =~ "/assignment/b"
    assert call_iri =~ "/call/b"
    assert attribute_iri =~ "/attribute/b"
    assert location_iri =~ "/location/b"

    assert {:ok, ^call_iri} = IRI.call(context, container_iri: module_iri, span: call.info.span)
  end

  test "uses canonical hash inputs for unsafe expression fragments" do
    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    assert {:ok, module_iri} =
             IRI.module(context, name: "pkg.module", source_path: "src/pkg/module.py")

    unsafe_kind = "operator expression with spaces / slash"
    encoded_kind = Fragment.encode(unsafe_kind)

    assert encoded_kind ==
             "h-" <> Fragment.hash(Fragment.canonical_input(:segment, unsafe_kind))

    assert {:ok, iri} =
             IRI.expression(context,
               container_iri: module_iri,
               kind: unsafe_kind,
               span: %{start_byte: 10, end_byte: 18}
             )

    assert iri == module_iri <> "/expression/#{encoded_kind}/b10-18"
  end
end
