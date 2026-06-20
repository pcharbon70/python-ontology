# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.Phase3IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @fixtures Path.expand("../../fixtures/python_projects", __DIR__)

  test "accepts the src layout fixture project" do
    assert {:ok, %Result{} = result} = Project.discover(fixture("src_layout"))

    assert result.root_marker.type == :pyproject

    assert Enum.map(result.files, & &1.relative_path) == [
             "src/sample_pkg/__init__.py",
             "src/sample_pkg/api.pyi",
             "src/sample_pkg/app.py",
             "tests/test_app.py"
           ]

    assert file!(result, "src/sample_pkg/app.py").package_kind == :regular
    assert file!(result, "src/sample_pkg/app.py").package_name == "sample_pkg"
    assert file!(result, "src/sample_pkg/api.pyi").stub?
    assert file!(result, "tests/test_app.py").role == :test
    assert result.metadata.skipped_reasons.default_excluded_directory == 3
  end

  test "accepts the flat layout fixture project" do
    assert {:ok, %Result{} = result} = Project.discover(fixture("flat_layout"))

    assert result.root_marker.type == :setup_py

    assert Enum.map(result.files, & &1.relative_path) == [
             "flat_pkg/__init__.py",
             "flat_pkg/core.py",
             "setup.py",
             "test_flat.py"
           ]

    assert file!(result, "flat_pkg/core.py").package_kind == :regular
    assert file!(result, "flat_pkg/core.py").package_root == ""
    assert file!(result, "flat_pkg/core.py").module_name == "flat_pkg.core"
    assert file!(result, "test_flat.py").role == :test
  end

  test "accepts the namespace package fixture project" do
    assert {:ok, %Result{} = result} = Project.discover(fixture("namespace_layout"))

    assert result.root_marker.type == :pyproject

    assert Enum.map(result.files, & &1.relative_path) == [
             "src/acme/plugins/plugin.py",
             "tests/test_plugin.py"
           ]

    plugin = file!(result, "src/acme/plugins/plugin.py")

    assert plugin.package_kind == :namespace
    assert plugin.package_root == "src"
    assert plugin.package_name == "acme.plugins"
    assert plugin.module_name == "acme.plugins.plugin"
  end

  test "fixture project parser handoff works for every selected file" do
    for fixture_name <- ["src_layout", "flat_layout", "namespace_layout"] do
      assert {:ok, %Result{} = result} = Project.discover(fixture(fixture_name))

      for input <- Project.parser_inputs(result) do
        assert {:ok, parsed} = Parser.parse_file(input.path, source_id: input.source_id)
        assert parsed.source_id == input.source_id
        assert parsed.path == input.path
      end
    end
  end

  test "fixture traversal is deterministic across repeated discovery runs" do
    results =
      for _run <- 1..5 do
        assert {:ok, %Result{} = result} = Project.discover(fixture("src_layout"))
        {Enum.map(result.files, & &1.relative_path), result.metadata}
      end

    assert Enum.uniq(results) == [hd(results)]
  end

  defp fixture(name), do: Path.join(@fixtures, name)

  defp file!(result, relative_path) do
    Enum.find(result.files, &(&1.relative_path == relative_path)) ||
      flunk("missing discovered file #{relative_path}")
  end
end
