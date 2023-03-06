defmodule ExRoseTree.Zipper.PiblingTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "first_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_pibling(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.first_pibling(z) == nil
    end

    test "should return nil if no previous pibling found matching the predicate",
         %{z_with_piblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_pibling(z, predicate) == nil
    end

    test "should return the first pibling found", %{
      z_with_piblings: z
    } do
      actual = Zipper.first_pibling(z)
      assert 2 == actual.focus.term
    end

    test "should return the first first pibling matching the predicate", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 4)

      actual = Zipper.first_pibling(z, predicate)
      assert 4 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 14)

      assert Zipper.first_pibling(z, predicate) == nil
    end
  end

  describe "last_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_pibling(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.last_pibling(z) == nil
    end

    test "should return nil if no next pibling found matching the predicate",
         %{z_with_piblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_pibling(z, predicate) == nil
    end

    test "should return the last pibling found", %{
      z_with_piblings: z
    } do
      actual = Zipper.last_pibling(z)
      assert 18 == actual.focus.term
    end

    test "should return the first last pibling matching the predicate", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 14)

      actual = Zipper.last_pibling(z, predicate)
      assert 14 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 6)

      assert Zipper.last_pibling(z, predicate) == nil
    end
  end

  describe "previous_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_pibling(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.previous_pibling(z) == nil
    end

    test "should return nil if no previous pibling found matching the predicate",
         %{z_with_piblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_pibling(z, predicate) == nil
    end

    test "should return the first previous pibling found", %{
      z_with_piblings: z
    } do
      actual = Zipper.previous_pibling(z)
      assert 6 == actual.focus.term
    end

    test "should return the first previous pibling matching the predicate", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 4)

      actual = Zipper.previous_pibling(z, predicate)
      assert 4 == actual.focus.term
    end
  end

  describe "next_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_pibling(z) == nil
    end

    test "should return nil if parent has no siblings", %{z_with_parent: z} do
      assert Zipper.next_pibling(z) == nil
    end

    test "should return nil if no next pibling found matching the predicate",
         %{z_with_piblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_pibling(z, predicate) == nil
    end

    test "should return the first next pibling found", %{
      z_with_piblings: z
    } do
      actual = Zipper.next_pibling(z)
      assert 14 == actual.focus.term
    end

    test "should return the first next pibling matching the predicate", %{
      z_with_piblings: z
    } do
      predicate = &(&1.term == 18)

      actual = Zipper.next_pibling(z, predicate)
      assert 18 == actual.focus.term
    end
  end

  describe "pibling_at/2" do
    test "should return nil when parent has no siblings", %{simple_z: z} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Zipper.pibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that is out of bounds for the parent's siblings",
         %{z_with_piblings: z} do
      [parent | _] = z.path

      num_piblings = Enum.count(parent.prev) + Enum.count(parent.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_piblings..20)
        assert Zipper.pibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Zipper's index",
         %{z_with_piblings: z} do
      [parent | _] = z.path

      current_idx = Enum.count(parent.prev)

      assert Zipper.pibling_at(z, current_idx) == nil
    end

    test "should return the pibling at the given index", %{z_with_piblings: z} do
      actual = Zipper.pibling_at(z, 0)
      assert 2 == actual.focus.term
    end
  end

  describe "first_grandpibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_grandpibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.first_grandpibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.first_grandpibling(z) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{z_with_grandpiblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_grandpibling(z, predicate) == nil
    end

    test "should return the first grandpibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.first_grandpibling(z)
      assert 2 == actual.focus.term
    end

    test "should return the first first grandpibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.first_grandpibling(z, predicate)
      assert 3 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 6)

      assert Zipper.first_grandpibling(z, predicate) == nil
    end
  end

  describe "last_grandpibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_grandpibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.last_grandpibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.last_grandpibling(z) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{z_with_grandpiblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_grandpibling(z, predicate) == nil
    end

    test "should return the last grandpibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.last_grandpibling(z)
      assert 8 == actual.focus.term
    end

    test "should return the first last grandpibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.last_grandpibling(z, predicate)
      assert 7 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           z_with_grandpiblings: z
         } do
      predicate = &(&1.term == 3)

      assert Zipper.last_grandpibling(z, predicate) == nil
    end
  end

  describe "previous_grandpibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_grandpibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.previous_grandpibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.previous_grandpibling(z) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{z_with_grandpiblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_grandpibling(z, predicate) == nil
    end

    test "should return the previous grandpibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.previous_grandpibling(z)
      assert 4 == actual.focus.term
    end

    test "should return the first previous grandpibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.previous_grandpibling(z, predicate)
      assert 3 == actual.focus.term
    end
  end

  describe "next_grandpibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_grandpibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.next_grandpibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.next_grandpibling(z) == nil
    end

    test "should return nil if no next grandpibling found matching the predicate",
         %{z_with_grandpiblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_grandpibling(z, predicate) == nil
    end

    test "should return the next grandpibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.next_grandpibling(z)
      assert 6 == actual.focus.term
    end

    test "should return the first next grandpibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.next_grandpibling(z, predicate)
      assert 7 == actual.focus.term
    end
  end

  describe "first_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_ancestral_pibling(z) == nil
    end

    test "should return nil if no ancestors have siblings", %{z_with_no_ancestral_piblings: z} do
      assert Zipper.first_ancestral_pibling(z) == nil
    end

    test "should return nil if no previous pibling for any ancestor found matching the predicate",
         %{
           z_with_piblings: z_1,
           z_with_grandpiblings: z_2,
           z_with_ancestral_piblings: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.first_ancestral_pibling(z, predicate) == nil
      end
    end

    test "should return the first previous ancestral pibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.first_ancestral_pibling(z)
      assert 2 == actual.focus.term
    end

    test "should return the first previous pibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.first_ancestral_pibling(z, predicate)
      assert 3 == actual.focus.term
    end
  end

  describe "last_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_ancestral_pibling(z) == nil
    end

    test "should return nil if no ancestors have siblings", %{z_with_no_ancestral_piblings: z} do
      assert Zipper.last_ancestral_pibling(z) == nil
    end

    test "should return nil if no next pibling for any ancestor found matching the predicate",
         %{
           z_with_piblings: z_1,
           z_with_grandpiblings: z_2,
           z_with_ancestral_piblings: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.last_ancestral_pibling(z, predicate) == nil
      end
    end

    test "should return the first next ancestral pibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.last_ancestral_pibling(z)
      assert 8 == actual.focus.term
    end

    test "should return the first next ancestral pibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.last_ancestral_pibling(z, predicate)
      assert 7 == actual.focus.term
    end
  end

  describe "previous_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_ancestral_pibling(z) == nil
    end

    test "should return nil if no ancestors have siblings", %{z_with_no_ancestral_piblings: z} do
      assert Zipper.previous_ancestral_pibling(z) == nil
    end

    test "should return nil if no previous pibling for any ancestor found matching the predicate",
         %{
           z_with_piblings: z_1,
           z_with_grandpiblings: z_2,
           z_with_ancestral_piblings: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.previous_ancestral_pibling(z, predicate) == nil
      end
    end

    test "should return the first previous ancestral pibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.previous_ancestral_pibling(z)
      assert 4 == actual.focus.term
    end

    test "should return the first previous pibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.previous_ancestral_pibling(z, predicate)
      assert 3 == actual.focus.term
    end
  end

  describe "next_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_ancestral_pibling(z) == nil
    end

    test "should return nil if no ancestors have siblings", %{z_with_no_ancestral_piblings: z} do
      assert Zipper.next_ancestral_pibling(z) == nil
    end

    test "should return nil if no next pibling for any ancestor found matching the predicate",
         %{
           z_with_piblings: z_1,
           z_with_grandpiblings: z_2,
           z_with_ancestral_piblings: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.next_ancestral_pibling(z, predicate) == nil
      end
    end

    test "should return the first next ancestral pibling found", %{
      z_with_grandpiblings: z
    } do
      actual = Zipper.next_ancestral_pibling(z)
      assert 6 == actual.focus.term
    end

    test "should return the first next ancestral pibling matching the predicate", %{
      z_with_grandpiblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.next_ancestral_pibling(z, predicate)
      assert 7 == actual.focus.term
    end
  end

  describe "first_extended_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_extended_pibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.first_extended_pibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.first_extended_pibling(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.first_extended_pibling(z) == nil
    end

    test "should return nil if no extended pibling found matching predicate",
         %{
           z_with_extended_cousins: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_extended_pibling(z, predicate) == nil
    end

    test "should return the first extended pibling found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.first_extended_pibling(z)
      assert 50 == actual.term
    end

    test "should return the first extended pibling found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 45)

      assert %Zipper{focus: actual} = Zipper.first_extended_pibling(z, predicate)
      assert 45 == actual.term
    end
  end

  describe "last_extended_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_extended_pibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.last_extended_pibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.last_extended_pibling(z) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.last_extended_pibling(z) == nil
    end

    test "should return nil if no extended pibling found matching predicate",
         %{
           z_with_extended_cousins: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_extended_pibling(z, predicate) == nil
    end

    test "should return the last extended pibling found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.last_extended_pibling(z)
      assert 58 == actual.term
    end

    test "should return the last extended pibling found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 54)

      assert %Zipper{focus: actual} = Zipper.last_extended_pibling(z, predicate)
      assert 54 == actual.term
    end
  end

  describe "previous_extended_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_extended_pibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.previous_extended_pibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.previous_extended_pibling(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.previous_extended_pibling(z) == nil
    end

    test "should return nil if no extended pibling found matching predicate",
         %{
           z_with_extended_cousins: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_extended_pibling(z, predicate) == nil
    end

    test "should return the previous extended pibling found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.previous_extended_pibling(z)
      assert 49 == actual.term
    end

    test "should return the previous extended pibling found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 45)

      assert %Zipper{focus: actual} = Zipper.previous_extended_pibling(z, predicate)
      assert 45 == actual.term
    end
  end

  describe "next_extended_pibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_extended_pibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.next_extended_pibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.next_extended_pibling(z) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.next_extended_pibling(z) == nil
    end

    test "should return nil if no extended pibling found matching predicate",
         %{
           z_with_extended_cousins: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_extended_pibling(z, predicate) == nil
    end

    test "should return the next extended pibling found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.next_extended_pibling(z)
      assert 52 == actual.term
    end

    test "should return the next extended pibling found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 54)

      assert %Zipper{focus: actual} = Zipper.next_extended_pibling(z, predicate)
      assert 54 == actual.term
    end
  end
end
