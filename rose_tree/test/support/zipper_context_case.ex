defmodule RoseTree.ZipperContextCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to pre-populated `RoseTree.Zipper.Context`
  structs.
  """

  use ExUnit.CaseTemplate

  alias RoseTree.TreeNode
  alias RoseTree.Zipper.{Context, Location}
  alias RoseTree.Support.Generators

  using do
    quote do
      import ExUnit.CaptureLog

      require RoseTree.TreeNode
      require RoseTree.Zipper.Context

      alias RoseTree.{TreeNode, Util}
      alias RoseTree.Zipper.{Context, Location}
      alias RoseTree.Support.Generators
    end
  end

  setup_all do
    # basic trees
    empty_tree = %TreeNode{term: nil, children: []}
    leaf_tree = %TreeNode{term: 1, children: []}

    simple_tree = %TreeNode{
      term: 1,
      children: [
        %TreeNode{term: 2, children: []},
        %TreeNode{term: 3, children: []},
        %TreeNode{term: 4, children: []}
      ]
    }

    # random trees

    tree_x5 = Generators.random_tree(total_nodes: 5)
    tree_x25 = Generators.random_tree(total_nodes: 25)
    tree_x100 = Generators.random_tree(total_nodes: 100)
    tree_x = Generators.random_tree()

    # basic zipper contexts
    empty_ctx = %Context{focus: empty_tree, prev: [], next: [], path: []}
    leaf_ctx = %Context{focus: leaf_tree, prev: [], next: [], path: []}
    simple_ctx = %Context{focus: simple_tree, prev: [], next: [], path: []}

    # random zipper contexts
    ctx_x5 = %Context{focus: tree_x5, prev: [], next: [], path: []}
    ctx_x25 = %Context{focus: tree_x25, prev: [], next: [], path: []}
    ctx_x100 = %Context{focus: tree_x100, prev: [], next: [], path: []}
    ctx_x = %Context{focus: tree_x, prev: [], next: [], path: []}

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

    all_contexts_with_idx =
      [
        empty_ctx,
        leaf_ctx,
        simple_ctx,
        ctx_x5,
        ctx_x25,
        ctx_x100,
        ctx_x
      ]
      |> Enum.with_index()

    %{
      # trees
      all_trees_with_idx: all_trees_with_idx,
      empty_tree: empty_tree,
      leaf_tree: leaf_tree,
      simple_tree: simple_tree,
      tree_x: tree_x,
      tree_x5: tree_x5,
      tree_x25: tree_x25,
      tree_x100: tree_x100,
      # contexts
      all_contexts_with_idx: all_contexts_with_idx,
      empty_ctx: empty_ctx,
      leaf_ctx: leaf_ctx,
      simple_ctx: simple_ctx,
      ctx_x5: ctx_x5,
      ctx_x25: ctx_x25,
      ctx_x100: ctx_x100,
      ctx_x: ctx_x
    }
  end
end
