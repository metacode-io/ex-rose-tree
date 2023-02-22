defmodule RoseTree.MixProject do
  use Mix.Project

  def project do
    [
      app: :rose_tree,
      name: "Rose Tree with Zipper",
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test
      ],
      docs: [
        main: "RoseTree",
        groups_for_modules: [
          Tree: [
            RoseTree
          ],
          Zipper: [
            RoseTree.Zipper,
            RoseTree.Zipper.Location
          ],
          Util: [
            RoseTree.Util
          ],
          "Dev Support": [
            RoseTree.Support.Generators,
            RoseTree.Support.Trees,
            RoseTree.Support.Zippers
          ]
        ],
        groups_for_docs: [
          Guards: & &1[:section] == :guards,
          "Basic Functionality": & &1[:section] == :basic,
          "Direct Ancestors": & &1[:section] == :ancestors,
          "Direct Descendants": & &1[:section] == :descendants,
          "Siblings": & &1[:section] == :siblings,
          "Niblings: Nieces & Nephews": & &1[:section] == :niblings,
          "Piblings: Aunts & Uncles": & &1[:section] == :piblings,
          "First Cousins": & &1[:section] == :first_cousins,
          "Second Cousins": & &1[:section] == :second_cousins,
          "Extended Cousins": & &1[:section] == :extended_cousins,
          "Basic Traversal": & &1[:section] == :traversal,
          "Breadth-first Traversal": & &1[:section] == :breadth_first,
          "Depth-first Traversal": & &1[:section] == :depth_first,
          "Searching": & &1[:section] == :searching,
        ],
        extras: []
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:credo, "~> 1.6.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14.5", only: :test},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:benchee, "~> 1.1", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "dev", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_env), do: ["lib"]
end
