// covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output

use rustler::NifMap;
use tree_sitter::{Node, Parser, TreeCursor};

const TREE_SITTER_PYTHON_CRATE_VERSION: &str = "0.25.0";

#[derive(NifMap)]
struct ParserInfo {
    adapter: String,
    language: String,
    grammar: String,
    tree_sitter_language_version: usize,
    tree_sitter_min_compatible_language_version: usize,
    grammar_abi_version: usize,
    tree_sitter_python_crate_version: String,
}

#[derive(NifMap)]
struct ParsePayload {
    adapter: String,
    language: String,
    grammar: String,
    tree_sitter_language_version: usize,
    tree_sitter_min_compatible_language_version: usize,
    grammar_abi_version: usize,
    tree_sitter_python_crate_version: String,
    has_error: bool,
    root: SyntaxNode,
}

#[derive(NifMap)]
struct SyntaxNode {
    kind: String,
    field_name: Option<String>,
    named: bool,
    extra: bool,
    error: bool,
    missing: bool,
    has_error: bool,
    start_byte: usize,
    end_byte: usize,
    start_point: SourcePoint,
    end_point: SourcePoint,
    child_count: usize,
    named_child_count: usize,
    children: Vec<SyntaxNode>,
}

#[derive(NifMap)]
struct SourcePoint {
    row: usize,
    column: usize,
}

#[rustler::nif]
fn parser_info() -> ParserInfo {
    parser_info_payload()
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_string(source: String) -> Result<ParsePayload, String> {
    let language: tree_sitter::Language = tree_sitter_python::LANGUAGE.into();
    let mut parser = Parser::new();

    parser
        .set_language(&language)
        .map_err(|error| format!("failed to load Python grammar: {error}"))?;

    let tree = parser
        .parse(&source, None)
        .ok_or_else(|| String::from("Tree-sitter returned no parse tree"))?;

    let root = tree.root_node();
    let mut payload = parse_payload(root, &language);
    payload.has_error = root.has_error();

    Ok(payload)
}

fn parser_info_payload() -> ParserInfo {
    let language: tree_sitter::Language = tree_sitter_python::LANGUAGE.into();

    ParserInfo {
        adapter: String::from("PythonOntology.Parser.TreeSitter"),
        language: String::from("python"),
        grammar: String::from("tree-sitter-python"),
        tree_sitter_language_version: tree_sitter::LANGUAGE_VERSION,
        tree_sitter_min_compatible_language_version: tree_sitter::MIN_COMPATIBLE_LANGUAGE_VERSION,
        grammar_abi_version: language.abi_version(),
        tree_sitter_python_crate_version: String::from(TREE_SITTER_PYTHON_CRATE_VERSION),
    }
}

fn parse_payload(root: Node, language: &tree_sitter::Language) -> ParsePayload {
    ParsePayload {
        adapter: String::from("PythonOntology.Parser.TreeSitter"),
        language: String::from("python"),
        grammar: String::from("tree-sitter-python"),
        tree_sitter_language_version: tree_sitter::LANGUAGE_VERSION,
        tree_sitter_min_compatible_language_version: tree_sitter::MIN_COMPATIBLE_LANGUAGE_VERSION,
        grammar_abi_version: language.abi_version(),
        tree_sitter_python_crate_version: String::from(TREE_SITTER_PYTHON_CRATE_VERSION),
        has_error: false,
        root: syntax_node(root, None),
    }
}

fn syntax_node(node: Node, field_name: Option<String>) -> SyntaxNode {
    let start = node.start_position();
    let end = node.end_position();

    SyntaxNode {
        kind: node.kind().to_string(),
        field_name,
        named: node.is_named(),
        extra: node.is_extra(),
        error: node.is_error(),
        missing: node.is_missing(),
        has_error: node.has_error(),
        start_byte: node.start_byte(),
        end_byte: node.end_byte(),
        start_point: SourcePoint {
            row: start.row,
            column: start.column,
        },
        end_point: SourcePoint {
            row: end.row,
            column: end.column,
        },
        child_count: node.child_count(),
        named_child_count: node.named_child_count(),
        children: child_nodes(node),
    }
}

fn child_nodes(node: Node) -> Vec<SyntaxNode> {
    let mut cursor = node.walk();

    if !cursor.goto_first_child() {
        return Vec::new();
    }

    let mut children = Vec::with_capacity(node.child_count());

    loop {
        children.push(syntax_node(cursor.node(), current_field_name(&cursor)));

        if !cursor.goto_next_sibling() {
            break;
        }
    }

    children
}

fn current_field_name(cursor: &TreeCursor) -> Option<String> {
    cursor.field_name().map(str::to_string)
}

rustler::init!("Elixir.PythonOntology.Parser.Native");
