# covers: python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Builders.RDF do
  @moduledoc """
  RDF builder for first-slice Python facts.
  """

  alias PythonOntology.Builders.Confidence, as: ConfidenceBuilder
  alias PythonOntology.Builders.Context
  alias PythonOntology.Builders.Result
  alias PythonOntology.Facts.Fact
  alias PythonOntology.IRI
  alias PythonOntology.Pipeline.Diagnostic

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

  @doc """
  Builds RDF triples from extracted facts.
  """
  @spec build([Fact.t()], Context.t()) :: Result.t()
  def build(facts, %Context{} = context) when is_list(facts) do
    state =
      Enum.reduce(facts, initial_state(), fn fact, state ->
        build_fact(fact, context, state)
      end)

    %Result{
      triples: Enum.uniq(state.triples),
      diagnostics: state.diagnostics,
      resources: state.resources,
      metadata: %{fact_count: length(facts), triple_count: length(Enum.uniq(state.triples))}
    }
  end

  defp initial_state, do: %{triples: [], diagnostics: [], resources: %{}}

  defp build_fact(%Fact{} = fact, context, state) do
    with {:ok, resource_iri} <- resource_iri(fact, context, state),
         class_iri = class_iri(context, fact),
         triples <- fact_triples(fact, context, state, resource_iri, class_iri),
         confidence_triples <- confidence_triples(fact, context, resource_iri, class_iri) do
      state
      |> add_resource(fact.id, resource_iri)
      |> add_triples(triples ++ confidence_triples)
    else
      {:error, reason} ->
        add_diagnostic(state, diagnostic(fact, reason))
    end
  end

  defp resource_iri(%Fact{kind: :source_file} = fact, context, _state) do
    Context.resource(context, ["source-file", fact.source_path || fact.source_id || fact.id])
  end

  defp resource_iri(%Fact{kind: :package} = fact, context, _state) do
    IRI.package(context.iri_context,
      kind: fact.package_kind || :regular,
      name: fact.package_name || fact.name,
      source_path: fact.source_path || fact.source_id || fact.id,
      root_path: fact.package_root || fact.source_path || fact.source_id || fact.id
    )
  end

  defp resource_iri(%Fact{kind: :module} = fact, context, _state) do
    IRI.module(context.iri_context,
      name: fact.module_name || fact.name,
      source_path: fact.source_path || fact.source_id || fact.id,
      stub?: get_in(fact.identity, [:stub?]) || false
    )
  end

  defp resource_iri(%Fact{kind: :class} = fact, context, state) do
    with {:ok, module_iri} <- module_iri(fact, context, state) do
      IRI.class(context.iri_context,
        module_iri: module_iri,
        lexical_path: Map.get(fact.identity, :lexical_path) || [fact.name],
        span: fact.span
      )
    end
  end

  defp resource_iri(%Fact{kind: kind} = fact, context, state) when kind in [:function, :method] do
    with {:ok, module_iri} <- module_iri(fact, context, state) do
      IRI.function(context.iri_context,
        module_iri: module_iri,
        lexical_path: Map.get(fact.identity, :lexical_path) || [fact.name],
        method?: kind == :method,
        span: fact.span
      )
    end
  end

  defp resource_iri(%Fact{kind: :import} = fact, context, state) do
    span_resource(fact, context, state, &IRI.import_statement/2)
  end

  defp resource_iri(%Fact{kind: :import_alias} = fact, context, _state) do
    Context.resource(context, ["import-alias", fact.source_id || fact.id, fact.node_id || fact.id])
  end

  defp resource_iri(%Fact{kind: :call} = fact, context, state) do
    span_resource(fact, context, state, &IRI.call/2)
  end

  defp resource_iri(%Fact{kind: :attribute} = fact, context, state) do
    span_resource(fact, context, state, &IRI.attribute/2)
  end

  defp resource_iri(%Fact{kind: :subscript} = fact, context, state) do
    span_resource(fact, context, state, &IRI.subscript/2)
  end

  defp resource_iri(%Fact{} = fact, context, state) do
    with {:ok, container_iri} <- module_iri(fact, context, state) do
      IRI.resource(context.iri_context, [
        "fact-node",
        Atom.to_string(fact.kind),
        container_iri,
        fact.id
      ])
    end
  end

  defp span_resource(fact, context, state, fun) do
    with {:ok, container_iri} <- module_iri(fact, context, state) do
      fun.(context.iri_context, container_iri: container_iri, span: fact.span)
    end
  end

  defp module_iri(%Fact{} = fact, context, state) do
    module_id = "module:#{fact.module_name || module_name_from_source(fact)}"

    case Map.fetch(state.resources, module_id) do
      {:ok, module_iri} ->
        {:ok, module_iri}

      :error ->
        IRI.module(context.iri_context,
          name: fact.module_name || module_name_from_source(fact),
          source_path: fact.source_path || fact.source_id || fact.id
        )
    end
  end

  defp fact_triples(fact, context, state, resource_iri, class_iri) do
    location = location_triples(fact, context, resource_iri)

    [
      {resource_iri, @rdf_type, class_iri}
    ]
    |> append_literal(context, :structure, :qualifiedName, fact.qualified_name)
    |> append_literal(context, :structure, :moduleName, module_name_literal(fact))
    |> append_literal(context, :structure, :name, fact.name)
    |> append_literal(context, :structure, :rawText, fact.raw_text)
    |> append_literal(context, :structure, :targetText, fact.target_text)
    |> append_literal(context, :structure, :literalValue, literal_value(fact))
    |> append_attribute_literals(context, fact)
    |> append_relationships(fact, context, state, resource_iri)
    |> Kernel.++(location)
  end

  defp append_relationships(triples, %Fact{kind: :class} = fact, context, state, resource_iri) do
    with {:ok, module_iri} <- module_iri(fact, context, state) do
      triples ++
        [{module_iri, Context.vocabulary(context, :structure, :definesClass), resource_iri}]
    else
      _error -> triples
    end
  end

  defp append_relationships(triples, %Fact{kind: kind} = fact, context, state, resource_iri)
       when kind in [:function, :method] do
    with {:ok, module_iri} <- module_iri(fact, context, state) do
      triples ++
        [{module_iri, Context.vocabulary(context, :structure, :definesFunction), resource_iri}]
    else
      _error -> triples
    end
  end

  defp append_relationships(triples, %Fact{kind: :parameter} = fact, context, state, resource_iri) do
    parent_iri = fact.parent_id && state.resources[fact.parent_id]

    if parent_iri do
      triples ++
        [{parent_iri, Context.vocabulary(context, :structure, :hasParameter), resource_iri}]
    else
      triples
    end
  end

  defp append_relationships(triples, %Fact{kind: :decorator} = fact, context, state, resource_iri) do
    parent_iri = fact.parent_id && state.resources[fact.parent_id]

    if parent_iri do
      triples ++
        [{parent_iri, Context.vocabulary(context, :structure, :hasDecorator), resource_iri}]
    else
      triples
    end
  end

  defp append_relationships(
         triples,
         %Fact{kind: :base_class} = fact,
         context,
         state,
         resource_iri
       ) do
    parent_iri = fact.parent_id && state.resources[fact.parent_id]

    if parent_iri do
      triples ++
        [{parent_iri, Context.vocabulary(context, :structure, :hasBaseClass), resource_iri}]
    else
      triples
    end
  end

  defp append_relationships(
         triples,
         %Fact{kind: :import_alias} = fact,
         context,
         state,
         resource_iri
       ) do
    parent_iri = fact.parent_id && state.resources[fact.parent_id]

    if parent_iri do
      triples ++
        [{parent_iri, Context.vocabulary(context, :core, :hasImportAlias), resource_iri}]
    else
      triples
    end
  end

  defp append_relationships(
         triples,
         %Fact{kind: :annotation} = fact,
         context,
         state,
         resource_iri
       ) do
    parent_iri = fact.parent_id && state.resources[fact.parent_id]

    if parent_iri do
      triples ++
        [{parent_iri, Context.vocabulary(context, :structure, :hasAnnotation), resource_iri}]
    else
      triples
    end
  end

  defp append_relationships(triples, _fact, _context, _state, _resource_iri), do: triples

  defp confidence_triples(fact, context, resource_iri, class_iri) do
    with {:ok, assertion_iri} <-
           Context.fact_iri(context,
             kind: Atom.to_string(fact.confidence),
             subject: resource_iri,
             predicate: @rdf_type,
             object: class_iri,
             source: fact.node_id || fact.source_id
           ),
         {:ok, triples} <-
           ConfidenceBuilder.triples(context.iri_context,
             fact_iri: assertion_iri,
             category: fact.confidence,
             evidence: fact.evidence
           ) do
      [
        {assertion_iri, Context.vocabulary(context, :core, :assertsSubject), resource_iri},
        {assertion_iri, Context.vocabulary(context, :core, :assertsPredicate), @rdf_type},
        {assertion_iri, Context.vocabulary(context, :core, :assertsObject), class_iri}
      ] ++ triples
    else
      _error -> []
    end
  end

  defp location_triples(%Fact{span: nil}, _context, _resource_iri), do: []

  defp location_triples(%Fact{} = fact, context, resource_iri) do
    with {:ok, location_iri} <-
           IRI.source_location(context.iri_context, container_iri: resource_iri, span: fact.span) do
      point = fact.span.point.start

      [
        {resource_iri, Context.vocabulary(context, :core, :hasLocation), location_iri},
        {location_iri, @rdf_type, Context.vocabulary(context, :core, :SourceLocation)},
        {location_iri, Context.vocabulary(context, :core, :line), to_string(point.row)},
        {location_iri, Context.vocabulary(context, :core, :column), to_string(point.column)}
      ]
    else
      _error -> []
    end
  end

  defp class_iri(context, %Fact{kind: :source_file}),
    do: Context.vocabulary(context, :core, :SourceFile)

  defp class_iri(context, %Fact{kind: :package}),
    do: Context.vocabulary(context, :structure, :Package)

  defp class_iri(context, %Fact{kind: :module}),
    do: Context.vocabulary(context, :structure, :Module)

  defp class_iri(context, %Fact{kind: :import_alias}),
    do: Context.vocabulary(context, :core, :ImportAlias)

  defp class_iri(context, %Fact{kind: :class}),
    do: Context.vocabulary(context, :structure, :Class)

  defp class_iri(context, %Fact{kind: :function}),
    do: Context.vocabulary(context, :structure, :Function)

  defp class_iri(context, %Fact{kind: :method}),
    do: Context.vocabulary(context, :structure, :Method)

  defp class_iri(context, %Fact{kind: :parameter}),
    do: Context.vocabulary(context, :structure, :Parameter)

  defp class_iri(context, %Fact{kind: :decorator}),
    do: Context.vocabulary(context, :structure, :Decorator)

  defp class_iri(context, %Fact{kind: :annotation}),
    do: Context.vocabulary(context, :structure, :Annotation)

  defp class_iri(context, %Fact{kind: :base_class}),
    do: Context.vocabulary(context, :structure, :BaseClass)

  defp class_iri(context, %Fact{kind: :import}),
    do: Context.vocabulary(context, :core, :ImportStatement)

  defp class_iri(context, %Fact{kind: :call}),
    do: Context.vocabulary(context, :core, :CallExpression)

  defp class_iri(context, %Fact{kind: :literal}), do: Context.vocabulary(context, :core, :Literal)

  defp class_iri(context, %Fact{kind: :attribute}),
    do: Context.vocabulary(context, :core, :AttributeExpression)

  defp class_iri(context, %Fact{kind: :subscript}),
    do: Context.vocabulary(context, :core, :SubscriptExpression)

  defp class_iri(context, %Fact{}), do: Context.vocabulary(context, :core, :PythonCodeElement)

  defp append_literal(triples, _context, _layer, _term, nil), do: triples

  defp append_literal(triples, context, layer, term, value) do
    triples ++
      [
        {List.first(triples) |> elem(0), Context.vocabulary(context, layer, term),
         to_string(value)}
      ]
  end

  defp append_attribute_literals(triples, context, %Fact{kind: :import_alias} = fact) do
    triples
    |> append_literal(context, :core, :importName, fact.attributes[:imported_name])
    |> append_literal(context, :core, :aliasName, fact.attributes[:alias])
    |> append_literal(context, :core, :bindsName, fact.name)
  end

  defp append_attribute_literals(triples, context, %Fact{kind: :parameter} = fact) do
    triples
    |> append_literal(context, :structure, :parameterKind, fact.attributes[:kind])
    |> append_literal(context, :structure, :defaultText, fact.attributes[:default])
    |> append_literal(context, :typing, :annotationText, fact.attributes[:annotation])
  end

  defp append_attribute_literals(triples, context, %Fact{kind: :annotation} = fact) do
    append_literal(triples, context, :typing, :annotationText, fact.raw_text)
  end

  defp append_attribute_literals(triples, _context, %Fact{}), do: triples

  defp module_name_literal(%Fact{kind: :module, name: name}), do: name
  defp module_name_literal(%Fact{}), do: nil

  defp literal_value(%Fact{value: nil}), do: nil
  defp literal_value(%Fact{value: value}), do: inspect(value)

  defp add_resource(state, id, resource_iri) do
    %{state | resources: Map.put(state.resources, id, resource_iri)}
  end

  defp add_triples(state, triples), do: %{state | triples: state.triples ++ triples}

  defp add_diagnostic(state, diagnostic),
    do: %{state | diagnostics: state.diagnostics ++ [diagnostic]}

  defp module_name_from_source(%Fact{source_id: source_id}) when is_binary(source_id) do
    source_id
    |> String.replace_suffix(".pyi", "")
    |> String.replace_suffix(".py", "")
    |> String.trim_leading("src/")
    |> String.replace("/", ".")
  end

  defp module_name_from_source(%Fact{id: id}), do: id

  defp diagnostic(fact, reason) do
    %Diagnostic{
      stage: :builder,
      severity: :error,
      message: "could not build RDF for #{fact.kind} fact: #{inspect(reason)}",
      source_id: fact.source_id,
      path: fact.path,
      span: fact.span,
      node_id: fact.node_id,
      details: %{fact_id: fact.id, reason: reason}
    }
  end
end
