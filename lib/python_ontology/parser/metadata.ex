# covers: python_ontology.parser.normalized_output python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output
defmodule PythonOntology.Parser.Metadata do
  @moduledoc """
  Parser and grammar metadata captured with each parser result.
  """

  @type t :: %__MODULE__{
          adapter: String.t(),
          language: String.t(),
          grammar: String.t(),
          tree_sitter_language_version: non_neg_integer(),
          tree_sitter_min_compatible_language_version: non_neg_integer(),
          grammar_abi_version: non_neg_integer(),
          tree_sitter_python_crate_version: String.t(),
          options: map()
        }

  @enforce_keys [
    :adapter,
    :language,
    :grammar,
    :tree_sitter_language_version,
    :tree_sitter_min_compatible_language_version,
    :grammar_abi_version,
    :tree_sitter_python_crate_version,
    :options
  ]
  defstruct [
    :adapter,
    :language,
    :grammar,
    :tree_sitter_language_version,
    :tree_sitter_min_compatible_language_version,
    :grammar_abi_version,
    :tree_sitter_python_crate_version,
    :options
  ]

  @doc false
  def from_native(parsed, opts) do
    %__MODULE__{
      adapter: parsed.adapter,
      language: parsed.language,
      grammar: parsed.grammar,
      tree_sitter_language_version: parsed.tree_sitter_language_version,
      tree_sitter_min_compatible_language_version:
        parsed.tree_sitter_min_compatible_language_version,
      grammar_abi_version: parsed.grammar_abi_version,
      tree_sitter_python_crate_version: parsed.tree_sitter_python_crate_version,
      options: opts |> Keyword.drop([:adapter]) |> Map.new()
    }
  end
end
