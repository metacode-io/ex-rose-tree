defmodule RoseTree.Zipper.KinTest do
  use ExUnit.Case, async: true
  use RoseTree.ZipperContextCase

  alias RoseTree.Zipper.Kin

  doctest RoseTree.Zipper.Kin

  ## ANCESTORS

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

  ## DESCENDANTS

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

  ## SIBLINGS

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

  ## NIBLINGS (NIECES + NEPHEWS)

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

  ## PIBLINGS (AUNTS + UNCLES)

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

  ## FIRST COUSINS

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
end
