defmodule Tagged.Typedef do
  @moduledoc ~S"""
  Generates type definitions for tagged value tuples.

  This module is executed by default, but can be disabled for a whole module
  with keyword argument `types: false` to `use/2`, or for a single definition
  with keyword argument `type: false` to `deftagged/2`.

  ## Examples

  - Disable type declaration for all tagged value tuple definitions

        defmodule DocTest.NoTypes do
          use Tagged, types: false

          deftagged foo
        end

        _iex> use DocTest.NoTypes
        _iex> t foo
        No type information for Kernel.foo was found or Kernel.foo is private

  - Override type declaration for a single tagged value tuple definition

        defmodule DocTest.SomeTypes do
          use Tagged

          deftagged foo, type: false
          deftagged bar
        end

        _iex> use DocTest.SomeTypes
        _iex> t foo
        No type information for Kernel.foo was found or Kernel.foo is private
        _iex> t bar
        @type bar() :: bar(term())

        @type bar(t) :: {:bar, value :: t}

        Tagged value tuple with a wrapped type t() \\ term()

  """
  @moduledoc since: "0.1.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @doc false
  @spec __deftagged__(Keyword.t()) :: Macro.t() | false
  def __deftagged__(params) do
    with true <- Keyword.get(params, :type, true) do
      name = Keyword.get(params, :name)
      tag = Keyword.get(params, :tag)

      quote do
        @typedoc ~S"""
        Tagged value tuple with a wrapped type `t` \\\\ `term()`
        """
        @type unquote(name)(t) :: {unquote(tag), value :: t}
        @type unquote(name)() :: unquote(name)(term())
      end
    end
  end
end
