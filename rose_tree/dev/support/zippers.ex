defmodule RoseTree.Support.Zippers do
  @moduledoc """
  Sample Zippers for use in development and testing.

  WARNING :: Do not make modifications to the values or structures
  of these samples without being prepared to rewrite any unit test
  that relies on them!
  """

  alias RoseTree.Support.Trees
  alias RoseTree.Zipper
  alias RoseTree.Zipper.Location

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
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10)
      ]
    }
  end

  def z_with_grandparent() do
    %Zipper{
      focus: RoseTree.new(20),
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
      focus: RoseTree.new(20),
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
      focus: RoseTree.new(5),
      prev: [
        RoseTree.new(4),
        RoseTree.new(3),
        RoseTree.new(2),
        RoseTree.new(1)
      ],
      next: [
        RoseTree.new(6),
        RoseTree.new(7),
        RoseTree.new(8),
        RoseTree.new(9)
      ]
    }
  end

  def z_with_grandchildren() do
    %Zipper{
      focus:
        RoseTree.new(0, [
          RoseTree.new(1, [4, 5, 6]),
          RoseTree.new(2, [7, 8, 9]),
          RoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_grandchildren_2() do
    %Zipper{
      focus:
        RoseTree.new(0, [
          RoseTree.new(-100),
          RoseTree.new(1, [4, 5, 6]),
          RoseTree.new(2, [7, 8, 9]),
          RoseTree.new(3, [10, 11, 12]),
          RoseTree.new(100)
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_great_grandchildren() do
    %Zipper{
      focus:
        RoseTree.new(0, [
          RoseTree.new(1, [4, 5, 6]),
          RoseTree.new(2, [
            RoseTree.new(7, [13, 14, 15]),
            RoseTree.new(8, [16, 17, 18]),
            RoseTree.new(9, [19, 20, 21])
          ]),
          RoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_great_grandchildren_2() do
    %Zipper{
      focus:
        RoseTree.new(0, [
          RoseTree.new(1, [4, 5, 6]),
          RoseTree.new(2, [
            RoseTree.new(-100),
            RoseTree.new(7, [13, 14, 15]),
            RoseTree.new(8, [16, 17, 18]),
            RoseTree.new(9, [19, 20, 21]),
            RoseTree.new(100)
          ]),
          RoseTree.new(3, [10, 11, 12])
        ]),
      prev: [],
      next: [],
      path: []
    }
  end

  def z_with_niblings() do
    %Zipper{
      focus: RoseTree.new(5),
      prev: [
        RoseTree.new(4),
        RoseTree.new(3, [
          RoseTree.new(10),
          RoseTree.new(11),
          RoseTree.new(12)
        ]),
        RoseTree.new(2),
        RoseTree.new(1)
      ],
      next: [
        RoseTree.new(6),
        RoseTree.new(7, [
          RoseTree.new(13),
          RoseTree.new(14),
          RoseTree.new(15)
        ]),
        RoseTree.new(8),
        RoseTree.new(9)
      ]
    }
  end

  def z_with_grand_niblings() do
    %Zipper{
      focus: RoseTree.new(5),
      prev: [
        RoseTree.new(4),
        RoseTree.new(3, [
          RoseTree.new(10, [
            RoseTree.new(18),
            RoseTree.new(19),
            RoseTree.new(20)
          ]),
          RoseTree.new(11),
          RoseTree.new(12)
        ]),
        RoseTree.new(2, [
          RoseTree.new(16),
          RoseTree.new(17, [
            RoseTree.new(21),
            RoseTree.new(22)
          ])
        ]),
        RoseTree.new(1)
      ],
      next: [
        RoseTree.new(6),
        RoseTree.new(7, [
          RoseTree.new(13),
          RoseTree.new(14, [
            RoseTree.new(26),
            RoseTree.new(27),
            RoseTree.new(28)
          ]),
          RoseTree.new(15)
        ]),
        RoseTree.new(8, [
          RoseTree.new(23),
          RoseTree.new(24),
          RoseTree.new(25, [
            RoseTree.new(29),
            RoseTree.new(30)
          ])
        ]),
        RoseTree.new(9)
      ]
    }
  end

  def z_with_descendant_niblings() do
    %Zipper{
      focus: RoseTree.new(5),
      prev: [
        RoseTree.new(3, [
          RoseTree.new(10, [
            RoseTree.new(18),
            RoseTree.new(19),
          ]),
          RoseTree.new(11, [
            RoseTree.new(20),
            RoseTree.new(21),
          ]),
          RoseTree.new(12, [
            RoseTree.new(22),
            RoseTree.new(23, [
              RoseTree.new(24),
              RoseTree.new(25)
            ])
          ])
        ]),
        RoseTree.new(2, [
          RoseTree.new(16),
          RoseTree.new(17)
        ]),
        RoseTree.new(1)
      ],
      next: [
        RoseTree.new(7, [
          RoseTree.new(13, [
            RoseTree.new(29, [
              RoseTree.new(37),
              RoseTree.new(38)
            ]),
            RoseTree.new(30),
            RoseTree.new(31)
          ]),
          RoseTree.new(14, [
            RoseTree.new(32),
            RoseTree.new(33),
            RoseTree.new(34)
          ]),
          RoseTree.new(15)
        ]),
        RoseTree.new(8, [
          RoseTree.new(26),
          RoseTree.new(27),
          RoseTree.new(28, [
            RoseTree.new(35),
            RoseTree.new(36)
          ])
        ]),
        RoseTree.new(9)
      ],
      path: [
        Location.new(100)
      ]
    }
  end

  def z_with_piblings() do
    %Zipper{
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            RoseTree.new(6),
            RoseTree.new(4),
            RoseTree.new(2)
          ],
          next: [
            RoseTree.new(14),
            RoseTree.new(16),
            RoseTree.new(18)
          ]
        )
      ]
    }
  end

  def z_with_grandpiblings() do
    %Zipper{
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10),
        Location.new(5,
          prev: [
            RoseTree.new(4),
            RoseTree.new(3),
            RoseTree.new(2)
          ],
          next: [
            RoseTree.new(6),
            RoseTree.new(7),
            RoseTree.new(8)
          ]
        )
      ]
    }
  end

  def z_with_ancestral_piblings() do
    %Zipper{
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(13),
        Location.new(12),
        Location.new(11),
        Location.new(10),
        Location.new(5,
          prev: [
            RoseTree.new(4),
            RoseTree.new(3),
            RoseTree.new(2)
          ],
          next: [
            RoseTree.new(6),
            RoseTree.new(7),
            RoseTree.new(8)
          ]
        )
      ]
    }
  end

  def z_with_no_ancestral_piblings() do
    %Zipper{
      focus: RoseTree.new(20),
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
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(10,
          prev: [
            RoseTree.new(6),
            RoseTree.new(4, [
              RoseTree.new(22),
              RoseTree.new(23),
              RoseTree.new(24)
            ]),
            RoseTree.new(2, [
              RoseTree.new(19),
              RoseTree.new(20),
              RoseTree.new(21)
            ])
          ],
          next: [
            RoseTree.new(14),
            RoseTree.new(16, [
              RoseTree.new(25),
              RoseTree.new(26),
              RoseTree.new(27)
            ]),
            RoseTree.new(17),
            RoseTree.new(18, [
              RoseTree.new(28),
              RoseTree.new(29),
              RoseTree.new(30)
            ])
          ]
        )
      ]
    }
  end

  def z_with_2nd_cousins() do
    %Zipper{
      focus: RoseTree.new(200),
      prev: [],
      next: [],
      path: [
        Location.new(15),
        Location.new(10,
          prev: [
            RoseTree.new(6),
            RoseTree.new(4, [
              RoseTree.new(22, [
                RoseTree.new(44),
                RoseTree.new(45),
                RoseTree.new(46)
              ]),
              RoseTree.new(23),
              RoseTree.new(24, [
                RoseTree.new(47),
                RoseTree.new(48),
                RoseTree.new(49)
              ])
            ]),
            RoseTree.new(2, [
              RoseTree.new(19),
              RoseTree.new(20, [
                RoseTree.new(50),
                RoseTree.new(51)
              ]),
              RoseTree.new(21)
            ])
          ],
          next: [
            RoseTree.new(14),
            RoseTree.new(16, [
              RoseTree.new(25),
              RoseTree.new(26, [
                RoseTree.new(52),
                RoseTree.new(53)
              ]),
              RoseTree.new(27)
            ]),
            RoseTree.new(18, [
              RoseTree.new(28, [
                RoseTree.new(54),
                RoseTree.new(55),
                RoseTree.new(56)
              ]),
              RoseTree.new(29),
              RoseTree.new(30, [
                RoseTree.new(57),
                RoseTree.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def z_with_extended_cousins() do
    %Zipper{
      focus: RoseTree.new(20),
      prev: [],
      next: [],
      path: [
        Location.new(100),
        Location.new(15),
        Location.new(10,
          prev: [
            RoseTree.new(6),
            RoseTree.new(4, [
              RoseTree.new(22, [
                RoseTree.new(44),
                RoseTree.new(45, [
                  RoseTree.new(101),
                  RoseTree.new(102)
                ]),
                RoseTree.new(46)
              ]),
              RoseTree.new(23),
              RoseTree.new(24, [
                RoseTree.new(47),
                RoseTree.new(48),
                RoseTree.new(49)
              ])
            ]),
            RoseTree.new(2, [
              RoseTree.new(19),
              RoseTree.new(20, [
                RoseTree.new(50, [
                  RoseTree.new(103)
                ]),
                RoseTree.new(51, [
                  RoseTree.new(104)
                ])
              ]),
              RoseTree.new(21)
            ])
          ],
          next: [
            RoseTree.new(14),
            RoseTree.new(16, [
              RoseTree.new(25),
              RoseTree.new(26, [
                RoseTree.new(52, [
                  RoseTree.new(105),
                  RoseTree.new(110)
                ]),
                RoseTree.new(53, [
                  RoseTree.new(106)
                ])
              ]),
              RoseTree.new(27)
            ]),
            RoseTree.new(18, [
              RoseTree.new(28, [
                RoseTree.new(54),
                RoseTree.new(55, [
                  RoseTree.new(107),
                  RoseTree.new(108)
                ]),
                RoseTree.new(56)
              ]),
              RoseTree.new(29),
              RoseTree.new(30, [
                RoseTree.new(57),
                RoseTree.new(58)
              ])
            ])
          ]
        )
      ]
    }
  end

  def z_with_extended_cousins_2() do
    %Zipper{
      focus: RoseTree.new(3),
      prev: [
        RoseTree.new(1),
        RoseTree.new(2)
      ],
      next: [],
      path: [
        Location.new(5,
          prev: [RoseTree.new(4)],
          next: [RoseTree.new(6)]),
        Location.new(8,
          prev: [RoseTree.new(7)],
          next: [RoseTree.new(9)]),
        Location.new(10,
          prev: [],
          next: [
            RoseTree.new(11),
            RoseTree.new(12, [
              RoseTree.new(13),
              RoseTree.new(14)
            ])
          ]),
        Location.new(15,
          prev: [
            RoseTree.new(-16, [
              RoseTree.new(-18, [
                RoseTree.new(-21),
                RoseTree.new(-22)
              ]),
              RoseTree.new(-19, [
                RoseTree.new(-23),
                RoseTree.new(-24, [
                  RoseTree.new(-26),
                  RoseTree.new(-27, [
                    RoseTree.new(-29),
                    RoseTree.new(-30),
                    RoseTree.new(-31)
                  ]),
                  RoseTree.new(-28)
                ]),
                RoseTree.new(-25)
              ]),
              RoseTree.new(-20)
            ]),
            RoseTree.new(-17, [
              RoseTree.new(-32),
              RoseTree.new(-33),
              RoseTree.new(-34)
            ])
          ],
          next: [
            RoseTree.new(16, [
              RoseTree.new(18, [
                RoseTree.new(21),
                RoseTree.new(22)
              ]),
              RoseTree.new(19, [
                RoseTree.new(23),
                RoseTree.new(24, [
                  RoseTree.new(26),
                  RoseTree.new(27, [
                    RoseTree.new(29),
                    RoseTree.new(30),
                    RoseTree.new(31)
                  ]),
                  RoseTree.new(28)
                ]),
                RoseTree.new(25)
              ]),
              RoseTree.new(20)
            ]),
            RoseTree.new(17, [
              RoseTree.new(32),
              RoseTree.new(33),
              RoseTree.new(34)
            ])
          ]),
        Location.new(35)
      ]
    }
  end
end
