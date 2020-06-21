defmodule Tagged.PipeWith do
  @moduledoc ~S"""
  Generates a function for selective execution, with pass-through of terms that
  does not match, much like the regular `with ... <- ..., do: ...` construct.

  ## Examples

  Given a module that defines a `success() | failure()` type:

      defmodule PipeWith do
        use Tagged

        deftagged not_an_integer(term())
        deftagged not_a_number(term())

        @type reason() :: not_an_integer() | not_a_number()

        deftagged success(integer())
        deftagged failure(reason())

        @type result() :: success() | failure()

        def validate_input(x) when is_integer(x), do: success(x)
        def validate_input(x), do: failure(not_an_integer(x))

        def next_number(x), do: x + 1

        def try_recovery({_, x}) when is_number(x), do: success(floor(x))
        def try_recovery({_, x}), do: failure(not_a_number(x))
      end

  This is quite similar to the regular `with ... <- ..., do: ..., else: ...`
  for happy paths:

      iex> require PipeWith
      iex> import PipeWith
      iex> with success(v) <- validate_input(1),
      ...>      do: next_number(v)
      2
      iex> validate_input(1)
      ...> |> with_success(&next_number/1)
      2

  When the path is not a happy path, it offers more fluent control over
  recovery from failures at any point in the pipe:

      iex> require PipeWith
      iex> import PipeWith
      iex> with success(v) <- validate_input(0.7) do
      ...>   next_number(v)
      ...> else
      ...>   failure(e) -> with success(v) <- try_recovery(e),
      ...>                      do: next_number(v)
      ...> end
      1
      iex> validate_input(0.7)
      ...> |> with_failure(&try_recovery/1)
      ...> |> with_success(&next_number/1)
      1

  """
  @moduledoc since: "0.2.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @doc false
  @spec __deftagged__(Keyword.t()) :: [Macro.t()]
  def __deftagged__(params) do
    with true <- Keyword.get(params, :pipe_with, true),
         module = Keyword.get(params, :module),
         ex_tag = Keyword.get(params, :ex_tag),
         arity = Keyword.get(params, :arity),
         name = Keyword.get(params, :name),
         tag = Keyword.get(params, :tag),
         p? = Keyword.get(params, :__private__) do
      [
        gen_doc(module, name, arity, ex_tag, p?),
        gen_pipe_with(name, tag, arity, p?)
      ]
    else
      _ -> []
    end
  end

  @spec gen_doc(module(), atom(), integer(), String.t(), boolean()) :: Macro.t()
  defp gen_doc(_, _, _, _, true), do: nil

  defp gen_doc(module, name, 0, ex_tag, false) do
    quote do
      @doc """
      Calls `f/0`, when `term` matches `#{unquote(ex_tag)}`
      When `term` does not match, is is returned as-is.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> :#{unquote(ex_tag)}
          ...> |> with_#{unquote(name)}(fn -> :match end)
          :match
          iex> :not_#{unquote(ex_tag)}
          ...> |> with_#{unquote(name)}(fn -> :match end)
          :not_#{unquote(ex_tag)}

      """
    end
  end

  defp gen_doc(module, name, arity, ex_tag, false) do
    match = for(_ <- 1..arity, do: "_") |> Enum.join(", ")
    vals = for(i <- 1..arity, do: "#{i}") |> Enum.join(", ")

    ex_hit = "{:#{ex_tag}, #{vals}}"

    quote do
      @doc """
      Calls `f/#{unquote(arity)}` with the wrapped value, when `term` matches a
      `#{unquote(ex_tag)}` tagged tuple. When `term` does not match, is is
      returned as-is.

          iex> require #{unquote(module)}
          iex> import #{unquote(module)}
          iex> #{unquote(ex_hit)}
          ...> |> with_#{unquote(name)}(fn #{unquote(match)} -> :match end)
          :match
          iex> {:not_#{unquote(ex_tag)}, :miss} |> with_#{unquote(name)}(& &1)
          {:not_#{unquote(ex_tag)}, :miss}

      """
    end
  end

  @spec gen_pipe_with(atom(), atom(), integer(), boolean()) :: Macro.t()
  defp gen_pipe_with(name, tag, 0, false) do
    quote location: :keep do
      def unquote(:"with_#{name}")(term, f) do
        with unquote(tag) <- term, do: f.()
      end
    end
  end

  defp gen_pipe_with(name, tag, 0, true) do
    quote location: :keep do
      defp unquote(:"with_#{name}")(term, f) do
        with unquote(tag) <- term, do: f.()
      end
    end
  end

  defp gen_pipe_with(name, tag, arity, false) do
    args = Macro.generate_arguments(arity, nil)

    quote do
      def unquote(:"with_#{name}")(term, f) do
        with {unquote(tag), unquote_splicing(args)} <- term,
             do: f.(unquote_splicing(args))
      end
    end
  end

  defp gen_pipe_with(name, tag, arity, true) do
    args = Macro.generate_arguments(arity, nil)

    quote do
      defp unquote(:"with_#{name}")(term, f) do
        with {unquote(tag), unquote_splicing(args)} <- term,
             do: f.(unquote_splicing(args))
      end
    end
  end
end
