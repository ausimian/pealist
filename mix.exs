defmodule Pealist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :pealist,
      version: version(),
      description: "Parsing support for Apple's property list formats",
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/ausimian/pealist",
      source_ref: "#{version()}",
      extras: ["LICENSE.md", "CHANGELOG.md", "README.md"]
    ]
  end

  def application do
    [extra_applications: [:xmerl]]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        github: "https://github.com/ausimian/plist/#{version()}"
      }
    ]
  end

  defp version do
    version_from_pkg() || version_from_github() || version_from_git() || "0.0.0"
  end

  defp version_from_github do
    if System.get_env("GITHUB_REF_TYPE") == "tag" do
      System.get_env("GITHUB_REF_NAME")
    end
  end

  defp version_from_pkg do
    if File.exists?("./hex_metadata.config") do
      {:ok, info} = :file.consult("./hex_metadata.config")
      Map.new(info)["version"]
    end
  end

  defp version_from_git do
    case System.cmd("git", ["describe", "--dirty"], stderr_to_stdout: true) do
      {version, 0} -> String.trim(version)
      _ -> nil
    end
  end
end
