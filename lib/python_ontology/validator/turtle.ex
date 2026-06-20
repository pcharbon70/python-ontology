# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.owl_open_world python_ontology.validation_strategy.no_validation_by_execution python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.Turtle do
  @moduledoc """
  Parse gate for authored Turtle ontology files.
  """

  alias PythonOntology.Validator.Diagnostic

  @type parse_result :: %{
          path: Path.t(),
          graph: term(),
          metadata: map()
        }

  @doc """
  Returns the default ontology directory.
  """
  @spec ontology_dir() :: Path.t()
  def ontology_dir do
    case :code.priv_dir(:python_ontology) do
      {:error, _reason} -> Path.expand("../../../priv/ontologies", __DIR__)
      path -> Path.join(to_string(path), "ontologies")
    end
  end

  @doc """
  Returns authored Turtle ontology files in deterministic order.
  """
  @spec ontology_files(Path.t()) :: [Path.t()]
  def ontology_files(dir \\ ontology_dir()) when is_binary(dir) do
    dir
    |> Path.join("*.ttl")
    |> Path.wildcard()
    |> Enum.sort()
  end

  @doc """
  Parses every authored Turtle file under a directory.
  """
  @spec validate_directory(Path.t(), keyword()) ::
          {:ok, [parse_result()]} | {:error, [Diagnostic.t()]}
  def validate_directory(dir \\ ontology_dir(), opts \\ [])
      when is_binary(dir) and is_list(opts) do
    dir
    |> ontology_files()
    |> validate_files(opts)
  end

  @doc """
  Parses an explicit list of Turtle files.
  """
  @spec validate_files([Path.t()], keyword()) ::
          {:ok, [parse_result()]} | {:error, [Diagnostic.t()]}
  def validate_files(paths, opts \\ []) when is_list(paths) and is_list(opts) do
    paths
    |> Enum.sort()
    |> Enum.map(&validate_file(&1, opts))
    |> split_results()
  end

  @doc """
  Parses one Turtle file.
  """
  @spec validate_file(Path.t(), keyword()) :: {:ok, parse_result()} | {:error, Diagnostic.t()}
  def validate_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    normalized_path = Path.expand(path)

    case RDF.Turtle.read_file(normalized_path, opts) do
      {:ok, graph} ->
        {:ok,
         %{
           path: normalized_path,
           graph: graph,
           metadata: %{
             triple_count: triple_count(graph)
           }
         }}

      {:error, reason} ->
        {:error,
         %Diagnostic{
           stage: :turtle_parse,
           severity: :error,
           message: "Turtle parse failed for #{normalized_path}",
           path: normalized_path,
           details: %{reason: inspect(reason)}
         }}
    end
  end

  defp split_results(results) do
    {oks, errors} =
      Enum.reduce(results, {[], []}, fn
        {:ok, result}, {oks, errors} -> {[result | oks], errors}
        {:error, diagnostic}, {oks, errors} -> {oks, [diagnostic | errors]}
      end)

    case Enum.reverse(errors) do
      [] -> {:ok, Enum.reverse(oks)}
      diagnostics -> {:error, diagnostics}
    end
  end

  defp triple_count(graph) do
    Enum.count(graph)
  rescue
    _exception -> nil
  end
end
