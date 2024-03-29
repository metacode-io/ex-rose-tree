defmodule ExRoseTreeTest do
  use ExUnit.Case
  use ExRoseTree.ExRoseTreeCase

  doctest ExRoseTree

  @bad_trees [
    {%{term: "parent", children: []}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8},
    {%ExRoseTree{term: "parent", children: "bad_child"}, 9},
    {nil, 10}
  ]

  @tree_values [
    {%{a: "value"}, 0},
    {true, 1},
    {false, 2},
    {5, 3},
    {"a word", 4},
    {6.4, 5},
    {:a_thing, 6},
    {[1, 2, 3], 7},
    {{1, 2}, 8}
  ]

  describe "rose_tree?/1 guard" do
    test "should return true when given a valid ExRoseTree struct", %{all_trees_with_idx: all} do
      for {tree, idx} <- all do
        assert ExRoseTree.rose_tree?(tree) == true,
               "Expected `true` for element at index #{idx}"
      end
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_trees do
        assert ExRoseTree.rose_tree?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty?/1 guard" do
    test "should return true when given an empty ExRoseTree struct", %{empty_tree: tree} do
      assert ExRoseTree.empty?(tree) == true
    end

    test "should return false when given a non-empty ExRoseTree struct", %{simple_tree: tree} do
      assert ExRoseTree.empty?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_trees do
        assert ExRoseTree.empty?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "leaf?/1 guard" do
    test "should return true when given an empty ExRoseTree struct", %{empty_tree: tree} do
      assert ExRoseTree.leaf?(tree) == true
    end

    test "should return true when given a ExRoseTree struct with no children", %{leaf_tree: tree} do
      assert ExRoseTree.leaf?(tree) == true
    end

    test "should return false when given a ExRoseTree struct with one or more children", %{
      simple_tree: tree
    } do
      assert ExRoseTree.leaf?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_trees do
        assert ExRoseTree.leaf?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "parent?/1 guard" do
    test "should return true when given a ExRoseTree struct with one or more children", %{
      simple_tree: tree
    } do
      assert ExRoseTree.parent?(tree) == true
    end

    test "should return false when given a ExRoseTree struct with no children", %{leaf_tree: tree} do
      assert ExRoseTree.parent?(tree) == false
    end

    test "should return false when given an empty ExRoseTree struct", %{empty_tree: tree} do
      assert ExRoseTree.parent?(tree) == false
    end

    test "should return false when given bad values" do
      for {value, idx} <- @bad_trees do
        assert ExRoseTree.parent?(value) == false,
               "Expected `false` for element at index #{idx}"
      end
    end
  end

  describe "empty/0" do
    test "should return an empty ExRoseTree struct", %{empty_tree: tree} do
      empty_tree = ExRoseTree.empty()

      assert match?(^tree, empty_tree)
      assert ExRoseTree.empty?(empty_tree) == true
      assert %ExRoseTree{term: nil, children: []} = empty_tree
    end
  end

  describe "new/2 when using only the first parameter" do
    test "should return a new leaf ExRoseTree for any valid erlang term besides nil" do
      for {value, idx} <- @tree_values do
        tree = ExRoseTree.new(value)

        assert ExRoseTree.leaf?(tree) == true,
               "Expected a leaf ExRoseTree for element at index #{idx}"

        assert %ExRoseTree{term: ^value, children: []} = tree,
               "Expected term to be #{inspect(value)} and children to be [] for element at index #{idx}"
      end
    end

    test "should return a new empty ExRoseTree when nil is passed" do
      tree = ExRoseTree.new(nil)

      assert ExRoseTree.empty?(tree) == true
      assert %ExRoseTree{term: nil, children: []} = tree
    end
  end

  describe "new/2 when using both parameters" do
    test "should return a new leaf ExRoseTree when the second arg is an empty list" do
      tree = ExRoseTree.new(5, [])

      assert ExRoseTree.leaf?(tree) == true
      assert %ExRoseTree{term: 5, children: []} = tree
    end

    test "should return a new empty ExRoseTree when the first arg is nil and the second arg is an empty list" do
      tree = ExRoseTree.new(nil, [])

      assert ExRoseTree.empty?(tree) == true
      assert %ExRoseTree{term: nil, children: []} = tree
    end

    test "should return a new parent ExRoseTree when the second arg is a populated list of values" do
      tree = ExRoseTree.new(5, [4, 3, 2, 1])

      assert ExRoseTree.parent?(tree) == true
    end

    test "should have each input child turned into a new leaf ExRoseTree when the second arg is a populated list" do
      input_list = [4, 3, 2, 1]

      expected_children = for x <- input_list, do: ExRoseTree.new(x)

      tree = ExRoseTree.new(5, input_list)

      assert %ExRoseTree{term: 5, children: ^expected_children} = tree

      for child <- tree.children, do: assert(ExRoseTree.leaf?(child) == true)
    end

    test "should return a new parent ExRoseTree with ExRoseTree children when the second arg is a populated list of ExRoseTrees" do
      input_list = for x <- 1..4, do: ExRoseTree.new(x)

      tree = ExRoseTree.new(5, input_list)

      assert %ExRoseTree{term: 5, children: ^input_list} = tree

      for child <- tree.children, do: assert(ExRoseTree.leaf?(child) == true)
    end
  end

  describe "get_term/1" do
    test "should return the term value of a ExRoseTree" do
      assert 5 = ExRoseTree.get_term(%ExRoseTree{term: 5, children: []})
    end
  end

  describe "set_term/2" do
    test "should set the term value of a ExRoseTree to the given value" do
      tree = %ExRoseTree{term: 5, children: []}

      for {value, _idx} <- @tree_values do
        updated_tree = ExRoseTree.set_term(tree, value)
        assert %ExRoseTree{term: ^value} = updated_tree
      end
    end

    test "should not modify the children of a ExRoseTree", %{simple_tree: tree} do
      updated_tree = ExRoseTree.set_term(tree, "new value")

      assert updated_tree.children == tree.children
    end
  end

  describe "map_term/2" do
    test "should call the given map_fn" do
      expected_log = "Called map_fn from map_term/2"

      map_fn = fn x ->
        Logger.info(expected_log)

        x * 2
      end

      tree = ExRoseTree.new(5)

      log =
        capture_log(fn ->
          ExRoseTree.map_term(tree, map_fn)
        end)

      assert log =~ expected_log
    end

    test "should set the term value to the result of the applied map_fn" do
      map_fn = &(&1 * 2)

      initial_term = 5

      expected_term = map_fn.(initial_term)

      tree = ExRoseTree.new(initial_term)

      updated_tree = ExRoseTree.map_term(tree, map_fn)

      assert %ExRoseTree{term: ^expected_term} = updated_tree
    end

    test "should not affect the children of the ExRoseTree when mapping the term" do
      map_fn = &(&1 * 2)

      expected_children = for x <- [4, 3, 2, 1], do: ExRoseTree.new(x)

      tree = ExRoseTree.new(5, expected_children)

      updated_tree = ExRoseTree.map_term(tree, map_fn)

      assert updated_tree.children == tree.children
    end
  end

  describe "get_children/1" do
    test "should return the list of child trees for a ExRoseTree", %{simple_tree: tree} do
      expected_children = tree.children

      assert ^expected_children = ExRoseTree.get_children(tree)
    end
  end

  describe "set_children/2" do
    test "should update a ExRoseTree to a leaf tree when passed an empty list", %{
      simple_tree: tree
    } do
      updated_tree = ExRoseTree.set_children(tree, [])

      assert ExRoseTree.leaf?(updated_tree) == true
      assert %ExRoseTree{children: []} = updated_tree
    end

    test "should update the children of a ExRoseTree to the list of elements", %{
      simple_tree: tree
    } do
      input_list = [4, 3, 2, 1]

      expected_children = for x <- input_list, do: ExRoseTree.new(x)

      updated_tree = ExRoseTree.set_children(tree, input_list)

      assert %ExRoseTree{children: ^expected_children} = updated_tree

      for child <- updated_tree.children, do: assert(ExRoseTree.leaf?(child) == true)
    end

    test "should update the children of a ExRoseTree to the list of ExRoseTree elements", %{
      simple_tree: tree
    } do
      input_list = for x <- [4, 3, 2, 1], do: ExRoseTree.new(x)

      updated_tree = ExRoseTree.set_children(tree, input_list)

      assert %ExRoseTree{children: ^input_list} = updated_tree

      for child <- updated_tree.children, do: assert(ExRoseTree.leaf?(child) == true)
    end

    test "should not modify the term value of a ExRoseTree when updating its children", %{
      simple_tree: tree
    } do
      input_list = for x <- [4, 3, 2, 1], do: ExRoseTree.new(x)

      updated_tree = ExRoseTree.set_children(tree, input_list)

      assert updated_tree.term == tree.term
    end
  end

  describe "map_children/2" do
    test "should call the given map_fn", %{simple_tree: tree} do
      expected_log = "Called map_fn from map_children/2"

      map_fn = fn %ExRoseTree{} = child ->
        Logger.info(expected_log)

        %{child | term: child.term * 2}
      end

      log =
        capture_log(fn ->
          ExRoseTree.map_children(tree, map_fn)
        end)

      assert log =~ expected_log
    end

    test "should set the children to the resulting list of children when the map_fn was applied to each",
         %{simple_tree: tree} do
      map_fn = fn %ExRoseTree{} = child -> %{child | term: child.term * 2} end

      expected_children = for x <- tree.children, do: map_fn.(x)

      updated_tree = ExRoseTree.map_children(tree, map_fn)

      assert updated_tree.children == expected_children
    end

    test "should not affect the term value of the ExRoseTree when mapping children", %{
      simple_tree: tree
    } do
      map_fn = fn %ExRoseTree{} = child -> %{child | term: child.term * 2} end

      updated_tree = ExRoseTree.map_children(tree, map_fn)

      assert updated_tree.term == tree.term
    end

    test "should raise ArgumentError if the map_fn returns a result that is not a ExRoseTree", %{
      simple_tree: tree
    } do
      map_fn = fn child -> child.term * 2 end

      assert_raise(ArgumentError, fn -> ExRoseTree.map_children(tree, map_fn) end)
    end
  end

  describe "prepend_child/2" do
    test "should create a new child from the given value and prepend it to the head of the list of children",
         %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.prepend_child(tree, 10)

      assert [^new_child | _] = updated_tree.children
    end

    test "should prepend the new child to the head of the list of children", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.prepend_child(tree, new_child)

      assert [^new_child | _] = updated_tree.children
    end

    test "should not affect the term value of the ExRoseTree", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.prepend_child(tree, new_child)

      assert updated_tree.term == tree.term
    end

    test "should not affect the other children", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.prepend_child(tree, new_child)

      [_ | rest] = updated_tree.children

      assert rest == tree.children
    end
  end

  describe "pop_first_child/1" do
    test "should return a tuple of an unchanged ExRoseTree and nil if the original has no children" do
      tree = %ExRoseTree{term: 10, children: []}

      assert {^tree, nil} = ExRoseTree.pop_first_child(tree)
    end

    test "should return a tuple of the new ExRoseTree without the popped child, and the popped child" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      assert {
               %ExRoseTree{
                 term: 10,
                 children: [
                   %ExRoseTree{term: 6, children: []},
                   %ExRoseTree{term: 4, children: []},
                   %ExRoseTree{term: 2, children: []}
                 ]
               },
               %ExRoseTree{term: 8, children: []}
             } = ExRoseTree.pop_first_child(tree)
    end
  end

  describe "append_child/2" do
    test "should create a new child from the given value and append it to the end of the list of children",
         %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.append_child(tree, 10)

      assert [^new_child | _] = Enum.reverse(updated_tree.children)
    end

    test "should append the new child to the end of the list of children", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.append_child(tree, new_child)

      assert [^new_child | _] = Enum.reverse(updated_tree.children)
    end

    test "should not affect the term value of the ExRoseTree", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.append_child(tree, new_child)

      assert updated_tree.term == tree.term
    end

    test "should not affect the other children", %{simple_tree: tree} do
      new_child = %ExRoseTree{term: 10, children: []}

      updated_tree = ExRoseTree.append_child(tree, new_child)

      [_ | rest] = Enum.reverse(updated_tree.children)

      assert Enum.reverse(rest) == tree.children
    end
  end

  describe "pop_last_child/1" do
    test "should return a tuple of an unchanged ExRoseTree and nil if the original has no children" do
      tree = %ExRoseTree{term: 10, children: []}

      assert {^tree, nil} = ExRoseTree.pop_last_child(tree)
    end

    test "should return a tuple of the new ExRoseTree without the popped child, and the popped child" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      assert {
               %ExRoseTree{
                 term: 10,
                 children: [
                   %ExRoseTree{term: 8, children: []},
                   %ExRoseTree{term: 6, children: []},
                   %ExRoseTree{term: 4, children: []}
                 ]
               },
               %ExRoseTree{term: 2, children: []}
             } = ExRoseTree.pop_last_child(tree)
    end
  end

  describe "insert_child/3" do
    test "should increase the number of children by 1" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 2, children: []}
        ]
      }

      new_child = %ExRoseTree{term: 4, children: []}

      expected_length = 2

      assert %ExRoseTree{children: children} = ExRoseTree.insert_child(tree, new_child, 1)

      assert length(children) == expected_length
    end

    test "should accept a ExRoseTree as input value and insert it unchanged" do
      tree = %ExRoseTree{term: 10, children: []}

      new_child = %ExRoseTree{term: 4, children: []}

      assert %ExRoseTree{children: [^new_child]} = ExRoseTree.insert_child(tree, new_child, 0)
    end

    test "should accept any other term as input value and insert it, turning it into a ExRoseTree" do
      tree = %ExRoseTree{term: 10, children: []}

      new_child = 4

      expected_child = %ExRoseTree{term: 4, children: []}

      assert %ExRoseTree{children: [^expected_child]} =
               ExRoseTree.insert_child(tree, new_child, 0)
    end

    test "should insert the new child at the correct index when given a positive index" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      new_child = %ExRoseTree{term: 5, children: []}

      assert %ExRoseTree{children: children} = ExRoseTree.insert_child(tree, new_child, 2)

      assert new_child == Enum.at(children, 2)
    end

    test "should insert the new child at the head when given a negative index that exceeds the count of children" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      new_child = %ExRoseTree{term: 5, children: []}

      assert %ExRoseTree{children: children} = ExRoseTree.insert_child(tree, new_child, -10)

      assert [^new_child | _] = children
    end

    test "should insert the new child at correct index starting from the back when given a negative index" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      new_child = %ExRoseTree{term: 5, children: []}

      assert %ExRoseTree{children: children} = ExRoseTree.insert_child(tree, new_child, -1)

      assert new_child == Enum.at(children, 3)
    end

    test "should insert the new child at the end when given an index that exceeds the count of children" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      new_child = %ExRoseTree{term: 5, children: []}

      assert %ExRoseTree{children: children} = ExRoseTree.insert_child(tree, new_child, 10)

      assert [^new_child | _] = Enum.reverse(children)
    end
  end

  describe "remove_child/2" do
    test "should return a tuple of an unchanged ExRoseTree and nil if the original has no children" do
      tree = %ExRoseTree{term: 10, children: []}

      assert {^tree, nil} = ExRoseTree.remove_child(tree, 5)
    end

    test "should decrease the number of children by 1" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 2, children: []}
        ]
      }

      expected_length = 0

      assert {%ExRoseTree{children: children}, _} = ExRoseTree.remove_child(tree, 0)

      assert length(children) == expected_length
    end

    test "should remove the child at the correct index when given a positive index and return updated ExRoseTree and the removed child as tuple" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      expected_tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      expected_child = %ExRoseTree{term: 4, children: []}

      assert {^expected_tree, ^expected_child} = ExRoseTree.remove_child(tree, 2)
    end

    test "should remove the child at the correct index when given a negative index and return updated ExRoseTree and the removed child as tuple" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      expected_tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      expected_child = %ExRoseTree{term: 6, children: []}

      assert {^expected_tree, ^expected_child} = ExRoseTree.remove_child(tree, -3)
    end

    test "should not remove any child when given a negative index that is greater than child count and instead return original ExRoseTree and nil as tuple" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      assert {^tree, nil} = ExRoseTree.remove_child(tree, -10)
    end

    test "should not remove any child when given a positive index that is greater than child count and instead return original ExRoseTree and nil as tuple" do
      tree = %ExRoseTree{
        term: 10,
        children: [
          %ExRoseTree{term: 8, children: []},
          %ExRoseTree{term: 6, children: []},
          %ExRoseTree{term: 4, children: []},
          %ExRoseTree{term: 2, children: []}
        ]
      }

      assert {^tree, nil} = ExRoseTree.remove_child(tree, 10)
    end
  end

  describe "unfold/2" do
    test "generates an leaf ExRoseTree when given an unfold_fn that does not generate more seeds" do
      unfold_fn = fn x -> {x, []} end

      rose_tree = ExRoseTree.unfold(3, unfold_fn)

      assert ExRoseTree.leaf?(rose_tree) == true
      assert %ExRoseTree{term: 3, children: []} = rose_tree
    end

    test "generates a parent tree when given an unfold_fn that recursively returns a new value and list of new seeds to evaluate" do
      unfold_fn = fn
        x when x > 0 -> {x, Enum.to_list(0..(x - 1))}
        x -> {x, []}
      end

      rose_tree = ExRoseTree.unfold(3, unfold_fn)

      assert ExRoseTree.parent?(rose_tree) == true
      assert %ExRoseTree{term: 3, children: children} = rose_tree
      assert Enum.count(children) > 0 == true
    end

    test "generates a tree with x number of trees when given an unfold_fn that allows specification of total trees" do
      for _ <- 1..10 do
        random_total = Generators.random_number_of_nodes()

        {initial_seed, unfold_fn} = Generators.default_init(total_nodes: random_total)

        tree = ExRoseTree.unfold(initial_seed, unfold_fn)

        assert ExRoseTree.rose_tree?(tree) == true
        assert Enum.count(tree) == random_total
      end
    end
  end

  describe "all_rose_trees?/1" do
    test "should return true when all elements in the list are tree trees" do
      list = [
        ExRoseTree.empty(),
        ExRoseTree.new(5),
        ExRoseTree.new(5, [6, 7, 8, 9]),
        ExRoseTree.new(5, [6, 7, 8, 9, ExRoseTree.new(10)])
      ]

      assert ExRoseTree.all_rose_trees?(list) == true
    end

    test "should return false when at least one element in the list is not a tree" do
      list = [
        ExRoseTree.empty(),
        ExRoseTree.new(5),
        ExRoseTree.new(5, [6, 7, 8, 9]),
        ExRoseTree.new(5, [6, 7, 8, 9, ExRoseTree.new(10)]),
        "gooby pls"
      ]

      assert ExRoseTree.all_rose_trees?(list) == false
    end
  end

  describe "after implementing the Enumerable protocol" do
    setup do
      rose_tree = ExRoseTree.new(5, [4, 3, 2, 1])

      %{rose_tree: rose_tree}
    end

    test "Enum.count/1 should return 0 for an empty ExRoseTree", %{empty_tree: tree} do
      assert 0 = Enum.count(tree)
    end

    test "Enum.count/1 should the correct number of elements", %{rose_tree: tree} do
      assert 5 = Enum.count(tree)
    end

    test "Enum.member?/1 should return `false` for an empty ExRoseTree", %{empty_tree: tree} do
      assert false == Enum.member?(tree, 5)
    end

    test "Enum.member?/1 should return `true` if a member is found", %{rose_tree: tree} do
      assert true == Enum.member?(tree, 3)
    end

    test "Enum.member?/1 should return `false` if a member is NOT found", %{rose_tree: tree} do
      assert false == Enum.member?(tree, 6)
    end

    test "Enum.slice/2 should return a list of sliced values according to the index range", %{
      simple_tree: tree
    } do
      assert [2, 3] == Enum.slice(tree, 1..2)
    end

    test "Enum.reduce/3 should be able to reduce over each element, accumulating the application of the given function",
         %{rose_tree: tree} do
      assert [1, 2, 3, 4, 5] = Enum.reduce(tree, [], fn t, acc -> [t | acc] end)
    end

    test "Enum.reduce/3 should work with the Stream module", %{simple_tree: tree} do
      stream = Stream.with_index(tree)

      assert [{tree.term, 0}] == Enum.take(stream, 1)
    end

    test "Enum.reduce/3 should work with :suspend mechanics", %{simple_tree: tree_1} do
      tree_2 = Generators.random_tree(total_trees: 4)

      list_1 = Enum.to_list(tree_1)
      list_2 = Enum.to_list(tree_2)

      expected = Enum.zip(list_1, list_2)

      actual = Enum.zip(tree_1, tree_2)

      assert expected == actual
    end
  end
end
