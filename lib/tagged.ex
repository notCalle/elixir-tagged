defmodule Tagged do
  @moduledoc ~S"""
  Handle tagged value tuples, such as `{:ok, value}` and `{:error, reason}`, in
  various ways, by constructing macros for the regular matching constructs.

  ## Construct and Destructure

      defmodule Tagged.Status
        use Tagged

        deftagged ok
        deftagged error
      end


  ## Guard Statements

  TODO:

  ## Pipe filters

  TBD

  """

  defmacro __using__(_opts) do
    quote do
      use unquote(__MODULE__.Constructor)

      defmacro __using__(_opts) do
        quote do: import(unquote(__MODULE__))
      end
    end
  end
end
