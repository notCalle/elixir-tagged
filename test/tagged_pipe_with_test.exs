defmodule TaggedPipeWithTest do
  use ExUnit.Case

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

  test "does not need to import module" do
    require PipeWith, as: P
    assert P.success(1) |> P.with_success(& &1) == 1
    refute P.failure(1) |> P.with_success(& &1) == 1
  end
end
