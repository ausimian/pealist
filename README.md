# Pealist

An Elixir library to parse files in Apple's binary property list format.

## Installation

Add plist to your list of dependencies in `mix.exs`:

    def deps do
      [{:pealist, "~> 0.1"}]
    end

## Usage

    plist = File.read!(path) |> Pealist.decode()
