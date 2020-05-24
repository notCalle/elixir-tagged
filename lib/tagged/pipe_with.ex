defmodule Tagged.PipeWith do
  @moduledoc ~S"""
  Generates a function for selective execution, with pass-through of terms that
  does not match, much like the regular `with ... <- ..., do: ...` construct.

  ## Examples

  Given a module that defines a `success() | failure()` type:

      defmodule DocTest.PipeWith do
        use Tagged

        deftagged not_an_integer
        deftagged not_a_number

        @type reason :: not_an_integer() | not_a_number()

        deftagged success
        deftagged failure

        @type result :: success(integer()) | failure(reason())

        def validate_input(x) when is_integer(x), do: success(x)
        def validate_input(x), do: failure(not_an_integer(x))

        def next_number(x), do: x + 1

        def try_recovery({_, x}) when is_number(x), do: success(floor(x))
        def try_recovery({_, x}), do: failure(not_a_number(x))
      end

  This is quite similar to the regular `with ... <- ..., do: ..., else: ...`
  for happy paths:

      iex> require DocTest.PipeWith
      iex> import DocTest.PipeWith
      iex> with success(v) <- validate_input(1),
      ...>      do: next_number(v)
      2
      iex> validate_input(1)
      ...> |> with_success(&next_number/1)
      2

  When the path is not a happy path, it offers more fluent control over
  recovery from failures at any point in the pipe:

      iex> require DocTest.PipeWith
      iex> import DocTest.PipeWith
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
    with true <- Keyword.get(params, :pipe_with, true) do
      module = Keyword.get(params, :module)
      name = Keyword.get(params, :name)
      tag = Keyword.get(params, :tag)

      quote do
        @doc """
        Calls `f/1` with the wrapped value, when `term` matches a
        `#{unquote(tag)}` tagged tuple. When `term` does not match, is is
        returned as-is.

            iex> require #{unquote(module)}
            iex> import #{unquote(module)}
            iex> {:#{unquote(tag)}, :match} |> with_#{unquote(name)}(& &1)
            :match
            iex> {:not_#{unquote(tag)}, :match} |> with_#{unquote(name)}(& &1)
            {:not_#{unquote(tag)}, :match}

        """
        defmacro unquote(:"with_#{name}")(term, f) do
          name = unquote(name)
          tag = unquote(tag)

          quote do
            with unquote(name)(value) <- unquote(term), do: unquote(f).(value)
          end
        end
      end
    end
  end
end
