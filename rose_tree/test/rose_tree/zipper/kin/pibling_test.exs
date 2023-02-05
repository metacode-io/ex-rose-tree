defmodule RoseTree.Zipper.PiblingTest do
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
      ctx_with_ancestral_piblings: Zippers.ctx_with_ancestral_piblings(),
      ctx_with_no_ancestral_piblings: Zippers.ctx_with_no_ancestral_piblings()
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
      assert Kin.first_grandpibling(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.first_grandpibling(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.first_grandpibling(ctx) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{ctx_with_grandpiblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_grandpibling(ctx, predicate) == nil
    end

    test "should return the first grandpibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.first_grandpibling(ctx)
      assert 2 == actual.focus.term
    end

    test "should return the first first grandpibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 3)

      actual = Kin.first_grandpibling(ctx, predicate)
      assert 3 == actual.focus.term
    end

    test "should return nil and not seek past the original grandparent for a predicate match", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 6)

      assert Kin.first_grandpibling(ctx, predicate) == nil
    end
  end

  describe "last_grandpibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.last_grandpibling(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.last_grandpibling(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.last_grandpibling(ctx) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{ctx_with_grandpiblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_grandpibling(ctx, predicate) == nil
    end

    test "should return the last grandpibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.last_grandpibling(ctx)
      assert 8 == actual.focus.term
    end

    test "should return the first last grandpibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 7)

      actual = Kin.last_grandpibling(ctx, predicate)
      assert 7 == actual.focus.term
    end

    test "should return nil and not seek before the original grandparent for a predicate match",
         %{
           ctx_with_grandpiblings: ctx
         } do
      predicate = &(&1.term == 3)

      assert Kin.last_grandpibling(ctx, predicate) == nil
    end
  end

  describe "previous_grandpibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_grandpibling(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.previous_grandpibling(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.previous_grandpibling(ctx) == nil
    end

    test "should return nil if no previous grandpibling found matching the predicate",
         %{ctx_with_grandpiblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_grandpibling(ctx, predicate) == nil
    end

    test "should return the previous grandpibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.previous_grandpibling(ctx)
      assert 4 == actual.focus.term
    end

    test "should return the first previous grandpibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 3)

      actual = Kin.previous_grandpibling(ctx, predicate)
      assert 3 == actual.focus.term
    end
  end

  describe "next_grandpibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_grandpibling(ctx) == nil
    end

    test "should return nil if no grandparent found", %{ctx_with_parent: ctx} do
      assert Kin.next_grandpibling(ctx) == nil
    end

    test "should return nil if grandparent has no siblings", %{ctx_with_grandparent: ctx} do
      assert Kin.next_grandpibling(ctx) == nil
    end

    test "should return nil if no next grandpibling found matching the predicate",
         %{ctx_with_grandpiblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_grandpibling(ctx, predicate) == nil
    end

    test "should return the next grandpibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.next_grandpibling(ctx)
      assert 6 == actual.focus.term
    end

    test "should return the first next grandpibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 7)

      actual = Kin.next_grandpibling(ctx, predicate)
      assert 7 == actual.focus.term
    end
  end

  describe "previous_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.previous_ancestral_pibling(ctx) == nil
    end

    test "should return nil if no ancestors have siblings", %{ctx_with_no_ancestral_piblings: ctx} do
      assert Kin.previous_ancestral_pibling(ctx) == nil
    end

    test "should return nil if no previous pibling for any ancestor found matching the predicate",
         %{
           ctx_with_piblings: ctx_1,
           ctx_with_grandpiblings: ctx_2,
           ctx_with_ancestral_piblings: ctx_3
         } do
      predicate = &(&1.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3] do
        assert Kin.previous_ancestral_pibling(ctx, predicate) == nil
      end
    end

    test "should return the first previous ancestral pibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.previous_ancestral_pibling(ctx)
      assert 4 == actual.focus.term
    end

    test "should return the first previous pibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 3)

      actual = Kin.previous_ancestral_pibling(ctx, predicate)
      assert 3 == actual.focus.term
    end
  end

  describe "next_ancestral_pibling/2" do
    test "should return nil if no parent found", %{simple_ctx: ctx} do
      assert Kin.next_ancestral_pibling(ctx) == nil
    end

    test "should return nil if no ancestors have siblings", %{ctx_with_no_ancestral_piblings: ctx} do
      assert Kin.next_ancestral_pibling(ctx) == nil
    end

    test "should return nil if no next pibling for any ancestor found matching the predicate",
         %{
           ctx_with_piblings: ctx_1,
           ctx_with_grandpiblings: ctx_2,
           ctx_with_ancestral_piblings: ctx_3
         } do
      predicate = &(&1.term == :not_found)

      for ctx <- [ctx_1, ctx_2, ctx_3] do
        assert Kin.next_ancestral_pibling(ctx, predicate) == nil
      end
    end

    test "should return the first next ancestral pibling found", %{
      ctx_with_grandpiblings: ctx
    } do
      actual = Kin.next_ancestral_pibling(ctx)
      assert 6 == actual.focus.term
    end

    test "should return the first next ancestral pibling matching the predicate", %{
      ctx_with_grandpiblings: ctx
    } do
      predicate = &(&1.term == 7)

      actual = Kin.next_ancestral_pibling(ctx, predicate)
      assert 7 == actual.focus.term
    end
  end
end
