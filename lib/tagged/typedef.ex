defmodule Tagged.Typedef do
  @moduledoc ~S"""
  Generates type definitions for tagged value tuples.

  This module is executed by default, but can be disabled with `type: false`
  as keyword argument for either `defmacro` or `use Tagged`.

  ## Examples

  - Disable type declaration for all tagged value tuple definitions

        defmodule NoTypes do
          use Tagged, type: false

          deftagged foo
        end

        _iex> use NoTypes
        _iex> t NoTypes.foo
        No type information for NoTypes.foo was found or NoTypes.foo is private

  - Override type declaration for a single tagged value tuple definition

        defmodule SomeTypes do
          use Tagged

          deftagged foo, type: false
          deftagged bar
        end

        _iex> use Types
        _iex> t NoTypes.foo
        No type information for NoTypes.foo was found or NoTypes.foo is private
        _iex> t NoTypes.bar
        @type bar() :: {:bar, term()}

        Tagged value tuple, containing term().
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
      name = Keyword.get(params, :name_var)
      tag = Keyword.get(params, :tag_atom)

      quote do
        @typedoc "Tagged value tuple, containing `term()`."
        @type unquote(name) :: {unquote(tag), term()}

        # FIXME: Why doesn't this work?
        # @type unquote(name)(t) :: {unquote(tag), t}
      end
    end
  end
end
