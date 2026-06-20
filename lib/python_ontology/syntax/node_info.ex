# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.NodeInfo do
  @moduledoc """
  Shared fields carried by every normalized syntax node.
  """

  alias PythonOntology.Syntax.NodeId
  alias PythonOntology.Syntax.Provenance
  alias PythonOntology.Syntax.Source
  alias PythonOntology.Syntax.Span

  @type t :: %__MODULE__{
          id: NodeId.t(),
          source: Source.t(),
          span: Span.t(),
          provenance: Provenance.t()
        }

  @enforce_keys [:id, :source, :span, :provenance]
  defstruct [:id, :source, :span, :provenance]
end
