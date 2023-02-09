defmodule RoseTree.Support.Zippers do
  @moduledoc """
  Sample Zippers for use in development and testing.
  """

  alias RoseTree.Support.Trees
  alias RoseTree.TreeNode
  alias RoseTree.Zipper.{Context, Location}

  def empty_ctx() do
    %Context{focus: Trees.empty_tree(), prev: [], next: [], path: []}
  end

  def leaf_ctx() do
    %Context{focus: Trees.leaf_tree(), prev: [], next: [], path: []}
  end

  def simple_ctx() do
    %Context{focus: Trees.simple_tree(), prev: [], next: [], path: []}
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

  def ctx_with_descendant_niblings() do
    %Context{
      focus: TreeNode.new(5),
      prev: [
        TreeNode.new(3, [
          TreeNode.new(10, [
            TreeNode.new(18),
            TreeNode.new(19),
          ]),
          TreeNode.new(11, [
            TreeNode.new(20),
            TreeNode.new(21),
          ]),
          TreeNode.new(12, [
            TreeNode.new(22),
            TreeNode.new(23, [
              TreeNode.new(24),
              TreeNode.new(25)
            ])
          ])
        ]),
        TreeNode.new(2, [
          TreeNode.new(16),
          TreeNode.new(17)
        ]),
        TreeNode.new(1)
      ],
      next: [
        TreeNode.new(7, [
          TreeNode.new(13, [
            TreeNode.new(29, [
              TreeNode.new(37),
              TreeNode.new(38)
            ]),
            TreeNode.new(30),
            TreeNode.new(31)
          ]),
          TreeNode.new(14, [
            TreeNode.new(32),
            TreeNode.new(33),
            TreeNode.new(34)
          ]),
          TreeNode.new(15)
        ]),
        TreeNode.new(8, [
          TreeNode.new(26),
          TreeNode.new(27),
          TreeNode.new(28, [
            TreeNode.new(35),
            TreeNode.new(36)
          ])
        ]),
        TreeNode.new(9)
      ],
      path: [
        Location.new(100)
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

  def ctx_with_ancestral_piblings() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(13),
        Location.new(12),
        Location.new(11),
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

  def ctx_with_no_ancestral_piblings() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(12),
        Location.new(11),
        Location.new(10),
        Location.new(5)
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
            TreeNode.new(17),
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

  def ctx_with_2nd_cousins() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(15),
        Location.new(10,
          prev: [
            TreeNode.new(6),
            TreeNode.new(4, [
              TreeNode.new(22, [
                TreeNode.new(44),
                TreeNode.new(45),
                TreeNode.new(46)
              ]),
              TreeNode.new(23),
              TreeNode.new(24, [
                TreeNode.new(47),
                TreeNode.new(48),
                TreeNode.new(49)
              ])
            ]),
            TreeNode.new(2, [
              TreeNode.new(19),
              TreeNode.new(20, [
                TreeNode.new(50),
                TreeNode.new(51)
              ]),
              TreeNode.new(21)
            ])
          ],
          next: [
            TreeNode.new(14),
            TreeNode.new(16, [
              TreeNode.new(25),
              TreeNode.new(26, [
                TreeNode.new(52),
                TreeNode.new(53)
              ]),
              TreeNode.new(27)
            ]),
            TreeNode.new(18, [
              TreeNode.new(28, [
                TreeNode.new(54),
                TreeNode.new(55),
                TreeNode.new(56)
              ]),
              TreeNode.new(29),
              TreeNode.new(30, [
                TreeNode.new(57),
                TreeNode.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def ctx_with_extended_cousins() do
    %Context{
      focus: TreeNode.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(100),
        Location.new(15),
        Location.new(10,
          prev: [
            TreeNode.new(6),
            TreeNode.new(4, [
              TreeNode.new(22, [
                TreeNode.new(44),
                TreeNode.new(45, [
                  TreeNode.new(101),
                  TreeNode.new(102)
                ]),
                TreeNode.new(46)
              ]),
              TreeNode.new(23),
              TreeNode.new(24, [
                TreeNode.new(47),
                TreeNode.new(48),
                TreeNode.new(49)
              ])
            ]),
            TreeNode.new(2, [
              TreeNode.new(19),
              TreeNode.new(20, [
                TreeNode.new(50, [
                  TreeNode.new(103)
                ]),
                TreeNode.new(51, [
                  TreeNode.new(104)
                ])
              ]),
              TreeNode.new(21)
            ])
          ],
          next: [
            TreeNode.new(14),
            TreeNode.new(16, [
              TreeNode.new(25),
              TreeNode.new(26, [
                TreeNode.new(52, [
                  TreeNode.new(105),
                  TreeNode.new(110)
                ]),
                TreeNode.new(53, [
                  TreeNode.new(106)
                ])
              ]),
              TreeNode.new(27)
            ]),
            TreeNode.new(18, [
              TreeNode.new(28, [
                TreeNode.new(54),
                TreeNode.new(55, [
                  TreeNode.new(107),
                  TreeNode.new(108)
                ]),
                TreeNode.new(56)
              ]),
              TreeNode.new(29),
              TreeNode.new(30, [
                TreeNode.new(57),
                TreeNode.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def ctx_with_extended_cousins_2() do
    %Context{
      focus: 3,
      prev: [
        TreeNode.new(1),
        TreeNode.new(2)
      ],
      next: [],
      path: [
        Location.new(5,
          prev: [TreeNode.new(4)],
          next: [TreeNode.new(6)]),
        Location.new(8,
          prev: [TreeNode.new(7)],
          next: [TreeNode.new(9)]),
        Location.new(10,
          prev: [],
          next: [
            TreeNode.new(11),
            TreeNode.new(12, [
              TreeNode.new(13),
              TreeNode.new(14)
            ])
          ]),
        Location.new(15,
          prev: [
            TreeNode.new(-16, [
              TreeNode.new(-18, [
                TreeNode.new(-21),
                TreeNode.new(-22)
              ]),
              TreeNode.new(-19, [
                TreeNode.new(-23),
                TreeNode.new(-24, [
                  TreeNode.new(-26),
                  TreeNode.new(-27, [
                    TreeNode.new(-29),
                    TreeNode.new(-30),
                    TreeNode.new(-31)
                  ]),
                  TreeNode.new(-28)
                ]),
                TreeNode.new(-25)
              ]),
              TreeNode.new(-20)
            ]),
            TreeNode.new(-17, [
              TreeNode.new(-32),
              TreeNode.new(-33),
              TreeNode.new(-34)
            ])
          ],
          next: [
            TreeNode.new(16, [
              TreeNode.new(18, [
                TreeNode.new(21),
                TreeNode.new(22)
              ]),
              TreeNode.new(19, [
                TreeNode.new(23),
                TreeNode.new(24, [
                  TreeNode.new(26),
                  TreeNode.new(27, [
                    TreeNode.new(29),
                    TreeNode.new(30),
                    TreeNode.new(31)
                  ]),
                  TreeNode.new(28)
                ]),
                TreeNode.new(25)
              ]),
              TreeNode.new(20)
            ]),
            TreeNode.new(17, [
              TreeNode.new(32),
              TreeNode.new(33),
              TreeNode.new(34)
            ])
          ]),
        Location.new(35)
      ]
    }
  end
end
