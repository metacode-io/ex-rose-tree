defmodule RoseTree.Zipper.TraversalTest do
  use ExUnit.Case

  alias RoseTree.Support.{Generators, Zippers}
  alias RoseTree.Zipper.{Context, Traversal}

  doctest RoseTree.Zipper.Traversal

  setup_all do
    %{
      empty_ctx: Zippers.empty_ctx(),
      leaf_ctx: Zippers.leaf_ctx(),
      simple_ctx: Zippers.simple_ctx(),
      ctx_with_parent: Zippers.ctx_with_parent(),
      ctx_with_grandchildren: Zippers.ctx_with_grandchildren(),
      ctx_with_siblings: Zippers.ctx_with_siblings(),
      ctx_with_ancestral_piblings: Zippers.ctx_with_ancestral_piblings(),
      ctx_with_descendant_niblings: Zippers.ctx_with_descendant_niblings()
    }
  end

  describe "descend/1" do
    test "should return nil if given an empty Context with no siblings", %{empty_ctx: ctx} do
      assert Traversal.descend(ctx) == nil
    end

    test "should return nil if given a leaf Context with no siblings", %{leaf_ctx: ctx} do
      assert Traversal.descend(ctx) == nil
    end

    test "should return the first child if given a Context with children", %{simple_ctx: ctx} do
      assert %Context{focus: focus} = Traversal.descend(ctx)
      assert 2 == focus.term
    end

    test "should return the next sibling if given a Context with no children but with next siblings",
         %{ctx_with_siblings: ctx} do
      assert %Context{focus: focus} = Traversal.descend(ctx)
      assert 6 == focus.term
    end

    test "should return the next ancestral pibling if given a Context with no children or siblings, but with next piblings",
         %{ctx_with_ancestral_piblings: ctx} do
      assert %Context{focus: focus} = Traversal.descend(ctx)
      assert 6 == focus.term
    end
  end

  describe "descend_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_ctx: ctx} do
      for reps <- 0..-5 do
        assert Traversal.descend_for(ctx, reps) == nil
      end
    end

    test "should return nil if given a Context with no depth-first descendants", %{leaf_ctx: ctx} do
      for reps <- 1..5 do
        assert Traversal.descend_for(ctx, reps) == nil
      end
    end

    test "should return correct result of descending x number of times", %{
      ctx_with_grandchildren: ctx
    } do
      expected_results = [1, 4, 5, 6, 2, 7, 8, 9, 3, 10]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Context{focus: focus} = Traversal.descend_for(ctx, reps),
                 "Expected a new Context for #{reps} reps "

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "descend_if/2" do
    test "should return nil if there are no descendants", %{leaf_ctx: ctx} do
      assert Traversal.descend_if(ctx, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_ctx: ctx} do
      assert Traversal.descend_if(ctx, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new context if the given predicate matches", %{simple_ctx: ctx} do
      assert %Context{focus: focus} = Traversal.descend_if(ctx, &(&1.focus.term == 2))
      assert focus.term == 2
    end
  end

  describe "descend_until/2" do
    test "should return nil if there are no descendants", %{leaf_ctx: ctx} do
      assert Traversal.descend_until(ctx, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_ctx: ctx} do
      assert Traversal.descend_until(ctx, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new context if the given predicate is eventually matched", %{
      ctx_with_grandchildren: ctx
    } do
      assert %Context{focus: focus} = Traversal.descend_until(ctx, &(&1.focus.term == 12))
      assert focus.term == 12
    end
  end

  describe "ascend/1" do
    test "should return nil if given a Context with no parents or siblings", %{simple_ctx: ctx} do
      assert Traversal.ascend(ctx) == nil
    end

    test "should return the parent if given a Context with parents and no previous siblings", %{
      ctx_with_parent: ctx
    } do
      assert %Context{focus: focus} = Traversal.ascend(ctx)
      assert 10 == focus.term
    end

    test "should return the previous sibling if given a Context with parent and previous siblings that have no children",
         %{ctx_with_siblings: ctx} do
      ctx = Generators.add_zipper_locations(ctx, num_locations: 1)
      assert %Context{focus: focus} = Traversal.ascend(ctx)
      assert 4 == focus.term
    end

    test "should return the previous descendant nibling if given a Context with parent and previous siblings with children",
         %{ctx_with_descendant_niblings: ctx} do
      assert %Context{focus: focus} = Traversal.ascend(ctx)
      assert 25 == focus.term
    end
  end

  describe "ascend_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_ctx: ctx} do
      for reps <- 0..-5 do
        assert Traversal.ascend_for(ctx, reps) == nil
      end
    end

    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_ctx: ctx
    } do
      for reps <- 1..5 do
        assert Traversal.ascend_for(ctx, reps) == nil
      end
    end

    test "should return correct result of ascending x number of times", %{
      ctx_with_descendant_niblings: ctx
    } do
      new_ctx = Traversal.descend_for(ctx, 10)

      expected_results = [32, 14, 31, 30, 38, 37, 29, 13, 7, 5]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Context{focus: focus} = Traversal.ascend_for(new_ctx, reps),
                 "Expected a new Context for #{reps} reps "

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "ascend_if/2" do
    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_ctx: ctx
    } do
      assert Traversal.ascend_if(ctx, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{
      ctx_with_descendant_niblings: ctx
    } do
      assert Traversal.ascend_if(ctx, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new context if the given predicate matches", %{
      ctx_with_descendant_niblings: ctx
    } do
      assert %Context{focus: focus} = Traversal.ascend_if(ctx, &(&1.focus.term == 25))
      assert focus.term == 25
    end
  end

  describe "ascend_until/2" do
    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_ctx: ctx
    } do
      assert Traversal.ascend_until(ctx, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{
      ctx_with_descendant_niblings: ctx
    } do
      assert Traversal.ascend_until(ctx, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new context if the given predicate is eventually matched", %{
      ctx_with_descendant_niblings: ctx
    } do
      assert %Context{focus: focus} = Traversal.ascend_until(ctx, &(&1.focus.term == 12))
      assert focus.term == 12
    end
  end
end
