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
         arity = Keyword.get(params, :arity),
         name = Keyword.get(params, :name),
         tag = Keyword.get(params, :tag) do
      gen_guard(tag, module, name, arity)
    else
      _ -> []
    end
  end

  defp gen_guard(tag, module, name, 0) do
    quote do
      @doc """
      Guard macro for testing if `term` is a `#{unquote(tag)}` tag, with
      constructor `#{unquote(name)}/0`.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> f = fn x when is_#{unquote(name)}(x) -> x; _ -> nil end
          iex> :#{unquote(tag)} |> f.()
          :#{unquote(tag)}
          iex> :not_#{unquote(tag)} |> f.()
          nil

      """
      defguard unquote(:"is_#{name}")(term)
               when term == unquote(tag)
    end
  end

  defp gen_guard(tag, module, name, arity) do
    quote do
      @doc """
      Guard macro for testing if `term` is a `#{unquote(tag)}` tagged tuple, with
      constructor `#{unquote(name)}/#{unquote(arity)}`.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> f = fn x when is_#{unquote(name)}(x) -> x; _ -> nil end
          iex> {:#{unquote(tag)}, true} |> f.()
          {:#{unquote(tag)}, true}
          iex> {:not_#{unquote(tag)}, true} |> f.()
          nil

      """
      defguard unquote(:"is_#{name}")(term)
               when elem(term, 0) == unquote(tag) and
                      tuple_size(term) == unquote(arity + 1)
    end
  end
end
