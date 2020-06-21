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

        @type bar(t) :: {:bar, t}

        Tagged value tuple with a wrapped type t() \\ term()

  """
  @moduledoc since: "0.1.0"

  ##############################################################################
  ##
  ##  Public API ends here, internal helper functions follows
  ##
  ##############################################################################

  @doc false
  @spec __deftagged__(Keyword.t()) :: Macro.t() | []
  def __deftagged__(params) do
    with true <- Keyword.get(params, :type, true),
         name = Keyword.get(params, :name),
         args = Keyword.get(params, :args),
         tag = Keyword.get(params, :tag),
         p? = Keyword.get(params, :__private__),
         of_type = Keyword.get(params, :of, args) do
      gen_typedef(name, tag, List.wrap(of_type), p?)
    else
      _ -> []
    end
  end

  @doc false
  @spec gen_typedef(atom(), atom(), Macro.t(), boolean()) :: Macro.t()
  def gen_typedef(name, tag, [], false) do
    quote location: :keep do
      @type unquote(name)() :: unquote(tag)
    end
  end

  def gen_typedef(name, tag, [], true) do
    quote location: :keep do
      @typep unquote(name)() :: unquote(tag)
    end
  end

  #
  # FIXME: Generate proper arity type declarations when a type argument is
  # `_`, to allow for parameterized type usage (as we did before).
  #
  # E.g.
  #     deftagged ok(_)
  #     => @type ok(t1) :: {:ok, t1}
  #        @type ok() :: ok(term())
  #
  # FIXME: Multiple arity definitions of the same name will cause
  # redefinitions of @type t/0 and must instead accumulate and declare the sum
  # type in a __before_compile__ hook.
  #
  # E.g.
  #     deftagged error(term())
  #     => @type error() :: {:error, term()}
  #     deftagged error()
  #     => ** (CompileError) ... type error/0 is already defined
  #
  def gen_typedef(name, tag, of_type, false) do
    quote location: :keep do
      @type unquote(name)() :: {unquote(tag), unquote_splicing(of_type)}
    end
  end

  def gen_typedef(name, tag, of_type, true) do
    quote location: :keep do
      @typep unquote(name)() :: {unquote(tag), unquote_splicing(of_type)}
    end
  end
end
