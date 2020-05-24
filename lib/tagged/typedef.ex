defmodule Tagged.Typedef do
  @moduledoc ~S"""
  Generates type definitions for tagged value tuples.

  This module is executed by default, but can be disabled for a whole module
  with keyword argument `types: false` to `use/2`, or for a single definition
  with keyword argument `type: false` to `Tagged.deftagged/2`.

  The wrapped type can be declared statically, which makes it opaque, by giving
  the `of:` keyword to `Tagged.deftagged/2`.

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

        @opaque bar(t)

        Tagged value tuple with a wrapped type t() \\ term()

  - Make the wrapped type static opaque

        defmodule DocTest.OpaqueType do
          use Tagged

          deftagged foo, of: Pid.t()
        end

        _iex> use DocTest.OpaqueType
        _iex> t foo
        @opaque foo()

  """
  @moduledoc since: "0.1.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @typep macro?() :: Macro.t() | false

  @doc false
  @spec __deftagged__(Keyword.t()) :: macro?
  def __deftagged__(params) do
    with true <- Keyword.get(params, :type, true),
         name = Keyword.get(params, :name),
         tag = Keyword.get(params, :tag),
         of_type = Keyword.get(params, :of, false) do
      gen_typedef(name, tag, of_type)
    end
  end

  @doc false
  @spec gen_typedef(atom(), atom(), macro?()) :: Macro.t()
  def gen_typedef(name, tag, false) do
    quote do
      @typedoc ~S"""
      Tagged value tuple with a wrapped type `t` \\\\ `term()`
      """
      @opaque unquote(name)(t) :: {unquote(tag), value :: t}
      @type unquote(name)() :: unquote(name)(term())
    end
  end

  def gen_typedef(name, tag, of_type) do
    quote do
      @typedoc ~S"""
      Tagged value tuple with a wrapped type `t` \\\\ `term()`
      """
      @opaque unquote(name)() :: {unquote(tag), unquote(of_type)}
    end
  end
end
