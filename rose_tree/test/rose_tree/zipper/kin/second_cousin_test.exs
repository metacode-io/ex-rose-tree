defmodule RoseTree.Zipper.SecondCousinTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup_all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_parent: Zippers.ctx_with_parent(),
      ctx_with_grandparent: Zippers.ctx_with_grandparent(),
      ctx_with_piblings: Zippers.ctx_with_piblings(),
      ctx_with_grandpiblings: Zippers.ctx_with_grandpiblings(),
      ctx_with_2nd_cousins: Zippers.ctx_with_2nd_cousins()
    }
  end

  describe "first_second_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.first_second_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.first_second_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.first_second_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.first_second_cousin(ctx) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{ctx_with_2nd_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_second_cousin(ctx, predicate) == nil
    end

    test "should return the first second-cousin found", %{
      ctx_with_2nd_cousins: ctx
    } do
      actual = Kin.first_second_cousin(ctx)
      assert 50 == actual.focus.term
    end

    test "should return the first second-cousin matching the predicate", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 45)

      actual = Kin.first_second_cousin(ctx, predicate)
      assert 45 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 58)

      assert Kin.first_second_cousin(ctx, predicate) == nil
    end
  end

  describe "last_second_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.last_second_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.last_second_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.last_second_cousin(ctx) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.last_second_cousin(ctx) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{ctx_with_2nd_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_second_cousin(ctx, predicate) == nil
    end

    test "should return the last second-cousin found", %{
      ctx_with_2nd_cousins: ctx
    } do
      actual = Kin.last_second_cousin(ctx)
      assert 58 == actual.focus.term
    end

    test "should return the last second-cousin matching the predicate", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 55)

      actual = Kin.last_second_cousin(ctx, predicate)
      assert 55 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           ctx_with_2nd_cousins: ctx
         } do
      predicate = &(&1.term == 45)

      assert Kin.last_second_cousin(ctx, predicate) == nil
    end
  end

  describe "previous_second_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_second_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.previous_second_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.previous_second_cousin(ctx) == nil
    end

    test "should return nil if no previous grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.previous_second_cousin(ctx) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{ctx_with_2nd_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_second_cousin(ctx, predicate) == nil
    end

    test "should return the first previous second-cousin found", %{
      ctx_with_2nd_cousins: ctx
    } do
      actual = Kin.previous_second_cousin(ctx)
      assert 49 == actual.focus.term
    end

    test "should return the first previous second-cousin matching the predicate", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 49)

      actual = Kin.previous_second_cousin(ctx, predicate)
      assert 49 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 54)

      assert Kin.previous_second_cousin(ctx, predicate) == nil
    end
  end

  describe "next_second_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_second_cousin(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.next_second_cousin(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.next_second_cousin(ctx) == nil
    end

    test "should return nil if no next grandpibling has children",
         %{ctx_with_grandpiblings: ctx} do
      assert Kin.next_second_cousin(ctx) == nil
    end

    test "should return nil if no second-cousin found matching predicate",
         %{ctx_with_2nd_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_second_cousin(ctx, predicate) == nil
    end

    test "should return the next second-cousin found", %{
      ctx_with_2nd_cousins: ctx
    } do
      actual = Kin.next_second_cousin(ctx)
      assert 52 == actual.focus.term
    end

    test "should return the next second-cousin matching the predicate", %{
      ctx_with_2nd_cousins: ctx
    } do
      predicate = &(&1.term == 55)

      actual = Kin.next_second_cousin(ctx, predicate)
      assert 55 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           ctx_with_2nd_cousins: ctx
         } do
      predicate = &(&1.term == 45)

      assert Kin.next_second_cousin(ctx, predicate) == nil
    end
  end
end
