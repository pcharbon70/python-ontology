# covers: python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.include_python_sources
from flat_pkg import meaning


def test_meaning():
    assert meaning() == 42
