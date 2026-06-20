# covers: package.python_ontology.public_analysis_api python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Analysis.PublicAPITest do
  use ExUnit.Case, async: true

  alias PythonOntology.Analysis.Result
  alias PythonOntology.Project.Diagnostic

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @project_fixture Path.expand("../../fixtures/python_projects/src_layout", __DIR__)
  @base_iri "https://analysis.example/python/"

  test "analyze_file returns graph diagnostics options and validation status" do
    assert {:ok, %Result{} = result} =
             PythonOntology.analyze_file(@fixture, base_iri: @base_iri)

    assert result.mode == :file
    assert [file] = result.files

    assert String.ends_with?(
             file.relative_path,
             "test/fixtures/python_parser/valid/first_slice.py"
           )

    assert length(result.pipeline_results) == 1
    assert length(result.triples) > 0
    assert result.options.base_iri == @base_iri
    assert result.options.validate?
    assert result.validation_status == :pass
    assert result.validation_report.status == :pass
    assert result.metadata.analyzed_file_count == 1
    assert result.metadata.triple_count == length(result.triples)
  end

  test "analyze_project discovers project files and merges graphs deterministically" do
    assert {:ok, %Result{} = first} =
             PythonOntology.analyze_project(@project_fixture, base_iri: @base_iri)

    assert {:ok, %Result{} = second} =
             PythonOntology.analyze_project(@project_fixture, base_iri: @base_iri)

    assert first.mode == :project

    assert Enum.map(first.files, & &1.relative_path) == [
             "src/sample_pkg/__init__.py",
             "src/sample_pkg/api.pyi",
             "src/sample_pkg/app.py",
             "tests/test_app.py"
           ]

    assert length(first.pipeline_results) == 4
    assert first.triples == second.triples
    assert first.validation_status == :pass
    assert first.metadata.analyzed_file_count == 4
    assert first.metadata.triple_count == length(first.triples)
  end

  test "analyze_file can skip validation when requested" do
    assert {:ok, %Result{} = result} =
             PythonOntology.analyze_file(@fixture,
               base_iri: @base_iri,
               validate?: false
             )

    assert result.validation_status == :not_run
    assert result.validation_result == nil
    assert result.validation_report == nil
  end

  test "analysis entrypoints enforce file and project input modes" do
    assert {:error, %Diagnostic{} = diagnostic} =
             PythonOntology.analyze_file(@project_fixture, base_iri: @base_iri)

    assert diagnostic.stage == :analysis_input
    assert diagnostic.details == %{actual_mode: :project, expected_mode: :file}

    assert {:error, %Diagnostic{} = diagnostic} =
             PythonOntology.analyze_project(@fixture, base_iri: @base_iri)

    assert diagnostic.stage == :analysis_input
    assert diagnostic.details == %{actual_mode: :file, expected_mode: :project}
  end
end
