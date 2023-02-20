defmodule RoseTree.ZipperTest do
  use ExUnit.Case, async: true
  use RoseTree.ZipperCase

  alias RoseTree.Support.Zippers

  doctest RoseTree.Zipper

  @bad_zippers [
    {%{focus: %RoseTree{term: 1, children: []}, prev: [], next: [], path: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8},
    {%Zipper{focus: :not_a_node, prev: [], next: [], path: []}, 9},
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: :not_a_list, next: [], path: []},
     10},
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: [], next: :not_a_list, path: []},
     11},
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: [], next: [], path: :not_a_list},
     12},
    {nil, 13}
  ]

  setup do
    %{
      z_with_parent: Zippers.z_with_parent(),
      z_with_grandparent: Zippers.z_with_grandparent()
    }
  end

  describe "zipper?/1 guard" do
    test "should return true when given a valid Zipper struct", %{all_zippers_with_idx: all} do
      for {z, idx} <- all do
        assert Zipper.zipper?(z) == true,
               "Expected `true` for element at index #{idx}"
      end
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_zippers do
        assert Zipper.zipper?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty?/1 guard" do
    test "should return true when given an empty Zipper struct", %{empty_z: z} do
      assert Zipper.empty?(z) == true
    end

    test "should return false when given a non-empty Zipper struct", %{simple_z: z} do
      assert Zipper.empty?(z) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_zippers do
        assert Zipper.empty?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "at_root?/1 guard" do
    test "should return true when given a Zipper with an empty path", %{simple_z: z} do
      assert Zipper.at_root?(z) == true
    end

    test "should return false when given a Zipper with a populated path", %{
      simple_z: z_1,
      z_x5: z_2
    } do
      new_loc = Location.new(z_1.focus, prev: z_1.prev, next: z_1.next)

      new_z = %Zipper{z_2 | path: [new_loc]}

      assert Zipper.at_root?(new_z) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_zippers do
        assert Zipper.at_root?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "has_children?/1 guard" do
    test "should return true when given a Zipper whose focus has children", %{simple_z: z} do
      assert Zipper.has_children?(z) == true
    end

    test "should return false when given a Zipper whose focus has no children", %{leaf_z: z} do
      assert Zipper.has_children?(z) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_zippers do
        assert Zipper.has_children?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "has_siblings?/1 guard" do
    test "should return true when given a Zipper who has previous RoseTree siblings", %{
      simple_z: z,
      simple_tree: tree
    } do
      new_z = %Zipper{z | prev: [tree]}

      assert Zipper.has_siblings?(new_z) == true
    end

    test "should return true when given a Zipper who has next RoseTree siblings", %{
      simple_z: z,
      simple_tree: tree
    } do
      new_z = %Zipper{z | next: [tree]}

      assert Zipper.has_siblings?(new_z) == true
    end

    test "should return true when given a Zipper who has both previous and next RoseTree siblings",
         %{simple_z: z, simple_tree: tree} do
      new_z = %Zipper{z | prev: [tree], next: [tree]}

      assert Zipper.has_siblings?(new_z) == true
    end

    test "should return false when given a Zipper who has neither previous or next RoseTree siblings",
         %{simple_z: z} do
      assert Zipper.has_siblings?(z) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_zippers do
        assert Zipper.has_siblings?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "new/2" do
    test "should raise an ArgumentError if `prev` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      previous_siblings = [tree_2, :bad_tree]

      assert_raise ArgumentError, fn -> Zipper.new(tree_1, prev: previous_siblings) end
    end

    test "should raise an ArgumentError if `next` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      next_siblings = [tree_2, :bad_tree]

      assert_raise ArgumentError, fn -> Zipper.new(tree_1, next: next_siblings) end
    end

    test "should raise an ArgumentError if `path` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      path = [Location.new(tree_2), :bad_location]

      assert_raise ArgumentError, fn -> Zipper.new(tree_1, path: path) end
    end
  end

  describe "root?/1" do
    test "should return false if given a Zipper with populated path", %{
      simple_z: z,
      simple_tree: tree
    } do
      path = [Location.new(tree)]

      new_z = %Zipper{z | path: path}

      assert Zipper.root?(new_z) == false
    end
  end

  describe "index_of_parent/1" do
    test "should return nil if given a Zipper with no parent", %{simple_z: z} do
      assert nil == Zipper.index_of_parent(z)
    end

    test "should return 0 if parent has no siblings", %{z_with_parent: z} do
      assert 0 == Zipper.index_of_parent(z)
    end
  end

  describe "index_of_grandparent/1" do
    test "should return nil if given a Zipper with no parent", %{simple_z: z} do
      assert nil == Zipper.index_of_grandparent(z)
    end

    test "should return nil if given a Zipper with no grandparent", %{z_with_parent: z} do
      assert nil == Zipper.index_of_grandparent(z)
    end

    test "should return 0 if grandparent has no siblings", %{z_with_grandparent: z} do
      assert 0 == Zipper.index_of_grandparent(z)
    end
  end

  describe "parent_location/1" do
    test "should return nil if given a root Zipper", %{simple_z: z} do
      assert nil == Zipper.parent_location(z)
    end
  end

  describe "parent_term/1" do
    test "should return nil if given a root Zipper", %{simple_z: z} do
      assert nil == Zipper.parent_term(z)
    end
  end

  describe "map_focus/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a RoseTree", %{
      simple_z: z
    } do
      map_fn = fn tree_node -> tree_node.term * 2 end

      assert_raise(ArgumentError, fn -> Zipper.map_focus(z, map_fn) end)
    end
  end

  describe "map_prev_siblings/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a RoseTree", %{
      simple_z: z,
      tree_x5: tree
    } do
      map_fn = fn tree_node -> tree_node.term * 2 end

      new_z = %Zipper{z | prev: [tree]}

      assert_raise(ArgumentError, fn -> Zipper.map_prev_siblings(new_z, map_fn) end)
    end
  end

  describe "map_next_siblings/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a RoseTree", %{
      simple_z: z,
      tree_x5: tree
    } do
      map_fn = fn tree_node -> tree_node.term * 2 end

      new_z = %Zipper{z | next: [tree]}

      assert_raise(ArgumentError, fn -> Zipper.map_next_siblings(new_z, map_fn) end)
    end
  end

  describe "map_path/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a Location", %{
      simple_z: z,
      tree_x5: tree
    } do
      map_fn = fn location -> location.term * 2 end

      path = [Location.new(tree)]

      new_z = %Zipper{z | path: path}

      assert_raise(ArgumentError, fn -> Zipper.map_path(new_z, map_fn) end)
    end
  end
end
