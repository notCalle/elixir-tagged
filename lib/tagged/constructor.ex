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

          deftagged ok(term())
          deftagged error(term())
        end

        iex> require Tagged.Status
        iex> import Tagged.Status, only: [ok: 1]
        iex> ok(:computer)
        {:ok, :computer}
        iex> with ok(it) <- Keyword.fetch([a: "bacon"], :a), do: "Chunky #{it}!"
        "Chunky bacon!"

  - Override constructor name

        defmodule Tagged.Outcome
          use Tagged

          deftagged ok, as: success(term())
          deftagged error, as: failure(term())
        end

        iex> require Tagged.Outcome
        iex> import Tagged.Outcome, only: [failure: 1, success: 1]
        iex> failure(:is_human)
        {:error, :is_human}
        iex> with success(it) <- {:ok, "Computer"}, do: "OK, #{it}!"
        "OK, Computer!"
  """
  @moduledoc since: "0.1.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @doc false
  @spec __deftagged__(Keyword.t()) :: [Macro.t()]
  def __deftagged__(params) do
    tag = Keyword.get(params, :tag)
    ex_tag = Keyword.get(params, :ex_tag)
    module = Keyword.get(params, :module)
    name = Keyword.get(params, :name)
    arity = Keyword.get(params, :arity)
    p? = Keyword.get(params, :__private__)

    [
      gen_doc(ex_tag, module, name, arity, p?),
      gen_constructor(tag, name, arity, p?)
    ]
  end

  @spec gen_doc(String.t(), module(), atom(), integer(), boolean()) :: Macro.t()
  defp gen_doc(_, _, _, _, true), do: nil

  defp gen_doc(ex_tag, module, name, 0, false) do
    quote location: :keep do
      @doc """
      Constructor `#{unquote(name)}/0` for `#{unquote(ex_tag)}` tags.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> with #{unquote(name)}() <- :#{unquote(ex_tag)}, do: true
          true
          iex> with #{unquote(name)}() <- :not_#{unquote(ex_tag)}, do: true
          :not_#{unquote(ex_tag)}

      """
    end
  end

  defp gen_doc(ex_tag, module, name, arity, false) do
    ex_match = for(_ <- 1..arity, do: "_") |> Enum.join(", ")
    ex_vals = for(i <- 1..arity, do: "#{i}") |> Enum.join(", ")

    ex_match = "#{name}(#{ex_match})"
    ex_hit = "{:#{ex_tag}, #{ex_vals}}"
    ex_miss = "{:not_#{ex_tag}, #{ex_vals}}"

    quote location: :keep do
      @doc """
      Constructor `#{unquote(name)}/#{unquote(arity)}` for `:#{unquote(ex_tag)}`
      tagged value tuples. Can also be used to destructure tuples.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> with #{unquote(ex_match)} <- #{unquote(ex_hit)}, do: true
          true
          iex> with #{unquote(ex_match)} <- #{unquote(ex_miss)}, do: true
          #{unquote(ex_miss)}

      """
    end
  end

  @spec gen_constructor(atom(), atom(), integer(), boolean()) :: Macro.t()
  defp gen_constructor(tag, name, 0, false) do
    quote location: :keep do
      defmacro unquote(name)(), do: unquote(tag)
    end
  end

  defp gen_constructor(tag, name, 0, true) do
    quote location: :keep do
      defmacrop unquote(name)(), do: unquote(tag)
    end
  end

  defp gen_constructor(tag, name, arity, false) do
    cons_args = Macro.generate_arguments(arity, nil)

    quote location: :keep do
      defmacro unquote(name)(unquote_splicing(cons_args)) do
        args = [unquote_splicing(cons_args)]
        tag = unquote(tag)

        quote do: {unquote(tag), unquote_splicing(args)}
      end
    end
  end

  defp gen_constructor(tag, name, arity, true) do
    cons_args = Macro.generate_arguments(arity, nil)

    quote location: :keep do
      defmacrop unquote(name)(unquote_splicing(cons_args)) do
        args = [unquote_splicing(cons_args)]
        tag = unquote(tag)

        quote do: {unquote(tag), unquote_splicing(args)}
      end
    end
  end
end
