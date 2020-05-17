defmodule TaggedTest do
  use ExUnit.Case
  doctest Tagged

  test "greets the world" do
    assert Tagged.hello() == :world
  end
end
