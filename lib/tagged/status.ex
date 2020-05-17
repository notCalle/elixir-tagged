defmodule Tagged.Status do
  @moduledoc ~S"""
  Resoning in terms of the status of a result.

      iex> use Tagged.Status
      iex> ok(:computer)
      {:ok, :computer}
      iex> with ok(it) <- Keyword.fetch([a: "bacon"], :a), do: "Chunky #{it}!"
      "Chunky bacon!"

  """
  use Tagged

  deftagged(ok)
  deftagged(error)
end
