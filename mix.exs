defmodule Tagged.MixProject do
  use Mix.Project

  @description """
  Generates definitions of various things related to `{:tag, value}` tuples.
  """

  @version "0.1.0"

  @deps [
    {:dialyxir, "~> 1.0", only: :dev, runtime: false},
    {:ex_doc, "~> 0.22", only: :dev, runtime: false},
    {:excoveralls, "~> 0.12", only: :test, runtime: false},
    {:version_tasks, "~> 0.11", only: :dev, runtime: false}
  ]

  def project do
    [
      app: :tagged,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: @deps,
      package: package(),
      description: @description,
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/notCalle/elixir-tagged.git"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Calle Englund"],
      links: %{
        "GitHub" => "https://github.com/notCalle/elixir-tagged"
      }
    ]
  end
end
