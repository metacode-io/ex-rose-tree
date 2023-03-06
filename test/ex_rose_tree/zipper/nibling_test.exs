defmodule ExRoseTree.Zipper.Zipper.NiblingTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "first_nibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.first_nibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.first_nibling(z) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_nibling(z, predicate) == nil
    end

    test "should return the first nibling", %{
      z_with_niblings: z
    } do
      actual = Zipper.first_nibling(z)
      assert 10 == actual.focus.term
    end

    test "should return the first nibling that matches the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 11)

      actual = Zipper.first_nibling(z, predicate)
      assert 11 == actual.focus.term
    end
  end

  describe "last_nibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.last_nibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.last_nibling(z) == nil
    end

    test "should return nil if no next nibling matching the predicate is found",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_nibling(z, predicate) == nil
    end

    test "should return the last nibling", %{
      z_with_niblings: z
    } do
      actual = Zipper.last_nibling(z)
      assert 15 == actual.focus.term
    end

    test "should return the last nibling that matches the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 14)

      actual = Zipper.last_nibling(z, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "previous_nibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.previous_nibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.previous_nibling(z) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_nibling(z, predicate) == nil
    end

    test "should return the previous nibling", %{
      z_with_niblings: z
    } do
      actual = Zipper.previous_nibling(z)
      assert 12 == actual.focus.term
    end

    test "should return the previous nibling that matches the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 11)

      actual = Zipper.previous_nibling(z, predicate)
      assert 11 == actual.focus.term
    end
  end

  describe "next_nibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.next_nibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.next_nibling(z) == nil
    end

    test "should return nil if no next nibling matching the predicate is found",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_nibling(z, predicate) == nil
    end

    test "should return the next nibling", %{
      z_with_niblings: z
    } do
      actual = Zipper.next_nibling(z)
      assert 13 == actual.focus.term
    end

    test "should return the next nibling matching the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 14)

      actual = Zipper.next_nibling(z, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "first_nibling_at_sibling/3" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.first_nibling_at_sibling(z, 3) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.first_nibling_at_sibling(z, 3) == nil
    end

    test "should return nil when given an index that is out of bounds for siblings",
         %{z_with_niblings: z} do
      num_siblings = Enum.count(z.prev) + Enum.count(z.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Zipper.first_nibling_at_sibling(z, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Zipper's index",
         %{z_with_niblings: z} do
      current_idx = Enum.count(z.prev)

      assert Zipper.first_nibling_at_sibling(z, current_idx) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found for the sibling at index",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_nibling_at_sibling(z, 6, predicate) == nil
    end

    test "should return the first nibling for sibling at index", %{
      z_with_niblings: z
    } do
      actual = Zipper.first_nibling_at_sibling(z, 6)
      assert 13 == actual.focus.term
    end

    test "should return the first nibling that matches the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 14)

      actual = Zipper.first_nibling_at_sibling(z, 6, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "last_nibling_at_sibling/3" do
    test "should return nil if no siblings are found", %{simple_z: z} do
      assert Zipper.last_nibling_at_sibling(z, 7) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.last_nibling_at_sibling(z, 7) == nil
    end

    test "should return nil when given an index that is out of bounds for siblings",
         %{z_with_niblings: z} do
      num_siblings = Enum.count(z.prev) + Enum.count(z.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Zipper.last_nibling_at_sibling(z, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Zipper's index",
         %{z_with_niblings: z} do
      current_idx = Enum.count(z.prev)

      assert Zipper.last_nibling_at_sibling(z, current_idx) == nil
    end

    test "should return nil if no next nibling matching the predicate is found for the sibling at index",
         %{z_with_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_nibling_at_sibling(z, 2, predicate) == nil
    end

    test "should return the last nibling for sibling at index", %{
      z_with_niblings: z
    } do
      actual = Zipper.last_nibling_at_sibling(z, 2)
      assert 12 == actual.focus.term
    end

    test "should return the last nibling matching the predicate", %{
      z_with_niblings: z
    } do
      predicate = &(&1.term == 10)

      actual = Zipper.last_nibling_at_sibling(z, 2, predicate)
      assert 10 == actual.focus.term
    end
  end

  describe "previous_grandnibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.previous_grandnibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.previous_grandnibling(z) == nil
    end

    test "should return nil if no siblings with grandchildren are found",
         %{z_with_niblings: z} do
      assert Zipper.previous_grandnibling(z) == nil
    end

    test "should return nil if no previous grandnibling matching the predicate is found",
         %{z_with_grand_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_grandnibling(z, predicate) == nil
    end

    test "should return the previous grandnibling", %{
      z_with_grand_niblings: z
    } do
      actual = Zipper.previous_grandnibling(z)
      assert 20 == actual.focus.term
    end

    test "should return the previous grandnibling matching the predicate", %{
      z_with_grand_niblings: z
    } do
      predicate = &(&1.term == 21)

      actual = Zipper.previous_grandnibling(z, predicate)
      assert 21 == actual.focus.term
    end
  end

  describe "next_grandnibling/2" do
    test "should return nil if no siblings found", %{simple_z: z} do
      assert Zipper.next_grandnibling(z) == nil
    end

    test "should return nil if no siblings with children are found",
         %{z_with_siblings: z} do
      assert Zipper.next_grandnibling(z) == nil
    end

    test "should return nil if no siblings with grandchildren are found",
         %{z_with_niblings: z} do
      assert Zipper.next_grandnibling(z) == nil
    end

    test "should return nil if no next grandnibling matching the predicate is found",
         %{z_with_grand_niblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_grandnibling(z, predicate) == nil
    end

    test "should return the next grandnibling", %{
      z_with_grand_niblings: z
    } do
      actual = Zipper.next_grandnibling(z)
      assert 26 == actual.focus.term
    end

    test "should return the next grandnibling matching the predicate", %{
      z_with_grand_niblings: z
    } do
      predicate = &(&1.term == 30)

      actual = Zipper.next_grandnibling(z, predicate)
      assert 30 == actual.focus.term
    end
  end

  describe "first_descendant_nibling/2" do
    test "should return nil if no previous sibling found", %{simple_z: z} do
      assert Zipper.first_descendant_nibling(z) == nil
    end

    test "should return nil if first previous sibling has no children", %{
      z_with_niblings: z
    } do
      assert Zipper.first_descendant_nibling(z) == nil
    end

    test "should return nil if no previous descendant nibling, starting from first, found matching predicate",
         %{
           z_with_descendant_niblings: z
         } do
      predicate = &(&1.focus.term == :not_found)

      assert Zipper.first_descendant_nibling(z, predicate) == nil
    end

    test "should return the first descendant nibling found", %{
      z_with_descendant_niblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.first_descendant_nibling(z)
      assert 300 == focus.term
    end

    test "should return the first previous descendant nibling, starting from first, found matching the predicate",
         %{
           z_with_descendant_niblings: z
         } do
      predicate = &(&1.focus.term == 200)

      assert %Zipper{focus: focus} = Zipper.first_descendant_nibling(z, predicate)
      assert 200 == focus.term
    end
  end

  describe "last_descendant_nibling/2" do
    test "should return nil if no previous sibling found", %{simple_z: z} do
      assert Zipper.last_descendant_nibling(z) == nil
    end

    test "should return nil if first previous sibling has no children", %{
      z_with_niblings: z
    } do
      assert Zipper.last_descendant_nibling(z) == nil
    end

    test "should return nil if no previous descendant nibling, starting from first, found matching predicate",
         %{
           z_with_descendant_niblings: z
         } do
      predicate = &(&1.focus.term == :not_found)

      assert Zipper.last_descendant_nibling(z, predicate) == nil
    end

    test "should return the first descendant nibling found", %{
      z_with_descendant_niblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.last_descendant_nibling(z)
      assert 901 == focus.term
    end

    test "should return the first previous descendant nibling, starting from first, found matching the predicate",
         %{
           z_with_descendant_niblings: z
         } do
      predicate = &(&1.focus.term == 701)

      assert %Zipper{focus: focus} = Zipper.last_descendant_nibling(z, predicate)
      assert 701 == focus.term
    end
  end

  describe "previous_descendant_nibling/2" do
    test "should return nil if no previous sibling found", %{simple_z: z} do
      assert Zipper.previous_descendant_nibling(z) == nil
    end

    test "should return nil if immediately previous sibling has no children", %{
      z_with_niblings: z
    } do
      assert Zipper.previous_descendant_nibling(z) == nil
    end

    test "should return nil if no previous descendant nibling found matching predicate", %{
      z_with_descendant_niblings: z
    } do
      predicate = &(&1.focus.term == :not_found)

      assert Zipper.previous_descendant_nibling(z, predicate) == nil
    end

    test "should return the last previous descendant nibling found", %{
      z_with_descendant_niblings: z
    } do
      actual = Zipper.previous_descendant_nibling(z)
      assert 25 == actual.focus.term
    end

    test "should return the last previous descendant nibling found matching the predicate", %{
      z_with_descendant_niblings: z
    } do
      predicate = &(&1.focus.term == 12)

      assert %Zipper{focus: focus} = Zipper.previous_descendant_nibling(z, predicate)
      assert 12 == focus.term
    end
  end

  describe "next_descendant_nibling/2" do
    test "should return nil if no next sibling found", %{simple_z: z} do
      assert Zipper.next_descendant_nibling(z) == nil
    end

    test "should return nil if immediately next sibling has no children", %{
      z_with_niblings: z
    } do
      assert Zipper.next_descendant_nibling(z) == nil
    end

    test "should return nil if no next descendant nibling found matching predicate", %{
      z_with_descendant_niblings: z
    } do
      predicate = &(&1.focus.term == :not_found)

      assert Zipper.next_descendant_nibling(z, predicate) == nil
    end

    test "should return the last next descendant nibling found", %{
      z_with_descendant_niblings: z
    } do
      actual = Zipper.next_descendant_nibling(z)
      assert 37 == actual.focus.term
    end

    test "should return the last next descendant nibling found matching the predicate", %{
      z_with_descendant_niblings: z
    } do
      predicate = &(&1.focus.term == 29)

      assert %Zipper{focus: focus} = Zipper.next_descendant_nibling(z, predicate)
      assert 29 == focus.term
    end
  end

  describe "first_extended_nibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_extended_nibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.first_extended_nibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.first_extended_nibling(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.first_extended_nibling(z) == nil
    end

    test "should return nil if no extended nibling found matching predicate",
         %{
           z_with_extended_niblings: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_extended_nibling(z, predicate) == nil
    end

    test "should return the first extended nibling found",
         %{z_with_extended_niblings: z} do
      assert %Zipper{focus: actual} = Zipper.first_extended_nibling(z)
      assert 202 == actual.term
    end

    test "should return the first extended nibling found matching the predicate",
         %{z_with_extended_niblings: z} do
      predicate = &(&1.term == 203)

      assert %Zipper{focus: actual} = Zipper.first_extended_nibling(z, predicate)
      assert 203 == actual.term
    end
  end

  describe "last_extended_nibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_extended_nibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.last_extended_nibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.last_extended_nibling(z) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.last_extended_nibling(z) == nil
    end

    test "should return nil if no extended nibling found matching predicate",
         %{
           z_with_extended_niblings: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_extended_nibling(z, predicate) == nil
    end

    test "should return the last extended nibling found",
         %{z_with_extended_niblings: z} do
      assert %Zipper{focus: actual} = Zipper.last_extended_nibling(z)
      assert 209 == actual.term
    end

    test "should return the last extended nibling found matching the predicate",
         %{z_with_extended_niblings: z} do
      predicate = &(&1.term == 208)

      assert %Zipper{focus: actual} = Zipper.last_extended_nibling(z, predicate)
      assert 208 == actual.term
    end
  end

  describe "previous_extended_nibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_extended_nibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.previous_extended_nibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.previous_extended_nibling(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.previous_extended_nibling(z) == nil
    end

    test "should return nil if no extended nibling found matching predicate",
         %{
           z_with_extended_niblings: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_extended_nibling(z, predicate) == nil
    end

    test "should return the previous extended nibling found",
         %{z_with_extended_niblings: z} do
      assert %Zipper{focus: actual} = Zipper.previous_extended_nibling(z)
      assert 201 == actual.term
    end

    test "should return the previous extended nibling found matching the predicate",
         %{z_with_extended_niblings: z} do
      predicate = &(&1.term == 200)

      assert %Zipper{focus: actual} = Zipper.previous_extended_nibling(z, predicate)
      assert 200 == actual.term
    end
  end

  describe "next_extended_nibling/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_extended_nibling(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.next_extended_nibling(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.next_extended_nibling(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.next_extended_nibling(z) == nil
    end

    test "should return nil if no extended nibling found matching predicate",
         %{
           z_with_extended_niblings: z
         } do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_extended_nibling(z, predicate) == nil
    end

    test "should return the previous extended nibling found",
         %{z_with_extended_niblings: z} do
      assert %Zipper{focus: actual} = Zipper.next_extended_nibling(z)
      assert 204 == actual.term
    end

    test "should return the previous extended nibling found matching the predicate",
         %{z_with_extended_niblings: z} do
      predicate = &(&1.term == 206)

      assert %Zipper{focus: actual} = Zipper.next_extended_nibling(z, predicate)
      assert 206 == actual.term
    end
  end
end
