# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.SHACL.Validator do
  @moduledoc """
  Generated graph validation entrypoint.
  """

  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator.Diagnostic
  alias PythonOntology.Validator.Turtle

  @type triple :: Result.triple()

  @doc """
  Validates a generated RDF graph against the authored PythonOntology shapes graph.

  Section 2.1 establishes graph and shapes loading. Section 2.2 adds the first
  closed-world shape checks.
  """
  @spec validate(term(), keyword()) :: {:ok, Result.t()} | {:error, [Diagnostic.t()]}
  def validate(data_graph, opts \\ []) when is_list(opts) do
    with {:ok, triples} <- normalize_graph(data_graph),
         {:ok, shapes} <- load_shapes(opts) do
      {:ok,
       %Result{
         conforms?: true,
         data_graph: triples,
         shapes_graph: shapes.graph,
         metadata: %{
           data_triple_count: length(triples),
           shapes_path: shapes.path,
           shapes_triple_count: shapes.metadata.triple_count
         }
       }}
    end
  end

  @doc """
  Returns the default shapes graph path.
  """
  @spec default_shapes_path() :: Path.t()
  def default_shapes_path do
    Path.join(Turtle.ontology_dir(), "python-shapes.ttl")
  end

  defp normalize_graph(%{triples: triples}) when is_list(triples), do: normalize_graph(triples)

  defp normalize_graph(triples) when is_list(triples) do
    if Enum.all?(triples, &triple?/1) do
      {:ok, triples}
    else
      {:error, [diagnostic("data graph triples must be {subject, predicate, object} strings")]}
    end
  end

  defp normalize_graph(_data_graph) do
    {:error, [diagnostic("data graph must be a triple list or a struct with triples")]}
  end

  defp triple?({subject, predicate, object})
       when is_binary(subject) and is_binary(predicate) and is_binary(object),
       do: true

  defp triple?(_triple), do: false

  defp load_shapes(opts) do
    opts
    |> Keyword.get(:shapes_path, default_shapes_path())
    |> Turtle.validate_file(Keyword.get(opts, :turtle_options, []))
    |> case do
      {:ok, shapes} -> {:ok, shapes}
      {:error, %Diagnostic{} = diagnostic} -> {:error, [diagnostic]}
    end
  end

  defp diagnostic(message) do
    %Diagnostic{
      stage: :shacl_validation,
      severity: :error,
      message: message
    }
  end
end
