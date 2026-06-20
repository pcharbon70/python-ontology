# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.InputTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Diagnostic
  alias PythonOntology.Project.Input

  @tmp_root Path.expand("../../tmp/project_input_test", __DIR__)

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "detects explicit Python source file paths" do
    path = Path.join(@tmp_root, "module.py")
    File.write!(path, "x = 1\n")

    assert {:ok, %Input{mode: :file, path: expanded, extension: ".py"}} =
             Project.classify_input(path)

    assert expanded == Path.expand(path)
  end

  test "detects explicit Python stub file paths" do
    path = Path.join(@tmp_root, "module.pyi")
    File.write!(path, "x: int\n")

    assert {:ok, %Input{mode: :file, extension: ".pyi"}} = Project.classify_input(path)
  end

  test "detects explicit directory paths" do
    path = Path.join(@tmp_root, "project")
    File.mkdir_p!(path)

    assert {:ok, %Input{mode: :project, path: expanded, extension: nil}} =
             Project.classify_input(path)

    assert expanded == Path.expand(path)
  end

  test "returns diagnostics for missing and unsupported paths" do
    assert {:error, %Diagnostic{stage: :input, severity: :error, path: missing_path}} =
             Project.classify_input(Path.join(@tmp_root, "missing.py"))

    assert missing_path == Path.expand(Path.join(@tmp_root, "missing.py"))

    unsupported = Path.join(@tmp_root, "README.md")
    File.write!(unsupported, "# docs\n")

    assert {:error, %Diagnostic{stage: :input, details: %{extension: ".md"}}} =
             Project.classify_input(unsupported)
  end
end
