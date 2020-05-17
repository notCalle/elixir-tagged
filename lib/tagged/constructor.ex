defmodule Tagged.Constructor do
  @moduledoc ~S"""
  Helper macros for defining constructors for tagged value tuples.

      defmodule Tagged.Status do
        use Tagged

        deftagged ok
        deftagged error
      end

      iex> use Tagged.Status
      iex> ok(:computer)
      {:ok, :computer}
      iex> with ok(it) <- Keyword.fetch([a: "it"], :a), do: "Found #{it}"
      "Found it"

  """

  @doc false
  def __deftagged__(name, nil), do: __deftagged__(name, name)

  @doc false
  def __deftagged__(name, tag) do
    name = name |> Macro.to_string() |> String.to_atom()
    tag = tag |> Macro.to_string() |> String.to_atom()

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
      @spec unquote(name)(term()) :: {unquote(tag), term()}
      defmacro unquote(name)(value) do
        {unquote(tag), value}
      end
    end
  end

  @doc ~S"""
  Define a macro `name/1` that can be used to construct and destructure a tagged
  value tuple of type `{atom(), term()}`.

  ## Examples

  - When given only one argument, the tag is the same as the macro name

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

  - When given two arguments, the tag is given by the second

        defmodule Tagged.Outcome
          use Tagged

          deftagged success, ok
          deftagged failure, error
        end

        iex> use Tagged.Outcome
        iex> failure(:is_human)
        {:error, :is_human}
        iex> with success(it) <- {:ok, "Computer"}, do: "OK, #{it}!"
        "OK, Computer!"

  """
  defmacro deftagged(name, tag \\ nil), do: __deftagged__(name, tag)

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__), unquote(opts)
    end
  end
end
