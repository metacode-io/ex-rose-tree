defmodule RoseTree.Zipper.TraversalTest do
  use ExUnit.Case

  alias RoseTree.Support.Generators
  alias RoseTree.Zipper.{Context, Traversal}

  doctest RoseTree.Zipper.Traversal

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
end
