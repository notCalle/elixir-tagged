defmodule Tagged do
  @moduledoc ~S"""
  Generates definitions or various things related to tagged value tuples, like
  `{:ok, value}` and `{:error, reason}`.

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

  ## Guard Statements

  TODO:

  ## Pipe filters

  TBD

  """

  require __MODULE__.Constructor
  @doc ~S"""
  Generates a macro that definies all things related to a tagged value tuple,
  `{atom(), term()}`. By default the macro has the same name as the tag, and all
  the things are generated.

  ## Keywords

  - `as: name`

    Override default macro name. See `Tagged.Constructor`

  """
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

  @doc false
  @spec get_params(Macro.t(), Keyword.t(), Module.t()) :: Keyword.t()
  defp get_params(tag, opts, module) do
    name = Keyword.get(opts, :as, tag)

    [
      name_atom: name |> Macro.to_string() |> String.to_atom(),
      tag_atom: tag |> Macro.to_string() |> String.to_atom(),
      opts: opts ++ Module.get_attribute(module, :tagged__using__opts, [])
    ]
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
    |> pipe(&__MODULE__.Typedef.__deftagged__(&1))
    |> finish()
  end

  defmacro __using__(opts) do
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
