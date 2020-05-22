defmodule Tagged do
  @moduledoc ~S"""
  Generates definitions of various things related to tuples with a tagged value,
  such as the ubiquitous `{:ok, value}` and `{:error, reason}`.

  ## Examples

      defmodule Tagged.Status
        use Tagged

        deftagged ok
        deftagged error
      end

  ### Construct and Destructure

      iex> use Tagged.Status
      iex> ok(:computer)
      {:ok, :computer}
      iex> with error(reason) <- {:ok, :computer}, do: raise reason
      {:ok, :computer}

  See `Tagged.Constructor` for further details.

  ### Type definitions

      _iex> use Tagged.Status
      _iex> t Tagged.Status.error
      @type error() :: {:error, term()}

      Tagged value tuple, containing term().

  See `Tagged.Typedef` for further details.

  ### Pipe selective execution

      iex> use Tagged.Status
      iex> ok(:computer) |> with_ok(& "OK, #{&1}")
      "OK, computer"

  See `Tagged.PipeWith` for further details.

  """
  @moduledoc since: "0.1.0"

  require __MODULE__.Constructor
  require __MODULE__.Typedef
  import KeywordValidator, only: [validate!: 2]

  @doc ~S"""
  Generates a macro that definies all things related to a tagged value tuple,
  `{atom(), term()}`. By default the macro has the same name as the tag, and all
  the things are generated.

  ## Keywords

  - `as: name`

    Override default macro name. See `Tagged.Constructor`

  - `type: false`

    Override generation of type definition. See `Tagged.Typedef`

  - `pipe_with: false`

    Override generation of pipe filter. See `Tagged.PipeWith`

  """
  @doc since: "0.1.0"
  defmacro deftagged(tag, opts \\ []) do
    block =
      get_params(tag, Macro.expand_once(opts, __CALLER__), __CALLER__.module)
      |> generate_parts()

    quote do: (unquote_splicing(block))
  end

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @typep block :: [Macro.t()]
  @typep macro? :: Macro.t() | false | nil
  @typep accumulator :: {block(), Keyword.t()}
  @typep macro_gen :: (Keyword.t() -> macro?())

  @opts_schema %{
    as: [optional: true, type: {:tuple, {:atom, :list, :any}}],
    type: [optional: true, type: :boolean],
    pipe_with: [optional: true, type: :boolean]
  }

  @doc false
  @spec get_params(Macro.t(), Keyword.t(), module()) :: Keyword.t()
  defp get_params(tag, opts, module) do
    opts = validate!(opts, @opts_schema)
    name = Keyword.get(opts, :as, tag)

    [
      name: name |> Macro.to_string() |> String.to_atom(),
      tag: tag |> Macro.to_string() |> String.to_atom(),
      module: module
    ] ++ opts ++ Module.get_attribute(module, :tagged__using__opts, [])
  end

  @doc false
  @spec start(Keyword.t()) :: accumulator()
  defp start(params), do: {[], params}

  @doc false
  @spec finish(accumulator()) :: block()
  defp finish({acc, _}), do: acc |> Enum.reverse()

  @doc false
  @spec accumulate(accumulator(), macro?()) :: accumulator()
  defp accumulate(acc, result) when result in [nil, false], do: acc
  defp accumulate({acc, params}, result), do: {[result | acc], params}

  @doc false
  @spec pipe(accumulator(), macro_gen()) :: accumulator()
  defp pipe({_, params} = acc, f), do: accumulate(acc, f.(params))

  @doc false
  @spec generate_parts(Keyword.t()) :: Macro.t()
  defp generate_parts(params) do
    start(params)
    |> pipe(&__MODULE__.Constructor.__deftagged__(&1))
    |> pipe(&__MODULE__.PipeWith.__deftagged__(&1))
    |> pipe(&__MODULE__.Typedef.__deftagged__(&1))
    |> finish()
  end

  @opts_schema %{
    types: [optional: true, type: :boolean],
    pipe_with: [optional: true, type: :boolean]
  }

  @opts_map %{
    types: :type
  }

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

      defmacro __using__(opts) do
        quote do: import(unquote(__MODULE__), unquote(opts))
      end
    end
  end
end
