defmodule RoseTree.Support.Trees do
  @moduledoc """
  Sample RoseTrees for use in development and testing.
  """

  def empty_tree() do
    %RoseTree{term: nil, children: []}
  end

  def leaf_tree() do
    %RoseTree{term: 1, children: []}
  end

  def simple_tree() do
    %RoseTree{
      term: 1,
      children: [
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 4, children: []}
      ]
    }
  end

end
