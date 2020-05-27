defmodule Tagged.Outcome do
  @moduledoc ~S"""
  Reasoning in terms of the outcome of an action.

      iex> require Tagged.Outcome
      iex> import Tagged.Outcome, only: [failure: 1, success: 1]
      iex> failure(:is_human)
      {:error, :is_human}
      iex> with success(it) <- {:ok, "Computer"}, do: "OK, #{it}!"
      "OK, Computer!"

  """
  @moduledoc since: "0.1.0"

  use Tagged

  @deprecated "Define your own module, with the proper type constraints."
  deftagged ok, as: success(result :: term())
  @deprecated "Define your own module, with the proper type constraints."
  deftagged error, as: failure(reason :: term())
end
