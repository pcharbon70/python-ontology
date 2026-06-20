# covers: python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Analysis.Phase1IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @base_iri "https://analysis.example/python/"

  setup do
    tmp_dir =
      Path.join(System.tmp_dir!(), "python_ontology_analysis_phase1_#{System.unique_integer()}")

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  test "Mix task writes Turtle output for a Python file", %{tmp_dir: tmp_dir} do
    output_path = Path.join(tmp_dir, "analysis.ttl")

    Mix.Task.reenable("python_ontology.analyze")

    assert capture_io(fn ->
             Mix.Tasks.PythonOntology.Analyze.run([
               @fixture,
               "--base-iri",
               @base_iri,
               "--output",
               output_path
             ])
           end) == ""

    output = File.read!(output_path)

    assert output =~ "@prefix pycore:"
    assert output =~ "@prefix pystruct:"
    assert output =~ "<#{@base_iri}"
    refute output =~ "moduleName> \"false\""
  end
end
