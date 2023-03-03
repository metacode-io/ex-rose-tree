defmodule RoseTree.Zipper.SecondCousinTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "first_second_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_second_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.first_second_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.first_second_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.first_second_cousin(z) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{z_with_2nd_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_second_cousin(z, predicate) == nil
    end

    test "should return the first second-cousin found", %{
      z_with_2nd_cousins: z
    } do
      actual = Zipper.first_second_cousin(z)
      assert 50 == actual.focus.term
    end

    test "should return the first second-cousin matching the predicate", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 45)

      actual = Zipper.first_second_cousin(z, predicate)
      assert 45 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 58)

      assert Zipper.first_second_cousin(z, predicate) == nil
    end
  end

  describe "last_second_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_second_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.last_second_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.last_second_cousin(z) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.last_second_cousin(z) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{z_with_2nd_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_second_cousin(z, predicate) == nil
    end

    test "should return the last second-cousin found", %{
      z_with_2nd_cousins: z
    } do
      actual = Zipper.last_second_cousin(z)
      assert 58 == actual.focus.term
    end

    test "should return the last second-cousin matching the predicate", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 55)

      actual = Zipper.last_second_cousin(z, predicate)
      assert 55 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           z_with_2nd_cousins: z
         } do
      predicate = &(&1.term == 45)

      assert Zipper.last_second_cousin(z, predicate) == nil
    end
  end

  describe "previous_second_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_second_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.previous_second_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.previous_second_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.previous_second_cousin(z) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{z_with_2nd_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_second_cousin(z, predicate) == nil
    end

    test "should return the first previous second-cousin found", %{
      z_with_2nd_cousins: z
    } do
      actual = Zipper.previous_second_cousin(z)
      assert 49 == actual.focus.term
    end

    test "should return the first previous second-cousin matching the predicate", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 49)

      actual = Zipper.previous_second_cousin(z, predicate)
      assert 49 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 54)

      assert Zipper.previous_second_cousin(z, predicate) == nil
    end
  end

  describe "next_second_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_second_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.next_second_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.next_second_cousin(z) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.next_second_cousin(z) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{z_with_2nd_cousins: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_second_cousin(z, predicate) == nil
    end

    test "should return the next second-cousin found", %{
      z_with_2nd_cousins: z
    } do
      actual = Zipper.next_second_cousin(z)
      assert 52 == actual.focus.term
    end

    test "should return the next second-cousin matching the predicate", %{
      z_with_2nd_cousins: z
    } do
      predicate = &(&1.term == 55)

      actual = Zipper.next_second_cousin(z, predicate)
      assert 55 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           z_with_2nd_cousins: z
         } do
      predicate = &(&1.term == 45)

      assert Zipper.next_second_cousin(z, predicate) == nil
    end
  end
end
