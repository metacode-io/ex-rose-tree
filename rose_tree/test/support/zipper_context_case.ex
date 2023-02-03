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

    ctx_with_locations = Generators.random_zipper(num_locations: 3)

    ctx_with_parent = %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10)
      ]
    }

    ctx_with_siblings = %Context{
      focus: TreeNode.new(5),
      prev: [
        TreeNode.new(4),
        TreeNode.new(3),
        TreeNode.new(2),
        TreeNode.new(1)
      ],
      next: [
        TreeNode.new(6),
        TreeNode.new(7),
        TreeNode.new(8),
        TreeNode.new(9)
      ]
    }

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

    ctx_with_niblings = %Context{
      focus: TreeNode.new(5),
      prev: [
        TreeNode.new(4),
        TreeNode.new(3, [
          TreeNode.new(10),
          TreeNode.new(11),
          TreeNode.new(12)
        ]),
        TreeNode.new(2),
        TreeNode.new(1)
      ],
      next: [
        TreeNode.new(6),
        TreeNode.new(7, [
          TreeNode.new(13),
          TreeNode.new(14),
          TreeNode.new(15)
        ]),
        TreeNode.new(8),
        TreeNode.new(9)
      ]
    }

    ctx_with_grand_niblings = %Context{
      focus: TreeNode.new(5),
      prev: [
        TreeNode.new(4),
        TreeNode.new(3, [
          TreeNode.new(10, [
            TreeNode.new(18),
            TreeNode.new(19),
            TreeNode.new(20)
          ]),
          TreeNode.new(11),
          TreeNode.new(12)
        ]),
        TreeNode.new(2, [
          TreeNode.new(16),
          TreeNode.new(17, [
            TreeNode.new(21),
            TreeNode.new(22)
          ])
        ]),
        TreeNode.new(1)
      ],
      next: [
        TreeNode.new(6),
        TreeNode.new(7, [
          TreeNode.new(13),
          TreeNode.new(14, [
            TreeNode.new(26),
            TreeNode.new(27),
            TreeNode.new(28)
          ]),
          TreeNode.new(15)
        ]),
        TreeNode.new(8, [
          TreeNode.new(23),
          TreeNode.new(24),
          TreeNode.new(25, [
            TreeNode.new(29),
            TreeNode.new(30)
          ])
        ]),
        TreeNode.new(9)
      ]
    }

    ctx_with_piblings = %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            TreeNode.new(6),
            TreeNode.new(4),
            TreeNode.new(2)
          ],
          next: [
            TreeNode.new(14),
            TreeNode.new(16),
            TreeNode.new(18)
          ]
        )
      ]
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
        ctx_with_parent,
        ctx_with_siblings,
        ctx_with_locations,
        ctx_with_grandchildren,
        ctx_with_grandchildren_2,
        ctx_with_great_grandchildren,
        ctx_with_great_grandchildren_2,
        ctx_with_niblings,
        ctx_with_grand_niblings,
        ctx_with_piblings
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
      ctx_with_parent: ctx_with_parent,
      ctx_with_siblings: ctx_with_siblings,
      ctx_with_locations: ctx_with_locations,
      ctx_with_grandchildren: ctx_with_grandchildren,
      ctx_with_grandchildren_2: ctx_with_grandchildren_2,
      ctx_with_great_grandchildren: ctx_with_great_grandchildren,
      ctx_with_great_grandchildren_2: ctx_with_great_grandchildren_2,
      ctx_with_niblings: ctx_with_niblings,
      ctx_with_grand_niblings: ctx_with_grand_niblings,
      ctx_with_piblings: ctx_with_piblings,

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
