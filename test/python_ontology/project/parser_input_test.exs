# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.ParserInputTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @fixtures Path.expand("../../fixtures/python_projects", __DIR__)

  test "returns parser-ready inputs with summary metadata from discovered files" do
    fixture = Path.join(@fixtures, "src_layout")

    assert {:ok, %Result{} = result} = Project.discover(fixture)
    assert result.diagnostics == []

    assert result.metadata.selected_count == 4
    assert result.metadata.file_count == 4
    assert result.metadata.source_file_count == 3
    assert result.metadata.test_file_count == 1
    assert result.metadata.stub_file_count == 1
    assert result.metadata.package_file_count == 3
    assert result.metadata.regular_package_count == 1
    assert result.metadata.namespace_package_count == 0
    assert result.metadata.skipped_reasons.default_excluded_directory == 3

    parser_inputs = Project.parser_inputs(result)

    assert Enum.map(parser_inputs, & &1.source_id) == [
             "src/sample_pkg/__init__.py",
             "src/sample_pkg/api.pyi",
             "src/sample_pkg/app.py",
             "tests/test_app.py"
           ]

    for input <- parser_inputs do
      assert Path.type(input.path) == :absolute
      assert File.regular?(input.path)
      assert input.source_id == input.relative_path
      assert input.source_file.relative_path == input.relative_path

      assert {:ok, parsed} = Parser.parse_file(input.path, source_id: input.source_id)
      assert parsed.path == input.path
      assert parsed.source_id == input.source_id
    end
  end
end
