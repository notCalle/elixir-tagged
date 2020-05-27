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
defmodule Tagged.Status
  use Tagged

  deftagged ok
  deftagged error
end
```

### Construct and Destructure

```elixir
iex> use Tagged.Status
iex> ok(:computer)
{:ok, :computer}
iex> with error(reason) <- {:ok, :computer}, do: raise reason
{:ok, :computer}
```

### Type definitions

```elixir
_iex> use Tagged.Status
_iex> t Tagged.Status.error
@type error() :: {:error, term()}

Tagged value tuple, containing term().
```

### Selective execution with unwrapped value

```elixir
iex> use Tagged.Status
iex> ok(:computer) |> with_ok(& "OK, #{&1}")
"OK, computer"
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
    {:tagged, "~> 0.3.0"}
  ]
end
```
