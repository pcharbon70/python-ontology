# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.IRI.Builder do
  @moduledoc """
  Builder-facing IRI helper API.
  """

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Fragment
  alias PythonOntology.IRI.Identity

  @doc """
  Returns an ontology vocabulary IRI.
  """
  @spec vocabulary(atom() | String.t(), atom() | String.t()) :: String.t()
  def vocabulary(layer, term), do: IRI.vocabulary_iri(layer, term)

  @doc """
  Builds a generated analyzed-code resource IRI from canonical segments.
  """
  @spec resource(Context.t(), [term()]) :: {:ok, String.t()}
  def resource(%Context{} = context, segments), do: Identity.build(context, segments)

  @doc """
  Builds a deterministic fact resource IRI from canonical fact inputs.
  """
  @spec fact(Context.t(), keyword()) :: {:ok, String.t()} | {:error, Diagnostic.t()}
  def fact(%Context{} = context, opts) when is_list(opts) do
    with {:ok, kind} <- required_string(opts, :kind),
         {:ok, subject} <- required_string(opts, :subject),
         {:ok, predicate} <- required_string(opts, :predicate) do
      canonical_input =
        canonical_fact_input(
          kind: kind,
          subject: subject,
          predicate: predicate,
          object: Keyword.get(opts, :object),
          source: Keyword.get(opts, :source)
        )

      Identity.build(context, ["fact", kind, "h-" <> Fragment.hash(canonical_input)])
    end
  end

  @doc """
  Returns the canonical fact hash input.
  """
  @spec canonical_fact_input(keyword()) :: String.t()
  def canonical_fact_input(opts) do
    [
      "python_ontology_fact:v1",
      "kind=#{Keyword.get(opts, :kind)}",
      "subject=#{Keyword.get(opts, :subject)}",
      "predicate=#{Keyword.get(opts, :predicate)}",
      "object=#{Keyword.get(opts, :object)}",
      "source=#{Keyword.get(opts, :source)}"
    ]
    |> Enum.join("\n")
  end

  defp required_string(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_binary(value) and value != "" ->
        {:ok, value}

      {:ok, value} ->
        builder_error(key, value, "#{key} must be a non-empty string")

      :error ->
        builder_error(key, nil, "#{key} is required")
    end
  end

  defp builder_error(field, input, message) do
    {:error,
     %Diagnostic{
       stage: :builder_iri,
       severity: :error,
       message: message,
       input: input,
       details: %{field: field}
     }}
  end
end
