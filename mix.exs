defmodule Plist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plist,
      version: "0.0.7",
      description: "An Elixir library to parse files in Apple's property list formats",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  def application do
    [extra_applications: [:xmerl]]
  end

  defp package do
    [
      maintainers: ["Ciarán Walsh"],
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/ciaran/plist"
      }
    ]
  end
end
