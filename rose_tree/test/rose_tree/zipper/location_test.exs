defmodule RoseTree.Zipper.LocationTest do
  use ExUnit.Case

  require RoseTree.Zipper.Location
  alias RoseTree.Zipper.Location
  alias RoseTree.TreeNode

  doctest RoseTree.Zipper.Location

  @bad_locs [
    {%{prev: [], term: nil, next: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8},
    {%Location{prev: 5, term: 6, next: [7]}, 9},
    {nil, 10}
  ]

  describe "location?/1 guard" do
    test "should return true when given an empty Location struct" do
      loc = %Location{
        prev: [],
        term: nil,
        next: []
      }

      assert Location.location?(loc) == true
    end

    test "should return true when given a valid Location struct" do
      loc = %Location{
        prev: [TreeNode.new(5)],
        term: 6,
        next: [TreeNode.new(7)]
      }

      assert Location.location?(loc) == true
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_locs do
        assert Location.location?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end
end
