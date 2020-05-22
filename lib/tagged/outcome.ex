defmodule Tagged.Outcome do
  @moduledoc ~S"""
  Reasoning in terms of the outcome of an action.

      iex> use Tagged.Outcome
      iex> failure(:is_human)
      {:error, :is_human}
      iex> with success(it) <- {:ok, "Computer"}, do: "OK, #{it}!"
      "OK, Computer!"

  """
  @moduledoc since: "0.1.0"

  use Tagged

  deftagged ok, as: success
  deftagged error, as: failure
end
