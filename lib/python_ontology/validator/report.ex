# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.Report do
  @moduledoc """
  Structured validation report for CLI output and tests.
  """

  alias PythonOntology.SHACL
  alias PythonOntology.Validator.Diagnostic
  alias PythonOntology.Validator.Violation

  @enforce_keys [:status, :stage]
  defstruct [
    :status,
    :stage,
    severity_counts: %{},
    violations: [],
    diagnostics: [],
    metadata: %{}
  ]

  @type status :: :pass | :fail
  @type t :: %__MODULE__{
          status: status(),
          stage: atom(),
          severity_counts: map(),
          violations: [Violation.t()],
          diagnostics: [Diagnostic.t()],
          metadata: map()
        }

  @doc """
  Builds a report from a SHACL validation result.
  """
  @spec from_shacl_result(SHACL.Result.t()) :: t()
  def from_shacl_result(%SHACL.Result{} = result) do
    violations = Enum.sort_by(result.violations, &violation_sort_key/1)
    diagnostics = Enum.sort_by(result.diagnostics, &diagnostic_sort_key/1)

    %__MODULE__{
      status: if(result.conforms?, do: :pass, else: :fail),
      stage: :shacl_validation,
      severity_counts: severity_counts(violations, diagnostics),
      violations: violations,
      diagnostics: diagnostics,
      metadata: Map.new(result.metadata)
    }
  end

  @doc """
  Returns a deterministic map representation.
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = report) do
    %{
      status: report.status,
      stage: report.stage,
      severity_counts: report.severity_counts,
      metadata: report.metadata,
      violations: Enum.map(report.violations, &Violation.to_map/1),
      diagnostics: Enum.map(report.diagnostics, &diagnostic_to_map/1)
    }
  end

  defp severity_counts(violations, diagnostics) do
    Enum.reduce(violations, %{}, fn violation, counts ->
      Map.update(counts, violation.severity, 1, &(&1 + 1))
    end)
    |> then(fn counts ->
      Enum.reduce(diagnostics, counts, fn diagnostic, counts ->
        Map.update(counts, diagnostic.severity, 1, &(&1 + 1))
      end)
    end)
  end

  defp violation_sort_key(%Violation{} = violation) do
    {to_string(violation.target_node), to_string(violation.shape), to_string(violation.path),
     to_string(violation.message)}
  end

  defp diagnostic_sort_key(%Diagnostic{} = diagnostic) do
    {to_string(diagnostic.stage), to_string(diagnostic.path), to_string(diagnostic.message)}
  end

  defp diagnostic_to_map(%Diagnostic{} = diagnostic) do
    %{
      stage: diagnostic.stage,
      severity: diagnostic.severity,
      message: diagnostic.message,
      path: diagnostic.path,
      details: Map.new(diagnostic.details)
    }
  end
end
