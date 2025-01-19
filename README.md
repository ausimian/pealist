# Pealist

An Elixir library to parse files in Apple's binary property list format.

This library was forked from [plist](https://github.com/ciaran/plist) which
appears unmaintained as of 2025.

## Installation

Add pealist to your list of dependencies in `mix.exs`:

    def deps do
      [{:pealist, "~> 0.1"}]
    end

## Usage

    plist = File.read!(path) |> Pealist.decode()
