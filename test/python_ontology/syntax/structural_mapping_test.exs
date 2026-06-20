# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.StructuralMappingTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "normalizes module root and top-level statement order" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, %Syntax.ModuleNode{} = module} = Syntax.normalize(parsed)

    assert module.info.provenance.raw_type == "module"
    assert module.info.source.id == @fixture

    assert Enum.map(module.body, & &1.info.provenance.raw_type) == [
             "import_statement",
             "import_statement",
             "import_from_statement",
             "class_definition"
           ]
  end

  test "normalizes import statements and aliases" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    imports = Enum.filter(module.body, &match?(%Syntax.Import{}, &1))

    assert [
             %Syntax.Import{names: [%Syntax.Alias{name: "os", as: nil}]},
             %Syntax.Import{names: [%Syntax.Alias{name: "sys", as: "system"}]},
             %Syntax.Import{
               module: "pathlib",
               names: [%Syntax.Alias{name: "Path", as: "FilePath"}]
             }
           ] = imports
  end

  test "normalizes decorated classes and method-candidate functions" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    class = Enum.find(module.body, &match?(%Syntax.Class{}, &1))
    assert %Syntax.Class{name: "Example"} = class
    assert [%Syntax.Decorator{raw_text: "@decorator(\"value\")"}] = class.decorators
    assert [%Syntax.BaseClass{raw_text: "Base"}] = class.bases

    function = Enum.find(class.body, &match?(%Syntax.Function{}, &1))
    assert %Syntax.Function{name: "method", method_candidate?: true} = function

    assert Enum.map(function.parameters, &{&1.name, &1.kind}) == [
             {"self", :positional},
             {"name", :positional},
             {"args", :vararg},
             {"enabled", :positional},
             {"kwargs", :kwarg}
           ]

    assert Enum.find(function.parameters, &(&1.name == "name")).annotation.raw_text == "str"
    assert function.return_annotation.raw_text == "str"
  end
end
