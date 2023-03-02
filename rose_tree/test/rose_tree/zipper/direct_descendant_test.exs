defmodule RoseTree.Zipper.DirectDescendantTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper

  setup_all do
    %{
      empty_z: Zippers.empty_z(),
      leaf_z: Zippers.leaf_z(),
      simple_z: Zippers.simple_z(),
      z_with_siblings: Zippers.z_with_siblings(),
      z_with_grandchildren: Zippers.z_with_grandchildren(),
      z_with_grandchildren_2: Zippers.z_with_grandchildren_2(),
      z_with_great_grandchildren: Zippers.z_with_great_grandchildren(),
      z_with_great_grandchildren_2: Zippers.z_with_great_grandchildren_2()
    }
  end

  describe "first_child/2" do
    test "should return nil when given a Zipper with an empty focus", %{empty_z: z} do
      assert Zipper.first_child(z) == nil
    end

    test "should return nil when given a Zipper with a leaf focus", %{leaf_z: z} do
      assert Zipper.first_child(z) == nil
    end

    test "should return nil when given a predicate that does not match any children of the Zipper",
         %{simple_z: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_child(z, predicate) == nil
    end
  end

  describe "last_child/2" do
    test "should return nil when given a Zipper with an empty focus", %{empty_z: z} do
      assert Zipper.last_child(z) == nil
    end

    test "should return nil when given a Zipper with a leaf focus", %{leaf_z: z} do
      assert Zipper.last_child(z) == nil
    end

    test "should return nil when given a predicate that does not match any children of the Zipper",
         %{simple_z: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_child(z, predicate) == nil
    end
  end

  describe "child_at/1" do
    test "should return nil when given a Zipper with an empty focus", %{empty_z: z} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Zipper.child_at(z, idx) == nil
      end
    end

    test "should return nil when given a Zipper with a leaf focus", %{leaf_z: z} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Zipper.child_at(z, idx) == nil
      end
    end

    test "should return nil when given a index that is out of bounds for the children of the Zipper",
         %{simple_z: z} do
      num_children = Enum.count(z.focus.children)

      for _ <- 0..5 do
        idx = Enum.random(num_children..10)
        assert Zipper.child_at(z, idx) == nil
      end
    end
  end

  describe "first_grandchild/2" do
    test "should return the first grandchild that is found for the Zipper", %{
      z_with_grandchildren: z_1,
      z_with_grandchildren_2: z_2
    } do
      for z <- [z_1, z_2] do
        actual = Zipper.first_grandchild(z)
        assert 4 == actual.focus.term
      end
    end

    test "should return the first grandchild that is found that matches the predicate for the Zipper",
         %{z_with_grandchildren: z_1, z_with_grandchildren_2: z_2} do
      predicate = &(&1.term > 7)

      for z <- [z_1, z_2] do
        actual = Zipper.first_grandchild(z, predicate)
        assert 8 == actual.focus.term
      end
    end

    test "should return nil if Zipper has children but no grandchildren", %{simple_z: z} do
      assert Zipper.first_grandchild(z) == nil
    end

    test "should return nil if Zipper has no children", %{leaf_z: z} do
      assert Zipper.first_grandchild(z) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Zipper",
         %{z_with_grandchildren: z_1, z_with_grandchildren_2: z_2} do
      predicate = &(&1.term == 20)

      for z <- [z_1, z_2] do
        assert Zipper.first_grandchild(z, predicate) == nil
      end
    end
  end

  describe "last_grandchild/2" do
    test "should return the last grandchild that is found for the Zipper", %{
      z_with_grandchildren: z_1,
      z_with_grandchildren_2: z_2
    } do
      for z <- [z_1, z_2] do
        actual = Zipper.last_grandchild(z)
        assert 12 == actual.focus.term
      end
    end

    test "should return the last grandchild that is found that matches the predicate for the Zipper",
         %{z_with_grandchildren: z_1, z_with_grandchildren_2: z_2} do
      predicate = &(&1.term < 9)

      for z <- [z_1, z_2] do
        actual = Zipper.last_grandchild(z, predicate)
        assert 8 == actual.focus.term
      end
    end

    test "should return nil if Zipper has children but no grandchildren", %{simple_z: z} do
      assert Zipper.last_grandchild(z) == nil
    end

    test "should return nil if Zipper has no children", %{leaf_z: z} do
      assert Zipper.last_grandchild(z) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Zipper",
         %{z_with_grandchildren: z_1, z_with_grandchildren_2: z_2} do
      predicate = &(&1.term == 20)

      for z <- [z_1, z_2] do
        assert Zipper.last_grandchild(z, predicate) == nil
      end
    end
  end

  describe "first_great_grandchild/2" do
    test "should return the first great grandchild that is found for the Zipper", %{
      z_with_great_grandchildren: z_1,
      z_with_great_grandchildren_2: z_2
    } do
      for z <- [z_1, z_2] do
        actual = Zipper.first_great_grandchild(z)
        assert 13 == actual.focus.term
      end
    end

    test "should return the first grandchild that is found that matches the predicate for the Zipper",
         %{z_with_great_grandchildren: z_1, z_with_great_grandchildren_2: z_2} do
      predicate = &(&1.term > 16)

      for z <- [z_1, z_2] do
        actual = Zipper.first_great_grandchild(z, predicate)
        assert 17 == actual.focus.term
      end
    end

    test "should return nil if Zipper has children but no grandchildren", %{simple_z: z} do
      assert Zipper.first_great_grandchild(z) == nil
    end

    test "should return nil if Zipper has no children", %{leaf_z: z} do
      assert Zipper.first_great_grandchild(z) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Zipper",
         %{z_with_great_grandchildren: z_1, z_with_great_grandchildren_2: z_2} do
      predicate = &(&1.term == 30)

      for z <- [z_1, z_2] do
        assert Zipper.first_great_grandchild(z, predicate) == nil
      end
    end
  end

  describe "last_great_grandchild/2" do
    test "should return the last great grandchild that is found for the Zipper", %{
      z_with_great_grandchildren: z_1,
      z_with_great_grandchildren_2: z_2
    } do
      for z <- [z_1, z_2] do
        actual = Zipper.last_great_grandchild(z)
        assert 21 == actual.focus.term
      end
    end

    test "should return the last grandchild that is found that matches the predicate for the Zipper",
         %{z_with_great_grandchildren: z_1, z_with_great_grandchildren_2: z_2} do
      predicate = &(&1.term < 18)

      for z <- [z_1, z_2] do
        actual = Zipper.last_great_grandchild(z, predicate)
        assert 17 == actual.focus.term
      end
    end

    test "should return nil if Zipper has children but no grandchildren", %{simple_z: z} do
      assert Zipper.last_great_grandchild(z) == nil
    end

    test "should return nil if Zipper has no children", %{leaf_z: z} do
      assert Zipper.last_great_grandchild(z) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Zipper",
         %{z_with_great_grandchildren: z_1, z_with_great_grandchildren_2: z_2} do
      predicate = &(&1.term == 30)

      for z <- [z_1, z_2] do
        assert Zipper.last_great_grandchild(z, predicate) == nil
      end
    end
  end

  describe "rightmost_descendant/2" do
    test "should return nil when given a zipper with no children",
         %{empty_z: z_0, leaf_z: z_1, z_with_siblings: z_2} do
      for z <- [z_0, z_1, z_2] do
        assert Zipper.rightmost_descendant(z) == nil
      end
    end

    test "should return the rightmost descendant of the Zipper", %{z_with_great_grandchildren: z} do
      assert %Zipper{focus: actual} = Zipper.rightmost_descendant(z)
      assert actual.term == 12
    end

    test "should return the rightmost descendant of the Zipper if predicate matches", %{
      z_with_great_grandchildren: z
    } do
      predicate = &(&1.focus.term == 3)

      assert %Zipper{focus: actual} = Zipper.rightmost_descendant(z, predicate)
      assert actual.term == 3
    end

    test "should return rightmost descendant of the Zipper if predicate doesn't find a match", %{
      z_with_great_grandchildren: z
    } do
      predicate = &(&1.focus.term == 30)

      assert %Zipper{focus: actual} = Zipper.rightmost_descendant(z, predicate)
      assert actual.term == 12
    end
  end

  describe "leftmost_descendant/2" do
    test "should return nil when given a zipper with no children",
         %{empty_z: z_0, leaf_z: z_1, z_with_siblings: z_2} do
      for z <- [z_0, z_1, z_2] do
        assert Zipper.leftmost_descendant(z) == nil
      end
    end

    test "should return the leftmost descendant of the Zipper", %{z_with_great_grandchildren: z} do
      assert %Zipper{focus: actual} = Zipper.leftmost_descendant(z)
      assert actual.term == 4
    end

    test "should return the rightmost descendant of the Zipper if predicate matches", %{
      z_with_great_grandchildren: z
    } do
      predicate = &(&1.focus.term == 1)

      assert %Zipper{focus: actual} = Zipper.leftmost_descendant(z, predicate)
      assert actual.term == 1
    end

    test "should return rightmost descendant of the Zipper if predicate doesn't find a match", %{
      z_with_great_grandchildren: z
    } do
      predicate = &(&1.focus.term == 40)

      assert %Zipper{focus: actual} = Zipper.leftmost_descendant(z, predicate)
      assert actual.term == 4
    end
  end
end
