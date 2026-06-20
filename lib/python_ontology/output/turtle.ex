# covers: python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Output.Turtle do
  @moduledoc """
  Stable Turtle serialization for generated PythonOntology RDF triples.
  """

  alias PythonOntology.Analysis
  alias PythonOntology.Pipeline

  @type triple :: {String.t(), String.t(), String.t()}

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"
  @pytyping "https://w3id.org/python-code/typing#"
  @pyruntime "https://w3id.org/python-code/runtime#"
  @pyevolution "https://w3id.org/python-code/evolution#"

  @doc """
  Serializes generated triples to a deterministic Turtle string.
  """
  @spec to_string(term(), keyword()) :: String.t()
  def to_string(graph, opts \\ []) when is_list(opts) do
    triples = triples(graph)

    prefixes(opts) <>
      "\n" <>
      Enum.map_join(triples, "\n", &triple_line/1) <>
      "\n"
  end

  @doc """
  Writes generated triples to a Turtle file, creating parent directories as needed.
  """
  @spec write_file(term(), Path.t(), keyword()) :: :ok | {:error, term()}
  def write_file(graph, path, opts \\ []) when is_binary(path) and is_list(opts) do
    path = Path.expand(path)

    with :ok <- File.mkdir_p(Path.dirname(path)) do
      File.write(path, to_string(graph, opts))
    end
  end

  defp triples(%Analysis.Result{triples: triples}), do: triples(triples)
  defp triples(%Pipeline.Result{triples: triples}), do: triples(triples)
  defp triples(%{triples: triples}), do: triples(triples)
  defp triples(triples) when is_list(triples), do: Enum.sort_by(triples, &triple_sort_key/1)

  defp triple_sort_key({subject, predicate, object}), do: {subject, predicate, object}

  defp prefixes(_opts) do
    [
      "@prefix rdf: <#{rdf_type_namespace()}> .",
      "@prefix pycore: <#{@pycore}> .",
      "@prefix pystruct: <#{@pystruct}> .",
      "@prefix pytyping: <#{@pytyping}> .",
      "@prefix pyruntime: <#{@pyruntime}> .",
      "@prefix pyevolution: <#{@pyevolution}> ."
    ]
    |> Enum.join("\n")
  end

  defp triple_line({subject, predicate, object}) do
    "#{iri(subject)} #{iri(predicate)} #{object(object)} ."
  end

  defp iri(value), do: "<#{value}>"

  defp object(value) do
    if iri?(value) do
      iri(value)
    else
      string_literal(value)
    end
  end

  defp iri?(value), do: String.starts_with?(value, ["http://", "https://"])

  defp string_literal(value) do
    escaped =
      value
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> String.replace("\n", "\\n")
      |> String.replace("\r", "\\r")
      |> String.replace("\t", "\\t")

    "\"#{escaped}\""
  end

  defp rdf_type_namespace do
    @rdf_type
    |> String.split("#", parts: 2)
    |> hd()
    |> Kernel.<>("#")
  end
end
