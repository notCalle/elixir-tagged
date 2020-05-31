defmodule Tagged.Guard do
  @moduledoc """
  Generates macros for use in guard expressions.

  ## Examples

      iex> require Outcome
      iex> import Outcome
      iex> f = fn x when is_success(x) -> x; _ -> success(nil) end
      iex> success(:computer) |> f.()
      {:ok, :computer}
      iex> failure(:computer) |> f.()
      {:ok, nil}

  """
  @moduledoc since: "0.3.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @doc false
  def __deftagged__(params) do
    with true <- Keyword.get(params, :guard, true),
         module = Keyword.get(params, :module),
         ex_tag = Keyword.get(params, :ex_tag),
         arity = Keyword.get(params, :arity),
         name = Keyword.get(params, :name),
         tag = Keyword.get(params, :tag) do
      gen_guard(tag, module, name, arity, ex_tag)
    else
      _ -> []
    end
  end

  defp gen_guard(tag, module, name, 0, ex_tag) do
    quote do
      @file unquote(__ENV__.file)
      @doc """
      Guard macro for testing if `term` is a `#{unquote(ex_tag)}` tag, with
      constructor `#{unquote(name)}/0`.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> f = fn x when is_#{unquote(name)}(x) -> x; _ -> nil end
          iex> #{unquote(name)}() |> f.()
          :#{unquote(ex_tag)}
          iex> :not_#{unquote(ex_tag)} |> f.()
          nil

      """
      defguard unquote(:"is_#{name}")(term)
               when term == unquote(tag)
    end
  end

  defp gen_guard(tag, module, name, arity, ex_tag) do
    args = for(i <- 1..arity, do: "#{i}") |> Enum.join(", ")

    quote do
      @doc """
      Guard macro for testing if `term` is a `#{unquote(ex_tag)}` tagged tuple,
      with constructor `#{unquote(name)}/#{unquote(arity)}`.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> f = fn x when is_#{unquote(name)}(x) -> x; _ -> nil end
          iex> #{unquote(name)}(#{unquote(args)}) |> f.()
          {:#{unquote(ex_tag)}, #{unquote(args)}}
          iex> {:not_#{unquote(ex_tag)}, #{unquote(args)}} |> f.()
          nil

      """
      defguard unquote(:"is_#{name}")(term)
               when elem(term, 0) == unquote(tag) and
                      tuple_size(term) == unquote(arity + 1)
    end
  end
end
