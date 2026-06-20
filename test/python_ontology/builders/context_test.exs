# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.fact_confidence_model.builder_propagation python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Builders.ContextTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Builders.Context
  alias PythonOntology.Pipeline.Diagnostic

  test "builds builder context with shared IRI and vocabulary helpers" do
    assert {:ok, context} =
             Context.new(
               base_iri: "https://analysis.example/python/",
               repository_root: "/tmp/project",
               namespaces: %{py: "https://w3id.org/python-code/structure#"},
               confidence_options: [include_evidence?: true]
             )

    assert context.iri_context.base_iri == "https://analysis.example/python/"
    assert context.iri_context.repository_root == "/tmp/project"
    assert context.namespaces.py == "https://w3id.org/python-code/structure#"
    assert context.confidence_options.include_evidence?

    assert Context.vocabulary(context, :structure, :Module) ==
             "https://w3id.org/python-code/structure#Module"

    assert {:ok, "https://analysis.example/python/module/sample"} =
             Context.resource(context, ["module", "sample"])
  end

  test "accumulates structured diagnostics explicitly" do
    assert {:ok, context} = Context.new()

    diagnostic = %Diagnostic{
      stage: :builder,
      severity: :error,
      message: "missing fact field"
    }

    assert %{diagnostics: [^diagnostic]} = Context.add_diagnostic(context, diagnostic)
  end
end
