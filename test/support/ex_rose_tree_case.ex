defmodule ExRoseTree.ExRoseTreeCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to pre-polutated `ExRoseTree` structs.
  """

  use ExUnit.CaseTemplate

  alias ExRoseTree
  alias ExRoseTree.Support.Generators

  using do
    quote do
      import ExUnit.CaptureLog

      require Logger
      require ExRoseTree

      alias ExRoseTree
      alias ExRoseTree.Support.Generators
    end
  end

  setup do
    empty_tree = %ExRoseTree{term: nil, children: []}

    leaf_tree = %ExRoseTree{term: 1, children: []}

    simple_tree = %ExRoseTree{
      term: 1,
      children: [
        %ExRoseTree{term: 2, children: []},
        %ExRoseTree{term: 3, children: []},
        %ExRoseTree{term: 4, children: []}
      ]
    }

    tree_x5 = Generators.random_tree(total_nodes: 5)

    tree_x25 = Generators.random_tree(total_nodes: 25)

    tree_x100 = Generators.random_tree(total_nodes: 100)

    tree_x = Generators.random_tree()

    all_trees_with_idx =
      [
        empty_tree,
        leaf_tree,
        simple_tree,
        tree_x5,
        tree_x25,
        tree_x100,
        tree_x
      ]
      |> Enum.with_index()

    %{
      all_trees_with_idx: all_trees_with_idx,
      empty_tree: empty_tree,
      leaf_tree: leaf_tree,
      simple_tree: simple_tree,
      tree_x: tree_x,
      tree_x5: tree_x5,
      tree_x25: tree_x25,
      tree_x100: tree_x100
    }
  end
end
