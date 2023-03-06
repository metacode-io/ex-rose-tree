defmodule ExRoseTree.Zipper.ExtendedCousinTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "first_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.first_extended_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.first_extended_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.first_extended_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.first_extended_cousin(z) == nil
    end

    test "should return the same value as Zipper.first_first_cousin/2 when no further extended cousins exist",
         %{z_with_1st_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.first_first_cousin(z)

      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 19
    end

    test "should return the same value as Zipper.first_second_cousin/2 when no further extended cousins exist",
         %{z_with_2nd_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.first_second_cousin(z)

      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 50
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           z_with_1st_cousins: z_1,
           z_with_2nd_cousins: z_2,
           z_with_extended_cousins: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.first_extended_cousin(z, predicate) == nil
      end
    end

    test "should return the first extended cousin found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z)
      assert 103 == actual.term
    end

    test "should return the first extended cousin found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 102)

      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z, predicate)
      assert 102 == actual.term
    end

    test "should return the first extended cousin found in scenario 2",
         %{z_with_extended_cousins_2: z} do
      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z)
      assert -29 == actual.term
    end

    test "should return the first extended cousin found matching the predicate in scenario 2",
         %{z_with_extended_cousins_2: z} do
      predicate = &(&1.term == -31)

      assert %Zipper{focus: actual} = Zipper.first_extended_cousin(z, predicate)
      assert -31 == actual.term
    end
  end

  describe "last_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.last_extended_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.last_extended_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.last_extended_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.last_extended_cousin(z) == nil
    end

    test "should return the same value as Zipper.last_first_cousin/2 when no further extended cousins exist",
         %{z_with_1st_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.last_first_cousin(z)

      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 30
    end

    test "should return the same value as Zipper.last_second_cousin/2 when no further extended cousins exist",
         %{z_with_2nd_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.last_second_cousin(z)

      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 58
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           z_with_1st_cousins: z_1,
           z_with_2nd_cousins: z_2,
           z_with_extended_cousins: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.last_extended_cousin(z, predicate) == nil
      end
    end

    test "should return the last extended cousin found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z)
      assert 108 == actual.term
    end

    test "should return the last extended cousin found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 106)

      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z, predicate)
      assert 106 == actual.term
    end

    test "should return the last extended cousin found in scenario 2",
         %{z_with_extended_cousins_2: z} do
      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z)
      assert 31 == actual.term
    end

    test "should return the last extended cousin found matching the predicate in scenario 2",
         %{z_with_extended_cousins_2: z} do
      predicate = &(&1.term == 29)

      assert %Zipper{focus: actual} = Zipper.last_extended_cousin(z, predicate)
      assert 29 == actual.term
    end
  end

  describe "previous_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.previous_extended_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.previous_extended_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.previous_extended_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.previous_extended_cousin(z) == nil
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           z_with_1st_cousins: z_1,
           z_with_2nd_cousins: z_2,
           z_with_extended_cousins: z_3
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3] do
        assert Zipper.previous_extended_cousin(z, predicate) == nil
      end
    end

    test "should return the same value as Zipper.previous_first_cousin/2 when no further extended cousins exist",
         %{z_with_1st_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.previous_first_cousin(z)

      assert %Zipper{focus: actual} = Zipper.previous_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 24
    end

    test "should return the same value as Zipper.previous_second_cousin/2 when no further extended cousins exist",
         %{z_with_2nd_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.previous_second_cousin(z)

      assert %Zipper{focus: actual} = Zipper.previous_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 49
    end

    test "should return the next extended cousin found",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: actual} = Zipper.previous_extended_cousin(z)
      assert 102 == actual.term
    end

    test "should return the next extended cousin found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 103)

      actual = Zipper.previous_extended_cousin(z, predicate)
      assert 103 == actual.focus.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{z_with_extended_cousins_2: z} do
      actual = Zipper.previous_extended_cousin(z)
      assert -31 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate in scenario 2",
         %{z_with_extended_cousins_2: z} do
      predicate = &(&1.term == -29)

      actual = Zipper.previous_extended_cousin(z, predicate)
      assert -29 == actual.focus.term
    end
  end

  describe "next_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_z: z} do
      assert Zipper.next_extended_cousin(z) == nil
    end

    test "should return nil if no grandparent found", %{z_with_parent: z} do
      assert Zipper.next_extended_cousin(z) == nil
    end

    test "should return nil if grandparent has no siblings", %{z_with_grandparent: z} do
      assert Zipper.next_extended_cousin(z) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{z_with_grandpiblings: z} do
      assert Zipper.next_extended_cousin(z) == nil
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           z_with_1st_cousins: z_1,
           z_with_2nd_cousins: z_2,
           z_with_extended_cousins: z_3,
           z_with_extended_cousins_2: z_4
         } do
      predicate = &(&1.term == :not_found)

      for z <- [z_1, z_2, z_3, z_4] do
        assert Zipper.next_extended_cousin(z, predicate) == nil
      end
    end

    test "should return the same value as Zipper.next_first_cousin/2 when no further extended cousins exist",
         %{z_with_1st_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.next_first_cousin(z)

      assert %Zipper{focus: actual} = Zipper.next_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 25
    end

    test "should return the same value matching predicate as Zipper.next_first_cousin/2 when no further extensions exist",
         %{
           z_with_1st_cousins: z
         } do
      predicate = &(&1.term == 29)

      assert %Zipper{focus: expected} = Zipper.next_first_cousin(z, predicate)

      assert %Zipper{focus: actual} = Zipper.next_extended_cousin(z, predicate)

      assert actual.term == expected.term
      assert 29 == actual.term
    end

    test "should return the same value as Zipper.next_second_cousin/2 when no further extended cousins exist",
         %{z_with_2nd_cousins: z} do
      assert %Zipper{focus: expected} = Zipper.next_second_cousin(z)

      assert %Zipper{focus: actual} = Zipper.next_extended_cousin(z)

      assert actual.term == expected.term
      assert actual.term == 52
    end

    test "should return the same value matching predicate as Zipper.next_second_cousin/2 when no further extensions exist",
         %{
           z_with_2nd_cousins: z
         } do
      for target <- 52..58 do
        predicate = &(&1.term == target)

        assert %Zipper{focus: expected} = Zipper.next_second_cousin(z, predicate)

        assert %Zipper{focus: actual} = Zipper.next_extended_cousin(z, predicate)

        assert actual.term == expected.term
        assert target == actual.term
      end
    end

    test "should return the next extended cousin found",
         %{z_with_extended_cousins: z} do
      actual = Zipper.next_extended_cousin(z)
      assert 105 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate",
         %{z_with_extended_cousins: z} do
      predicate = &(&1.term == 107)

      actual = Zipper.next_extended_cousin(z, predicate)
      assert 107 == actual.focus.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{z_with_extended_cousins_2: z} do
      actual = Zipper.next_extended_cousin(z)
      assert 29 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate in scenario 2",
         %{z_with_extended_cousins_2: z} do
      predicate = &(&1.term == 31)

      actual = Zipper.next_extended_cousin(z, predicate)
      assert 31 == actual.focus.term
    end
  end
end
