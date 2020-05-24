defmodule Tagged.Guard do
  @moduledoc """
  Generates macros for use in guard expressions.

  ## Examples

      iex> require Tagged.Outcome
      iex> import Tagged.Outcome
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
    with true <- Keyword.get(params, :guard, true) do
      module = Keyword.get(params, :module)
      name = Keyword.get(params, :name)
      tag = Keyword.get(params, :tag)

      quote do
        @doc """
        Guard macro for testing if `term` is a `#{unquote(tag)}` tagged tuple.

            iex> use #{unquote(module)}
            iex> f = fn x when is_#{unquote(name)}(x) -> x; _ -> nil end
            iex> {:#{unquote(tag)}, true} |> f.()
            {:#{unquote(tag)}, true}
            iex> {:not_#{unquote(tag)}, true} |> f.()
            nil

        """
        defguard unquote(:"is_#{name}")(term)
                 when elem(term, 0) == unquote(tag) and
                        tuple_size(term) == 2
      end
    end
  end
end
