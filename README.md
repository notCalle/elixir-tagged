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

## Installation

The package can be installed by adding `tagged` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:tagged, "~> 0.2.0"}
  ]
end
```
