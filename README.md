![Elixir CI](https://github.com/notCalle/elixir-tagged/workflows/Elixir%20CI/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/notCalle/elixir-tagged/badge.svg?branch=master)](https://coveralls.io/github/notCalle/elixir-tagged?branch=master)
[![Hex package](https://img.shields.io/hexpm/v/tagged)](https://hex.pm/packages/tagged)
[![Hexdocs](https://img.shields.io/badge/hex-docs-orange)](https://hexdocs.pm/tagged)
[![License](https://img.shields.io/github/license/notCalle/elixir-tagged)](https://github.com/notCalle/elixir-tagged/blob/master/LICENSE.txt)

# Tagged

Generates definitions of various things related to tuples with a tagged value,
such as the ubiquitous `{:ok, value}` and `{:error, reason}`.

## Examples

```elixir
defmodule Status
  use Tagged

  deftagged ok(value :: term())
  deftagged error(reason :: term())
end
```

### Construct and Destructure

```elixir
iex> require Status
iex> import Status
iex> ok(:computer)
{:ok, :computer}
iex> with error(reason) <- {:ok, :computer}, do: raise reason
{:ok, :computer}
iex> with error(reason) <- {:error, "OH NO!"}, do: raise reason
** (RuntimeError) OH NO!
```

### Type definitions

```elixir
_iex> require Status
_iex> t Status.error
@type error() :: {:error, reason :: term()}
```

### Selective execution with unwrapped value

```elixir
iex> require Status
iex> import Status
iex> ok(:computer) |> with_ok(& "OK, #{&1}")
"OK, computer"
iex> error("OH NO!") |> with_ok(& "OK, #{&1}")
{:error, "OH NO!"}
```

### Sum Algebraic Data Types

A module that defines some tagged values, a composit type, and guard of those,
forms a Sum Algebraic Data Type, also known as a Tagged Union.

```elixir
defmodule BinTree do
  use Tagged

  deftagged tree(left :: t(), right :: t())
  deftagged leaf(value :: term())
  deftagged nil, as: empty()

  @type t() :: tree() | leaf() | empty()

  defguard is_t(x) when is_tree(x) or is_leaf(x) or is_empty(x)
end

iex> require BinTree
iex> import BinTree
iex> t = tree(leaf(1),
...>          tree(leaf(2),
...>               empty()))
{:tree, {:leaf, 1}, {:tree, {:leaf, 2}, nil}}
iex> is_t(t)
true
```

## Installation

The package can be installed by adding `tagged` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:tagged, "~> 0.4.1"}
  ]
end
```
