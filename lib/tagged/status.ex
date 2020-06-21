defmodule Tagged.Status do
  @moduledoc ~S"""
  Resoning in terms of the status of a result.

      iex> require Tagged.Status
      iex> import Tagged.Status
      iex> ok(:computer)
      {:ok, :computer}
      iex> with ok(it) <- Keyword.fetch([a: "bacon"], :a), do: "Chunky #{it}!"
      "Chunky bacon!"
      iex> (Keyword.fetch([], :a)
      ...>  |> with_error(fn -> ok("bacon") end)
      ...>  |> with_ok(& "Chunky #{&1}!"))
      "Chunky bacon!"
      iex> is_error(error())
      true
      iex> is_error(error("OH NO!"))
      true

  """
  @moduledoc since: "0.1.0"

  use Tagged
  deftagged ok(value :: term())

  # FIXME: It should really be this easy:
  #
  # deftagged error()
  #           | error(reason :: term())
  #
  deftaggedp error, as: error0(), type: false
  deftaggedp error, as: error1(reason :: term()), type: false

  defmacro error(), do: error0()
  defmacro error(reason), do: error1(reason)

  defguard is_error(term) when is_error0(term) or is_error1(term)

  def with_error(value, f) do
    case Function.info(f, :arity) do
      {:arity, 0} -> value |> with_error0(f)
      {:arity, 1} -> value |> with_error1(f)
    end
  end

  @type error() :: :error | {:error, reason :: term()}
  #
  # FIXME: Instead of all that mess ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  @type t() :: error() | ok()
end
