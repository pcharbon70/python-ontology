# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Extractors.ContextTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Extractors.Context
  alias PythonOntology.Parser
  alias PythonOntology.Pipeline.Diagnostic
  alias PythonOntology.Project
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_projects/src_layout", __DIR__)

  test "builds context from project source file, parser metadata, syntax root, and IRI options" do
    assert {:ok, project} = Project.discover(@fixture)
    source_file = Enum.find(project.files, &(&1.relative_path == "src/sample_pkg/app.py"))

    assert {:ok, parsed} =
             Parser.parse_file(source_file.path, source_id: source_file.relative_path)

    assert {:ok, syntax_root} = Syntax.normalize(parsed)

    assert {:ok, context} =
             Context.from_parser_result(parsed, syntax_root,
               project_root: project.root_path,
               source_file: source_file,
               base_iri: "https://analysis.example/python/"
             )

    assert context.project_root == project.root_path
    assert context.source_file == source_file
    assert context.source_id == "src/sample_pkg/app.py"
    assert context.source_path == source_file.path
    assert context.relative_path == "src/sample_pkg/app.py"
    assert context.package_kind == :regular
    assert context.package_name == "sample_pkg"
    assert context.module_name == "sample_pkg.app"
    assert context.parser_metadata.adapter == "PythonOntology.Parser.TreeSitter"
    assert context.syntax_root == syntax_root
    assert context.iri_context.base_iri == "https://analysis.example/python/"
    assert context.iri_context.repository_root == project.root_path
  end

  test "accumulates structured diagnostics explicitly" do
    assert {:ok, context} = Context.new(source_id: "memory://module.py")

    diagnostic = %Diagnostic{
      stage: :extractor,
      severity: :warning,
      message: "unsupported syntax",
      source_id: context.source_id
    }

    assert %{diagnostics: [^diagnostic]} = Context.add_diagnostic(context, diagnostic)
  end
end
