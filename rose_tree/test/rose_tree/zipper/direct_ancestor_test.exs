defmodule RoseTree.Zipper.DirectAncestorTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper

  setup_all do
    %{
      empty_z: Zippers.empty_z(),
      leaf_z: Zippers.leaf_z(),
      simple_z: Zippers.simple_z(),
      z_with_parent: Zippers.z_with_parent(),
      z_with_grandparent: Zippers.z_with_grandparent(),
      z_with_great_grandparent: Zippers.z_with_great_grandparent()
    }
  end

  describe "parent/1" do
    test "should return nil for empty Zipper", %{empty_z: z} do
      assert Zipper.parent(z) == nil
    end

    test "should return nil for Zipper with no parent", %{simple_z: z} do
      assert Zipper.parent(z) == nil
    end

    test "should move focus to parent if one is found", %{z_with_parent: z} do
      %Zipper{focus: focus} = Zipper.parent(z)
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