# Weave

A simple block-based action executor. Each block is executed in a separate
`Task`, hence the name -- lets you weave together separate strands of execution
in your program.

## Execution Context
See `Weave.Context`. Every execution starts with some context.

## Actions

Weave only understands a fixed set of actions that are presented as a DAG. See
sample `cooling_pump` to see how to build such a DAG.

### `Weave.Library`
1. `Condition`
2. `Init`
3. `MapLambda`
4. `ReadState`
5. `WriteState`
6. `ReadTimeSeries`
7. `WriteTimeSeries`
8. `Switch`
9. `SendMqtt`
 
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `weave` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:weave, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/weave](https://hexdocs.pm/weave).

