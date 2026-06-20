# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.module_package_identity python_ontology.iri_identity_strategy.class_function_identity python_ontology.iri_identity_strategy.nested_scope_identity python_ontology.iri_identity_strategy.occurrence_disambiguation python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @repository_root Path.expand("../../fixtures", __DIR__)

  test "generates deterministic structural identities from normalized syntax" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    assert {:ok, context} =
             IRI.context(
               base_iri: "https://analysis.example/python/",
               repository_root: @repository_root
             )

    assert {:ok, package_iri} =
             IRI.package(context,
               kind: :namespace,
               name: "python_parser.valid",
               root_path: "python_parser/valid"
             )

    assert {:ok, module_iri} =
             IRI.module(context,
               name: "python_parser.valid.first_slice",
               source_path: @fixture
             )

    assert package_iri ==
             "https://analysis.example/python/package/namespace/python_parser.valid/root/python_parser/valid"

    assert module_iri ==
             "https://analysis.example/python/module/source/python_parser.valid.first_slice/source/python_parser/valid/first_slice.py"

    class = Enum.find(module.body, &match?(%Syntax.Class{name: "Example"}, &1))
    function = Enum.find(class.body, &match?(%Syntax.Function{name: "method"}, &1))

    assert {:ok, class_iri} =
             IRI.class(context,
               module_iri: module_iri,
               lexical_path: [class.name],
               occurrence: 2,
               span: class.info.span
             )

    assert {:ok, same_class_iri} =
             IRI.class(context,
               module_iri: module_iri,
               lexical_path: [class.name],
               occurrence: 2,
               span: class.info.span
             )

    assert class_iri == same_class_iri
    assert class_iri =~ "/class/Example/occurrence/2/span/b"

    assert {:ok, method_iri} =
             IRI.function(context,
               module_iri: module_iri,
               lexical_path: [class.name, function.name],
               method?: true,
               span: function.info.span
             )

    assert method_iri =~ "/method/Example/method/span/b"

    assert {:ok, arity_1} =
             IRI.function(context, module_iri: module_iri, lexical_path: ["helper"], arity: 1)

    assert {:ok, arity_3} =
             IRI.function(context, module_iri: module_iri, lexical_path: ["helper"], arity: 3)

    assert arity_1 == arity_3
  end
end
