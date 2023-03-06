defmodule ExRoseTree.Support.Zippers do
  @moduledoc """
  Sample Zippers for use in development and testing.

  WARNING :: Do not make modifications to the values or structures
  of these samples without being prepared to rewrite any unit test
  that relies on them!
  """

  alias ExRoseTree.Support.Trees
  alias ExRoseTree.Zipper
  alias ExRoseTree.Zipper.Location

  def empty_z() do
    %Zipper{focus: Trees.empty_tree(), prev: [], next: [], path: []}
  end

  def leaf_z() do
    %Zipper{focus: Trees.leaf_tree(), prev: [], next: [], path: []}
  end

  def simple_z() do
    %Zipper{focus: Trees.simple_tree(), prev: [], next: [], path: []}
  end

  def z_with_parent() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10)
      ]
    }
  end

  def z_with_grandparent() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5)
      ]
    }
  end

  def z_with_great_grandparent() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5),
        Location.new(1)
      ]
    }
  end

  def z_with_siblings() do
    %Zipper{
      focus: ExRoseTree.new(5),
      prev: [
        ExRoseTree.new(4),
        ExRoseTree.new(3),
        ExRoseTree.new(2),
        ExRoseTree.new(1)
      ],
      next: [
        ExRoseTree.new(6),
        ExRoseTree.new(7),
        ExRoseTree.new(8),
        ExRoseTree.new(9)
      ]
    }
  end

  def z_with_grandchildren() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(1, [4, 5, 6]),
          ExRoseTree.new(2, [7, 8, 9]),
          ExRoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_grandchildren_2() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(-100),
          ExRoseTree.new(1, [4, 5, 6]),
          ExRoseTree.new(2, [7, 8, 9]),
          ExRoseTree.new(3, [10, 11, 12]),
          ExRoseTree.new(100)
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_great_grandchildren() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(1, [4, 5, 6]),
          ExRoseTree.new(2, [
            ExRoseTree.new(7, [13, 14, 15]),
            ExRoseTree.new(8, [16, 17, 18]),
            ExRoseTree.new(9, [19, 20, 21])
          ]),
          ExRoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_great_grandchildren_2() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(1, [4, 5, 6]),
          ExRoseTree.new(2, [
            ExRoseTree.new(-100),
            ExRoseTree.new(7, [13, 14, 15]),
            ExRoseTree.new(8, [16, 17, 18]),
            ExRoseTree.new(9, [19, 20, 21]),
            ExRoseTree.new(100)
          ]),
          ExRoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_niblings() do
    %Zipper{
      focus: ExRoseTree.new(5),
      prev: [
        ExRoseTree.new(4),
        ExRoseTree.new(3, [
          ExRoseTree.new(10),
          ExRoseTree.new(11),
          ExRoseTree.new(12)
        ]),
        ExRoseTree.new(2),
        ExRoseTree.new(1)
      ],
      next: [
        ExRoseTree.new(6),
        ExRoseTree.new(7, [
          ExRoseTree.new(13),
          ExRoseTree.new(14),
          ExRoseTree.new(15)
        ]),
        ExRoseTree.new(8),
        ExRoseTree.new(9)
      ]
    }
  end

  def z_with_grand_niblings() do
    %Zipper{
      focus: ExRoseTree.new(5),
      prev: [
        ExRoseTree.new(4),
        ExRoseTree.new(3, [
          ExRoseTree.new(10, [
            ExRoseTree.new(18),
            ExRoseTree.new(19),
            ExRoseTree.new(20)
          ]),
          ExRoseTree.new(11),
          ExRoseTree.new(12)
        ]),
        ExRoseTree.new(2, [
          ExRoseTree.new(16),
          ExRoseTree.new(17, [
            ExRoseTree.new(21),
            ExRoseTree.new(22)
          ])
        ]),
        ExRoseTree.new(1)
      ],
      next: [
        ExRoseTree.new(6),
        ExRoseTree.new(7, [
          ExRoseTree.new(13),
          ExRoseTree.new(14, [
            ExRoseTree.new(26),
            ExRoseTree.new(27),
            ExRoseTree.new(28)
          ]),
          ExRoseTree.new(15)
        ]),
        ExRoseTree.new(8, [
          ExRoseTree.new(23),
          ExRoseTree.new(24),
          ExRoseTree.new(25, [
            ExRoseTree.new(29),
            ExRoseTree.new(30)
          ])
        ]),
        ExRoseTree.new(9)
      ]
    }
  end

  def z_with_descendant_niblings() do
    %Zipper{
      focus: ExRoseTree.new(5),
      prev: [
        ExRoseTree.new(3, [
          ExRoseTree.new(10, [
            ExRoseTree.new(18),
            ExRoseTree.new(19)
          ]),
          ExRoseTree.new(11, [
            ExRoseTree.new(20),
            ExRoseTree.new(21)
          ]),
          ExRoseTree.new(12, [
            ExRoseTree.new(22),
            ExRoseTree.new(23, [
              ExRoseTree.new(24),
              ExRoseTree.new(25)
            ])
          ])
        ]),
        ExRoseTree.new(2, [
          ExRoseTree.new(16),
          ExRoseTree.new(17)
        ]),
        ExRoseTree.new(1, [
          ExRoseTree.new(100, [
            ExRoseTree.new(200, [
              ExRoseTree.new(300),
              ExRoseTree.new(301)
            ]),
            ExRoseTree.new(201)
          ]),
          ExRoseTree.new(101)
        ])
      ],
      next: [
        ExRoseTree.new(7, [
          ExRoseTree.new(13, [
            ExRoseTree.new(29, [
              ExRoseTree.new(37),
              ExRoseTree.new(38)
            ]),
            ExRoseTree.new(30),
            ExRoseTree.new(31)
          ]),
          ExRoseTree.new(14, [
            ExRoseTree.new(32),
            ExRoseTree.new(33),
            ExRoseTree.new(34)
          ]),
          ExRoseTree.new(15)
        ]),
        ExRoseTree.new(8, [
          ExRoseTree.new(26),
          ExRoseTree.new(27),
          ExRoseTree.new(28, [
            ExRoseTree.new(35),
            ExRoseTree.new(36)
          ])
        ]),
        ExRoseTree.new(9, [
          ExRoseTree.new(700),
          ExRoseTree.new(701, [
            ExRoseTree.new(800),
            ExRoseTree.new(801, [
              ExRoseTree.new(900),
              ExRoseTree.new(901)
            ])
          ])
        ])
      ],
      path: [
        Location.new(100)
      ]
    }
  end

  def z_with_piblings() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            ExRoseTree.new(6),
            ExRoseTree.new(4),
            ExRoseTree.new(2)
          ],
          next: [
            ExRoseTree.new(14),
            ExRoseTree.new(16),
            ExRoseTree.new(18)
          ]
        )
      ]
    }
  end

  def z_with_grandpiblings() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5,
          prev: [
            ExRoseTree.new(4),
            ExRoseTree.new(3),
            ExRoseTree.new(2)
          ],
          next: [
            ExRoseTree.new(6),
            ExRoseTree.new(7),
            ExRoseTree.new(8)
          ]
        )
      ]
    }
  end

  def z_with_ancestral_piblings() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(13),
        Location.new(12),
        Location.new(11),
        Location.new(10),
        Location.new(5,
          prev: [
            ExRoseTree.new(4),
            ExRoseTree.new(3),
            ExRoseTree.new(2)
          ],
          next: [
            ExRoseTree.new(6),
            ExRoseTree.new(7),
            ExRoseTree.new(8)
          ]
        )
      ]
    }
  end

  def z_with_no_ancestral_piblings() do
    %Zipper{
      focus: ExRoseTree.new(20),
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

  def z_with_1st_cousins() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            ExRoseTree.new(6),
            ExRoseTree.new(4, [
              ExRoseTree.new(22),
              ExRoseTree.new(23),
              ExRoseTree.new(24)
            ]),
            ExRoseTree.new(2, [
              ExRoseTree.new(19),
              ExRoseTree.new(20),
              ExRoseTree.new(21)
            ])
          ],
          next: [
            ExRoseTree.new(14),
            ExRoseTree.new(16, [
              ExRoseTree.new(25),
              ExRoseTree.new(26),
              ExRoseTree.new(27)
            ]),
            ExRoseTree.new(17),
            ExRoseTree.new(18, [
              ExRoseTree.new(28),
              ExRoseTree.new(29),
              ExRoseTree.new(30)
            ])
          ]
        )
      ]
    }
  end

  def z_with_2nd_cousins() do
    %Zipper{
      focus: ExRoseTree.new(200),
      prev: [],
      next: [],
      path: [
        Location.new(15),
        Location.new(10,
          prev: [
            ExRoseTree.new(6),
            ExRoseTree.new(4, [
              ExRoseTree.new(22, [
                ExRoseTree.new(44),
                ExRoseTree.new(45),
                ExRoseTree.new(46)
              ]),
              ExRoseTree.new(23),
              ExRoseTree.new(24, [
                ExRoseTree.new(47),
                ExRoseTree.new(48),
                ExRoseTree.new(49)
              ])
            ]),
            ExRoseTree.new(2, [
              ExRoseTree.new(19),
              ExRoseTree.new(20, [
                ExRoseTree.new(50),
                ExRoseTree.new(51)
              ]),
              ExRoseTree.new(21)
            ])
          ],
          next: [
            ExRoseTree.new(14),
            ExRoseTree.new(16, [
              ExRoseTree.new(25),
              ExRoseTree.new(26, [
                ExRoseTree.new(52),
                ExRoseTree.new(53)
              ]),
              ExRoseTree.new(27)
            ]),
            ExRoseTree.new(18, [
              ExRoseTree.new(28, [
                ExRoseTree.new(54),
                ExRoseTree.new(55),
                ExRoseTree.new(56)
              ]),
              ExRoseTree.new(29),
              ExRoseTree.new(30, [
                ExRoseTree.new(57),
                ExRoseTree.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def z_with_extended_cousins() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(100),
        Location.new(15),
        Location.new(10,
          prev: [
            ExRoseTree.new(6),
            ExRoseTree.new(4, [
              ExRoseTree.new(22, [
                ExRoseTree.new(44),
                ExRoseTree.new(45, [
                  ExRoseTree.new(101),
                  ExRoseTree.new(102)
                ]),
                ExRoseTree.new(46)
              ]),
              ExRoseTree.new(23),
              ExRoseTree.new(24, [
                ExRoseTree.new(47),
                ExRoseTree.new(48),
                ExRoseTree.new(49)
              ])
            ]),
            ExRoseTree.new(2, [
              ExRoseTree.new(19),
              ExRoseTree.new(20, [
                ExRoseTree.new(50, [
                  ExRoseTree.new(103)
                ]),
                ExRoseTree.new(51, [
                  ExRoseTree.new(104)
                ])
              ]),
              ExRoseTree.new(21)
            ])
          ],
          next: [
            ExRoseTree.new(14),
            ExRoseTree.new(16, [
              ExRoseTree.new(25),
              ExRoseTree.new(26, [
                ExRoseTree.new(52, [
                  ExRoseTree.new(105),
                  ExRoseTree.new(110)
                ]),
                ExRoseTree.new(53, [
                  ExRoseTree.new(106)
                ])
              ]),
              ExRoseTree.new(27)
            ]),
            ExRoseTree.new(18, [
              ExRoseTree.new(28, [
                ExRoseTree.new(54),
                ExRoseTree.new(55, [
                  ExRoseTree.new(107),
                  ExRoseTree.new(108)
                ]),
                ExRoseTree.new(56)
              ]),
              ExRoseTree.new(29),
              ExRoseTree.new(30, [
                ExRoseTree.new(57),
                ExRoseTree.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def z_with_extended_cousins_2() do
    %Zipper{
      focus: ExRoseTree.new(3),
      prev: [
        ExRoseTree.new(1),
        ExRoseTree.new(2)
      ],
      next: [],
      path: [
        Location.new(5,
          prev: [ExRoseTree.new(4)],
          next: [ExRoseTree.new(6)]
        ),
        Location.new(8,
          prev: [ExRoseTree.new(7)],
          next: [ExRoseTree.new(9)]
        ),
        Location.new(10,
          prev: [],
          next: [
            ExRoseTree.new(11),
            ExRoseTree.new(12, [
              ExRoseTree.new(13),
              ExRoseTree.new(14)
            ])
          ]
        ),
        Location.new(15,
          prev: [
            ExRoseTree.new(-16, [
              ExRoseTree.new(-18, [
                ExRoseTree.new(-21),
                ExRoseTree.new(-22)
              ]),
              ExRoseTree.new(-19, [
                ExRoseTree.new(-23),
                ExRoseTree.new(-24, [
                  ExRoseTree.new(-26),
                  ExRoseTree.new(-27, [
                    ExRoseTree.new(-29),
                    ExRoseTree.new(-30),
                    ExRoseTree.new(-31)
                  ]),
                  ExRoseTree.new(-28)
                ]),
                ExRoseTree.new(-25)
              ]),
              ExRoseTree.new(-20)
            ]),
            ExRoseTree.new(-17, [
              ExRoseTree.new(-32),
              ExRoseTree.new(-33),
              ExRoseTree.new(-34)
            ])
          ],
          next: [
            ExRoseTree.new(16, [
              ExRoseTree.new(18, [
                ExRoseTree.new(21),
                ExRoseTree.new(22)
              ]),
              ExRoseTree.new(19, [
                ExRoseTree.new(23),
                ExRoseTree.new(24, [
                  ExRoseTree.new(26),
                  ExRoseTree.new(27, [
                    ExRoseTree.new(29),
                    ExRoseTree.new(30),
                    ExRoseTree.new(31)
                  ]),
                  ExRoseTree.new(28)
                ]),
                ExRoseTree.new(25)
              ]),
              ExRoseTree.new(20)
            ]),
            ExRoseTree.new(17, [
              ExRoseTree.new(32),
              ExRoseTree.new(33),
              ExRoseTree.new(34)
            ])
          ]
        ),
        Location.new(35)
      ]
    }
  end

  def z_with_extended_niblings() do
    %Zipper{
      focus: ExRoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(100),
        Location.new(15),
        Location.new(10,
          prev: [
            ExRoseTree.new(6),
            ExRoseTree.new(4, [
              ExRoseTree.new(22, [
                ExRoseTree.new(44),
                ExRoseTree.new(45, [
                  ExRoseTree.new(101, [
                    ExRoseTree.new(200),
                    ExRoseTree.new(201)
                  ]),
                  ExRoseTree.new(102)
                ]),
                ExRoseTree.new(46)
              ]),
              ExRoseTree.new(23),
              ExRoseTree.new(24, [
                ExRoseTree.new(47),
                ExRoseTree.new(48),
                ExRoseTree.new(49)
              ])
            ]),
            ExRoseTree.new(2, [
              ExRoseTree.new(19),
              ExRoseTree.new(20, [
                ExRoseTree.new(50, [
                  ExRoseTree.new(103, [
                    ExRoseTree.new(202),
                    ExRoseTree.new(203)
                  ])
                ]),
                ExRoseTree.new(51, [
                  ExRoseTree.new(104, [
                    ExRoseTree.new(204)
                  ])
                ])
              ]),
              ExRoseTree.new(21)
            ])
          ],
          next: [
            ExRoseTree.new(14),
            ExRoseTree.new(16, [
              ExRoseTree.new(25),
              ExRoseTree.new(26, [
                ExRoseTree.new(52, [
                  ExRoseTree.new(105, [
                    ExRoseTree.new(204),
                    ExRoseTree.new(205)
                  ]),
                  ExRoseTree.new(110)
                ]),
                ExRoseTree.new(53, [
                  ExRoseTree.new(106, [
                    ExRoseTree.new(206)
                  ])
                ])
              ]),
              ExRoseTree.new(27)
            ]),
            ExRoseTree.new(18, [
              ExRoseTree.new(28, [
                ExRoseTree.new(54),
                ExRoseTree.new(55, [
                  ExRoseTree.new(107, [
                    ExRoseTree.new(207)
                  ]),
                  ExRoseTree.new(108, [
                    ExRoseTree.new(208),
                    ExRoseTree.new(209)
                  ])
                ]),
                ExRoseTree.new(56)
              ]),
              ExRoseTree.new(29),
              ExRoseTree.new(30, [
                ExRoseTree.new(57),
                ExRoseTree.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def z_depth_first() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(1, [
            ExRoseTree.new(2, [
              ExRoseTree.new(3),
              ExRoseTree.new(4),
              ExRoseTree.new(5, [
                ExRoseTree.new(6),
                ExRoseTree.new(7)
              ])
            ]),
            ExRoseTree.new(8),
            ExRoseTree.new(9),
            ExRoseTree.new(10, [
              ExRoseTree.new(11, [
                ExRoseTree.new(12),
                ExRoseTree.new(13)
              ]),
              ExRoseTree.new(14),
              ExRoseTree.new(15, [
                ExRoseTree.new(16)
              ])
            ]),
            ExRoseTree.new(17)
          ]),
          ExRoseTree.new(18),
          ExRoseTree.new(19, [
            ExRoseTree.new(20),
            ExRoseTree.new(21, [
              ExRoseTree.new(22),
              ExRoseTree.new(23),
              ExRoseTree.new(24, [
                ExRoseTree.new(25),
                ExRoseTree.new(26)
              ]),
              ExRoseTree.new(27, [
                ExRoseTree.new(28)
              ]),
              ExRoseTree.new(29)
            ]),
            ExRoseTree.new(30)
          ]),
          ExRoseTree.new(31, [
            ExRoseTree.new(32)
          ]),
          ExRoseTree.new(33),
          ExRoseTree.new(34, [
            ExRoseTree.new(35, [
              ExRoseTree.new(36),
              ExRoseTree.new(37)
            ]),
            ExRoseTree.new(38),
            ExRoseTree.new(39, [
              ExRoseTree.new(40)
            ])
          ])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_depth_first_siblings() do
    z = z_depth_first()

    %{z | prev: [ExRoseTree.new(-1)], next: [ExRoseTree.new(41)]}
  end

  def z_breadth_first() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(1, [
            ExRoseTree.new(7, [
              ExRoseTree.new(19),
              ExRoseTree.new(20),
              ExRoseTree.new(21, [
                ExRoseTree.new(33),
                ExRoseTree.new(34)
              ])
            ]),
            ExRoseTree.new(8),
            ExRoseTree.new(9),
            ExRoseTree.new(10, [
              ExRoseTree.new(22, [
                ExRoseTree.new(35),
                ExRoseTree.new(36)
              ]),
              ExRoseTree.new(23),
              ExRoseTree.new(24, [
                ExRoseTree.new(37)
              ])
            ]),
            ExRoseTree.new(11)
          ]),
          ExRoseTree.new(2),
          ExRoseTree.new(3, [
            ExRoseTree.new(12),
            ExRoseTree.new(13, [
              ExRoseTree.new(25),
              ExRoseTree.new(26),
              ExRoseTree.new(27, [
                ExRoseTree.new(38),
                ExRoseTree.new(39)
              ]),
              ExRoseTree.new(28, [
                ExRoseTree.new(40)
              ]),
              ExRoseTree.new(29)
            ]),
            ExRoseTree.new(14)
          ]),
          ExRoseTree.new(4, [
            ExRoseTree.new(15)
          ]),
          ExRoseTree.new(5),
          ExRoseTree.new(6, [
            ExRoseTree.new(16, [
              ExRoseTree.new(30),
              ExRoseTree.new(31)
            ]),
            ExRoseTree.new(17),
            ExRoseTree.new(18, [
              ExRoseTree.new(32)
            ])
          ])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_breadth_first_siblings() do
    %Zipper{
      focus:
        ExRoseTree.new(0, [
          ExRoseTree.new(2, [
            ExRoseTree.new(8, [
              ExRoseTree.new(20),
              ExRoseTree.new(21),
              ExRoseTree.new(22, [
                ExRoseTree.new(34),
                ExRoseTree.new(35)
              ])
            ]),
            ExRoseTree.new(9),
            ExRoseTree.new(10),
            ExRoseTree.new(11, [
              ExRoseTree.new(23, [
                ExRoseTree.new(36),
                ExRoseTree.new(37)
              ]),
              ExRoseTree.new(24),
              ExRoseTree.new(25, [
                ExRoseTree.new(38)
              ])
            ]),
            ExRoseTree.new(12)
          ]),
          ExRoseTree.new(3),
          ExRoseTree.new(4, [
            ExRoseTree.new(13),
            ExRoseTree.new(14, [
              ExRoseTree.new(26),
              ExRoseTree.new(27),
              ExRoseTree.new(28, [
                ExRoseTree.new(39),
                ExRoseTree.new(40)
              ]),
              ExRoseTree.new(29, [
                ExRoseTree.new(41)
              ]),
              ExRoseTree.new(30)
            ]),
            ExRoseTree.new(15)
          ]),
          ExRoseTree.new(5, [
            ExRoseTree.new(16)
          ]),
          ExRoseTree.new(6),
          ExRoseTree.new(7, [
            ExRoseTree.new(17, [
              ExRoseTree.new(31),
              ExRoseTree.new(32)
            ]),
            ExRoseTree.new(18),
            ExRoseTree.new(19, [
              ExRoseTree.new(33)
            ])
          ])
        ]),
      prev: [ExRoseTree.new(-1)],
      next: [ExRoseTree.new(1)],
      path: []
    }
  end
end
