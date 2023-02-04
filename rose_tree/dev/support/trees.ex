defmodule RoseTree.Support.Trees do
  @moduledoc """
  Sample RoseTrees for use in development and testing.
  """

  alias RoseTree.TreeNode

  def empty_tree() do
    %TreeNode{term: nil, children: []}
  end

  def leaf_tree() do
    %TreeNode{term: 1, children: []}
  end

  def simple_tree() do
    %TreeNode{
      term: 1,
      children: [
        %TreeNode{term: 2, children: []},
        %TreeNode{term: 3, children: []},
        %TreeNode{term: 4, children: []}
      ]
    }
  end

end
