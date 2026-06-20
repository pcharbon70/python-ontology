# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Extractors.StructuralTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Extractors.Context
  alias PythonOntology.Extractors.Structural
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "extracts source, module, imports, classes, functions, parameters, decorators, annotations, and bases" do
    assert {:ok, parsed} = Parser.parse_file(@fixture, source_id: "src/sample_pkg/first_slice.py")
    assert {:ok, syntax_root} = Syntax.normalize(parsed)

    assert {:ok, context} =
             Context.from_parser_result(parsed, syntax_root,
               project_root: Path.dirname(@fixture),
               module_name: "sample_pkg.first_slice"
             )

    result = Structural.extract(syntax_root, context)
    facts = result.facts

    assert %Fact{kind: :source_file, source_id: "src/sample_pkg/first_slice.py"} =
             fact(facts, :source_file)

    assert %Fact{kind: :module, name: "sample_pkg.first_slice", confidence: :source_declared} =
             fact(facts, :module)

    imports = Enum.filter(facts, &(&1.kind == :import))
    assert length(imports) == 3

    assert Enum.any?(imports, fn fact ->
             Enum.any?(fact.aliases, &(&1.name == "sys" and &1.as == "system"))
           end)

    aliases = Enum.filter(facts, &(&1.kind == :import_alias))
    assert Enum.any?(aliases, &(&1.name == "system" and &1.attributes.imported_name == "sys"))
    assert Enum.any?(aliases, &(&1.name == "FilePath" and &1.attributes.imported_name == "Path"))

    class = fact(facts, :class)
    assert class.name == "Example"
    assert class.bases == ["Base"]
    assert class.decorators == ["@decorator(\"value\")"]

    method = fact(facts, :method)
    assert method.name == "method"
    assert method.qualified_name == "Example.method"
    assert method.attributes.method?

    parameters = Enum.filter(facts, &(&1.kind == :parameter))

    assert Enum.map(parameters, &{&1.name, &1.attributes.kind}) == [
             {"self", :positional},
             {"name", :positional},
             {"args", :vararg},
             {"enabled", :keyword_only},
             {"kwargs", :kwarg}
           ]

    assert Enum.any?(facts, &(&1.kind == :decorator and &1.raw_text == "@decorator(\"value\")"))
    assert Enum.any?(facts, &(&1.kind == :base_class and &1.raw_text == "Base"))
    assert Enum.any?(facts, &(&1.kind == :annotation and &1.raw_text == "str"))
    assert Enum.any?(facts, &(&1.kind == :annotation and &1.raw_text == "int"))

    assert Enum.all?(facts, &match?(%Fact{}, &1))
    refute Enum.any?(facts, &match?({_, _, _}, &1))
  end

  defp fact(facts, kind),
    do: Enum.find(facts, &(&1.kind == kind)) || flunk("missing #{kind} fact")
end
