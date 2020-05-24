defmodule DocTest do
  use ExUnit.Case

  doctest Tagged
  doctest Tagged.Constructor
  doctest Tagged.Guard

  defmodule PipeWith do
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

  doctest Tagged.PipeWith

  defmodule NoTypes do
    use Tagged, types: false

    deftagged foo
  end

  defmodule SomeTypes do
    use Tagged

    deftagged foo, type: false
    deftagged bar
  end

  doctest Tagged.Typedef
  doctest Tagged.Outcome
  doctest Tagged.Status
end
