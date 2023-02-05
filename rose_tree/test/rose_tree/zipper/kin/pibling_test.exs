defmodule RoseTree.Zipper.PiblingTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup_all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_parent: Zippers.ctx_with_parent(),
      ctx_with_piblings: Zippers.ctx_with_piblings(),
      ctx_with_grandpiblings: Zippers.ctx_with_grandpiblings()
    }
  end

  describe "first_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.first_pibling(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.first_pibling(ctx) == nil
    end

    test "should return nil if no previous pibling found matching the predicate",
         %{ctx_with_piblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_pibling(ctx, predicate) == nil
    end

    test "should return the first pibling found", %{
      ctx_with_piblings: ctx
    } do
      actual = Kin.first_pibling(ctx)
      assert 2 == actual.focus.term
    end

    test "should return the first first pibling matching the predicate", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 4)

      actual = Kin.first_pibling(ctx, predicate)
      assert 4 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 14)

      assert Kin.first_pibling(ctx, predicate) == nil
    end
  end

  describe "last_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.last_pibling(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.last_pibling(ctx) == nil
    end

    test "should return nil if no next pibling found matching the predicate",
         %{ctx_with_piblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_pibling(ctx, predicate) == nil
    end

    test "should return the last pibling found", %{
      ctx_with_piblings: ctx
    } do
      actual = Kin.last_pibling(ctx)
      assert 18 == actual.focus.term
    end

    test "should return the first last pibling matching the predicate", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 14)

      actual = Kin.last_pibling(ctx, predicate)
      assert 14 == actual.focus.term
    end

    test "should return nil and not seek before the original parent for a predicate match", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 6)

      assert Kin.last_pibling(ctx, predicate) == nil
    end
  end

  describe "previous_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_pibling(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.previous_pibling(ctx) == nil
    end

    test "should return nil if no previous pibling found matching the predicate",
         %{ctx_with_piblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_pibling(ctx, predicate) == nil
    end

    test "should return the first previous pibling found", %{
      ctx_with_piblings: ctx
    } do
      actual = Kin.previous_pibling(ctx)
      assert 6 == actual.focus.term
    end

    test "should return the first previous pibling matching the predicate", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 4)

      actual = Kin.previous_pibling(ctx, predicate)
      assert 4 == actual.focus.term
    end
  end

  describe "next_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_pibling(ctx) == nil
    end

    test "should return nil if parent has no siblings", %{ctx_with_parent: ctx} do
      assert Kin.next_pibling(ctx) == nil
    end

    test "should return nil if no next pibling found matching the predicate",
         %{ctx_with_piblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_pibling(ctx, predicate) == nil
    end

    test "should return the first next pibling found", %{
      ctx_with_piblings: ctx
    } do
      actual = Kin.next_pibling(ctx)
      assert 14 == actual.focus.term
    end

    test "should return the first next pibling matching the predicate", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 18)

      actual = Kin.next_pibling(ctx, predicate)
      assert 18 == actual.focus.term
    end
  end

  describe "pibling_at/2" do
    test "should return nil when parent has no siblings", %{simple_ctx: ctx} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Kin.pibling_at(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that is out of bounds for the parent's siblings",
         %{ctx_with_piblings: ctx} do
      [parent | _] = ctx.path

      num_piblings = Enum.count(parent.prev) + Enum.count(parent.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_piblings..20)
        assert Kin.pibling_at(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Context's index",
         %{ctx_with_piblings: ctx} do
      [parent | _] = ctx.path

      current_idx = Enum.count(parent.prev)

      assert Kin.pibling_at(ctx, current_idx) == nil
    end

    test "should return the pibling at the given index", %{ctx_with_piblings: ctx} do
      actual = Kin.pibling_at(ctx, 0)
      assert 2 == actual.focus.term
    end
  end

  describe "first_grandpibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.first_pibling(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.first_pibling(ctx) == nil
    end

    test "should return nil if no previous pibling found matching the predicate",
         %{ctx_with_piblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_pibling(ctx, predicate) == nil
    end

    test "should return the first pibling found", %{
      ctx_with_piblings: ctx
    } do
      actual = Kin.first_pibling(ctx)
      assert 2 == actual.focus.term
    end

    test "should return the first first pibling matching the predicate", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 4)

      actual = Kin.first_pibling(ctx, predicate)
      assert 4 == actual.focus.term
    end

    test "should return nil and not seek past the original parent for a predicate match", %{
      ctx_with_piblings: ctx
    } do
      predicate = &(&1.term == 14)

      assert Kin.first_pibling(ctx, predicate) == nil
    end
  end
end
