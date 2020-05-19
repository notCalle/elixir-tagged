defmodule Tagged.Constructor do
  @moduledoc ~S"""
  Generates macros for constructing, and destructuring tagged value tuples.
  By default, the macro name is the same as the tag, but can be overriden with
  the `as: name` keyword argument.

  This module is always executed.

  ## Examples

  - Define constructors with the same name as the tag

        defmodule Tagged.Status
          use Tagged

          deftagged ok
          deftagged error
        end

        iex> use Tagged.Status
        iex> ok(:computer)
        {:ok, :computer}
        iex> with ok(it) <- Keyword.fetch([a: "bacon"], :a), do: "Chunky #{it}!"
        "Chunky bacon!"

  - Override constructor name

        defmodule Tagged.Outcome
          use Tagged

          deftagged ok, as: success
          deftagged error, as: failure
        end

        iex> use Tagged.Outcome
        iex> failure(:is_human)
        {:error, :is_human}
        iex> with success(it) <- {:ok, "Computer"}, do: "OK, #{it}!"
        "OK, Computer!"
  """
  @moduledoc since: "0.1.0"

  ################################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ################################################################################

  @doc false
  @spec __deftagged__(Keyword.t()) :: Macro.t()
  def __deftagged__(params) do
    name = Keyword.get(params, :name_atom)
    tag = Keyword.get(params, :tag_atom)

    quote do
      @doc """
      Constructor for `#{unquote(tag)}` tagged value tuples. Can also be used
      to destructure tuples.

          iex> use #{unquote(__MODULE__)}
          iex> with #{unquote(name)}(val) <- {:#{unquote(tag)}, :match}, do: val
          :match
          iex> with #{unquote(name)}(_) <- {:not_#{unquote(tag)}, :match}, do: true
          {:not_#{unquote(tag)}, :match}

      """
      @spec unquote(name)(term()) :: unquote(name)()
      defmacro unquote(name)(value) do
        {unquote(tag), value}
      end
    end
  end

  @spec generate_type([Macro.t()], atom(), atom()) :: [Macro.t()]
  defp generate_type(block, name, tag) do
    name = Macro.var(name, nil)

    [
      quote do
        @typedoc "Tagged value type, containing `term()`."
        @type unquote(name) :: {unquote(tag), term()}
      end
      | block
    ]
  end

  @spec generate_macro([Macro.t()], atom(), atom()) :: [Macro.t()]
  defp generate_macro(block, name, tag) do
    [
      quote do
        @doc """
        Constructor for `#{unquote(tag)}` tagged value tuples. Can also be used
        to destructure tuples.

            iex> use #{unquote(__MODULE__)}
            iex> with #{unquote(name)}(val) <- {:#{unquote(tag)}, :match}, do: val
            :match
            iex> with #{unquote(name)}(_) <- {:not_#{unquote(tag)}, :match}, do: true
            {:not_#{unquote(tag)}, :match}

        """
        @spec unquote(name)(term()) :: unquote(name)()
        defmacro unquote(name)(value) do
          {unquote(tag), value}
        end
      end
      | block
    ]
  end

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__), unquote(opts)
    end
  end
end
