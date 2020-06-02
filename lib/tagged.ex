defmodule Tagged do
  @moduledoc ~S"""
  Generates definitions to assist working with tagged value tuples,
  such as the ubiquitous `{:ok, value}` and `{:error, reason}`.

  ## Examples

      defmodule Status
        use Tagged

        deftagged ok(value :: term())
        deftagged error(reason :: term())
      end

  ### Construct and Destructure

      iex> require Status
      iex> Status.ok(:computer)
      {:ok, :computer}
      iex> with Status.error(reason) <- {:ok, :computer}, do: raise reason
      {:ok, :computer}

  See `Tagged.Constructor` for further details.

  ### Type definitions

      _iex> t Status.error
      @type error() :: {:error, reason :: term()}

      Tagged value tuple, containing reason :: term()

  See `Tagged.Typedef` for further details.

  ### Pipe selective execution

      iex> require Status
      iex> import Status, only: [ok: 1, with_ok: 2]
      iex> ok(:computer) |> with_ok(& "OK, #{&1}")
      "OK, computer"

  See `Tagged.PipeWith` for further details.

  ### Sum Algebraic Data Type: Binary Tree

  A module that defines some tagged values, a composit type, and guard of those,
  forms a Sum Algebraic Data Type, also known as a Tagged Union.

      defmodule BinTree do
        use Tagged

        deftagged tree(left :: t(), right :: t())
        deftagged leaf(value :: term())
        deftagged nil, as: empty()

        @type t() :: tree() | leaf() | empty()

        defguard is_t(x) when is_tree(x) or is_leaf(x) or is_empty(x)

        @spec leaves(tree()) :: [term()]
        def leaves(empty()), do: []
        def leaves(leaf(v)), do: [v]
        def leaves(tree(l, r)), do: leaves(l) ++ leaves(r)
      end

      iex> require BinTree
      iex> import BinTree
      iex> t = tree(leaf(1),
      ...>          tree(leaf(2),
      ...>               empty()))
      {:tree, {:leaf, 1}, {:tree, {:leaf, 2}, nil}}
      iex> is_t(t)
      true
      iex> leaves(t)
      [1, 2]

  """
  @moduledoc since: "0.1.0"

  import KeywordValidator, only: [validate!: 2]

  @doc ~S"""
  Defines a public tagged value tuple.

  By default the tagged tuple has the same name as the tag, and all of
  constructor, guard, pipe selector, and type are generated.

  If `tag` is specified bare, as in `deftagged ok`, the constructor will have an
  arity of `1`, and the type will wrap a `term()`, for backwards compatibility.

      deftagged ok <=> deftagged ok(term())

  If the `tag` is specified in the form of a parameterized type, the
  constructor will have the same arity as the specified type.

  When the constructor name is changed with `as:`, the type declaration belongs
  to the name, and not the tag.

      deftagged ok, as: success(term())

  ## Keywords

  - `as: name(...)`

    Override default macro name. See `Tagged.Constructor`.

  - `type: false`

    Override generation of type definition. See `Tagged.Typedef`.

  - `guard: false`

    Override generation of guard expression macros. See `Tagged.Guard`.

  - `pipe_with: false`

    Override generation of pipe filter. See `Tagged.PipeWith`.

  - ~~`of: typedef`~~ DEPRECATED ~> 0.4.0

    ~~Declare the wrapped type statically, making it opaque. See `Tagged.Typedef`.~~

  """
  @doc since: "0.1.0"
  defmacro deftagged(tag, opts \\ []) do
    __deftagged__(tag, [__private__: false] ++ opts, __CALLER__)
  end

  @doc ~S"""
  Defines a private tagged value tuple.

  See `Tagged.deftagged/2` for further details and examples.
  """
  @doc since: "0.5.0"
  defmacro deftaggedp(tag, opts \\ []) do
    __deftagged__(tag, [__private__: true] ++ opts, __CALLER__)
  end

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################
  @typep block :: [Macro.t()]
  @typep code :: block() | Macro.t()
  @typep accumulator :: {block(), Keyword.t()}
  @typep macro_gen :: (Keyword.t() -> code())

  @doc false
  @spec __deftagged__(Macro.t(), Keyword.t(), Macro.Env.t()) :: Macro.t()
  defp __deftagged__(tag, opts, caller) do
    module = caller.module

    block =
      (opts ++
         Macro.expand_once(opts, caller) ++
         Module.get_attribute(module, :tagged__using__opts, []))
      |> validate_opts()
      |> (fn opts -> [module: module] ++ opts end).()
      |> parse_tag(tag)
      |> parse_name()
      |> parse_args()
      |> generate_parts()

    quote do: (unquote_splicing(block))
  end

  @opts_schema %{
    as: [optional: true, type: {:tuple, {:atom, :list, :any}}],
    of: [optional: true, type: {:tuple, {:any, :list, :any}}],
    guard: [optional: true, type: :boolean],
    type: [optional: true, type: :boolean],
    pipe_with: [optional: true, type: :boolean],
    __private__: [optional: false, type: :boolean]
  }
  @doc false
  @spec validate_opts(Keyword.t()) :: Keyword.t()
  defp validate_opts(opts), do: validate!(opts, @opts_schema)

  @doc false
  @spec tag_to_s(atom()) :: String.t()
  defp tag_to_s(nil), do: "nil"
  defp tag_to_s(tag) when is_atom(tag), do: "#{tag}"

  @doc false
  @spec parse_tag(Keyword.t(), Macro.t()) :: Keyword.t()
  defp parse_tag(opts, {tag, _, args}),
    do: [tag: tag, ex_tag: tag_to_s(tag), args: args] ++ opts

  defp parse_tag(opts, tag) when is_atom(tag),
    do: [tag: tag, ex_tag: tag_to_s(tag)] ++ opts

  @doc false
  @spec parse_name(Keyword.t()) :: Keyword.t()
  defp parse_name(opts) do
    with tag = Keyword.get(opts, :tag),
         {name, _, args} <- Keyword.get(opts, :as, name: tag) do
      [name: name, args: args]
    end ++ opts
  end

  @doc false
  @spec parse_args(Keyword.t()) :: Keyword.t()
  defp parse_args(opts) do
    case Keyword.get(opts, :args) do
      args when is_list(args) ->
        [args: args, arity: length(args)] ++ opts

      _ ->
        [args: {:term, [], []}, arity: 1] ++ opts
    end
  end

  @doc false
  @spec start(Keyword.t()) :: accumulator()
  defp start(params), do: {[], params}

  @doc false
  @spec finish(accumulator()) :: block()
  defp finish({acc, _}), do: acc

  @doc false
  @spec accumulate(block(), accumulator()) :: accumulator()
  defp accumulate(result, {acc, params}), do: {acc ++ result, params}

  @doc false
  @spec pipe(accumulator(), macro_gen()) :: accumulator()
  defp pipe({_, params} = acc, f) do
    f.(params)
    |> List.wrap()
    |> accumulate(acc)
  end

  @doc false
  @spec generate_parts(Keyword.t()) :: Macro.t()
  defp generate_parts(params) do
    start(params)
    |> pipe(&__MODULE__.Constructor.__deftagged__(&1))
    |> pipe(&__MODULE__.Guard.__deftagged__(&1))
    |> pipe(&__MODULE__.PipeWith.__deftagged__(&1))
    |> pipe(&__MODULE__.Typedef.__deftagged__(&1))
    |> finish()
  end

  @opts_schema %{
    guards: [optional: true, type: :boolean],
    types: [optional: true, type: :boolean],
    pipe_with: [optional: true, type: :boolean]
  }

  @opts_map %{
    guards: :guard,
    types: :type
  }

  @spec __using__(Macro.t()) :: no_return()
  defmacro __using__(opts) do
    opts =
      opts
      |> Macro.expand_once(__CALLER__)
      |> validate!(@opts_schema)
      |> Enum.map(fn {k, v} -> {Map.get(@opts_map, k, k), v} end)

    quote do
      Module.register_attribute(__MODULE__, :tagged__using__opts, [])
      Module.put_attribute(__MODULE__, :tagged__using__opts, unquote(opts))

      import unquote(__MODULE__)

      @deprecated """
      Use `require/2` and `import/2` instead.
      """
      defmacro __using__(opts) do
        quote do: import(unquote(__MODULE__), unquote(opts))
      end
    end
  end
end
