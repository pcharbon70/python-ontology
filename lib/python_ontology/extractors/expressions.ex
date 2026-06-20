# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Extractors.Expressions do
  @moduledoc """
  Extracts first-slice expression navigation facts from normalized syntax.
  """

  alias PythonOntology.Confidence
  alias PythonOntology.Extractors.Context
  alias PythonOntology.Facts
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Facts.Result
  alias PythonOntology.Pipeline.Diagnostic
  alias PythonOntology.Syntax

  @doc """
  Extracts expression facts and recoverable diagnostics.
  """
  @spec extract(term(), Context.t()) :: Result.t()
  def extract(root, %Context{} = context) do
    nodes = [root | Syntax.descendants(root)]

    facts = nodes |> Enum.flat_map(&expression_facts(&1, context))
    diagnostics = nodes |> Enum.flat_map(&diagnostics(&1, context))

    Facts.result(facts,
      diagnostics: diagnostics,
      metadata: %{extractor: __MODULE__, fact_count: length(facts)}
    )
  end

  defp expression_facts(%Syntax.Call{} = call, context) do
    [call_fact(call, context)]
  end

  defp expression_facts(%Syntax.Attribute{} = attribute, context) do
    [
      syntax_fact(:attribute, attribute, context,
        id: "attribute:#{attribute.info.id}",
        target_text: render(attribute),
        attributes: %{
          object: render(attribute.object),
          attribute: render(attribute.attribute)
        },
        identity: %{container_id: "module:#{module_name(context)}", span: attribute.info.span}
      )
    ]
  end

  defp expression_facts(%Syntax.Subscript{} = subscript, context) do
    [
      syntax_fact(:subscript, subscript, context,
        id: "subscript:#{subscript.info.id}",
        target_text: render(subscript),
        attributes: %{
          object: render(subscript.object),
          index: render(subscript.index)
        },
        identity: %{container_id: "module:#{module_name(context)}", span: subscript.info.span}
      )
    ]
  end

  defp expression_facts(%Syntax.Literal{} = literal, context) do
    [
      syntax_fact(:literal, literal, context,
        id: "literal:#{literal.info.id}",
        raw_text: literal.raw_text,
        value: literal.value,
        attributes: %{kind: literal.kind},
        identity: %{container_id: "module:#{module_name(context)}", span: literal.info.span}
      )
    ]
  end

  defp expression_facts(_node, _context), do: []

  defp call_fact(%Syntax.Call{} = call, context) do
    target_text = render(call.function)
    {confidence, evidence, attributes} = call_confidence(call, target_text)

    syntax_fact(:call, call, context,
      id: "call:#{call.info.id}",
      target: call.function,
      target_text: target_text,
      arguments: Enum.map(call.arguments, &render/1),
      confidence: confidence,
      evidence: evidence,
      attributes:
        Map.merge(attributes, %{
          argument_count: length(call.arguments),
          arguments: Enum.map(call.arguments, &render/1)
        }),
      identity: %{container_id: "module:#{module_name(context)}", span: call.info.span}
    )
  end

  defp call_confidence(%Syntax.Call{} = call, "importlib.import_module") do
    source_evidence = Confidence.syntax_evidence(call.info)

    {:ok, runtime_evidence} =
      Confidence.runtime_evidence(:dynamic_import, inputs: [source_evidence])

    {:runtime_dependent, [source_evidence, runtime_evidence],
     %{runtime_boundary: :dynamic_import, unresolved?: true}}
  end

  defp call_confidence(%Syntax.Call{} = call, target_text) do
    source_evidence = Confidence.syntax_evidence(call.info)

    if simple_target?(call.function) and is_binary(target_text) do
      {:source_declared, [source_evidence], %{unresolved?: false}}
    else
      {:ok, unresolved_evidence} =
        Confidence.unresolved_evidence(:dynamic_target, inputs: [source_evidence])

      {:unresolved, [source_evidence, unresolved_evidence], %{unresolved?: true}}
    end
  end

  defp syntax_fact(kind, node, context, attrs) do
    evidence =
      Keyword.get_lazy(attrs, :evidence, fn -> [Confidence.syntax_evidence(node.info)] end)

    {:ok, fact} =
      Fact.new(
        kind,
        attrs
        |> Keyword.put(:source_id, context.source_id)
        |> Keyword.put(:path, context.source_path)
        |> Keyword.put(:span, node.info.span)
        |> Keyword.put(:node_id, node.info.id)
        |> Keyword.put(:raw_node_type, node.info.provenance.raw_type)
        |> Keyword.put(:evidence, evidence)
      )

    fact
  end

  defp diagnostics(%Syntax.Generic{} = generic, context) do
    [
      %Diagnostic{
        stage: :extractor,
        severity: :warning,
        message: "unsupported normalized syntax node #{inspect(generic.raw_type)} preserved",
        source_id: context.source_id,
        path: context.source_path,
        span: generic.info.span,
        node_id: generic.info.id,
        details: %{raw_type: generic.raw_type}
      }
    ]
  end

  defp diagnostics(%Syntax.Call{} = call, context) do
    case call_confidence(call, render(call.function)) do
      {:runtime_dependent, _evidence, attributes} ->
        [
          %Diagnostic{
            stage: :extractor,
            severity: :warning,
            message: "runtime-dependent dynamic import call",
            source_id: context.source_id,
            path: context.source_path,
            span: call.info.span,
            node_id: call.info.id,
            details: attributes
          }
        ]

      {:unresolved, _evidence, attributes} ->
        [
          %Diagnostic{
            stage: :extractor,
            severity: :warning,
            message: "unresolved dynamic call target",
            source_id: context.source_id,
            path: context.source_path,
            span: call.info.span,
            node_id: call.info.id,
            details: attributes
          }
        ]

      _source_declared ->
        []
    end
  end

  defp diagnostics(_node, _context), do: []

  defp simple_target?(%Syntax.Identifier{}), do: true
  defp simple_target?(%Syntax.Attribute{}), do: true
  defp simple_target?(_node), do: false

  defp module_name(%Context{module_name: module_name})
       when is_binary(module_name) and module_name != "",
       do: module_name

  defp module_name(%Context{source_id: source_id}) do
    source_id
    |> String.replace_suffix(".pyi", "")
    |> String.replace_suffix(".py", "")
    |> String.trim_leading("src/")
    |> String.replace("/", ".")
  end

  defp render(nil), do: nil
  defp render(%Syntax.Identifier{name: name}), do: name
  defp render(%Syntax.Literal{raw_text: raw_text}) when is_binary(raw_text), do: raw_text
  defp render(%Syntax.Literal{value: value}), do: inspect(value)

  defp render(%Syntax.Attribute{object: object, attribute: attribute}),
    do: join_present([render(object), render(attribute)], ".")

  defp render(%Syntax.Subscript{object: object, index: index}),
    do: "#{render(object)}[#{render(index)}]"

  defp render(%Syntax.Call{function: function}), do: "#{render(function)}(...)"
  defp render(%Syntax.Generic{raw_text: raw_text}) when is_binary(raw_text), do: raw_text
  defp render(%Syntax.Generic{raw_type: raw_type}), do: raw_type
  defp render(%{raw_text: raw_text}) when is_binary(raw_text), do: raw_text
  defp render(%{info: %{provenance: %{raw_type: raw_type}}}), do: raw_type
  defp render(value), do: inspect(value)

  defp join_present(parts, separator) do
    parts
    |> Enum.reject(&is_nil/1)
    |> Enum.join(separator)
  end
end
