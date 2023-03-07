defmodule ExRoseTree.MixProject do
  use Mix.Project

  @source_url "https://github.com/StoatPower/ex-rose-tree"

  @version "0.1.0"

  def project do
    [
      app: :rose_tree,
      name: "Rose Tree with Zipper",
      version: @version,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test
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

  defp docs() do
    [
      source_url: @source_url,
      source_ref: "v#{@version}",
      language: "en",
      formatters: ["html"],
      main: "ExRoseTree",
      groups_for_modules: [
        Tree: [
          ExRoseTree
        ],
        Zipper: [
          ExRoseTree.Zipper,
          ExRoseTree.Zipper.Location
        ],
        Util: [
          ExRoseTree.Util
        ],
        "Dev Support": [
          ExRoseTree.Support.Generators,
          ExRoseTree.Support.Trees,
          ExRoseTree.Support.Zippers
        ]
      ],
      groups_for_docs: [
        Guards: &(&1[:section] == :guards),
        "Basic Functionality": &(&1[:section] == :basic),
        Term: &(&1[:section] == :term),
        Children: &(&1[:section] == :children),
        "Common Traversal": &(&1[:section] == :traversal),
        "Path Traversal": &(&1[:section] == :path_traversal),
        "Breadth-first Traversal": &(&1[:section] == :breadth_first),
        "Depth-first Traversal": &(&1[:section] == :depth_first),
        "Direct Ancestors": &(&1[:section] == :ancestors),
        "Direct Descendants": &(&1[:section] == :descendants),
        Siblings: &(&1[:section] == :siblings),
        "Niblings: Nieces & Nephews": &(&1[:section] == :niblings),
        "Piblings: Aunts & Uncles": &(&1[:section] == :piblings),
        "First Cousins": &(&1[:section] == :first_cousins),
        "Second Cousins": &(&1[:section] == :second_cousins),
        "Extended Cousins": &(&1[:section] == :extended_cousins),
        Special: &(&1[:section] == :special)
      ],
      extras: []
    ]
  end
end