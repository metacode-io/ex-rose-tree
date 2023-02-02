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

    ctx_with_siblings = Generators.random_zipper(num_locations: 0)
    ctx_with_locations = Generators.random_zipper(num_locations: 3)

    ctx_with_grandchildren = %Context{
      focus:
        TreeNode.new(0, [
          TreeNode.new(1, [4, 5, 6]),
          TreeNode.new(2, [7, 8, 9]),
          TreeNode.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }

    ctx_with_grandchildren_2 = %Context{
      focus:
        TreeNode.new(0, [
          TreeNode.new(-100),
          TreeNode.new(1, [4, 5, 6]),
          TreeNode.new(2, [7, 8, 9]),
          TreeNode.new(3, [10, 11, 12]),
          TreeNode.new(100)
        ]),
      prev: [],
      next: [],
      path: []
    }

    ctx_with_great_grandchildren = %Context{
      focus:
        TreeNode.new(0, [
          TreeNode.new(1, [4, 5, 6]),
          TreeNode.new(2, [
            TreeNode.new(7, [13, 14, 15]),
            TreeNode.new(8, [16, 17, 18]),
            TreeNode.new(9, [19, 20, 21])
          ]),
          TreeNode.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }

    ctx_with_great_grandchildren_2 = %Context{
      focus:
        TreeNode.new(0, [
          TreeNode.new(1, [4, 5, 6]),
          TreeNode.new(2, [
            TreeNode.new(-100),
            TreeNode.new(7, [13, 14, 15]),
            TreeNode.new(8, [16, 17, 18]),
            TreeNode.new(9, [19, 20, 21]),
            TreeNode.new(100)
          ]),
          TreeNode.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }

    root_loc = %Location{prev: [], term: 0, next: []}
    loc_1 = %Location{prev: [simple_tree], term: 1, next: [simple_tree]}
    loc_2 = %Location{prev: [simple_tree], term: 2, next: []}
    loc_3 = %Location{prev: [], term: 3, next: [simple_tree]}
    loc_4 = %Location{prev: [tree_x25, simple_tree], term: 4, next: [tree_x5, tree_x, tree_x100]}

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
        ctx_x,
        ctx_with_siblings,
        ctx_with_locations,
        ctx_with_grandchildren,
        ctx_with_grandchildren_2,
        ctx_with_great_grandchildren,
        ctx_with_great_grandchildren_2
      ]
      |> Enum.with_index()

    all_locs_with_idx =
      [
        root_loc,
        loc_1,
        loc_2,
        loc_3,
        loc_4
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
      ctx_x: ctx_x,
      ctx_with_siblings: ctx_with_siblings,
      ctx_with_locations: ctx_with_locations,
      ctx_with_grandchildren: ctx_with_grandchildren,
      ctx_with_grandchildren_2: ctx_with_grandchildren_2,
      ctx_with_great_grandchildren: ctx_with_great_grandchildren,
      ctx_with_great_grandchildren_2: ctx_with_great_grandchildren_2,

      # locations
      all_locs_with_idx: all_locs_with_idx,
      root_loc: root_loc,
      loc_1: loc_1,
      loc_2: loc_2,
      loc_3: loc_3,
      loc_4: loc_4
    }
  end
end
