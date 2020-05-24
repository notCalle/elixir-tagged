defmodule Tagged.Status do
  @moduledoc ~S"""
  Resoning in terms of the status of a result.

      iex> require Tagged.Status
      iex> import Tagged.Status, only: [ok: 1]
      iex> ok(:computer)
      {:ok, :computer}
      iex> with ok(it) <- Keyword.fetch([a: "bacon"], :a), do: "Chunky #{it}!"
      "Chunky bacon!"

  """
  @moduledoc since: "0.1.0"

  use Tagged

  deftagged ok
  deftagged error
end
