# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.module_package_identity python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.IRI.Identity do
  @moduledoc false

  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Path

  @doc false
  def package(%Context{} = context, opts) when is_list(opts) do
    kind = Keyword.get(opts, :kind, :regular)

    with {:ok, name} <- required_string(opts, :name),
         {:ok, path_segments} <- package_path_segments(context, kind, opts) do
      build(context, ["package", Atom.to_string(kind), name] ++ path_segments)
    end
  end

  @doc false
  def module(%Context{} = context, opts) when is_list(opts) do
    with {:ok, name} <- required_string(opts, :name),
         {:ok, source_path} <- required_path(context, opts, :source_path) do
      module_kind =
        if Keyword.get(opts, :stub?, String.ends_with?(source_path, ".pyi")),
          do: "stub",
          else: "source"

      build(context, ["module", module_kind, name, "source"] ++ String.split(source_path, "/"))
    end
  end

  defp package_path_segments(context, :regular, opts) do
    with {:ok, source_path} <- required_path(context, opts, :source_path) do
      {:ok, ["source"] ++ String.split(source_path, "/")}
    end
  end

  defp package_path_segments(context, :namespace, opts) do
    with {:ok, root_path} <- required_path(context, opts, :root_path) do
      {:ok, ["root"] ++ String.split(root_path, "/")}
    end
  end

  defp package_path_segments(_context, kind, _opts) do
    identity_error(:kind, kind, "package kind must be :regular or :namespace")
  end

  @doc false
  def build(%Context{} = context, segments) when is_list(segments) do
    encoded_segments =
      segments
      |> Enum.map(&encode_segment/1)
      |> Enum.reject(&(&1 == ""))

    {:ok, context.base_iri <> Enum.join(encoded_segments, "/")}
  end

  defp required_path(context, opts, key) do
    with {:ok, value} <- required_string(opts, key) do
      Path.canonicalize(value, context)
    end
  end

  defp required_string(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_binary(value) and value != "" ->
        {:ok, value}

      {:ok, value} ->
        identity_error(key, value, "#{key} must be a non-empty string")

      :error ->
        identity_error(key, nil, "#{key} is required")
    end
  end

  defp identity_error(field, input, message) do
    {:error,
     %Diagnostic{
       stage: :identity,
       severity: :error,
       message: message,
       input: input,
       details: %{field: field}
     }}
  end

  defp encode_segment(segment) do
    segment
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
  end
end
