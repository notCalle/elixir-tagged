defmodule TaggedTest do
  use ExUnit.Case
  doctest Tagged
end

defmodule ContructorTest do
  use ExUnit.Case
  doctest Tagged.Constructor
end

defmodule OutcomeTest do
  use ExUnit.Case
  doctest Tagged.Outcome, only: [:moduledoc]
end

defmodule StatusTest do
  use ExUnit.Case
  doctest Tagged.Status, only: [:moduledoc]
end
