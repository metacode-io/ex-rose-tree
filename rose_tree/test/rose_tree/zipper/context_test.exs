defmodule RoseTree.Zipper.ContextTest do
  use ExUnit.Case
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
end
