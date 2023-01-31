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
          "Tree": [
            RoseTree,
            RoseTree.TreeNode
          ],
          "Zipper": [
            RoseTree.Zipper,
            RoseTree.Zipper.Context,
            RoseTree.Zipper.Location,
            RoseTree.Zipper.Kin,
            RoseTree.Zipper.Traversal
          ],
          "Util": [
            RoseTree.Util
          ],
          "Dev Support": [
            RoseTree.Support.Generators
          ]
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
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "dev", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_env), do: ["lib"]
end
