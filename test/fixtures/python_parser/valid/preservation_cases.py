# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.initial_analysis_slice.tests_for_slice
async def fetch(session, urls):
    async with session.get(urls[0]) as response:
        try:
            return [item async for item in response.items() if item.ready]
        except Exception as error:
            raise RuntimeError("failed") from error
