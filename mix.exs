defmodule UnkeyElixirSdk.MixProject do
  use Mix.Project

  def project do
    [
      app: :unkey_elixir_sdk,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "UnkeyElixirSdk",
      source_url: "https://github.com/glamboyosa/unkey-elixir-sdk",
      # The main page in the docs
      main: "UnkeyElixirSdk",
      homepage_url: "https://hexdocs.pm/unkey_elixir_sdk",
      docs: [
        # The main page in the docs
        main: "UnkeyElixirSdk",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "unkey_elixir_sdk",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* ),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/glamboyosa/unkey-elixir-sdk"}
    ]
  end

  defp description() do
    "Unkey.dev Elixir SDK for interacting with the platform programatically."
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
