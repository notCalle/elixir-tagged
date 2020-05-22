# Tagged

Handle tagged value tuples, such as `{:ok, value}` and `{:error, reason}`, in
various ways, by constructing macros for the regular matching constructs.

### Construct and Destructure

```elixir
defmodule Tagged.Status
  use Tagged

  deftagged ok
  deftagged error
end

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

### Pipe selective execution
```elixir
iex> use Tagged.Status
iex> ok(:computer) |> with_ok(& "OK, #{&1}")
"OK, computer"
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tagged` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tagged, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tagged](https://hexdocs.pm/tagged).

