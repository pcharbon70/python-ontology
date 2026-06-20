# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.ModuleNode do
  @moduledoc "Normalized Python module syntax node."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, body: [], diagnostics: []]

  @type t :: %__MODULE__{info: NodeInfo.t(), body: list(), diagnostics: list()}
end

defmodule PythonOntology.Syntax.Import do
  @moduledoc "Normalized Python import statement."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, module: nil, names: [], relative_level: 0, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          module: String.t() | nil,
          names: list(),
          relative_level: non_neg_integer(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.Alias do
  @moduledoc "Normalized import alias."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :name]
  defstruct [:info, :name, as: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          name: String.t(),
          as: String.t() | nil,
          children: list()
        }
end

defmodule PythonOntology.Syntax.Class do
  @moduledoc "Normalized Python class definition."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :name]
  defstruct [:info, :name, bases: [], decorators: [], docstring: nil, body: [], children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          name: String.t(),
          bases: list(),
          decorators: list(),
          docstring: term(),
          body: list(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.Function do
  @moduledoc "Normalized Python function or method-candidate definition."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :name]
  defstruct [
    :info,
    :name,
    async?: false,
    method_candidate?: false,
    parameters: [],
    decorators: [],
    return_annotation: nil,
    docstring: nil,
    body: [],
    children: []
  ]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          name: String.t(),
          async?: boolean(),
          method_candidate?: boolean(),
          parameters: list(),
          decorators: list(),
          return_annotation: term(),
          docstring: term(),
          body: list(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.MethodCandidate do
  @moduledoc "Marker node for a function that appears in class scope."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :function]
  defstruct [:info, :function]

  @type t :: %__MODULE__{info: NodeInfo.t(), function: PythonOntology.Syntax.Function.t()}
end

defmodule PythonOntology.Syntax.Parameter do
  @moduledoc "Normalized Python parameter syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :name]
  defstruct [:info, :name, kind: :positional, annotation: nil, default: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          name: String.t(),
          kind: :positional | :keyword_only | :vararg | :kwarg | :positional_only | :unknown,
          annotation: term(),
          default: term(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.Decorator do
  @moduledoc "Normalized Python decorator syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, expression: nil, raw_text: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          expression: term(),
          raw_text: String.t() | nil,
          children: list()
        }
end

defmodule PythonOntology.Syntax.Annotation do
  @moduledoc "Normalized Python annotation syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, expression: nil, raw_text: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          expression: term(),
          raw_text: String.t() | nil,
          children: list()
        }
end

defmodule PythonOntology.Syntax.BaseClass do
  @moduledoc "Normalized Python class base expression."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, expression: nil, raw_text: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          expression: term(),
          raw_text: String.t() | nil,
          children: list()
        }
end

defmodule PythonOntology.Syntax.Docstring do
  @moduledoc "Normalized Python docstring syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :text]
  defstruct [:info, :text, raw_text: nil]

  @type t :: %__MODULE__{info: NodeInfo.t(), text: String.t(), raw_text: String.t() | nil}
end

defmodule PythonOntology.Syntax.Assignment do
  @moduledoc "Normalized Python assignment syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, targets: [], value: nil, annotation: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          targets: list(),
          value: term(),
          annotation: term(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.Identifier do
  @moduledoc "Normalized Python identifier syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :name]
  defstruct [:info, :name]

  @type t :: %__MODULE__{info: NodeInfo.t(), name: String.t()}
end

defmodule PythonOntology.Syntax.Call do
  @moduledoc "Normalized Python call expression."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, function: nil, arguments: [], children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          function: term(),
          arguments: list(),
          children: list()
        }
end

defmodule PythonOntology.Syntax.Attribute do
  @moduledoc "Normalized Python attribute access expression."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, object: nil, attribute: nil, children: []]

  @type t :: %__MODULE__{info: NodeInfo.t(), object: term(), attribute: term(), children: list()}
end

defmodule PythonOntology.Syntax.Subscript do
  @moduledoc "Normalized Python subscript expression."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info]
  defstruct [:info, object: nil, index: nil, children: []]

  @type t :: %__MODULE__{info: NodeInfo.t(), object: term(), index: term(), children: list()}
end

defmodule PythonOntology.Syntax.Literal do
  @moduledoc "Normalized Python literal syntax."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :kind]
  defstruct [:info, :kind, value: nil, raw_text: nil, children: []]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          kind: :string | :number | :boolean | :none | :list | :tuple | :dict | :set | :unknown,
          value: term(),
          raw_text: String.t() | nil,
          children: list()
        }
end

defmodule PythonOntology.Syntax.ControlFlow do
  @moduledoc "Normalized control-flow preservation node."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :kind]
  defstruct [:info, :kind, children: []]

  @type t :: %__MODULE__{info: NodeInfo.t(), kind: atom(), children: list()}
end

defmodule PythonOntology.Syntax.Comprehension do
  @moduledoc "Normalized comprehension preservation node."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :kind]
  defstruct [:info, :kind, children: []]

  @type t :: %__MODULE__{info: NodeInfo.t(), kind: atom(), children: list()}
end

defmodule PythonOntology.Syntax.Generic do
  @moduledoc "Generic normalized syntax node for unsupported parser nodes."

  alias PythonOntology.Syntax.NodeInfo

  @enforce_keys [:info, :raw_type]
  defstruct [:info, :raw_type, children: [], raw_text: nil]

  @type t :: %__MODULE__{
          info: NodeInfo.t(),
          raw_type: String.t(),
          children: list(),
          raw_text: String.t() | nil
        }
end
