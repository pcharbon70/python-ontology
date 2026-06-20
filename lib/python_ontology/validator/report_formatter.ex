# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.ReportFormatter do
  @moduledoc """
  Human and machine formatting for validation reports.
  """

  alias PythonOntology.Validator.Report

  @type format :: :text | :json

  @doc """
  Formats a validation report.
  """
  @spec format(Report.t(), format()) :: {:ok, String.t()} | {:error, String.t()}
  def format(%Report{} = report, :text), do: {:ok, text(report)}
  def format(%Report{} = report, :json), do: {:ok, json(Report.to_map(report))}

  def format(%Report{}, format),
    do: {:error, "unsupported validation report format #{inspect(format)}"}

  @doc """
  Formats a validation report or raises on unsupported formats.
  """
  @spec format!(Report.t(), format()) :: String.t()
  def format!(%Report{} = report, format) do
    case format(report, format) do
      {:ok, output} -> output
      {:error, message} -> raise ArgumentError, message
    end
  end

  defp text(%Report{} = report) do
    lines =
      [
        "status: #{report.status}",
        "stage: #{report.stage}",
        "violations: #{length(report.violations)}",
        "diagnostics: #{length(report.diagnostics)}"
      ] ++ violation_lines(report) ++ diagnostic_lines(report)

    Enum.join(lines, "\n") <> "\n"
  end

  defp violation_lines(%Report{violations: []}), do: []

  defp violation_lines(%Report{} = report) do
    ["", "validation violations:"] ++
      Enum.flat_map(report.violations, fn violation ->
        [
          "- target: #{violation.target_node}",
          "  shape: #{violation.shape}",
          "  path: #{violation.path}",
          "  message: #{violation.message}"
        ]
      end)
  end

  defp diagnostic_lines(%Report{diagnostics: []}), do: []

  defp diagnostic_lines(%Report{} = report) do
    ["", "validation diagnostics:"] ++
      Enum.flat_map(report.diagnostics, fn diagnostic ->
        [
          "- stage: #{diagnostic.stage}",
          "  severity: #{diagnostic.severity}",
          "  message: #{diagnostic.message}"
        ]
      end)
  end

  defp json(value) when is_map(value) do
    value
    |> Enum.sort_by(fn {key, _value} -> to_string(key) end)
    |> Enum.map(fn {key, value} -> json_string(to_string(key)) <> ":" <> json(value) end)
    |> Enum.join(",")
    |> then(&("{" <> &1 <> "}"))
  end

  defp json(value) when is_list(value) do
    value
    |> Enum.map(&json/1)
    |> Enum.join(",")
    |> then(&("[" <> &1 <> "]"))
  end

  defp json(nil), do: "null"
  defp json(true), do: "true"
  defp json(false), do: "false"
  defp json(value) when is_atom(value), do: json_string(Atom.to_string(value))
  defp json(value) when is_binary(value), do: json_string(value)
  defp json(value) when is_integer(value), do: Integer.to_string(value)
  defp json(value) when is_float(value), do: Float.to_string(value)

  defp json_string(value) do
    escaped =
      value
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> String.replace("\n", "\\n")
      |> String.replace("\r", "\\r")
      |> String.replace("\t", "\\t")

    "\"" <> escaped <> "\""
  end
end
