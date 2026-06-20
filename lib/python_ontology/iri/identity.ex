# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.module_package_identity python_ontology.iri_identity_strategy.class_function_identity python_ontology.iri_identity_strategy.nested_scope_identity python_ontology.iri_identity_strategy.occurrence_disambiguation python_ontology.iri_identity_strategy.expression_span_identity python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.IRI.Identity do
  @moduledoc false

  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Fragment
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

  @doc false
  def class(%Context{} = _context, opts) when is_list(opts) do
    with {:ok, module_iri} <- required_string(opts, :module_iri),
         {:ok, lexical_path} <- lexical_path(opts) do
      build_from(module_iri, ["class"] ++ lexical_path ++ disambiguation_segments(opts))
    end
  end

  @doc false
  def function(%Context{} = _context, opts) when is_list(opts) do
    with {:ok, module_iri} <- required_string(opts, :module_iri),
         {:ok, lexical_path} <- lexical_path(opts) do
      kind = if Keyword.get(opts, :method?, false), do: "method", else: "function"
      build_from(module_iri, [kind] ++ lexical_path ++ disambiguation_segments(opts))
    end
  end

  @doc false
  def import_statement(%Context{} = _context, opts), do: span_bound_resource(opts, "import")

  @doc false
  def assignment(%Context{} = _context, opts), do: span_bound_resource(opts, "assignment")

  @doc false
  def call(%Context{} = _context, opts), do: span_bound_resource(opts, "call")

  @doc false
  def attribute(%Context{} = _context, opts), do: span_bound_resource(opts, "attribute")

  @doc false
  def subscript(%Context{} = _context, opts), do: span_bound_resource(opts, "subscript")

  @doc false
  def expression(%Context{} = _context, opts) do
    expression_kind = Keyword.get(opts, :kind, "expression")
    span_bound_resource(opts, ["expression", expression_kind])
  end

  @doc false
  def source_location(%Context{} = _context, opts), do: span_bound_resource(opts, "location")

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
    build_from(context.base_iri, segments)
  end

  defp build_from(base, segments) do
    encoded_segments =
      segments
      |> Enum.map(&encode_segment/1)
      |> Enum.reject(&(&1 == ""))

    {:ok, base <> separator(base) <> Enum.join(encoded_segments, "/")}
  end

  defp separator(base) do
    if String.ends_with?(base, ["/", "#"]), do: "", else: "/"
  end

  defp lexical_path(opts) do
    cond do
      is_list(opts[:lexical_path]) ->
        validate_lexical_path(opts[:lexical_path])

      is_binary(opts[:name]) and opts[:name] != "" ->
        opts[:name]
        |> String.split(".", trim: true)
        |> validate_lexical_path()

      true ->
        identity_error(
          :lexical_path,
          Keyword.get(opts, :lexical_path),
          "lexical_path or name is required"
        )
    end
  end

  defp validate_lexical_path(path) do
    if path != [] and Enum.all?(path, &(is_binary(&1) and &1 != "")) do
      {:ok, path}
    else
      identity_error(:lexical_path, path, "lexical_path must contain non-empty strings")
    end
  end

  defp disambiguation_segments(opts) do
    occurrence = Keyword.get(opts, :occurrence, 1)
    span = Keyword.get(opts, :span)

    []
    |> append_occurrence(occurrence)
    |> append_span(span)
  end

  defp append_occurrence(segments, occurrence) when is_integer(occurrence) and occurrence > 1 do
    segments ++ ["occurrence", Integer.to_string(occurrence)]
  end

  defp append_occurrence(segments, _occurrence), do: segments

  defp append_span(segments, nil), do: segments

  defp append_span(segments, span) do
    case span_bytes(span) do
      {start_byte, end_byte} -> segments ++ ["span", "b#{start_byte}-#{end_byte}"]
      nil -> segments
    end
  end

  defp span_bytes(%{byte: %{start: start_byte, end: end_byte}}), do: {start_byte, end_byte}
  defp span_bytes(%{start_byte: start_byte, end_byte: end_byte}), do: {start_byte, end_byte}
  defp span_bytes(_span), do: nil

  defp span_bound_resource(opts, kind) do
    with {:ok, container_iri} <- required_string(opts, :container_iri),
         {:ok, span_segment} <- required_span_segment(opts) do
      kind_segments = List.wrap(kind)
      build_from(container_iri, kind_segments ++ [span_segment])
    end
  end

  defp required_span_segment(opts) do
    case Keyword.fetch(opts, :span) do
      {:ok, span} ->
        case span_bytes(span) do
          {start_byte, end_byte} ->
            {:ok, "b#{start_byte}-#{end_byte}"}

          nil ->
            identity_error(:span, span, "span must include byte start and end")
        end

      :error ->
        identity_error(:span, nil, "span is required")
    end
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

  defp encode_segment(segment), do: Fragment.encode(segment)
end
