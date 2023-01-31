defmodule RoseTree.Zipper.ContextTest do
  use ExUnit.Case
  use RoseTree.ZipperContextCase

  doctest RoseTree.Zipper.Context

  describe "context?/1 guard" do
    test "should return true when given a valid Context struct", %{all_contexts_with_idx: all} do
      for {ctx, idx} <- all do
        assert Context.context?(ctx) == true,
               "Expected `true` for element at index #{idx}"
      end
    end
  end
end
