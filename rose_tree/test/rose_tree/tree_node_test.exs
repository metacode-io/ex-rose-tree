defmodule RoseTree.TreeNodeTest do
  use ExUnit.Case

  alias RoseTree.TreeNode

  doctest RoseTree.TreeNode

  describe "after implementing the Enumerable protocol" do
    test "should be able to count each element" do
      tree = TreeNode.new(5, [4,3,2,1])

      assert 5 = Enum.count(tree)
    end

    test "should be able to test for element membership" do
      tree = TreeNode.new(5, [4,3,2,1])

      assert true == Enum.member?(tree, 3)
      assert false == Enum.member?(tree, 6)
    end

    test "should be able to reduce over each element" do
      tree = TreeNode.new(5, [4,3,2,1])

      assert [1,2,3,4,5] = Enum.reduce(tree, [], fn t, acc -> [t | acc] end)
    end
  end

end
