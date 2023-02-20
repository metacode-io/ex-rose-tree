defmodule RoseTree.Zipper.FirstCousinTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper

  setup_all do
    %{
      simple_z: Zippers.simple_z(),
      z_with_parent: Zippers.z_with_parent(),
      z_with_piblings: Zippers.z_with_piblings(),
      z_with_1st_cousins: Zippers.z_with_1st_cousins()
    }
  end

  describe "first_first_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_first_cousin(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.first_first_cousin(z) == nil
    end

    test "should return nil if no previous pibling has children",
         %{z_with_piblings: z} do
      assert Zipper.first_first_cousin(z) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{z_with_1st_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_first_cousin(z, predicate) == nil
    end

    test "should return the first first-cousin found", %{
      z_with_1st_cousins: z
    } do
      actual = Zipper.first_first_cousin(z)
      assert 19 == actual.focus.term
    end

    test "should return the first first-cousin matching the predicate", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 23)

      actual = Zipper.first_first_cousin(z, predicate)
      assert 23 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 29)

      assert Zipper.first_first_cousin(z, predicate) == nil
    end
  end

  describe "last_first_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_first_cousin(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.last_first_cousin(z) == nil
    end

    test "should return nil if no next pibling has children",
         %{z_with_piblings: z} do
      assert Zipper.last_first_cousin(z) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{z_with_1st_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_first_cousin(z, predicate) == nil
    end

    test "should return the last first-cousin found", %{
      z_with_1st_cousins: z
    } do
      actual = Zipper.last_first_cousin(z)
      assert 30 == actual.focus.term
    end

    test "should return the last first-cousin matching the predicate", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 26)

      actual = Zipper.last_first_cousin(z, predicate)
      assert 26 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 22)

      assert Zipper.last_first_cousin(z, predicate) == nil
    end
  end

  describe "previous_first_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_first_cousin(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.previous_first_cousin(z) == nil
    end

    test "should return nil if no previous pibling has children",
         %{z_with_piblings: z} do
      assert Zipper.previous_first_cousin(z) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{z_with_1st_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_first_cousin(z, predicate) == nil
    end

    test "should return the first previous first-cousin found", %{
      z_with_1st_cousins: z
    } do
      actual = Zipper.previous_first_cousin(z)
      assert 24 == actual.focus.term
    end

    test "should return the first first-cousin matching the predicate", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 19)

      actual = Zipper.previous_first_cousin(z, predicate)
      assert 19 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 29)

      assert Zipper.previous_first_cousin(z, predicate) == nil
    end
  end

  describe "next_first_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_first_cousin(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.next_first_cousin(z) == nil
    end

    test "should return nil if no next pibling has children",
         %{z_with_piblings: z} do
      assert Zipper.next_first_cousin(z) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{z_with_1st_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_first_cousin(z, predicate) == nil
    end

    test "should return the last first-cousin found", %{
      z_with_1st_cousins: z
    } do
      actual = Zipper.next_first_cousin(z)
      assert 25 == actual.focus.term
    end

    test "should return the last first-cousin matching the predicate", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 29)

      actual = Zipper.next_first_cousin(z, predicate)
      assert 29 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      z_with_1st_cousins: z
    } do
      predicate = &(&1.term == 22)

      assert Zipper.next_first_cousin(z, predicate) == nil
    end
  end
end
