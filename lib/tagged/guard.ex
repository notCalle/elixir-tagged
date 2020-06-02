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
  @spec __deftagged__(Keyword.t()) :: [Macro.t()]
  def __deftagged__(params) do
    with true <- Keyword.get(params, :guard, true),
         module = Keyword.get(params, :module),
         ex_tag = Keyword.get(params, :ex_tag),
         arity = Keyword.get(params, :arity),
         name = Keyword.get(params, :name),
         tag = Keyword.get(params, :tag),
         p? = Keyword.get(params, :__private__) do
      [
        gen_doc(ex_tag, module, name, arity, p?),
        gen_guard(tag, name, arity, p?)
      ]
    else
      _ -> []
    end
  end

  @spec gen_doc(String.t(), module(), atom(), integer(), boolean()) :: Macro.t()
  defp gen_doc(_, _, _, _, true), do: nil

  defp gen_doc(ex_tag, module, name, 0, false) do
    quote do
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
    end
  end

  defp gen_doc(ex_tag, module, name, arity, false) do
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
    end
  end

  @spec gen_guard(atom(), atom(), integer(), boolean()) :: Macro.t()
  defp gen_guard(tag, name, 0, false) do
    quote do
      defguard unquote(:"is_#{name}")(term)
               when term == unquote(tag)
    end
  end

  defp gen_guard(tag, name, 0, true) do
    quote do
      defguardp unquote(:"is_#{name}")(term)
                when term == unquote(tag)
    end
  end

  defp gen_guard(tag, name, arity, false) do
    quote do
      defguard unquote(:"is_#{name}")(term)
               when elem(term, 0) == unquote(tag) and
                      tuple_size(term) == unquote(arity + 1)
    end
  end

  defp gen_guard(tag, name, arity, true) do
    quote do
      defguardp unquote(:"is_#{name}")(term)
                when elem(term, 0) == unquote(tag) and
                       tuple_size(term) == unquote(arity + 1)
    end
  end
end
