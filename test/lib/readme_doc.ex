defmodule ReadmeDoc do
  file = Path.expand("../../README.md", __DIR__)
  @moduledoc File.read!(file)
  @external_resource file
end
