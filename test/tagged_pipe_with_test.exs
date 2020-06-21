defmodule TaggedPipeWithTest do
  use ExUnit.Case

  defmodule PipeWith do
    use Tagged

    deftaggedp not_an_integer(number()), guard: false
    deftaggedp not_a_number(), guard: false

    @type reason :: not_an_integer() | not_a_number()

    deftagged success(integer())
    deftagged failure(reason())
    deftagged nil, as: nothing()

    @type result :: success() | failure() | nothing()

    def validate_input(nil), do: nothing()
    def validate_input(x) when is_integer(x), do: success(x)
    def validate_input(x), do: failure(not_an_integer(x))

    def next_number(x), do: x + 1

    def try_recovery(not_an_integer(x)) when is_number(x), do: success(floor(x))
    def try_recovery(_), do: failure(not_a_number())
  end

  doctest Tagged.PipeWith

  test "does not need to import module" do
    require PipeWith, as: P
    assert P.success(1) |> P.with_success(& &1) == 1
    refute P.failure(1) |> P.with_success(& &1) == 1
  end
end
