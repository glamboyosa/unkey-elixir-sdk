defmodule UnkeyElixirSdk.MixProject do
  use Mix.Project

  def project do
    [
      app: :unkey_elixir_sdk,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "UnkeyElixirSDK",
      source_url: "https://github.com/glamboyosa/unkeyelixirsdk",
      # The main page in the docs
      main: "MyApp",
      homepage_url: "https://hexdocs.pm/unkey_elixir_sdk",
      docs: [
        # The main page in the docs
        main: "UnkeyElixirSDK"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
