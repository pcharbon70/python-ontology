# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.Phase1IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "constructs deterministic confidence and evidence records for first-slice syntax" do
    assert Confidence.categories() == [
             :source_declared,
             :statically_inferred,
             :unresolved,
             :runtime_dependent
           ]

    assert Confidence.direct_syntax_default() == :source_declared

    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    import = Enum.find(module.body, &match?(%Syntax.Import{}, &1))
    import_evidence = Confidence.syntax_evidence(import.info)

    assert %Evidence{
             kind: :syntax_node,
             source_id: @fixture,
             raw_node_type: "import_statement"
           } = import_evidence

    inferred =
      Confidence.static_inference_evidence(:alias_resolution, [import_evidence],
        details: [name: "FilePath"]
      )

    assert %Evidence{kind: :static_inference, inputs: [^import_evidence]} = inferred

    assert {:ok, %Evidence{kind: :unresolved, reason: :dynamic_target}} =
             Confidence.unresolved_evidence(:dynamic_target, inputs: [import_evidence])

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :decorator}} =
             Confidence.runtime_evidence(:decorator, inputs: [import_evidence])
  end
end
