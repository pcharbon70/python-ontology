# covers: python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output
defmodule PythonOntology.IRI.Fragment do
  @moduledoc """
  Canonical IRI path segment escaping and hashing.
  """

  @max_safe_bytes 96
  @safe_segment ~r/\A[A-Za-z0-9._~-]+\z/

  @doc """
  Encodes a segment directly when it is short and safe, otherwise hashes it.
  """
  @spec encode(term()) :: String.t()
  def encode(value) do
    value = to_string(value)

    if safe?(value) do
      value
    else
      "h-" <> hash(canonical_input(:segment, value))
    end
  end

  @doc """
  Returns the canonical string used as hash input.
  """
  @spec canonical_input(atom() | String.t(), term()) :: String.t()
  def canonical_input(kind, value) do
    kind = to_string(kind)
    value = to_string(value)

    "python_ontology_iri:v1\nkind=#{kind}\nvalue=#{value}"
  end

  @doc """
  Returns a lowercase SHA-256 hex digest for a canonical input.
  """
  @spec hash(String.t()) :: String.t()
  def hash(canonical_input) when is_binary(canonical_input) do
    :crypto.hash(:sha256, canonical_input)
    |> Base.encode16(case: :lower)
  end

  defp safe?(value) do
    byte_size(value) <= @max_safe_bytes and String.match?(value, @safe_segment)
  end
end
