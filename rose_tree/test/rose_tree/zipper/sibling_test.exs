defmodule RoseTree.Zipper.Zipper.SiblingTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper

  setup all do
    %{
      simple_z: Zippers.simple_z(),
      z_with_siblings: Zippers.z_with_siblings()
    }
  end

  describe "first_sibling/2" do
    test "should return nil if Zipper has no previous siblings", %{simple_z: z} do
      assert Zipper.first_sibling(z) == nil
    end

    test "should return nil if no previous sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_sibling(z, predicate) == nil
    end

    test "should return the first sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.first_sibling(z)
      assert 1 == actual.focus.term
    end

    test "should return the first sibling node for Zipper that matches the predicate", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.first_sibling(z, predicate)
      assert 3 == actual.focus.term
    end

    test "should return nil and not seek past the original Zipper for a predicate match", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 7)

      assert Zipper.first_sibling(z, predicate) == nil
    end
  end

  describe "previous_sibling/2" do
    test "should return nil if Zipper has no previous siblings", %{simple_z: z} do
      assert Zipper.previous_sibling(z) == nil
    end

    test "should return nil if no previous sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_sibling(z, predicate) == nil
    end

    test "should return the previous sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.previous_sibling(z)
      assert 4 == actual.focus.term
    end

    test "should return the first previous sibling node for Zipper that matches the predicate",
         %{
           z_with_siblings: z
         } do
      predicate = &(&1.term == 2)

      actual = Zipper.previous_sibling(z, predicate)
      assert 2 == actual.focus.term
    end
  end

  describe "last_sibling/2" do
    test "should return nil if Zipper has no next siblings", %{simple_z: z} do
      assert Zipper.last_sibling(z) == nil
    end

    test "should return nil if no next sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_sibling(z, predicate) == nil
    end

    test "should return the last sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.last_sibling(z)
      assert 9 == actual.focus.term
    end

    test "should return the last next sibling node for Zipper that matches the predicate", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.last_sibling(z, predicate)
      assert 7 == actual.focus.term
    end

    test "should return nil and not seek before the original Zipper for a predicate match", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 3)

      assert Zipper.last_sibling(z, predicate) == nil
    end
  end

  describe "next_sibling/2" do
    test "should return nil if Zipper has no next siblings", %{simple_z: z} do
      assert Zipper.next_sibling(z) == nil
    end

    test "should return nil if no next sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_sibling(z, predicate) == nil
    end

    test "should return the next sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.next_sibling(z)
      assert 6 == actual.focus.term
    end

    test "should return the first next sibling node for Zipper that matches the predicate",
         %{
           z_with_siblings: z
         } do
      predicate = &(&1.term == 8)

      actual = Zipper.next_sibling(z, predicate)
      assert 8 == actual.focus.term
    end
  end

  describe "sibling_at/2" do
    test "should return nil when given a Zipper with no siblings", %{simple_z: z} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Zipper.sibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that is out of bounds for the siblings of the Zipper",
         %{z_with_siblings: z} do
      num_siblings = Enum.count(z.prev) + Enum.count(z.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Zipper.sibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Zipper's index",
         %{z_with_siblings: z} do
      current_idx = Enum.count(z.prev)

      assert Zipper.sibling_at(z, current_idx) == nil
    end
  end
end
