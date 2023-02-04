defmodule RoseTree.Zipper.Kin.SiblingTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_siblings: Zippers.ctx_with_siblings()
    }
  end

  describe "first_sibling/2" do
    test "should return nil if Context has no previous siblings", %{simple_ctx: ctx} do
      assert Kin.first_sibling(ctx) == nil
    end

    test "should return nil if no previous sibling is found for Context that matches the predicate",
         %{ctx_with_siblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_sibling(ctx, predicate) == nil
    end

    test "should return the first sibling node for Context", %{
      ctx_with_siblings: ctx
    } do
      actual = Kin.first_sibling(ctx)
      assert 1 == actual.focus.term
    end

    test "should return the first sibling node for Context that matches the predicate", %{
      ctx_with_siblings: ctx
    } do
      predicate = &(&1.term == 3)

      actual = Kin.first_sibling(ctx, predicate)
      assert 3 == actual.focus.term
    end

    test "should return nil and not seek past the original Context for a predicate match", %{
      ctx_with_siblings: ctx
    } do
      predicate = &(&1.term == 7)

      assert Kin.first_sibling(ctx, predicate) == nil
    end
  end

  describe "previous_sibling/2" do
    test "should return nil if Context has no previous siblings", %{simple_ctx: ctx} do
      assert Kin.previous_sibling(ctx) == nil
    end

    test "should return nil if no previous sibling is found for Context that matches the predicate",
         %{ctx_with_siblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_sibling(ctx, predicate) == nil
    end

    test "should return the previous sibling node for Context", %{
      ctx_with_siblings: ctx
    } do
      actual = Kin.previous_sibling(ctx)
      assert 4 == actual.focus.term
    end

    test "should return the first previous sibling node for Context that matches the predicate",
         %{
           ctx_with_siblings: ctx
         } do
      predicate = &(&1.term == 2)

      actual = Kin.previous_sibling(ctx, predicate)
      assert 2 == actual.focus.term
    end
  end

  describe "last_sibling/2" do
    test "should return nil if Context has no next siblings", %{simple_ctx: ctx} do
      assert Kin.last_sibling(ctx) == nil
    end

    test "should return nil if no next sibling is found for Context that matches the predicate",
         %{ctx_with_siblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_sibling(ctx, predicate) == nil
    end

    test "should return the last sibling node for Context", %{
      ctx_with_siblings: ctx
    } do
      actual = Kin.last_sibling(ctx)
      assert 9 == actual.focus.term
    end

    test "should return the last next sibling node for Context that matches the predicate", %{
      ctx_with_siblings: ctx
    } do
      predicate = &(&1.term == 7)

      actual = Kin.last_sibling(ctx, predicate)
      assert 7 == actual.focus.term
    end

    test "should return nil and not seek before the original Context for a predicate match", %{
      ctx_with_siblings: ctx
    } do
      predicate = &(&1.term == 3)

      assert Kin.last_sibling(ctx, predicate) == nil
    end
  end

  describe "next_sibling/2" do
    test "should return nil if Context has no next siblings", %{simple_ctx: ctx} do
      assert Kin.next_sibling(ctx) == nil
    end

    test "should return nil if no next sibling is found for Context that matches the predicate",
         %{ctx_with_siblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_sibling(ctx, predicate) == nil
    end

    test "should return the next sibling node for Context", %{
      ctx_with_siblings: ctx
    } do
      actual = Kin.next_sibling(ctx)
      assert 6 == actual.focus.term
    end

    test "should return the first next sibling node for Context that matches the predicate",
         %{
           ctx_with_siblings: ctx
         } do
      predicate = &(&1.term == 8)

      actual = Kin.next_sibling(ctx, predicate)
      assert 8 == actual.focus.term
    end
  end

  describe "sibling_at/2" do
    test "should return nil when given a Context with no siblings", %{simple_ctx: ctx} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Kin.sibling_at(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that is out of bounds for the siblings of the Context",
         %{ctx_with_siblings: ctx} do
      num_siblings = Enum.count(ctx.prev) + Enum.count(ctx.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Kin.sibling_at(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Context's index",
         %{ctx_with_siblings: ctx} do
      current_idx = Enum.count(ctx.prev)

      assert Kin.sibling_at(ctx, current_idx) == nil
    end
  end
end
