defmodule RoseTree.TreeNodeTest do
  use ExUnit.Case
  use RoseTree.TreeNodeCase

  doctest RoseTree.TreeNode

  @bad_trees [
    {%{term: "parent", children: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1,2,3], 7},
    {{1,2}, 8},
    {%TreeNode{term: "parent", children: "bad_child"}, 9},
    {nil, 10}
  ]

  @node_values [
    {%{a: "value"}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1,2,3], 7},
    {{1,2}, 8},
  ]

  describe "tree_node?/1 guard" do
    test "should return true when given a TreeNode struct", %{all_trees_with_idx: all} do
      for {tree, idx} <- all do
        assert TreeNode.tree_node?(tree) == true,
                "Expected `true` for element at index #{idx}"
      end
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_trees do
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
      for {value, idx} <- @bad_trees do
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
      for {value, idx} <- @bad_trees do
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
      for {value, idx} <- @bad_trees do
        assert TreeNode.parent?(value) == false,
                "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty/0" do
    test "should return an empty TreeNode struct", %{empty_tree: tree} do
      empty_tree = TreeNode.empty()

      assert match?(tree, empty_tree)
      assert TreeNode.empty?(empty_tree) == true
      assert %TreeNode{term: nil, children: []} = empty_tree
    end
  end

  describe "new/2 when using only the first parameter" do
    test "should return a new leaf TreeNode for any valid erlang term besides nil" do
      for {value, idx} <- @node_values do
        new_tree = TreeNode.new(value)

        assert TreeNode.leaf?(new_tree)
        assert %TreeNode{term: ^value, children: []} = new_tree
      end
    end

    test "should return a new empty TreeNode when nil is passed" do
      new_tree = TreeNode.new(nil)

      assert TreeNode.empty?(new_tree)
      assert %TreeNode{term: nil, children: []} = new_tree
    end
  end

  describe "new/2 when using both parameters" do
    test "should return a new leaf TreeNode when the second arg is an empty list" do
      new_tree = TreeNode.new(5, [])

      assert TreeNode.leaf?(new_tree)
      assert %TreeNode{term: 5, children: []} = new_tree
    end

    test "should return a new empty TreeNode when the first arg is nil and the second arg is an empty list" do
      new_tree = TreeNode.new(nil, [])

      assert TreeNode.empty?(new_tree)
      assert %TreeNode{term: nil, children: []} = new_tree
    end

    test "should return a new parent TreeNode when the second arg is a populated list of values" do
      new_tree = TreeNode.new(5, [4,3,2,1])

      assert TreeNode.parent?(new_tree)
    end

    test "should have each input child turned into a new leaf TreeNode when the second arg is a populated list" do
      input_list = [4,3,2,1]

      expected_children = for x <- input_list, do: TreeNode.new(x)

      new_tree = TreeNode.new(5, input_list)

      assert %TreeNode{term: 5, children: ^expected_children} = new_tree

      for child <- new_tree.children do
        assert TreeNode.leaf?(child) == true
      end
    end

    test "should return a new parent TreeNode with TreeNode children when the second arg is a populated list of TreeNodes" do
      input_list = for x <- 1..4, do: TreeNode.new(x)

      new_tree = TreeNode.new(5, input_list)

      assert %TreeNode{term: 5, children: ^input_list} = new_tree

      for child <- new_tree.children do
        assert TreeNode.leaf?(child) == true
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
