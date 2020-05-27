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

  defmodule BinTree do
    use Tagged

    deftagged tree(left :: t(), right :: t())
    deftagged leaf(value :: term())
    deftagged nil, as: empty()

    @type t() :: tree() | leaf() | empty()

    defguard is_t(x) when is_tree(x) or is_leaf(x) or is_empty(x)

    @spec leaves(t()) :: [term()]
    def leaves(empty()), do: []
    def leaves(leaf(v)), do: [v]
    def leaves(tree(l, r)), do: leaves(l) ++ leaves(r)
  end

  doctest Tagged
  doctest Tagged.Constructor
  doctest Tagged.Guard

  defmodule PipeWith do
    use Tagged

    deftagged not_an_integer
    deftagged not_a_number

    @type reason :: not_an_integer() | not_a_number()

    deftagged success(integer())
    deftagged failure(reason())

    @type result :: success() | failure()

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

  defmodule DocTest.OpaqueType do
    use Tagged

    deftagged foo, of: Pid.t()
  end

  doctest Tagged.Typedef
  doctest Tagged.Outcome
  doctest Tagged.Status
end
