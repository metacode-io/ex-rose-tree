defmodule RoseTree.Zipper.Kin.DirectDescendantTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup_all do
    %{
      empty_ctx: Zippers.empty_ctx(),
      leaf_ctx: Zippers.leaf_ctx(),
      simple_ctx: Zipper.simple_ctx(),
      ctx_with_grandchildren: Zipper.ctx_with_grandchildren(),
      ctx_with_grandchildren_2: Zipper.ctx_with_grandchildren_2(),
      ctx_with_great_grandchildren: Zipper.ctx_with_great_grandchildren(),
      ctx_with_great_grandchildren_2: Zipper.ctx_with_great_grandchildren_2()
    }
  end

  describe "first_child/2" do
    test "should return nil when given a Context with an empty focus", %{empty_ctx: ctx} do
      assert Kin.first_child(ctx) == nil
    end

    test "should return nil when given a Context with a leaf focus", %{leaf_ctx: ctx} do
      assert Kin.first_child(ctx) == nil
    end

    test "should return nil when given a predicate that does not match any children of the Context",
         %{simple_ctx: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.first_child(ctx, predicate) == nil
    end
  end

  describe "last_child/2" do
    test "should return nil when given a Context with an empty focus", %{empty_ctx: ctx} do
      assert Kin.last_child(ctx) == nil
    end

    test "should return nil when given a Context with a leaf focus", %{leaf_ctx: ctx} do
      assert Kin.last_child(ctx) == nil
    end

    test "should return nil when given a predicate that does not match any children of the Context",
         %{simple_ctx: ctx} do
      predicate = &(&1.term == :not_found)

      assert Kin.last_child(ctx, predicate) == nil
    end
  end

  describe "child_at/1" do
    test "should return nil when given a Context with an empty focus", %{empty_ctx: ctx} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Kin.child_at(ctx, idx) == nil
      end
    end

    test "should return nil when given a Context with a leaf focus", %{leaf_ctx: ctx} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Kin.child_at(ctx, idx) == nil
      end
    end

    test "should return nil when given a index that is out of bounds for the children of the Context",
         %{simple_ctx: ctx} do
      num_children = Enum.count(ctx.focus.children)

      for _ <- 0..5 do
        idx = Enum.random(num_children..10)
        assert Kin.child_at(ctx, idx) == nil
      end
    end
  end

  describe "first_grandchild/2" do
    test "should return the first grandchild that is found for the Context", %{
      ctx_with_grandchildren: ctx_1,
      ctx_with_grandchildren_2: ctx_2
    } do
      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.first_grandchild(ctx)
        assert 4 == actual.focus.term
      end
    end

    test "should return the first grandchild that is found that matches the predicate for the Context",
         %{ctx_with_grandchildren: ctx_1, ctx_with_grandchildren_2: ctx_2} do
      predicate = &(&1.term > 7)

      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.first_grandchild(ctx, predicate)
        assert 8 == actual.focus.term
      end
    end

    test "should return nil if Context has children but no grandchildren", %{simple_ctx: ctx} do
      assert Kin.first_grandchild(ctx) == nil
    end

    test "should return nil if Context has no children", %{leaf_ctx: ctx} do
      assert Kin.first_grandchild(ctx) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Context",
         %{ctx_with_grandchildren: ctx_1, ctx_with_grandchildren_2: ctx_2} do
      predicate = &(&1.term == 20)

      for ctx <- [ctx_1, ctx_2] do
        assert Kin.first_grandchild(ctx, predicate) == nil
      end
    end
  end

  describe "last_grandchild/2" do
    test "should return the last grandchild that is found for the Context", %{
      ctx_with_grandchildren: ctx_1,
      ctx_with_grandchildren_2: ctx_2
    } do
      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.last_grandchild(ctx)
        assert 12 == actual.focus.term
      end
    end

    test "should return the last grandchild that is found that matches the predicate for the Context",
         %{ctx_with_grandchildren: ctx_1, ctx_with_grandchildren_2: ctx_2} do
      predicate = &(&1.term < 9)

      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.last_grandchild(ctx, predicate)
        assert 8 == actual.focus.term
      end
    end

    test "should return nil if Context has children but no grandchildren", %{simple_ctx: ctx} do
      assert Kin.last_grandchild(ctx) == nil
    end

    test "should return nil if Context has no children", %{leaf_ctx: ctx} do
      assert Kin.last_grandchild(ctx) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Context",
         %{ctx_with_grandchildren: ctx_1, ctx_with_grandchildren_2: ctx_2} do
      predicate = &(&1.term == 20)

      for ctx <- [ctx_1, ctx_2] do
        assert Kin.last_grandchild(ctx, predicate) == nil
      end
    end
  end

  describe "first_great_grandchild/2" do
    test "should return the first great grandchild that is found for the Context", %{
      ctx_with_great_grandchildren: ctx_1,
      ctx_with_great_grandchildren_2: ctx_2
    } do
      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.first_great_grandchild(ctx)
        assert 13 == actual.focus.term
      end
    end

    test "should return the first grandchild that is found that matches the predicate for the Context",
         %{ctx_with_great_grandchildren: ctx_1, ctx_with_great_grandchildren_2: ctx_2} do
      predicate = &(&1.term > 16)

      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.first_great_grandchild(ctx, predicate)
        assert 17 == actual.focus.term
      end
    end

    test "should return nil if Context has children but no grandchildren", %{simple_ctx: ctx} do
      assert Kin.first_great_grandchild(ctx) == nil
    end

    test "should return nil if Context has no children", %{leaf_ctx: ctx} do
      assert Kin.first_great_grandchild(ctx) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Context",
         %{ctx_with_great_grandchildren: ctx_1, ctx_with_great_grandchildren_2: ctx_2} do
      predicate = &(&1.term == 30)

      for ctx <- [ctx_1, ctx_2] do
        assert Kin.first_great_grandchild(ctx, predicate) == nil
      end
    end
  end

  describe "last_great_grandchild/2" do
    test "should return the last great grandchild that is found for the Context", %{
      ctx_with_great_grandchildren: ctx_1,
      ctx_with_great_grandchildren_2: ctx_2
    } do
      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.last_great_grandchild(ctx)
        assert 21 == actual.focus.term
      end
    end

    test "should return the last grandchild that is found that matches the predicate for the Context",
         %{ctx_with_great_grandchildren: ctx_1, ctx_with_great_grandchildren_2: ctx_2} do
      predicate = &(&1.term < 18)

      for ctx <- [ctx_1, ctx_2] do
        actual = Kin.last_great_grandchild(ctx, predicate)
        assert 17 == actual.focus.term
      end
    end

    test "should return nil if Context has children but no grandchildren", %{simple_ctx: ctx} do
      assert Kin.last_great_grandchild(ctx) == nil
    end

    test "should return nil if Context has no children", %{leaf_ctx: ctx} do
      assert Kin.last_great_grandchild(ctx) == nil
    end

    test "should return nil if no grandchild is found that matches the predicate for the Context",
         %{ctx_with_great_grandchildren: ctx_1, ctx_with_great_grandchildren_2: ctx_2} do
      predicate = &(&1.term == 30)

      for ctx <- [ctx_1, ctx_2] do
        assert Kin.last_great_grandchild(ctx, predicate) == nil
      end
    end
  end
end
