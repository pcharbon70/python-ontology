# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.ReportModelValidationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator.Report
  alias PythonOntology.Validator.Violation

  test "builds deterministic report fields from SHACL results" do
    result = %Result{
      conforms?: false,
      data_graph: [],
      metadata: %{shapes_path: "priv/ontologies/python-shapes.ttl", data_triple_count: 4},
      violations: [
        %Violation{
          target_node: "z",
          shape: "SourceLocationShape",
          path: "line",
          message: "line must be integer"
        },
        %Violation{
          target_node: "a",
          shape: "ModuleShape",
          path: "moduleName",
          message: "module requires moduleName",
          source: "source-a",
          source_context: %{source_node: "source-a"}
        }
      ]
    }

    report = Report.from_shacl_result(result)

    assert report.status == :fail
    assert report.stage == :shacl_validation
    assert report.severity_counts == %{violation: 2}
    assert report.metadata.shapes_path == "priv/ontologies/python-shapes.ttl"
    assert Enum.map(report.violations, & &1.target_node) == ["a", "z"]

    report_map = Report.to_map(report)

    assert report_map.status == :fail

    assert report_map.violations |> hd() |> Map.fetch!(:source_context) == %{
             source_node: "source-a"
           }

    assert report_map == report |> Report.to_map()
  end

  test "reports passing SHACL results without violations" do
    report = Report.from_shacl_result(%Result{conforms?: true, data_graph: [], metadata: %{}})

    assert report.status == :pass
    assert report.severity_counts == %{}
    assert Report.to_map(report).violations == []
  end
end
