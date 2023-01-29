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
    tree_x5 = Generators.random_tree(total_nodes: 5)

    tree_x25 = Generators.random_tree(total_nodes: 25)

    tree_x100 = Generators.random_tree(total_nodes: 100)

    tree_x = Generators.random_tree()

    %{
      tree_x: tree_x,
      tree_x5: tree_x5,
      tree_x25: tree_x25,
      tree_x100: tree_x100
    }
  end
end
