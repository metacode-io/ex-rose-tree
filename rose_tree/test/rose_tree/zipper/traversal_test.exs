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
      ctx_with_siblings: Zippers.ctx_with_siblings(),
      ctx_with_ancestral_piblings: Zippers.ctx_with_ancestral_piblings()
    }
  end

  describe "to_root/1" do
    test "should return the current Context if already at the root" do
      root_context = %Context{focus: "root"}

      actual = Traversal.to_root(root_context)

      assert root_context == actual
    end

    test "should move the Context back to the root of the tree" do
      for _ <- 1..10 do
        num_locations = Enum.random(1..20)

        some_context =
          %Context{focus: "current"}
          |> Generators.add_zipper_locations(num_locations: num_locations)

        [root_location | _] = Enum.reverse(some_context.path)

        assert %Context{focus: focus, path: []} = Traversal.to_root(some_context)
        assert focus.term == root_location.term
      end
    end
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
end
