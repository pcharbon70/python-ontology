# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order
defmodule PythonOntology.Analysis.Phase3ProjectAcceptanceTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias PythonOntology.Output.Turtle
  alias PythonOntology.Validator

  @base_iri "https://analysis.example/python/"
  @fixture_project Path.expand("../../fixtures/python_initial_slice/project", __DIR__)

  setup do
    tmp_dir =
      Path.join(System.tmp_dir!(), "python_ontology_phase3_project_#{System.unique_integer()}")

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  test "public API analyzes the fixture project through validated Turtle output", %{
    tmp_dir: tmp_dir
  } do
    assert {:ok, result} = PythonOntology.analyze_project(@fixture_project, base_iri: @base_iri)

    assert result.validation_status == :pass

    assert Enum.map(result.files, & &1.relative_path) == [
             "src/initial_slice_pkg/__init__.py",
             "src/initial_slice_pkg/api.pyi",
             "src/initial_slice_pkg/complete.py",
             "tests/test_complete.py"
           ]

    refute Enum.any?(result.files, &String.starts_with?(&1.relative_path, "build/"))
    refute Enum.any?(result.files, &String.starts_with?(&1.relative_path, ".venv/"))

    facts = Enum.flat_map(result.pipeline_results, & &1.facts)
    assert Enum.any?(facts, &(&1.kind == :package and &1.name == "initial_slice_pkg"))
    assert Enum.any?(facts, &(&1.kind == :import_alias and &1.name == "Subject"))
    assert Enum.any?(facts, &(&1.kind == :class and &1.name == "Example"))
    assert Enum.any?(facts, &(&1.kind == :method and &1.name == "method"))
    assert Enum.any?(facts, &(&1.kind == :subscript))
    assert Enum.any?(facts, &(&1.confidence == :runtime_dependent))
    assert Enum.any?(facts, &(&1.confidence == :unresolved))

    output_path = Path.join(tmp_dir, "api-output.ttl")
    assert :ok = Turtle.write_file(result, output_path)
    assert {:ok, parsed} = Validator.Turtle.validate_file(output_path)
    assert parsed.metadata.triple_count == length(result.triples)
  end

  test "Mix task analyzes the fixture project and writes parseable Turtle", %{tmp_dir: tmp_dir} do
    output_path = Path.join(tmp_dir, "task-output.ttl")
    Mix.Task.reenable("python_ontology.analyze")

    assert capture_io(fn ->
             Mix.Tasks.PythonOntology.Analyze.run([
               @fixture_project,
               "--base-iri",
               @base_iri,
               "--output",
               output_path
             ])
           end) == ""

    output = File.read!(output_path)

    assert output =~ "@prefix pycore:"
    assert output =~ "@prefix pystruct:"
    assert output =~ "runtime_dependent"
    assert output =~ "unresolved"

    assert {:ok, parsed} = Validator.Turtle.validate_file(output_path)
    assert parsed.metadata.triple_count > 0
  end
end
