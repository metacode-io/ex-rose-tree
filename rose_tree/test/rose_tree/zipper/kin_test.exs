defmodule RoseTree.Zipper.KinTest do
  use ExUnit.Case, async: true
  use RoseTree.ZipperContextCase

  alias RoseTree.Zipper.Kin

  doctest RoseTree.Zipper.Kin

  describe "grandparent/1" do
    test "should return the grandparent of the current Context's focus if it has one",
         %{simple_ctx: ctx, root_loc: root_loc, loc_1: loc_1} do
      new_ctx = %Context{ctx | path: [loc_1, root_loc]}

      expected = Context.from_locations([root_loc])

      actual = Kin.grandparent(new_ctx)

      assert expected.focus.term == actual.focus.term
    end

    test "should return nil if the current Context's focus has no grandparent",
         %{simple_ctx: ctx, root_loc: root_loc} do
      new_ctx = %Context{ctx | path: [root_loc]}

      assert Kin.grandparent(new_ctx) == nil
    end
  end

  describe "great_grandparent/1" do
    test "should return the great grandparent of the current Context's focus if it has one",
         %{simple_ctx: ctx, root_loc: root_loc, loc_1: loc_1, loc_2: loc_2} do
      new_ctx = %Context{ctx | path: [loc_2, loc_1, root_loc]}

      expected = Context.from_locations([root_loc])

      actual = Kin.great_grandparent(new_ctx)

      assert expected.focus.term == actual.focus.term
    end

    test "should return nil if the current Context's focus has no great grandparent",
         %{simple_ctx: ctx, root_loc: root_loc} do
      new_ctx = %Context{ctx | path: [root_loc]}

      assert Kin.great_grandparent(new_ctx) == nil
    end
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
end
