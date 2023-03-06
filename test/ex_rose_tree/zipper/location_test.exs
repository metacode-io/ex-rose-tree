defmodule ExRoseTree.Zipper.LocationTest do
  use ExUnit.Case

  require ExRoseTree.Zipper.Location
  alias ExRoseTree.Zipper.Location
  alias ExRoseTree

  doctest ExRoseTree.Zipper.Location

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

  @loc_values [
    {%{a: "value"}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8}
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
        prev: [ExRoseTree.new(5)],
        term: 6,
        next: [ExRoseTree.new(7)]
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

  describe "new/2 when using only the first parameter" do
    test "should return a new Location for any valid erlang term" do
      for {value, idx} <- @loc_values do
        loc = Location.new(value)

        assert Location.location?(loc) == true,
               "Expected a valid Location struct for element at index #{idx}"

        assert %Location{prev: [], term: ^value, next: []} = loc,
               "Expected term to be #{inspect(value)} and prev and next to be empty lists for element at index #{idx}"
      end
    end
  end

  describe "new/2 when using the :prev option" do
    test "should return a new Location with prev field set if valid ExRoseTrees were passed" do
      prev = [ExRoseTree.new(5)]

      loc = Location.new(6, prev: prev)

      assert Location.location?(loc) == true
      assert %Location{prev: ^prev, term: 6, next: []} = loc
    end

    test "should return a new Location with next field set if valid ExRoseTrees were passed" do
      next = [ExRoseTree.new(7)]

      loc = Location.new(6, next: next)

      assert Location.location?(loc) == true
      assert %Location{prev: [], term: 6, next: ^next} = loc
    end

    test "should return a new Location with both prev and next fields set if valid ExRoseTrees were passed" do
      prev = [ExRoseTree.new(5)]
      next = [ExRoseTree.new(7)]

      loc = Location.new(6, prev: prev, next: next)

      assert Location.location?(loc) == true
      assert %Location{prev: ^prev, term: 6, next: ^next} = loc
    end

    test "should raise an ArgumentError if prev field set with an invalid element" do
      prev = [ExRoseTree.new(5), :bad_element]

      assert_raise ArgumentError, fn -> Location.new(6, prev: prev) end
    end

    test "should raise an ArgumentError if next field set with an invalid element" do
      next = [ExRoseTree.new(7), :bad_element]

      assert_raise ArgumentError, fn -> Location.new(6, next: next) end
    end
  end
end
