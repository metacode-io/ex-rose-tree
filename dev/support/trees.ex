defmodule ExRoseTree.Support.Trees do
  @moduledoc """
  Sample ExRoseTrees for use in development and testing.
  """

  def empty_tree() do
    %ExRoseTree{term: nil, children: []}
  end

  def leaf_tree() do
    %ExRoseTree{term: 1, children: []}
  end

  def simple_tree() do
    %ExRoseTree{
      term: 1,
      children: [
        %ExRoseTree{term: 2, children: []},
        %ExRoseTree{term: 3, children: []},
        %ExRoseTree{term: 4, children: []}
      ]
    }
  end
end
