# covers: python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.namespace_package_detection
from acme.plugins.plugin import plugin_name


def test_plugin_name():
    assert plugin_name() == "acme.plugins"
