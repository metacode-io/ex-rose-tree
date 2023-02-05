defmodule RoseTree.Zipper.FirstCousinTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup_all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_parent: Zippers.ctx_with_parent(),
      ctx_with_piblings: Zippers.ctx_with_piblings(),
      ctx_with_1st_cousins: Zippers.ctx_with_1st_cousins()
    }
  end

  describe "first_first_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.first_first_cousin(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.first_first_cousin(ctx) == nil
    end

    test "should return nil if no previous pibling has children",
         %{ctx_with_piblings: ctx} do
      assert Kin.first_first_cousin(ctx) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{ctx_with_1st_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_first_cousin(ctx, predicate) == nil
    end

    test "should return the first first-cousin found", %{
      ctx_with_1st_cousins: ctx
    } do
      actual = Kin.first_first_cousin(ctx)
      assert 19 == actual.focus.term
    end

    test "should return the first first-cousin matching the predicate", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 23)

      actual = Kin.first_first_cousin(ctx, predicate)
      assert 23 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 29)

      assert Kin.first_first_cousin(ctx, predicate) == nil
    end
  end

  describe "last_first_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.last_first_cousin(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.last_first_cousin(ctx) == nil
    end

    test "should return nil if no next pibling has children",
         %{ctx_with_piblings: ctx} do
      assert Kin.last_first_cousin(ctx) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{ctx_with_1st_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_first_cousin(ctx, predicate) == nil
    end

    test "should return the last first-cousin found", %{
      ctx_with_1st_cousins: ctx
    } do
      actual = Kin.last_first_cousin(ctx)
      assert 30 == actual.focus.term
    end

    test "should return the last first-cousin matching the predicate", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 26)

      actual = Kin.last_first_cousin(ctx, predicate)
      assert 26 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 22)

      assert Kin.last_first_cousin(ctx, predicate) == nil
    end
  end

  describe "previous_first_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_first_cousin(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.previous_first_cousin(ctx) == nil
    end

    test "should return nil if no previous pibling has children",
         %{ctx_with_piblings: ctx} do
      assert Kin.previous_first_cousin(ctx) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{ctx_with_1st_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_first_cousin(ctx, predicate) == nil
    end

    test "should return the first previous first-cousin found", %{
      ctx_with_1st_cousins: ctx
    } do
      actual = Kin.previous_first_cousin(ctx)
      assert 24 == actual.focus.term
    end

    test "should return the first first-cousin matching the predicate", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 19)

      actual = Kin.previous_first_cousin(ctx, predicate)
      assert 19 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 29)

      assert Kin.previous_first_cousin(ctx, predicate) == nil
    end
  end

  describe "next_first_cousin/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_first_cousin(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.next_first_cousin(ctx) == nil
    end

    test "should return nil if no next pibling has children",
         %{ctx_with_piblings: ctx} do
      assert Kin.next_first_cousin(ctx) == nil
    end

    test "should return nil if no first-cousin found matching predicate",
         %{ctx_with_1st_cousins: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_first_cousin(ctx, predicate) == nil
    end

    test "should return the last first-cousin found", %{
      ctx_with_1st_cousins: ctx
    } do
      actual = Kin.next_first_cousin(ctx)
      assert 25 == actual.focus.term
    end

    test "should return the last first-cousin matching the predicate", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 29)

      actual = Kin.next_first_cousin(ctx, predicate)
      assert 29 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      ctx_with_1st_cousins: ctx
    } do
      predicate = &(&1.term == 22)

      assert Kin.next_first_cousin(ctx, predicate) == nil
    end
  end
end
