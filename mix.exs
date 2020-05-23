defmodule Tagged.MixProject do
  use Mix.Project

  @description """
  Generates definitions of various things related to `{:tag, value}` tuples.
  """

  @version "0.2.0"

  @deps [
    {:keyword_validator, "~> 1.0"},
    # ----------------------------------------------------------------------
    {:dialyxir, "~> 1.0", only: :dev, runtime: false},
    {:ex_doc, "~> 0.22", only: :dev, runtime: false},
    {:version_tasks, "~> 0.11", only: :dev, runtime: false}
  ]

  @docs [
    main: "Tagged",
    api_reference: false,
    extras: ["CHANGELOG.md"],
    source_ref: "v#{@version}"
  ]

  def project do
    [
      app: :tagged,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: @deps,
      package: package(),
      description: @description,
      source_url: "https://github.com/notCalle/elixir-tagged",
      docs: @docs
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
