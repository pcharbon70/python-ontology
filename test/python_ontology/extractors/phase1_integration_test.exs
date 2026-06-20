# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Extractors.Phase1IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Extractors.Context
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Parser
  alias PythonOntology.Pipeline.Diagnostic
  alias PythonOntology.Project
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_projects/src_layout", __DIR__)

  test "context and fact contracts preserve source metadata, confidence, and diagnostics" do
    assert {:ok, project} = Project.discover(@fixture)
    source_file = Enum.find(project.files, &(&1.relative_path == "src/sample_pkg/app.py"))

    assert {:ok, parsed} =
             Parser.parse_file(source_file.path, source_id: source_file.relative_path)

    assert {:ok, syntax_root} = Syntax.normalize(parsed)

    assert {:ok, context} =
             Context.from_parser_result(parsed, syntax_root,
               project_root: project.root_path,
               source_file: source_file
             )

    source_evidence =
      Confidence.source_evidence(
        source_id: context.source_id,
        path: context.source_path,
        details: [module_name: context.module_name]
      )

    diagnostic = %Diagnostic{
      stage: :extractor,
      severity: :info,
      message: "contract fixture diagnostic",
      source_id: context.source_id,
      path: context.source_path
    }

    assert {:ok, fact} =
             Fact.module(
               id: "module:#{context.module_name}",
               name: context.module_name,
               source_id: context.source_id,
               path: context.source_path,
               identity: %{module_name: context.module_name},
               evidence: [source_evidence],
               diagnostics: [diagnostic]
             )

    assert fact.confidence == :source_declared
    assert fact.evidence == [source_evidence]
    assert fact.diagnostics == [diagnostic]
    refute match?({_, _, _}, fact)
  end
end
