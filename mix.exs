defmodule Tagged.MixProject do
  use Mix.Project

  @description """
  Generates definitions of various things related to `{:tag, value}` tuples.
  """

  @version "0.4.2"

  @deps [
    {:keyword_validator, "~> 1.0"},
    # ----------------------------------------------------------------------
    {:dialyxir, "~> 1.0", only: :dev, runtime: false},
    {:ex_doc, "~> 0.22", only: :dev, runtime: false},
    {:version_tasks, "~> 0.11", only: :dev, runtime: false},
    {:excoveralls, "~>0.12", only: :test}
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
      deps: @deps,
      description: @description,
      docs: @docs,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/notCalle/elixir-tagged",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # extra_applications: [:logger]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/lib"]
  def elixirc_paths(_), do: ["lib"]

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
