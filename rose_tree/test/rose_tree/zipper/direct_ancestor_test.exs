defmodule RoseTree.Zipper.DirectAncestorTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "parent/1" do
    test "should return nil for empty Zipper", %{empty_z: z} do
      assert Zipper.parent(z) == nil
    end

    test "should return nil for Zipper with no parent", %{simple_z: z_1, z_with_siblings: z_2} do
      for z <- [z_1, z_2] do
        assert Zipper.parent(z) == nil
      end
    end

    test "should move focus to parent if one is found", %{z_with_parent: z} do
      assert %Zipper{focus: focus} = Zipper.parent(z)
      assert focus.term == 10
    end
  end

  describe "grandparent/1" do
    test "should return nil for empty Zipper", %{empty_z: z} do
      assert Zipper.grandparent(z) == nil
    end

    test "should return nil for Zipper with no parent", %{simple_z: z} do
      assert Zipper.grandparent(z) == nil
    end

    test "should return nil for Zipper with no grandparent", %{z_with_parent: z} do
      assert Zipper.grandparent(z) == nil
    end

    test "should move focus to grandparent if one is found",
         %{z_with_grandparent: z} do
      %Zipper{focus: focus} = Zipper.grandparent(z)

      assert focus.term == 5
    end
  end

  describe "great_grandparent/1" do
    test "should return nil for empty Zipper", %{empty_z: z} do
      assert Zipper.great_grandparent(z) == nil
    end

    test "should return nil for Zipper with no parent", %{simple_z: z} do
      assert Zipper.great_grandparent(z) == nil
    end

    test "should return nil for Zipper with no grandparent", %{z_with_parent: z} do
      assert Zipper.great_grandparent(z) == nil
    end

    test "should return nil for Zipper with no great grandparent", %{z_with_grandparent: z} do
      assert Zipper.great_grandparent(z) == nil
    end

    test "should move focus to great grandparent if one is found",
         %{z_with_great_grandparent: z} do
      %Zipper{focus: focus} = Zipper.great_grandparent(z)

      assert focus.term == 1
    end
  end
end
