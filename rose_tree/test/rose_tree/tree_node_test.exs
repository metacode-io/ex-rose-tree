defmodule RoseTree.TreeNodeTest do
  use ExUnit.Case
  use RoseTree.TreeNodeCase

  doctest RoseTree.TreeNode

  @bad_values [
    {%{term: "parent", children: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {%TreeNode{term: "parent", children: "bad_child"}, 7}
  ]

  describe "tree_node?/1 guard" do
    test "should return true when given a TreeNode struct", %{all_trees_with_idx: all} do
      for {tree, idx} <- all do
        assert TreeNode.tree_node?(tree) == true,
                "Expected `true` for element at index #{idx}"
      end
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_values do
        assert TreeNode.tree_node?(value) == false,
                "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty?/1 guard" do
    test "should return true when given an empty TreeNode struct", %{empty_tree: tree} do
      assert TreeNode.empty?(tree) == true
    end

    test "should return false when given a non-empty TreeNode struct", %{simple_tree: tree} do
      assert TreeNode.empty?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_values do
        assert TreeNode.empty?(value) == false,
                "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "leaf?/1 guard" do
    test "should return true when given an empty TreeNode struct", %{empty_tree: tree} do
      assert TreeNode.leaf?(tree) == true
    end

    test "should return true when given a TreeNode struct with no children", %{leaf_tree: tree} do
      assert TreeNode.leaf?(tree) == true
    end

    test "should return false when given a TreeNode struct with one or more children", %{simple_tree: tree} do
      assert TreeNode.leaf?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_values do
        assert TreeNode.leaf?(value) == false,
                "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "parent?/1 guard" do
    test "should return true when given a TreeNode struct with one or more children", %{simple_tree: tree} do
      assert TreeNode.parent?(tree) == true
    end

    test "should return false when given a TreeNode struct with no children", %{leaf_tree: tree} do
      assert TreeNode.parent?(tree) == false
    end

    test "should return false when given an empty TreeNode struct", %{empty_tree: tree} do
      assert TreeNode.parent?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_values do
        assert TreeNode.parent?(value) == false,
                "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "after implementing the Enumerable protocol" do
    setup do
      tree_node = TreeNode.new(5, [4, 3, 2, 1])

      %{tree_node: tree_node}
    end

    test "Enum.count/1 should the correct number of elements", %{tree_node: tree} do
      assert 5 = Enum.count(tree)
    end

    test "Enum.member?/1 should return `true` if a member is found", %{tree_node: tree} do
      assert true == Enum.member?(tree, 3)
    end

    test "Enum.member?/1 should return `false` if a member is NOT found", %{tree_node: tree} do
      assert false == Enum.member?(tree, 6)
    end

    test "Enum.reduce/3 should be able to reduce over each element, accumulating the application of the given function", %{tree_node: tree} do
      assert [1, 2, 3, 4, 5] = Enum.reduce(tree, [], fn t, acc -> [t | acc] end)
    end
  end
end
