defmodule RoseTree.Support.Zippers do
  @moduledoc """
  Sample Zippers for use in development and testing.
  """

  alias RoseTree.Support.Trees
  alias RoseTree.Zipper.{Context, Location}

  def empty_ctx() do
    %Context{focus: Trees.empty_tree(), prev: [], next: [], path: []}
  end

  def leaf_ctx() do
    %Context{focus: Trees.leaf_tree(), prev: [], next: [], path: []}
  end

  def simple_ctx() do
    %Context{focus: Tree.simple_tree(), prev: [], next: [], path: []}
  end

  def ctx_with_parent() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10)
      ]
    }
  end

  def ctx_with_grandparent() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5)
      ]
    }
  end

  def ctx_with_great_grandparent() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5),
        Location.new(1)
      ]
    }
  end

  def ctx_with_siblings() do
    %Context{
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
  end

  def ctx_with_grandchildren() do
    %Context{
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
  end

  def ctx_with_grandchildren_2() do
    %Context{
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
  end

  def ctx_with_great_grandchildren() do
    %Context{
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
  end

  def ctx_with_great_grandchildren_2() do
    %Context{
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
  end

  def ctx_with_niblings() do
    %Context{
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
  end

  def ctx_with_grand_niblings() do
    %Context{
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
  end

  def ctx_with_piblings() do
    %Context{
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
  end

  def ctx_with_grandpiblings() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5,
          prev: [
            TreeNode.new(4),
            TreeNode.new(3),
            TreeNode.new(2)
          ],
          next: [
            TreeNode.new(6),
            TreeNode.new(7),
            TreeNode.new(8)
          ]
        )
      ]
    }
  end

  def ctx_with_1st_cousins() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            TreeNode.new(6),
            TreeNode.new(4, [
              TreeNode.new(22),
              TreeNode.new(23),
              TreeNode.new(24)
            ]),
            TreeNode.new(2, [
              TreeNode.new(19),
              TreeNode.new(20),
              TreeNode.new(21)
            ])
          ],
          next: [
            TreeNode.new(14),
            TreeNode.new(16, [
              TreeNode.new(25),
              TreeNode.new(26),
              TreeNode.new(27)
            ]),
            TreeNode.new(18, [
              TreeNode.new(28),
              TreeNode.new(29),
              TreeNode.new(30)
            ])
          ]
        )
      ]
    }
  end
end
