# covers: python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.include_python_sources
from sample_pkg import build_message


def test_build_message():
    assert build_message("ontology") == "hello ontology"
