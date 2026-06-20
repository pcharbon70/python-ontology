# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.Command do
  @moduledoc """
  Command adapter for validation flows used by tests and future Mix tasks.
  """

  alias PythonOntology.Validator
  alias PythonOntology.Validator.CommandResult
  alias PythonOntology.Validator.Report
  alias PythonOntology.Validator.ReportFormatter

  @doc """
  Validates a generated graph and returns command-style output and exit status.
  """
  @spec validate_graph(term(), keyword()) ::
          {:ok, CommandResult.t()} | {:error, CommandResult.t()}
  def validate_graph(data_graph, opts \\ []) when is_list(opts) do
    format = Keyword.get(opts, :format, :text)

    report =
      case Validator.validate_graph(data_graph, opts) do
        {:ok, result} -> Report.from_shacl_result(result)
        {:error, diagnostics} -> Report.from_diagnostics(diagnostics)
      end

    result = command_result(report, format)

    if result.exit_status == 0 do
      {:ok, result}
    else
      {:error, result}
    end
  end

  defp command_result(%Report{} = report, format) do
    %CommandResult{
      exit_status: exit_status(report),
      format: format,
      output: ReportFormatter.format!(report, format),
      report: report
    }
  end

  defp exit_status(%Report{status: :pass}), do: 0
  defp exit_status(%Report{}), do: 1
end
