# covers: python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Confidence.Evidence do
  @moduledoc """
  Evidence records explaining a fact confidence category.
  """

  alias PythonOntology.Syntax.NodeInfo

  @unresolved_reasons [
    :unknown_name,
    :dynamic_target,
    :unsupported_syntax,
    :missing_source,
    :ambiguous_binding
  ]

  @runtime_reasons [
    :dynamic_import,
    :decorator,
    :metaclass,
    :monkey_patching,
    :reflection,
    :runtime_state,
    :module_side_effect
  ]

  @enforce_keys [:kind]
  defstruct [
    :kind,
    :source_id,
    :path,
    :span,
    :syntax_node_id,
    :raw_node_type,
    :reason,
    inputs: [],
    details: %{}
  ]

  @type kind :: :source | :syntax_node | :static_inference | :unresolved | :runtime_dependent
  @type unresolved_reason :: unquote(Enum.reduce(@unresolved_reasons, &{:|, [], [&1, &2]}))
  @type runtime_reason :: unquote(Enum.reduce(@runtime_reasons, &{:|, [], [&1, &2]}))

  @type t :: %__MODULE__{
          kind: kind(),
          source_id: String.t() | nil,
          path: Path.t() | nil,
          span: term(),
          syntax_node_id: String.t() | nil,
          raw_node_type: String.t() | nil,
          reason: atom() | nil,
          inputs: [t()],
          details: map()
        }

  @doc """
  Builds source file/span evidence.
  """
  @spec source(keyword()) :: t()
  def source(opts) when is_list(opts) do
    %__MODULE__{
      kind: :source,
      source_id: opts[:source_id],
      path: opts[:path],
      span: opts[:span],
      details: Map.new(Keyword.get(opts, :details, []))
    }
  end

  @doc """
  Builds evidence from normalized syntax node info.
  """
  @spec syntax_node(NodeInfo.t() | keyword()) :: t()
  def syntax_node(%NodeInfo{} = info) do
    %__MODULE__{
      kind: :syntax_node,
      source_id: info.source.id,
      path: info.source.path,
      span: info.span,
      syntax_node_id: info.id,
      raw_node_type: info.provenance.raw_type
    }
  end

  def syntax_node(opts) when is_list(opts) do
    %__MODULE__{
      kind: :syntax_node,
      source_id: opts[:source_id],
      path: opts[:path],
      span: opts[:span],
      syntax_node_id: opts[:syntax_node_id],
      raw_node_type: opts[:raw_node_type],
      details: Map.new(Keyword.get(opts, :details, []))
    }
  end

  @doc """
  Builds static-inference evidence from source-declared inputs.
  """
  @spec static_inference(atom(), [t()], keyword()) :: t()
  def static_inference(reason, inputs, opts \\ []) when is_atom(reason) and is_list(inputs) do
    %__MODULE__{
      kind: :static_inference,
      reason: reason,
      inputs: inputs,
      details: Map.new(Keyword.get(opts, :details, []))
    }
  end

  @doc """
  Builds unresolved evidence.
  """
  @spec unresolved(unresolved_reason(), keyword()) :: {:ok, t()} | {:error, String.t()}
  def unresolved(reason, opts \\ []) do
    with :ok <- validate_reason(reason, @unresolved_reasons, "unresolved") do
      {:ok,
       %__MODULE__{
         kind: :unresolved,
         reason: reason,
         inputs: Keyword.get(opts, :inputs, []),
         details: Map.new(Keyword.get(opts, :details, []))
       }}
    end
  end

  @doc """
  Builds runtime-dependent evidence.
  """
  @spec runtime_dependent(runtime_reason(), keyword()) :: {:ok, t()} | {:error, String.t()}
  def runtime_dependent(reason, opts \\ []) do
    with :ok <- validate_reason(reason, @runtime_reasons, "runtime-dependent") do
      {:ok,
       %__MODULE__{
         kind: :runtime_dependent,
         reason: reason,
         inputs: Keyword.get(opts, :inputs, []),
         details: Map.new(Keyword.get(opts, :details, []))
       }}
    end
  end

  @doc """
  Validates and returns an evidence list.
  """
  @spec list([t()]) :: {:ok, [t()]} | {:error, String.t()}
  def list(evidence) when is_list(evidence) do
    if Enum.all?(evidence, &match?(%__MODULE__{}, &1)) do
      {:ok, evidence}
    else
      {:error, "evidence list must contain evidence records"}
    end
  end

  def list(_evidence), do: {:error, "evidence must be a list"}

  @doc """
  Returns supported unresolved reasons.
  """
  def unresolved_reasons, do: @unresolved_reasons

  @doc """
  Returns supported runtime-dependent reasons.
  """
  def runtime_reasons, do: @runtime_reasons

  defp validate_reason(reason, allowed, label) do
    if reason in allowed do
      :ok
    else
      {:error, "unknown #{label} evidence reason #{inspect(reason)}"}
    end
  end
end
