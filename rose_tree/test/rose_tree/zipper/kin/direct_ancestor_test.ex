defmodule RoseTree.Zipper.Kin.DirectAncestorTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.Zippers
  alias RoseTree.Zipper.Kin

  setup_all do
    %{
      empty_ctx: Zippers.empty_ctx(),
      leaf_ctx: Zippers.leaf_ctx(),
      simple_ctx: Zipper.simple_ctx(),
      ctx_with_parent: Zipper.ctx_with_parent(),
      ctx_with_grandparent: Zipper.ctx_with_grandparent(),
      ctx_with_great_grandparent: Zipper.ctx_with_great_grandparent()
    }
  end

  describe "parent/1" do
    test "should return nil for empty Context", %{empty_ctx: ctx} do
      assert Kin.parent(ctx) == nil
    end

    test "should return nil for Context with no parent", %{simple_ctx: ctx} do
      assert Kin.parent(ctx) == nil
    end

    test "should move focus to parent if one is found", %{ctx_with_parent: ctx} do
      %Context{focus: focus} = Kin.parent(ctx)
      assert focus.term == 10
    end
  end

  describe "grandparent/1" do
    test "should return nil for empty Context", %{empty_ctx: ctx} do
      assert Kin.grandparent(ctx) == nil
    end

    test "should return nil for Context with no parent", %{simple_ctx: ctx} do
      assert Kin.grandparent(ctx) == nil
    end

    test "should return nil for Context with no grandparent", %{ctx_with_parent: ctx} do
      assert Kin.grandparent(ctx) == nil
    end

    test "should move focus to grandparent if one is found",
         %{ctx_with_grandparent: ctx} do
      %Context{focus: focus} = Kin.grandparent(new_ctx)

      assert focus.term == 5
    end
  end

  describe "great_grandparent/1" do
    test "should return nil for empty Context", %{empty_ctx: ctx} do
      assert Kin.great_grandparent(ctx) == nil
    end

    test "should return nil for Context with no parent", %{simple_ctx: ctx} do
      assert Kin.great_grandparent(ctx) == nil
    end

    test "should return nil for Context with no grandparent", %{ctx_with_parent: ctx} do
      assert Kin.great_grandparent(ctx) == nil
    end

    test "should return nil for Context with no great grandparent", %{ctx_with_grandparent: ctx} do
      assert Kin.great_grandparent(ctx) == nil
    end

    test "should move focus to great grandparent if one is found",
         %{ctx_with_great_grandparent: ctx} do
      %Context{focus: focus} = Kin.great_grandparent(new_ctx)

      assert focus.term == 1
    end
  end
end
