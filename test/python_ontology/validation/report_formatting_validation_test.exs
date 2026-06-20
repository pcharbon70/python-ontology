# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.ReportFormattingValidationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Validator.Command
  alias PythonOntology.Validator.Report
  alias PythonOntology.Validator.ReportFormatter
  alias PythonOntology.Validator.Violation

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"

  test "formats validation reports for humans" do
    report = failing_report()

    assert {:ok, text} = ReportFormatter.format(report, :text)
    assert text =~ "status: fail"
    assert text =~ "violations: 1"
    assert text =~ "target: module"
    assert text =~ "message: module requires moduleName"
  end

  test "formats validation reports as deterministic JSON" do
    report = failing_report()

    assert {:ok, first} = ReportFormatter.format(report, :json)
    assert {:ok, second} = ReportFormatter.format(report, :json)
    assert first == second

    decoded = Jason.decode!(first)
    assert decoded["status"] == "fail"
    assert decoded["violations"] |> hd() |> Map.fetch!("target_node") == "module"
  end

  test "returns command exit status for passing and failing generated graph validation" do
    assert {:ok, pass} = Command.validate_graph(valid_graph(), format: :json)
    assert pass.exit_status == 0
    assert pass.report.status == :pass

    assert {:error, fail} =
             Command.validate_graph([{"module", @rdf_type, iri(:structure, "Module")}])

    assert fail.exit_status == 1
    assert fail.report.status == :fail
    assert fail.output =~ "status: fail"
  end

  defp failing_report do
    %Report{
      status: :fail,
      stage: :shacl_validation,
      severity_counts: %{violation: 1},
      violations: [
        %Violation{
          target_node: "module",
          shape: "ModuleShape",
          path: iri(:structure, "moduleName"),
          message: "module requires moduleName"
        }
      ],
      metadata: %{data_triple_count: 1}
    }
  end

  defp valid_graph do
    [
      {"module", @rdf_type, iri(:structure, "Module")},
      {"module", iri(:structure, "moduleName"), "sample"},
      {"module", iri(:core, "hasLocation"), "location"},
      {"location", @rdf_type, iri(:core, "SourceLocation")},
      {"location", iri(:core, "line"), "1"},
      {"location", iri(:core, "column"), "0"}
    ]
  end

  defp iri(:core, term), do: @pycore <> term
  defp iri(:structure, term), do: @pystruct <> term
end
