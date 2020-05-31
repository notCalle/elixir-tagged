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
  def __deftagged__(params) do
    with true <- Keyword.get(params, :pipe_with, true),
         module = Keyword.get(params, :module),
         ex_tag = Keyword.get(params, :ex_tag),
         arity = Keyword.get(params, :arity),
         name = Keyword.get(params, :name) do
      gen_pipe_with(module, name, arity, ex_tag)
    else
      _ -> []
    end
  end

  def gen_pipe_with(module, name, 0, ex_tag) do
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
      defmacro unquote(:"with_#{name}")(term, f) do
        name = unquote(name)

        quote do
          with unquote(name)() <- unquote(term), do: unquote(f).()
        end
      end
    end
  end

  def gen_pipe_with(module, name, arity, ex_tag) do
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
      defmacro unquote(:"with_#{name}")(term, f) do
        name = unquote(name)
        args = Macro.generate_arguments(unquote(arity), nil)

        quote do
          with unquote(name)(unquote_splicing(args)) <- unquote(term),
               do: unquote(f).(unquote_splicing(args))
        end
      end
    end
  end
end
