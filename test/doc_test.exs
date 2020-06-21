defmodule DocTest do
  use ExUnit.Case

  defmodule Outcome do
    use Tagged

    deftagged ok, as: success(value :: term())
    deftagged error, as: failure(reason :: term())
  end

  defmodule Status do
    use Tagged

    deftagged ok(value :: term())
    deftagged error(reason :: term())
  end

  doctest Tagged
  doctest Tagged.Constructor
  doctest Tagged.Guard

  defmodule NoTypes do
    use Tagged, types: false

    deftagged foo
  end

  defmodule SomeTypes do
    use Tagged

    deftagged foo, type: false
    deftagged bar
  end

  defmodule DocTest.OpaqueType do
    use Tagged

    deftagged foo, of: Pid.t()
  end

  doctest Tagged.Typedef
  doctest Tagged.Outcome
  doctest Tagged.Status

  doctest BinTree
  doctest ReadmeDoc
end
