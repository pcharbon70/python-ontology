# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.IRI.Context do
  @moduledoc """
  Configuration for generated analyzed-code resource IRIs.
  """

  alias PythonOntology.IRI.Diagnostic

  @default_base_iri "https://example.invalid/python-ontology/resources/"

  @enforce_keys [:base_iri]
  defstruct [:base_iri, repository_root: nil]

  @type t :: %__MODULE__{base_iri: String.t(), repository_root: Path.t() | nil}

  @doc """
  Returns the default generated-resource base IRI used for local analysis and tests.
  """
  @spec default_base_iri() :: String.t()
  def default_base_iri, do: @default_base_iri

  @doc """
  Builds an IRI context from options.
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, Diagnostic.t()}
  def new(opts \\ []) when is_list(opts) do
    base_iri =
      Keyword.get_lazy(opts, :base_iri, fn ->
        Application.get_env(:python_ontology, :resource_base_iri, @default_base_iri)
      end)

    with {:ok, normalized_base_iri} <- validate_base_iri(base_iri) do
      {:ok,
       %__MODULE__{
         base_iri: normalized_base_iri,
         repository_root: normalize_optional_root(opts[:repository_root])
       }}
    end
  end

  @doc """
  Validates a generated-resource base IRI.
  """
  @spec validate_base_iri(term()) :: {:ok, String.t()} | {:error, Diagnostic.t()}
  def validate_base_iri(nil), do: base_iri_error(nil, "base IRI is required")
  def validate_base_iri(""), do: base_iri_error("", "base IRI is required")

  def validate_base_iri(base_iri) when is_binary(base_iri) do
    parsed = URI.parse(base_iri)

    cond do
      String.match?(base_iri, ~r/\s/) ->
        base_iri_error(base_iri, "base IRI must not contain whitespace")

      parsed.scheme not in ["http", "https"] ->
        base_iri_error(base_iri, "base IRI must use the http or https scheme")

      is_nil(parsed.host) or parsed.host == "" ->
        base_iri_error(base_iri, "base IRI must include a host")

      parsed.query not in [nil, ""] ->
        base_iri_error(base_iri, "base IRI must not include a query string")

      parsed.fragment not in [nil, ""] ->
        base_iri_error(base_iri, "base IRI must not include a fragment")

      not String.ends_with?(base_iri, "/") ->
        base_iri_error(base_iri, "base IRI must end with /")

      true ->
        {:ok, base_iri}
    end
  end

  def validate_base_iri(base_iri), do: base_iri_error(base_iri, "base IRI must be a string")

  defp base_iri_error(input, message) do
    {:error,
     %Diagnostic{
       stage: :base_iri,
       severity: :error,
       message: message,
       input: input
     }}
  end

  defp normalize_optional_root(nil), do: nil
  defp normalize_optional_root(path) when is_binary(path), do: Path.expand(path)
end
