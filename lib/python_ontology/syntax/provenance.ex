# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.Provenance do
  @moduledoc """
  Raw parser provenance retained on normalized syntax nodes.
  """

  @type t :: %__MODULE__{
          raw_type: String.t() | nil,
          named: boolean() | nil,
          field_name: String.t() | nil,
          child_index: non_neg_integer() | nil,
          parent_path: [String.t() | non_neg_integer()],
          child_order: [String.t()]
        }

  defstruct raw_type: nil,
            named: nil,
            field_name: nil,
            child_index: nil,
            parent_path: [],
            child_order: []
end
