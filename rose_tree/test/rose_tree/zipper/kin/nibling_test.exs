defmodule RoseTree.Zipper.Kin.NiblingTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.{Context, Kin}

  setup_all do
    %{
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_siblings: Zippers.ctx_with_siblings(),
      ctx_with_niblings: Zippers.ctx_with_niblings(),
      ctx_with_grand_niblings: Zippers.ctx_with_grand_niblings(),
      ctx_with_descendant_niblings: Zippers.ctx_with_descendant_niblings()
    }
  end

  describe "first_nibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.first_nibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.first_nibling(ctx) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_nibling(ctx, predicate) == nil
    end

    test "should return the first nibling", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.first_nibling(ctx)
      assert 10 == actual.focus.term
    end

    test "should return the first nibling that matches the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 11)

      actual = Kin.first_nibling(ctx, predicate)
      assert 11 == actual.focus.term
    end
  end

  describe "last_nibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.last_nibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.last_nibling(ctx) == nil
    end

    test "should return nil if no next nibling matching the predicate is found",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_nibling(ctx, predicate) == nil
    end

    test "should return the last nibling", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.last_nibling(ctx)
      assert 15 == actual.focus.term
    end

    test "should return the last nibling that matches the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 14)

      actual = Kin.last_nibling(ctx, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "previous_nibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.previous_nibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.previous_nibling(ctx) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_nibling(ctx, predicate) == nil
    end

    test "should return the previous nibling", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.previous_nibling(ctx)
      assert 12 == actual.focus.term
    end

    test "should return the previous nibling that matches the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 11)

      actual = Kin.previous_nibling(ctx, predicate)
      assert 11 == actual.focus.term
    end
  end

  describe "next_nibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.next_nibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.next_nibling(ctx) == nil
    end

    test "should return nil if no next nibling matching the predicate is found",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_nibling(ctx, predicate) == nil
    end

    test "should return the next nibling", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.next_nibling(ctx)
      assert 13 == actual.focus.term
    end

    test "should return the next nibling matching the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 14)

      actual = Kin.next_nibling(ctx, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "first_nibling_at_sibling/3" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.first_nibling_at_sibling(ctx, 3) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.first_nibling_at_sibling(ctx, 3) == nil
    end

    test "should return nil when given an index that is out of bounds for siblings",
         %{ctx_with_niblings: ctx} do
      num_siblings = Enum.count(ctx.prev) + Enum.count(ctx.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Kin.first_nibling_at_sibling(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Context's index",
         %{ctx_with_niblings: ctx} do
      current_idx = Enum.count(ctx.prev)

      assert Kin.first_nibling_at_sibling(ctx, current_idx) == nil
    end

    test "should return nil if no previous nibling matching the predicate is found for the sibling at index",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_nibling_at_sibling(ctx, 6, predicate) == nil
    end

    test "should return the first nibling for sibling at index", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.first_nibling_at_sibling(ctx, 6)
      assert 13 == actual.focus.term
    end

    test "should return the first nibling that matches the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 14)

      actual = Kin.first_nibling_at_sibling(ctx, 6, predicate)
      assert 14 == actual.focus.term
    end
  end

  describe "last_nibling_at_sibling/3" do
    test "should return nil if no siblings are found", %{simple_ctx: ctx} do
      assert Kin.last_nibling_at_sibling(ctx, 7) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.last_nibling_at_sibling(ctx, 7) == nil
    end

    test "should return nil when given an index that is out of bounds for siblings",
         %{ctx_with_niblings: ctx} do
      num_siblings = Enum.count(ctx.prev) + Enum.count(ctx.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Kin.last_nibling_at_sibling(ctx, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Context's index",
         %{ctx_with_niblings: ctx} do
      current_idx = Enum.count(ctx.prev)

      assert Kin.last_nibling_at_sibling(ctx, current_idx) == nil
    end

    test "should return nil if no next nibling matching the predicate is found for the sibling at index",
         %{ctx_with_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_nibling_at_sibling(ctx, 2, predicate) == nil
    end

    test "should return the last nibling for sibling at index", %{
      ctx_with_niblings: ctx
    } do
      actual = Kin.last_nibling_at_sibling(ctx, 2)
      assert 12 == actual.focus.term
    end

    test "should return the last nibling matching the predicate", %{
      ctx_with_niblings: ctx
    } do
      predicate = &(&1.term == 10)

      actual = Kin.last_nibling_at_sibling(ctx, 2, predicate)
      assert 10 == actual.focus.term
    end
  end

  describe "previous_grandnibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.previous_grandnibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.previous_grandnibling(ctx) == nil
    end

    test "should return nil if no siblings with grandchildren are found",
         %{ctx_with_niblings: ctx} do
      assert Kin.previous_grandnibling(ctx) == nil
    end

    test "should return nil if no previous grandnibling matching the predicate is found",
         %{ctx_with_grand_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.previous_grandnibling(ctx, predicate) == nil
    end

    test "should return the previous grandnibling", %{
      ctx_with_grand_niblings: ctx
    } do
      actual = Kin.previous_grandnibling(ctx)
      assert 20 == actual.focus.term
    end

    test "should return the previous grandnibling matching the predicate", %{
      ctx_with_grand_niblings: ctx
    } do
      predicate = &(&1.term == 21)

      actual = Kin.previous_grandnibling(ctx, predicate)
      assert 21 == actual.focus.term
    end
  end

  describe "next_grandnibling/2" do
    test "should return nil if no siblings found", %{simple_ctx: ctx} do
      assert Kin.next_grandnibling(ctx) == nil
    end

    test "should return nil if no siblings with children are found",
         %{ctx_with_siblings: ctx} do
      assert Kin.next_grandnibling(ctx) == nil
    end

    test "should return nil if no siblings with grandchildren are found",
         %{ctx_with_niblings: ctx} do
      assert Kin.next_grandnibling(ctx) == nil
    end

    test "should return nil if no next grandnibling matching the predicate is found",
         %{ctx_with_grand_niblings: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.next_grandnibling(ctx, predicate) == nil
    end

    test "should return the next grandnibling", %{
      ctx_with_grand_niblings: ctx
    } do
      actual = Kin.next_grandnibling(ctx)
      assert 26 == actual.focus.term
    end

    test "should return the next grandnibling matching the predicate", %{
      ctx_with_grand_niblings: ctx
    } do
      predicate = &(&1.term == 30)

      actual = Kin.next_grandnibling(ctx, predicate)
      assert 30 == actual.focus.term
    end
  end

  describe "previous_descendant_nibling/2" do
    test "should return nil if no previous sibling found", %{simple_ctx: ctx} do
      assert Kin.previous_descendant_nibling(ctx) == nil
    end

    test "should return nil if immediately previous sibling has no children", %{ctx_with_niblings: ctx} do
      assert Kin.previous_descendant_nibling(ctx) == nil
    end

    test "should return nil if no previous descendant nibling found matching predicate", %{
      ctx_with_descendant_niblings: ctx
    } do
      predicate = &(&1.focus.term == :not_found)

      assert Kin.previous_descendant_nibling(ctx, predicate) == nil
    end

    test "should return the last previous descendant nibling found", %{
      ctx_with_descendant_niblings: ctx
    } do
      actual = Kin.previous_descendant_nibling(ctx)
      assert 25 == actual.focus.term
    end

    test "should return the last previous descendant nibling found matching the predicate", %{
      ctx_with_descendant_niblings: ctx
    } do
      predicate = &(&1.focus.term == 12)

      assert %Context{focus: focus} = Kin.previous_descendant_nibling(ctx, predicate)
      assert 12 == focus.term
    end
  end

  describe "next_descendant_nibling/2" do
    test "should return nil if no next sibling found", %{simple_ctx: ctx} do
      assert Kin.next_descendant_nibling(ctx) == nil
    end

    test "should return nil if immediately next sibling has no children", %{ctx_with_niblings: ctx} do
      assert Kin.next_descendant_nibling(ctx) == nil
    end

    test "should return nil if no next descendant nibling found matching predicate", %{
      ctx_with_descendant_niblings: ctx
    } do
      predicate = &(&1.focus.term == :not_found)

      assert Kin.next_descendant_nibling(ctx, predicate) == nil
    end

    test "should return the last next descendant nibling found", %{
      ctx_with_descendant_niblings: ctx
    } do
      actual = Kin.next_descendant_nibling(ctx)
      assert 37 == actual.focus.term
    end

    test "should return the last next descendant nibling found matching the predicate", %{
      ctx_with_descendant_niblings: ctx
    } do
      predicate = &(&1.focus.term == 29)

      assert %Context{focus: focus} = Kin.next_descendant_nibling(ctx, predicate)
      assert 29 == focus.term
    end
  end
end
