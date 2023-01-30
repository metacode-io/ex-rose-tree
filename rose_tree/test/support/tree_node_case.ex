defmodule RoseTree.TreeNodeCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to pre-polutated `RoseTree.TreeNode` structs.
  """

  use ExUnit.CaseTemplate

  alias RoseTree.TreeNode
  alias RoseTree.Support.Generators

  using do
    quote do
      require RoseTree.TreeNode

      alias RoseTree.TreeNode
      alias RoseTree.Support.Generators
    end
  end

  setup do
    empty_tree = %TreeNode{term: nil, children: []}

    leaf_tree = %TreeNode{term: "leaf", children: []}

    simple_tree = %TreeNode{term: "root", children: [
      %TreeNode{term: "child 1", children: []},
      %TreeNode{term: "child 2", children: []},
      %TreeNode{term: "child 3", children: []}
    ]}

    tree_x5 = Generators.random_tree(total_nodes: 5)

    tree_x25 = Generators.random_tree(total_nodes: 25)

    tree_x100 = Generators.random_tree(total_nodes: 100)

    tree_x = Generators.random_tree()

    all_trees_with_idx = [
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
