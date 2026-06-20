# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.normalized_output python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Parser do
  @moduledoc """
  Public parser API for Python source text and files.
  """

  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Parser.Result
  alias PythonOntology.Parser.TreeSitter

  @type option ::
          {:source_id, String.t()}
          | {:path, Path.t()}
          | {:adapter, module()}

  @doc """
  Parses Python source text with an explicit source identity.
  """
  @spec parse_string(String.t(), [option()]) :: {:ok, Result.t()} | {:error, Diagnostic.t()}
  def parse_string(source, opts) when is_binary(source) and is_list(opts) do
    with {:ok, source_id} <- fetch_source_id(opts),
         {:ok, parsed} <- adapter(opts).parse_string(source) do
      {:ok, result(parsed, source_id, normalize_optional_path(opts[:path]), opts)}
    else
      {:error, %Diagnostic{} = diagnostic} ->
        {:error, diagnostic}

      {:error, reason} ->
        {:error, parser_diagnostic(reason, opts)}
    end
  end

  @doc """
  Parses a Python source file.
  """
  @spec parse_file(Path.t(), [option()]) :: {:ok, Result.t()} | {:error, Diagnostic.t()}
  def parse_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    normalized_path = Path.expand(path)
    source_id = Keyword.get(opts, :source_id, normalized_path)
    opts = opts |> Keyword.put(:source_id, source_id) |> Keyword.put(:path, normalized_path)

    case File.read(normalized_path) do
      {:ok, source} ->
        parse_string(source, opts)

      {:error, reason} ->
        {:error, file_read_diagnostic(reason, source_id, normalized_path)}
    end
  end

  defp result(parsed, source_id, path, opts) do
    %Result{
      source_id: source_id,
      path: path,
      root: parsed.root,
      metadata: metadata(parsed, opts),
      diagnostics: [],
      has_error: parsed.has_error
    }
  end

  defp metadata(parsed, opts) do
    parsed
    |> Map.take([
      :adapter,
      :language,
      :grammar,
      :tree_sitter_language_version,
      :tree_sitter_min_compatible_language_version,
      :grammar_abi_version,
      :tree_sitter_python_crate_version
    ])
    |> Map.put(:options, public_options(opts))
  end

  defp public_options(opts) do
    opts
    |> Keyword.drop([:adapter])
    |> Map.new()
  end

  defp fetch_source_id(opts) do
    case Keyword.fetch(opts, :source_id) do
      {:ok, source_id} when is_binary(source_id) and source_id != "" ->
        {:ok, source_id}

      _ ->
        {:error,
         %Diagnostic{
           stage: :source_identity,
           severity: :error,
           message: "parse_string/2 requires a non-empty :source_id option"
         }}
    end
  end

  defp normalize_optional_path(nil), do: nil
  defp normalize_optional_path(path) when is_binary(path), do: Path.expand(path)

  defp adapter(opts), do: Keyword.get(opts, :adapter, TreeSitter)

  defp parser_diagnostic(reason, opts) do
    %Diagnostic{
      stage: :parser,
      severity: :error,
      message: "parser failed: #{inspect(reason)}",
      source_id: Keyword.get(opts, :source_id),
      path: normalize_optional_path(opts[:path]),
      raw: reason
    }
  end

  defp file_read_diagnostic(reason, source_id, path) do
    %Diagnostic{
      stage: :file_read,
      severity: :error,
      message: "could not read Python source file: #{:file.format_error(reason)}",
      source_id: source_id,
      path: path,
      raw: reason
    }
  end
end
