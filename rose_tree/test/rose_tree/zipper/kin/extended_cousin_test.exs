defmodule RoseTree.Zipper.ExtendedCousinTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.{Context, Kin}

  setup_all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_parent: Zippers.ctx_with_parent(),
      ctx_with_grandparent: Zippers.ctx_with_grandparent(),
      ctx_with_piblings: Zippers.ctx_with_piblings(),
      ctx_with_1st_cousins: Zippers.ctx_with_1st_cousins(),
      ctx_with_grandpiblings: Zippers.ctx_with_grandpiblings(),
      ctx_with_2nd_cousins: Zippers.ctx_with_2nd_cousins(),
      ctx_with_extended_cousins: Zippers.ctx_with_extended_cousins(),
      ctx_with_extended_cousins_2: Zippers.ctx_with_extended_cousins_2()
    }
  end

  describe "first_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.first_extended_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.first_extended_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.first_extended_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.first_extended_cousin(ctx) == nil
    end

    test "should return the same value as Kin.first_first_cousin/2 when no further extended cousins exist",
         %{ctx_with_1st_cousins: ctx} do
      assert %Context{focus: expected} = Kin.first_first_cousin(ctx)

      assert %Context{focus: actual} = Kin.first_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 19
    end

    test "should return the same value as Kin.first_second_cousin/2 when no further extended cousins exist",
         %{ctx_with_2nd_cousins: ctx} do
      assert %Context{focus: expected} = Kin.first_second_cousin(ctx)

      assert %Context{focus: actual} = Kin.first_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 50
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           ctx_with_1st_cousins: ctx_1,
           ctx_with_2nd_cousins: ctx_2,
           ctx_with_extended_cousins: ctx_3
         } do
      predicate = &(&1.focus.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3] do
        assert Kin.first_extended_cousin(ctx, predicate) == nil
      end
    end

    test "should return the first extended cousin found",
         %{ctx_with_extended_cousins: ctx} do
      assert %Context{focus: actual} = Kin.first_extended_cousin(ctx)
      assert 103 == actual.term
    end

    test "should return the first extended cousin found matching the predicate",
         %{ctx_with_extended_cousins: ctx} do
      predicate = &(&1.focus.term == 102)

      assert %Context{focus: actual} = Kin.first_extended_cousin(ctx, predicate)
      assert 102 == actual.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      assert %Context{focus: actual} = Kin.first_extended_cousin(ctx)
      assert -29 == actual.term
    end

    # test "should return the next extended cousin found matching the predicate in scenario 2",
    #      %{ctx_with_extended_cousins_2: ctx} do
    #   predicate = &(&1.term == -31)

    #   actual = Kin.first_extended_cousin(ctx, predicate)
    #   assert -31 == actual.focus.term
    # end
  end

  describe "last_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.last_extended_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.last_extended_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.last_extended_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.last_extended_cousin(ctx) == nil
    end

    test "should return the same value as Kin.last_first_cousin/2 when no further extended cousins exist",
         %{ctx_with_1st_cousins: ctx} do
      assert %Context{focus: expected} = Kin.last_first_cousin(ctx)

      assert %Context{focus: actual} = Kin.last_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 30
    end

    test "should return the same value as Kin.last_second_cousin/2 when no further extended cousins exist",
         %{ctx_with_2nd_cousins: ctx} do
      assert %Context{focus: expected} = Kin.last_second_cousin(ctx)

      assert %Context{focus: actual} = Kin.last_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 58
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           ctx_with_1st_cousins: ctx_1,
           ctx_with_2nd_cousins: ctx_2,
           ctx_with_extended_cousins: ctx_3
         } do
      predicate = &(&1.focus.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3] do
        assert Kin.last_extended_cousin(ctx, predicate) == nil
      end
    end

    test "should return the last extended cousin found",
         %{ctx_with_extended_cousins: ctx} do
      assert %Context{focus: actual} = Kin.last_extended_cousin(ctx)
      assert 108 == actual.term
    end

    test "should return the last extended cousin found matching the predicate",
         %{ctx_with_extended_cousins: ctx} do
      predicate = &(&1.focus.term == 106)

      assert %Context{focus: actual} = Kin.last_extended_cousin(ctx, predicate)
      assert 106 == actual.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      assert %Context{focus: actual} = Kin.last_extended_cousin(ctx)
      assert 31 == actual.term
    end

    # test "should return the next extended cousin found matching the predicate in scenario 2",
    #      %{ctx_with_extended_cousins_2: ctx} do
    #   predicate = &(&1.term == -29)

    #   actual = Kin.last_extended_cousin(ctx, predicate)
    #   assert -29 == actual.focus.term
    # end
  end

  describe "previous_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_extended_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.previous_extended_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.previous_extended_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.previous_extended_cousin(ctx) == nil
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           ctx_with_1st_cousins: ctx_1,
           ctx_with_2nd_cousins: ctx_2,
           ctx_with_extended_cousins: ctx_3
         } do
      predicate = &(&1.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3] do
        assert Kin.previous_extended_cousin(ctx, predicate) == nil
      end
    end

    test "should return the same value as Kin.previous_first_cousin/2 when no further extended cousins exist",
         %{ctx_with_1st_cousins: ctx} do
      assert %Context{focus: expected} = Kin.previous_first_cousin(ctx)

      assert %Context{focus: actual} = Kin.previous_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 24
    end

    test "should return the same value as Kin.previous_second_cousin/2 when no further extended cousins exist",
         %{ctx_with_2nd_cousins: ctx} do
      assert %Context{focus: expected} = Kin.previous_second_cousin(ctx)

      assert %Context{focus: actual} = Kin.previous_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 49
    end

    test "should return the next extended cousin found",
         %{ctx_with_extended_cousins: ctx} do
      assert %Context{focus: actual} = Kin.previous_extended_cousin(ctx)
      assert 102 == actual.term
    end

    test "should return the next extended cousin found matching the predicate",
         %{ctx_with_extended_cousins: ctx} do
      predicate = &(&1.term == 103)

      actual = Kin.previous_extended_cousin(ctx, predicate)
      assert 103 == actual.focus.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      actual = Kin.previous_extended_cousin(ctx)
      assert -31 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      predicate = &(&1.term == -29)

      actual = Kin.previous_extended_cousin(ctx, predicate)
      assert -29 == actual.focus.term
    end
  end

  describe "next_extended_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_extended_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.next_extended_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.next_extended_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.next_extended_cousin(ctx) == nil
    end

    test "should return nil if no extended cousin found matching predicate",
         %{
           ctx_with_1st_cousins: ctx_1,
           ctx_with_2nd_cousins: ctx_2,
           ctx_with_extended_cousins: ctx_3,
           ctx_with_extended_cousins_2: ctx_4
         } do
      predicate = &(&1.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3, ctx_4] do
        assert Kin.next_extended_cousin(ctx, predicate) == nil
      end
    end

    test "should return the same value as Kin.next_first_cousin/2 when no further extended cousins exist",
         %{ctx_with_1st_cousins: ctx} do
      assert %Context{focus: expected} = Kin.next_first_cousin(ctx)

      assert %Context{focus: actual} = Kin.next_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 25
    end

    test "should return the same value matching predicate as Kin.next_first_cousin/2 when no further extensions exist",
         %{
           ctx_with_1st_cousins: ctx
         } do
      predicate = &(&1.term == 29)

      assert %Context{focus: expected} = Kin.next_first_cousin(ctx, predicate)

      assert %Context{focus: actual} = Kin.next_extended_cousin(ctx, predicate)

      assert actual.term == expected.term
      assert 29 == actual.term
    end

    test "should return the same value as Kin.next_second_cousin/2 when no further extended cousins exist",
         %{ctx_with_2nd_cousins: ctx} do
      assert %Context{focus: expected} = Kin.next_second_cousin(ctx)

      assert %Context{focus: actual} = Kin.next_extended_cousin(ctx)

      assert actual.term == expected.term
      assert actual.term == 52
    end

    test "should return the same value matching predicate as Kin.next_second_cousin/2 when no further extensions exist",
         %{
           ctx_with_2nd_cousins: ctx
         } do
      for target <- 52..58 do
        predicate = &(&1.term == target)

        assert %Context{focus: expected} = Kin.next_second_cousin(ctx, predicate)

        assert %Context{focus: actual} = Kin.next_extended_cousin(ctx, predicate)

        assert actual.term == expected.term
        assert target == actual.term
      end
    end

    test "should return the next extended cousin found",
         %{ctx_with_extended_cousins: ctx} do
      actual = Kin.next_extended_cousin(ctx)
      assert 105 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate",
         %{ctx_with_extended_cousins: ctx} do
      predicate = &(&1.term == 107)

      actual = Kin.next_extended_cousin(ctx, predicate)
      assert 107 == actual.focus.term
    end

    test "should return the next extended cousin found in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      actual = Kin.next_extended_cousin(ctx)
      assert 29 == actual.focus.term
    end

    test "should return the next extended cousin found matching the predicate in scenario 2",
         %{ctx_with_extended_cousins_2: ctx} do
      predicate = &(&1.term == 31)

      actual = Kin.next_extended_cousin(ctx, predicate)
      assert 31 == actual.focus.term
    end
  end
end
