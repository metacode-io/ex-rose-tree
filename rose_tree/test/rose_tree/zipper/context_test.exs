defmodule RoseTree.Zipper.ContextTest do
  use ExUnit.Case, async: true
  use RoseTree.ZipperContextCase

  doctest RoseTree.Zipper.Context

  @bad_contexts [
    {%{focus: %TreeNode{term: 1, children: []}, prev: [], next: [], path: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8},
    {%Context{focus: :not_a_node, prev: [], next: [], path: []}, 9},
    {%Context{focus: %TreeNode{term: 1, children: []}, prev: :not_a_list, next: [], path: []},
     10},
    {%Context{focus: %TreeNode{term: 1, children: []}, prev: [], next: :not_a_list, path: []},
     11},
    {%Context{focus: %TreeNode{term: 1, children: []}, prev: [], next: [], path: :not_a_list},
     12},
    {nil, 13}
  ]

  describe "context?/1 guard" do
    test "should return true when given a valid Context struct", %{all_contexts_with_idx: all} do
      for {ctx, idx} <- all do
        assert Context.context?(ctx) == true,
               "Expected `true` for element at index #{idx}"
      end
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_contexts do
        assert Context.context?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty?/1 guard" do
    test "should return true when given an empty Context struct", %{empty_ctx: ctx} do
      assert Context.empty?(ctx) == true
    end

    test "should return false when given a non-empty Context struct", %{simple_ctx: ctx} do
      assert Context.empty?(ctx) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_contexts do
        assert Context.empty?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "at_root?/1 guard" do
    test "should return true when given a Context with an empty path", %{simple_ctx: ctx} do
      assert Context.at_root?(ctx) == true
    end

    test "should return false when given a Context with a populated path", %{
      simple_ctx: ctx_1,
      ctx_x5: ctx_2
    } do
      new_loc = Location.new(ctx_1.focus, prev: ctx_1.prev, next: ctx_1.next)

      new_ctx = %Context{ctx_2 | path: [new_loc]}

      assert Context.at_root?(new_ctx) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_contexts do
        assert Context.at_root?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "has_children?/1 guard" do
    test "should return true when given a Context whose focus has children", %{simple_ctx: ctx} do
      assert Context.has_children?(ctx) == true
    end

    test "should return false when given a Context whose focus has no children", %{leaf_ctx: ctx} do
      assert Context.has_children?(ctx) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_contexts do
        assert Context.has_children?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "has_siblings?/1 guard" do
    test "should return true when given a Context who has previous TreeNode siblings", %{
      simple_ctx: ctx,
      simple_tree: tree
    } do
      new_ctx = %Context{ctx | prev: [tree]}

      assert Context.has_siblings?(new_ctx) == true
    end

    test "should return true when given a Context who has next TreeNode siblings", %{
      simple_ctx: ctx,
      simple_tree: tree
    } do
      new_ctx = %Context{ctx | next: [tree]}

      assert Context.has_siblings?(new_ctx) == true
    end

    test "should return true when given a Context who has both previous and next TreeNode siblings",
         %{simple_ctx: ctx, simple_tree: tree} do
      new_ctx = %Context{ctx | prev: [tree], next: [tree]}

      assert Context.has_siblings?(new_ctx) == true
    end

    test "should return false when given a Context who has neither previous or next TreeNode siblings",
         %{simple_ctx: ctx} do
      assert Context.has_siblings?(ctx) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_contexts do
        assert Context.has_siblings?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "new/2" do
    test "should raise an ArgumentError if `prev` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      previous_siblings = [tree_2, :bad_tree]

      assert_raise ArgumentError, fn -> Context.new(tree_1, prev: previous_siblings) end
    end

    test "should raise an ArgumentError if `next` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      next_siblings = [tree_2, :bad_tree]

      assert_raise ArgumentError, fn -> Context.new(tree_1, next: next_siblings) end
    end

    test "should raise an ArgumentError if `path` has invalid elements", %{
      simple_tree: tree_1,
      tree_x5: tree_2
    } do
      path = [Location.new(tree_2), :bad_location]

      assert_raise ArgumentError, fn -> Context.new(tree_1, path: path) end
    end
  end
end
