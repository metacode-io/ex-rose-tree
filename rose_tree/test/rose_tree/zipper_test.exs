defmodule RoseTree.ZipperTest do
  use ExUnit.Case, async: true
  use ZipperCase

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
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: :not_a_list, next: [], path: []}, 10},
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: [], next: :not_a_list, path: []}, 11},
    {%Zipper{focus: %RoseTree{term: 1, children: []}, prev: [], next: [], path: :not_a_list}, 12},
    {nil, 13}
  ]

  describe "zipper?/1 guard" do
    test "should return true when given a valid Zipper struct",
         %{empty_z: z_1, leaf_z: z_2, simple_z: z_3, z_with_extended_cousins: z_4} do
      all = [z_1, z_2, z_3, z_4] |> Enum.with_index()

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
      z_with_parent: z
    } do
      assert Zipper.at_root?(z) == false
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
    test "should return true when given a Zipper who has only previous RoseTree siblings", %{
      z_with_siblings: z
    } do
      new_z = %{z | next: []}
      assert Zipper.has_siblings?(new_z) == true
    end

    test "should return true when given a Zipper who has only next RoseTree siblings", %{
      z_with_siblings: z
    } do
      new_z = %{z | prev: []}
      assert Zipper.has_siblings?(new_z) == true
    end

    test "should return true when given a Zipper who has both previous and next RoseTree siblings",
         %{z_with_siblings: z} do
      assert Zipper.has_siblings?(z) == true
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
      simple_z: z
    } do
      previous_siblings = [z.focus, :bad_tree]

      assert_raise ArgumentError, fn -> Zipper.new(z.focus, prev: previous_siblings) end
    end

    test "should raise an ArgumentError if `next` has invalid elements", %{
      simple_z: z
    } do
      next_siblings = [z.focus, :bad_tree]

      assert_raise ArgumentError, fn -> Zipper.new(z.focus, next: next_siblings) end
    end

    test "should raise an ArgumentError if `path` has invalid elements", %{
      simple_z: z
    } do
      path = [Location.new(z.focus), :bad_location]

      assert_raise ArgumentError, fn -> Zipper.new(z.focus, path: path) end
    end
  end

  describe "root?/1" do
    test "should return false if given a Zipper with populated path", %{
      simple_z: z
    } do
      path = [Location.new(z.focus)]

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

  describe "remove_focus/1" do
    test "should return an empty zipper and nil when given an empty zipper", %{empty_z: z} do
      assert {^z, nil} = Zipper.remove_focus(z)
    end

    test "should return an empty zipper and nil when given a root leaf zipper", %{
      empty_z: empty_z,
      leaf_z: z
    } do
      assert {^empty_z, nil} = Zipper.remove_focus(z)
    end

    test "should return a zipper focused on the parent with no children and the removed focus when given a zipper with parent and no siblings",
         %{z_with_parent: z} do
      expected_removal = z.focus

      assert {%Zipper{focus: focus}, ^expected_removal} = Zipper.remove_focus(z)
      assert focus.term == 10
      assert focus.children == []
    end

    test "should return a zipper focused on the previous sibling and the removed focus when given a zipper with prev siblings but no next siblings",
         %{z_with_siblings: z} do
      z_with_removed_next = %{z | next: []}

      expected_removal = z.focus
      [expected_focus | expected_prev] = z.prev

      assert {%Zipper{} = actual_z, ^expected_removal} = Zipper.remove_focus(z_with_removed_next)
      assert actual_z.focus.term == expected_focus.term
      assert actual_z.prev == expected_prev
      assert actual_z.next == []
    end

    test "should return a zipper focused on the next sibling and the removed focus when given a zipper with nex siblings",
         %{z_with_siblings: z} do
      expected_removal = z.focus
      [expected_focus | expected_next] = z.next

      assert {%Zipper{} = actual_z, ^expected_removal} = Zipper.remove_focus(z)
      assert actual_z.focus.term == expected_focus.term
      assert actual_z.next == expected_next
      assert actual_z.prev == z.prev
    end
  end

  describe "map_previous_siblings/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a RoseTree", %{
      z_with_siblings: z
    } do
      map_fn = fn tree_node -> tree_node.term * 2 end

      assert_raise(ArgumentError, fn -> Zipper.map_previous_siblings(z, map_fn) end)
    end
  end

  describe "map_next_siblings/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a RoseTree", %{
      z_with_siblings: z
    } do
      map_fn = fn tree_node -> tree_node.term * 2 end

      assert_raise(ArgumentError, fn -> Zipper.map_next_siblings(z, map_fn) end)
    end
  end

  describe "map_path/2" do
    test "should raise ArgumentError if the map_fn returns a result that is not a Location", %{
      z_with_grandparent: z
    } do
      map_fn = fn location -> location.term * 2 end

      assert_raise(ArgumentError, fn -> Zipper.map_path(z, map_fn) end)
    end
  end
end
