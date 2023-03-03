defmodule RoseTree.Zipper.ZipperTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.{Generators, Zippers}
  alias RoseTree.{Util, Zipper}
  alias RoseTree.Zipper.Location

  setup_all do
    %{
      empty_z: Zippers.empty_z(),
      leaf_z: Zippers.leaf_z(),
      simple_z: Zippers.simple_z(),
      z_with_parent: Zippers.z_with_parent(),
      z_with_grandchildren: Zippers.z_with_grandchildren(),
      z_with_great_grandparent: Zippers.z_with_great_grandparent(),
      z_with_siblings: Zippers.z_with_siblings(),
      z_with_piblings: Zippers.z_with_piblings(),
      z_with_ancestral_piblings: Zippers.z_with_ancestral_piblings(),
      z_with_niblings: Zippers.z_with_niblings(),
      z_with_descendant_niblings: Zippers.z_with_descendant_niblings(),
      z_with_extended_cousins: Zippers.z_with_extended_cousins(),
      z_with_extended_niblings: Zippers.z_with_extended_niblings(),
      z_depth_first: Zippers.z_depth_first(),
      z_depth_first_siblings: Zippers.z_depth_first_siblings(),
      z_depth_first_siblings_at_end: Zipper.descend_to_last(Zippers.z_depth_first_siblings()),
      z_breadth_first: Zippers.z_breadth_first(),
      z_breadth_first_siblings: Zippers.z_breadth_first_siblings(),
      z_breadth_first_siblings_at_end: Zipper.forward_to_last(Zippers.z_breadth_first_siblings())
    }
  end

  ## General Traversal

  describe "move_for/3" do
    test "should return nil when given a rep less than zero", %{simple_z: z} do
      assert nil == Zipper.move_for(z, &Zipper.descend/1, -5)
    end

    test "should return nil when given a req equal to zero", %{simple_z: z} do
      assert nil == Zipper.move_for(z, &Zipper.descend/1, 0)
    end

    test "should return nil when given a rep that is greater than total count of possible movements",
         %{simple_z: z} do
      assert nil == Zipper.move_for(z, &Zipper.descend/1, 50)
    end

    test "should return nil when the move_fn returns nil", %{simple_z: z} do
      nil_fn = fn _ -> nil end

      assert nil == Zipper.move_for(z, nil_fn, 2)
    end

    test "should raise CaseClauseError when the move_fn has bad return", %{simple_z: z} do
      not_a_move_fn = fn _ -> :not_a_zipper end

      assert_raise CaseClauseError, fn ->
        Zipper.move_for(z, not_a_move_fn, 2)
      end
    end

    test "should return new position when given a rep that is within movement range", %{
      z_with_grandchildren: z
    } do
      assert %Zipper{focus: actual} = Zipper.move_for(z, &Zipper.descend/1, 6)
      assert actual.term == 7
    end
  end

  describe "move_if/3" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.move_if(z, &Zipper.descend/1, not_a_predicate)
    end

    test "should return nil when the move_fn returns nil", %{simple_z: z} do
      nil_fn = fn _ -> nil end

      assert nil == Zipper.move_if(z, nil_fn, &Util.always/1)
    end

    test "should raise CaseClauseError when the move_fn has bad return", %{simple_z: z} do
      not_a_move_fn = fn _ -> :not_a_zipper end

      assert_raise CaseClauseError, fn ->
        Zipper.move_if(z, not_a_move_fn, &Util.always/1)
      end
    end

    test "should return nil if predicate returns false", %{simple_z: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.move_if(z, &Zipper.descend/1, predicate)
    end

    test "should move the focus if the predicate returns true", %{simple_z: z} do
      predicate = &(&1.focus.term == 2)

      assert %Zipper{focus: actual} = Zipper.move_if(z, &Zipper.descend/1, predicate)
      assert actual.term == 2
    end
  end

  describe "move_until/3" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.move_until(z, &Zipper.descend/1, not_a_predicate)
    end

    test "should return nil when the move_fn returns nil", %{simple_z: z} do
      nil_fn = fn _ -> nil end

      assert nil == Zipper.move_until(z, nil_fn, &Util.always/1)
    end

    test "should raise CaseClauseError when the move_fn has bad return", %{simple_z: z} do
      not_a_move_fn = fn _ -> :not_a_zipper end

      assert_raise CaseClauseError, fn ->
        Zipper.move_until(z, not_a_move_fn, &Util.always/1)
      end
    end

    test "should return nil if predicate never matches", %{simple_z: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.move_until(z, &Zipper.descend/1, predicate)
    end

    test "should move the focus if the predicate does match", %{simple_z: z} do
      predicate = &(&1.focus.term == 4)

      assert %Zipper{focus: actual} = Zipper.move_until(z, &Zipper.descend/1, predicate)
      assert actual.term == 4
    end
  end

  describe "move_while/3" do
    test "should return unchanged when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert z == Zipper.move_while(z, &Zipper.descend/1, not_a_predicate)
    end

    test "should return unchanged when the move_fn returns nil", %{simple_z: z} do
      nil_fn = fn _ -> nil end

      assert z == Zipper.move_while(z, nil_fn, &Util.always/1)
    end

    test "should raise CaseClauseError when the move_fn has bad return", %{simple_z: z} do
      not_a_move_fn = fn _ -> :not_a_zipper end

      assert_raise CaseClauseError, fn ->
        Zipper.move_while(z, not_a_move_fn, &Util.always/1)
      end
    end

    test "should return unchanged if predicate fails at the start", %{simple_z: z} do
      predicate = &(&1.focus.term == :no_match)

      assert z == Zipper.move_while(z, &Zipper.descend/1, predicate)
    end

    test "should move until the predicate stops matching", %{simple_z: z} do
      predicate = &(&1.focus.term != 3)

      assert %Zipper{focus: actual} = Zipper.move_while(z, &Zipper.descend/1, predicate)
      assert actual.term == 3
    end

    test "should move until the the move function can no longer continue", %{simple_z: z} do
      assert %Zipper{focus: actual} = Zipper.move_while(z, &Zipper.descend/1)
      assert actual.term == 4
    end
  end

  describe "find/3" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.find(z, &Zipper.descend/1, not_a_predicate)
    end

    test "should return nil when the move_fn returns nil", %{simple_z: z} do
      nil_fn = fn _ -> nil end

      assert nil == Zipper.find(z, nil_fn, &Util.never/1)
    end

    test "should raise CaseClauseError when the move_fn has bad return", %{simple_z: z} do
      not_a_move_fn = fn _ -> :not_a_zipper end

      assert_raise CaseClauseError, fn ->
        Zipper.find(z, not_a_move_fn, &Util.never/1)
      end
    end

    test "should return nil if predicate never matches", %{simple_z: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.find(z, &Zipper.descend/1, predicate)
    end

    test "should return unmoved if predicate matches at starting focus", %{simple_z: z} do
      predicate = &(&1.focus.term == 1)

      assert z == Zipper.find(z, &Zipper.descend/1, predicate)
    end

    test "should move until the predicate matches", %{simple_z: z} do
      predicate = &(&1.focus.term == 3)

      assert %Zipper{focus: actual} = Zipper.find(z, &Zipper.descend/1, predicate)
      assert actual.term == 3
    end
  end

  describe "map/3" do
    test "should return new leaf Zipper if given an empty zipper with valid map_fn", %{empty_z: z} do
      map_fn = &RoseTree.set_term(&1, 2)

      assert %Zipper{focus: actual, prev: [], next: [], path: []} =
               Zipper.map(z, &Zipper.descend/1, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
    end

    test "should raise an ArgumentError if given an invalid map_fn", %{simple_z: z} do
      bad_map_fn = fn _ -> 2 end

      assert_raise ArgumentError, fn -> Zipper.map(z, &Zipper.descend/1, bad_map_fn) end
    end

    test "should change only the focus and remain there if the move_fn returns nil immediately",
         %{simple_z: z} do
      move_fn = fn _ -> nil end
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      assert %Zipper{focus: actual, prev: prev, next: next, path: path} =
               Zipper.map(z, move_fn, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
      assert prev == z.prev
      assert next == z.next
      assert path == z.path
    end

    test "should change every node of the Zipper that lies along the move_fn's path, ending with a focus on last node visited",
         %{simple_z: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      expected_z = %Zipper{
        focus: %RoseTree{term: 8, children: []},
        prev: [
          %RoseTree{term: 6, children: []},
          %RoseTree{term: 4, children: []}
        ],
        next: [],
        path: [
          %Location{
            prev: [],
            term: 2,
            next: []
          }
        ]
      }

      assert expected_z == Zipper.map(z, &Zipper.descend/1, map_fn)
    end
  end

  describe "accumulate/4" do
    test "should return the empty Zipper and accumulator if given an empty zipper with valid acc_fn", %{empty_z: z} do
      accumulate_terms = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term | acc]
          end
        end

      assert {^z, []} = Zipper.accumulate(z, &Zipper.descend/1, [], accumulate_terms)
    end

    test "should return unmoved Zipper and accumulator if the move_fn returns nil immediately",
         %{simple_z: z} do
      move_fn = fn _ -> nil end
      acc_fn = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term * 2 | acc]
        end
      end

      assert {^z, [2]} = Zipper.accumulate(z, move_fn, [], acc_fn)
    end

    test "should accumulate every node of the Zipper that lies along the move_fn's path, ending with a focus on last node visited and the accumulated value",
         %{simple_z: z} do
      acc_fn = fn next_z, acc ->
        next_z.focus.term + acc
      end

      expected_z = %Zipper{
        focus: %RoseTree{term: 4, children: []},
        prev: [
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []}
        ],
        next: [],
        path: [
          %Location{
            prev: [],
            term: 1,
            next: []
          }
        ]
      }

      assert {^expected_z, 10} = Zipper.accumulate(z, &Zipper.descend/1, 0, acc_fn)
    end
  end

  ## Path Traversal

  describe "rewind_for/2" do
    test "should return nil if asked to rewind 0 or fewer times", %{z_with_parent: z} do
      for reps <- [0, -1] do
        assert nil == Zipper.rewind_for(z, reps)
      end
    end

    test "should return nil if asked to rewind more times than there are parents", %{simple_z: z} do
      assert nil == Zipper.rewind_for(z, 3)
    end

    test "should rewind the focus along the path n number of times", %{
      z_with_great_grandparent: z
    } do
      assert %Zipper{focus: actual} = Zipper.rewind_for(z, 3)
      assert actual.term == 1
    end
  end

  describe "rewind_if/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.rewind_if(z, not_a_predicate)
    end

    test "should return nil when parent/1 returns nil", %{simple_z: z} do
      assert nil == Zipper.rewind_if(z, &Util.always/1)
    end

    test "should return nil if predicate returns false", %{simple_z: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.rewind_if(z, predicate)
    end

    test "should move the focus if the predicate returns true", %{z_with_parent: z} do
      predicate = &(&1.focus.term == 10)

      assert %Zipper{focus: actual} = Zipper.rewind_if(z, predicate)
      assert actual.term == 10
    end
  end

  describe "rewind_until/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.rewind_until(z, not_a_predicate)
    end

    test "should return nil when no parents to rewind", %{simple_z: z} do
      assert nil == Zipper.rewind_until(z, &Util.always/1)
    end

    test "should return nil if predicate never matches", %{z_with_parent: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.rewind_until(z, predicate)
    end

    test "should move the focus if the predicate does match", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term == 1)

      assert %Zipper{focus: actual} = Zipper.rewind_until(z, predicate)
      assert actual.term == 1
    end
  end

  describe "rewind_while/2" do
    test "should return unchanged when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert z == Zipper.rewind_while(z, not_a_predicate)
    end

    test "should return unchanged when no parents", %{simple_z: z} do
      assert z == Zipper.rewind_while(z, &Util.always/1)
    end

    test "should return unchanged if predicate fails at the start", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term == :no_match)

      assert z == Zipper.rewind_while(z, predicate)
    end

    test "should move until the predicate stops matching", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term != 5)

      assert %Zipper{focus: actual} = Zipper.rewind_while(z, predicate)
      assert actual.term == 5
    end

    test "should move until the the move function can no longer continue", %{z_with_great_grandparent: z} do
      assert %Zipper{focus: actual} = Zipper.rewind_while(z)
      assert actual.term == 1
    end
  end

  describe "rewind_to_root/1" do
    test "should return the current Zipper if already at the root" do
      root = %Zipper{focus: "root"}

      actual = Zipper.rewind_to_root(root)

      assert root == actual
    end

    test "should move the Zipper back to the root of the tree" do
      for _ <- 1..10 do
        num_locations = Enum.random(1..20)

        some_zipper =
          %Zipper{focus: "current"}
          |> Generators.add_zipper_locations(num_locations: num_locations)

        [root_location | _] = Enum.reverse(some_zipper.path)

        assert %Zipper{focus: focus, path: []} = Zipper.rewind_to_root(some_zipper)
        assert focus.term == root_location.term
      end
    end
  end

  describe "rewind_find/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.rewind_find(z, not_a_predicate)
    end

    test "should return nil when no parent", %{simple_z: z} do
      assert nil == Zipper.rewind_find(z, &Util.never/1)
    end

    test "should return nil if predicate never matches", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.rewind_find(z, predicate)
    end

    test "should return unmoved if predicate matches at starting focus", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term == 20)

      assert z == Zipper.rewind_find(z, predicate)
    end

    test "should move until the predicate matches if match isn't found at starting focus", %{z_with_great_grandparent: z} do
      predicate = &(&1.focus.term == 5)

      assert %Zipper{focus: actual} = Zipper.rewind_find(z, predicate)
      assert actual.term == 5
    end
  end

  describe "rewind_map/2" do
    test "should return new leaf Zipper if given an empty zipper with valid map_fn", %{empty_z: z} do
      map_fn = &RoseTree.set_term(&1, 2)

      assert %Zipper{focus: actual, prev: [], next: [], path: []} =
               Zipper.rewind_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
    end

    test "should change only the focus and remain there if no parents",
         %{simple_z: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      assert %Zipper{focus: actual, prev: prev, next: next, path: path} =
               Zipper.rewind_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
      assert prev == z.prev
      assert next == z.next
      assert path == z.path
    end

    test "should change every node of the Zipper that lies along the path, ending with a focus on last node visited",
         %{z_with_great_grandparent: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{
          term: 2,
          children: [
            %RoseTree{
              term: 10,
              children: [
                %RoseTree{term: 20, children: [
                  %RoseTree{term: 40, children: []}
                ]}
              ]
            }
          ]
        },
        prev: [],
        next: [],
        path: []
      }

      assert expected_z == Zipper.rewind_map(z, map_fn)
    end
  end

  describe "rewind_accumulate/3" do
    test "should return the empty Zipper and accumulator if given an empty zipper with valid acc_fn", %{empty_z: z} do
      accumulate_terms = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term | acc]
          end
        end

      assert {^z, []} = Zipper.rewind_accumulate(z, [], accumulate_terms)
    end

    test "should return unmoved Zipper and accumulator if no parent",
         %{simple_z: z} do
      acc_fn = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term * 2 | acc]
        end
      end

      assert {^z, [2]} = Zipper.rewind_accumulate(z, [], acc_fn)
    end

    test "should accumulate every node of the Zipper that lies along the path, ending with a focus on last node visited and the accumulated value",
         %{z_with_great_grandparent: z} do
      acc_fn = fn next_z, acc ->
        next_z.focus.term + acc
      end

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{
          term: 1,
          children: [
            %RoseTree{
              term: 5,
              children: [
                %RoseTree{term: 10, children: [
                  %RoseTree{term: 20, children: []}
                ]}
              ]
            }
          ]
        },
        prev: [],
        next: [],
        path: []
      }

      assert {^expected_z, 36} = Zipper.rewind_accumulate(z, 0, acc_fn)
    end
  end

  ## Forward Traversal

  describe "forward/1" do
    test "should return nil if given an empty Zipper with no siblings", %{empty_z: z} do
      assert Zipper.forward(z) == nil
    end

    test "should return nil if given a leaf Zipper with no siblings", %{leaf_z: z} do
      assert Zipper.forward(z) == nil
    end

    test "should return the next sibling if given a Zipper with next siblings", %{
      z_breadth_first_siblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.forward(z)
      assert 1 == focus.term
    end

    test "should return the next extended cousin if given a Zipper with no next siblings but with next extended cousins",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: focus} = Zipper.forward(z)
      assert 105 == focus.term
    end

    test "should return the first extended nibling if given a Zipper with no next siblings or next extended cousins, but with first extended niblings",
         %{z_with_extended_niblings: z} do
      remove_next_from_path =
        z.path
        |> Enum.map(fn loc -> %{loc | next: []} end)

      new_z = %{z | path: remove_next_from_path}
      assert %Zipper{focus: focus} = Zipper.forward(new_z)
      assert 202 == focus.term
    end

    test "should return the first nibling if given a Zipper with no next sibling, next extended cousin, or first extended nibling",
         %{
           z_with_niblings: z
         } do
      new_z = %{z | next: []}
      assert %Zipper{focus: focus} = Zipper.forward(new_z)
      assert 10 == focus.term
    end

    test "should return first child if given a Zipper with no next siblings, next extended cousins, first extended niblings, or first niblings",
         %{
           simple_z: z
         } do
      assert %Zipper{focus: focus} = Zipper.forward(z)
      assert 2 == focus.term
    end
  end

  describe "forward_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_z: z} do
      for reps <- 0..-5 do
        assert Zipper.forward_for(z, reps) == nil
      end
    end

    test "should return nil if given a Zipper with no breadth-first descendants", %{leaf_z: z} do
      for reps <- 1..5 do
        assert Zipper.forward_for(z, reps) == nil
      end
    end

    test "should return correct result of moving forward x number of times", %{
      z_breadth_first_siblings: z
    } do
      expected_results = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Zipper{focus: focus} = Zipper.forward_for(z, reps),
                 "Expected a new Zipper for #{reps} reps "

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "forward_if/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.forward_if(z, not_a_predicate)
    end

    test "should return nil if there are no breadth-first descendants", %{leaf_z: z} do
      assert Zipper.forward_if(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.forward_if(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate matches", %{z_with_siblings: z} do
      assert %Zipper{focus: focus} = Zipper.forward_if(z, &(&1.focus.term == 6))
      assert focus.term == 6
    end
  end

  describe "forward_until/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.forward_until(z, not_a_predicate)
    end

    test "should return nil if there are no breadth-first descendants", %{leaf_z: z} do
      assert Zipper.forward_until(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.forward_until(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate is eventually matched", %{
      z_breadth_first_siblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.forward_until(z, &(&1.focus.term == 4))
      assert focus.term == 4
    end
  end

  describe "forward_while/2" do
    test "should return unchanged when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert z == Zipper.forward_while(z, not_a_predicate)
    end

    test "should return unchanged when no breadth-first descendants", %{leaf_z: z} do
      assert z == Zipper.forward_while(z, &Util.always/1)
    end

    test "should return unchanged if predicate fails at the start", %{z_breadth_first_siblings: z} do
      predicate = &(&1.focus.term == :no_match)

      assert z == Zipper.forward_while(z, predicate)
    end

    test "should move forward through the Zipper breadth-first until the last node is reached when the default predicate is used",
         %{
           z_breadth_first_siblings: z
         } do
      assert %Zipper{focus: actual} = Zipper.forward_while(z)
      assert actual.term == 41
    end

    test "should move forward through the Zipper breadth-first until the predicate returns false",
         %{
           z_breadth_first_siblings: z
         } do
      assert %Zipper{focus: actual} = Zipper.forward_while(z, &(&1.focus.term < 20))
      assert actual.term == 20
    end
  end

  describe "forward_to_last/1" do
    test "should return the current Zipper if already at the last breadth-first descendant", %{leaf_z: z} do
      assert ^z = Zipper.forward_to_last(z)
    end

    test "should move forward through the Zipper breadth-first until the last node is reached", %{
      z_breadth_first_siblings: z
    } do
      assert %Zipper{focus: actual} = Zipper.forward_to_last(z)
      assert actual.term == 41
    end
  end

  describe "forward_find/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.forward_find(z, not_a_predicate)
    end

    test "should return nil when no breadth-first descendants", %{leaf_z: z} do
      assert nil == Zipper.forward_find(z, &Util.never/1)
    end

    test "should return nil if predicate never matches", %{z_breadth_first_siblings: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.forward_find(z, predicate)
    end

    test "should return unmoved if predicate matches at starting focus", %{z_breadth_first_siblings: z} do
      predicate = &(&1.focus.term == 0)

      assert z == Zipper.forward_find(z, predicate)
    end

    test "should move until the predicate matches if match isn't found at starting focus", %{z_breadth_first_siblings: z} do
      predicate = &(&1.focus.term == 30)

      assert %Zipper{focus: actual} = Zipper.forward_find(z, predicate)
      assert actual.term == 30
    end
  end

  describe "forward_map/2" do
    test "should return new leaf Zipper if given an empty zipper with valid map_fn", %{empty_z: z} do
      map_fn = &RoseTree.set_term(&1, 2)

      assert %Zipper{focus: actual, prev: [], next: [], path: []} =
               Zipper.forward_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
    end

    test "should change only the focus and remain there if no breadth-first descendants",
         %{leaf_z: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      assert %Zipper{focus: actual, prev: prev, next: next, path: path} =
               Zipper.forward_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
      assert prev == z.prev
      assert next == z.next
      assert path == z.path
    end

    test "should change every node of the Zipper that lies along the path, ending with a focus on last node visited",
         %{z_breadth_first_siblings: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{term: 82, children: []},
        prev: [],
        next: [],
        path: [
          %RoseTree.Zipper.Location{
            prev: [
              %RoseTree{
                term: 56,
                children: [
                  %RoseTree{term: 78, children: []},
                  %RoseTree{term: 80, children: []}
                ]
              },
              %RoseTree{term: 54, children: []},
              %RoseTree{term: 52, children: []}
            ],
            term: 58,
            next: [%RoseTree{term: 60, children: []}]
          },
          %RoseTree.Zipper.Location{
            prev: [%RoseTree{term: 26, children: []}],
            term: 28,
            next: [%RoseTree{term: 30, children: []}]
          },
          %RoseTree.Zipper.Location{
            prev: [
              %RoseTree{term: 6, children: []},
              %RoseTree{
                term: 4,
                children: [
                  %RoseTree{
                    term: 16,
                    children: [
                      %RoseTree{term: 40, children: []},
                      %RoseTree{term: 42, children: []},
                      %RoseTree{
                        term: 44,
                        children: [
                          %RoseTree{term: 68, children: []},
                          %RoseTree{term: 70, children: []}
                        ]
                      }
                    ]
                  },
                  %RoseTree{term: 18, children: []},
                  %RoseTree{term: 20, children: []},
                  %RoseTree{
                    term: 22,
                    children: [
                      %RoseTree{
                        term: 46,
                        children: [
                          %RoseTree{term: 72, children: []},
                          %RoseTree{term: 74, children: []}
                        ]
                      },
                      %RoseTree{term: 48, children: []},
                      %RoseTree{
                        term: 50,
                        children: [%RoseTree{term: 76, children: []}]
                      }
                    ]
                  },
                  %RoseTree{term: 24, children: []}
                ]
              }
            ],
            term: 8,
            next: [
              %RoseTree{term: 10, children: [%RoseTree{term: 32, children: []}]},
              %RoseTree{term: 12, children: []},
              %RoseTree{
                term: 14,
                children: [
                  %RoseTree{
                    term: 34,
                    children: [
                      %RoseTree{term: 62, children: []},
                      %RoseTree{term: 64, children: []}
                    ]
                  },
                  %RoseTree{term: 36, children: []},
                  %RoseTree{term: 38, children: [%RoseTree{term: 66, children: []}]}
                ]
              }
            ]
          },
          %RoseTree.Zipper.Location{
            prev: [%RoseTree{term: -1, children: []}],
            term: 0,
            next: [%RoseTree{term: 2, children: []}]
          }
        ]
      }

      assert expected_z == Zipper.forward_map(z, map_fn)
    end
  end

  describe "forward_accumulate/3" do
    test "should return the empty Zipper and accumulator if given an empty zipper with valid acc_fn", %{empty_z: z} do
      accumulate_terms = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term | acc]
          end
        end

      assert {^z, []} = Zipper.forward_accumulate(z, [], accumulate_terms)
    end

    test "should return unmoved Zipper and accumulator if no breadth-first descendants",
         %{leaf_z: z} do
      acc_fn = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term * 2 | acc]
        end
      end

      assert {^z, [2]} = Zipper.forward_accumulate(z, [], acc_fn)
    end

    test "should accumulate every node of the Zipper that lies along the path, ending with a focus on last node visited and the accumulated value",
         %{z_breadth_first_siblings: z, z_breadth_first_siblings_at_end: z_at_end} do
      acc_fn = fn next_z, acc ->
        [next_z.focus.term | acc]
      end

      expected_acc = Enum.to_list(0..41) |> Enum.reverse()

      assert {^z_at_end, ^expected_acc} = Zipper.forward_accumulate(z, [], acc_fn)
    end
  end

  ## Backward Traversal

  describe "backward/1" do
    test "should return nil if given an empty Zipper with no siblings", %{empty_z: z} do
      assert Zipper.backward(z) == nil
    end

    test "should return nil if given a leaf Zipper with no siblings", %{leaf_z: z} do
      assert Zipper.backward(z) == nil
    end

    test "should return the previous sibling if given a Zipper with previous siblings", %{
      z_with_siblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.backward(z)
      assert 4 == focus.term
    end

    test "should return the previous extended cousin if given a Zipper with no previous siblings but with previous extended cousins",
         %{z_with_extended_cousins: z} do
      assert %Zipper{focus: focus} = Zipper.backward(z)
      assert 102 == focus.term
    end

    test "should return the last extended pibling if given a Zipper with no previous siblings or previous extended cousins, but with last extended piblings",
         %{z_with_extended_cousins: z} do
      remove_prev_from_path =
        z.path
        |> Enum.map(fn loc -> %{loc | prev: []} end)

      new_z = %{z | path: remove_prev_from_path}
      assert %Zipper{focus: focus} = Zipper.backward(new_z)
      assert 58 == focus.term
    end

    test "should return the last pibling if given a Zipper with no previous sibling, previous extended cousin, or last extended pibling",
         %{
           z_with_piblings: z
         } do
      new_z = %{z | prev: []}
      assert %Zipper{focus: focus} = Zipper.backward(new_z)
      assert 18 == focus.term
    end

    test "should return parent if given a Zipper with no previous sibling, previous extended cousin, or last extended pibling",
         %{
           z_with_parent: z
         } do
      assert %Zipper{focus: focus} = Zipper.backward(z)
      assert 10 == focus.term
    end
  end

  describe "backward_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_z: z} do
      for reps <- 0..-5 do
        assert Zipper.backward_for(z, reps) == nil
      end
    end

    test "should return nil if given a Zipper with no breadth-first ancestors", %{leaf_z: z} do
      for reps <- 1..5 do
        assert Zipper.backward_for(z, reps) == nil
      end
    end

    test "should return correct result of moving backward x number of times", %{
      z_breadth_first_siblings: z
    } do
      new_z = Zipper.forward_for(z, 10)

      expected_results = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Zipper{focus: focus} = Zipper.backward_for(new_z, reps),
                 "Expected a new Zipper for #{reps} reps"

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "backward_if/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.backward_if(z, not_a_predicate)
    end

    test "should return nil if there are no breadth-first ancestors", %{leaf_z: z} do
      assert Zipper.backward_if(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.backward_if(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate matches", %{z_with_siblings: z} do
      assert %Zipper{focus: focus} = Zipper.backward_if(z, &(&1.focus.term == 4))
      assert focus.term == 4
    end
  end

  describe "backward_until/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.backward_until(z, not_a_predicate)
    end

    test "should return nil if there are no breadth-first ancestors", %{leaf_z: z} do
      assert Zipper.backward_until(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.backward_until(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate is eventually matched", %{
      z_breadth_first_siblings_at_end: z
    } do
      assert %Zipper{focus: focus} = Zipper.backward_until(z, &(&1.focus.term == 20))
      assert focus.term == 20
    end
  end

  describe "backward_while/2" do
    test "should return unchanged when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert z == Zipper.backward_while(z, not_a_predicate)
    end

    test "should return unchanged when no breadth-first ancestors", %{leaf_z: z} do
      assert z == Zipper.backward_while(z, &Util.always/1)
    end

    test "should return unchanged if predicate fails at the start", %{z_breadth_first_siblings: z} do
      predicate = &(&1.focus.term == :no_match)

      assert z == Zipper.backward_while(z, predicate)
    end

    test "should move backward through the Zipper breadth-first until the first sibling root node is reached when the default predicate is used",
         %{
           z_breadth_first_siblings_at_end: z
         } do
      assert %Zipper{focus: actual} = Zipper.backward_while(z)
      assert actual.term == -1
    end

    test "should move backward through the Zipper breadth-first until the predicate returns false",
         %{
          z_breadth_first_siblings_at_end: z
         } do
      assert %Zipper{focus: actual} = Zipper.backward_while(z, &(&1.focus.term > 20))
      assert actual.term == 20
    end
  end

  describe "backward_to_root/1" do
    test "should return the current Zipper if already at the first breadth-first descendant", %{leaf_z: z} do
      assert ^z = Zipper.backward_to_root(z)
    end

    test "should move backward through the Zipper breadth-first until the first sibling root node is reached",
         %{
          z_breadth_first_siblings_at_end: z
         } do
      assert %Zipper{focus: actual} = Zipper.backward_to_root(z)
      assert actual.term == -1
    end
  end

  describe "backward_find/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.backward_find(z, not_a_predicate)
    end

    test "should return nil when no breadth-first ancestors", %{leaf_z: z} do
      assert nil == Zipper.backward_find(z, &Util.never/1)
    end

    test "should return nil if predicate never matches", %{z_breadth_first_siblings_at_end: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.backward_find(z, predicate)
    end

    test "should return unmoved if predicate matches at starting focus", %{z_breadth_first_siblings_at_end: z} do
      predicate = &(&1.focus.term == 41)

      assert z == Zipper.backward_find(z, predicate)
    end

    test "should move until the predicate matches if match isn't found at starting focus", %{z_breadth_first_siblings_at_end: z} do
      predicate = &(&1.focus.term == 30)

      assert %Zipper{focus: actual} = Zipper.backward_find(z, predicate)
      assert actual.term == 30
    end
  end

  describe "backward_map/2" do
    test "should return new leaf Zipper if given an empty zipper with valid map_fn", %{empty_z: z} do
      map_fn = &RoseTree.set_term(&1, 2)

      assert %Zipper{focus: actual, prev: [], next: [], path: []} =
               Zipper.backward_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
    end

    test "should change only the focus and remain there if no breadth-first ancestors",
         %{leaf_z: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      assert %Zipper{focus: actual, prev: prev, next: next, path: path} =
               Zipper.backward_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
      assert prev == z.prev
      assert next == z.next
      assert path == z.path
    end

    test "should change every node of the Zipper that lies along the path, ending with a focus on last node visited",
         %{z_breadth_first_siblings_at_end: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{term: -2, children: []},
        prev: [],
        next: [
          %RoseTree{
            term: 0,
            children: [
              %RoseTree{
                term: 4,
                children: [
                  %RoseTree{
                    term: 16,
                    children: [
                      %RoseTree{term: 40, children: []},
                      %RoseTree{term: 42, children: []},
                      %RoseTree{
                        term: 44,
                        children: [
                          %RoseTree{term: 68, children: []},
                          %RoseTree{term: 70, children: []}
                        ]
                      }
                    ]
                  },
                  %RoseTree{term: 18, children: []},
                  %RoseTree{term: 20, children: []},
                  %RoseTree{
                    term: 22,
                    children: [
                      %RoseTree{
                        term: 46,
                        children: [
                          %RoseTree{term: 72, children: []},
                          %RoseTree{term: 74, children: []}
                        ]
                      },
                      %RoseTree{term: 48, children: []},
                      %RoseTree{
                        term: 50,
                        children: [%RoseTree{term: 76, children: []}]
                      }
                    ]
                  },
                  %RoseTree{term: 24, children: []}
                ]
              },
              %RoseTree{term: 6, children: []},
              %RoseTree{
                term: 8,
                children: [
                  %RoseTree{term: 26, children: []},
                  %RoseTree{
                    term: 28,
                    children: [
                      %RoseTree{term: 52, children: []},
                      %RoseTree{term: 54, children: []},
                      %RoseTree{
                        term: 56,
                        children: [
                          %RoseTree{term: 78, children: []},
                          %RoseTree{term: 80, children: []}
                        ]
                      },
                      %RoseTree{
                        term: 58,
                        children: [%RoseTree{term: 82, children: []}]
                      },
                      %RoseTree{term: 60, children: []}
                    ]
                  },
                  %RoseTree{term: 30, children: []}
                ]
              },
              %RoseTree{term: 10, children: [%RoseTree{term: 32, children: []}]},
              %RoseTree{term: 12, children: []},
              %RoseTree{
                term: 14,
                children: [
                  %RoseTree{
                    term: 34,
                    children: [
                      %RoseTree{term: 62, children: []},
                      %RoseTree{term: 64, children: []}
                    ]
                  },
                  %RoseTree{term: 36, children: []},
                  %RoseTree{term: 38, children: [%RoseTree{term: 66, children: []}]}
                ]
              }
            ]
          },
          %RoseTree{term: 2, children: []}
        ],
        path: []
      }

      assert expected_z == Zipper.backward_map(z, map_fn)
    end
  end

  describe "backward_accumulate/3" do
    test "should return the empty Zipper and accumulator if given an empty zipper with valid acc_fn", %{empty_z: z} do
      accumulate_terms = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term | acc]
          end
        end

      assert {^z, []} = Zipper.backward_accumulate(z, [], accumulate_terms)
    end

    test "should return unmoved Zipper and accumulator if no breadth-first ancestors",
         %{leaf_z: z} do
      acc_fn = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term * 2 | acc]
        end
      end

      assert {^z, [2]} = Zipper.backward_accumulate(z, [], acc_fn)
    end

    test "should accumulate every node of the Zipper that lies along the path, ending with a focus on last node visited and the accumulated value",
         %{z_breadth_first_siblings_at_end: z} do
      acc_fn = fn next_z, acc ->
        [next_z.focus.term | acc]
      end

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{term: -1, children: []},
        prev: [],
        next: [
          %RoseTree{
            term: 0,
            children: [
              %RoseTree{
                term: 2,
                children: [
                  %RoseTree{
                    term: 8,
                    children: [
                      %RoseTree{term: 20, children: []},
                      %RoseTree{term: 21, children: []},
                      %RoseTree{
                        term: 22,
                        children: [
                          %RoseTree{term: 34, children: []},
                          %RoseTree{term: 35, children: []}
                        ]
                      }
                    ]
                  },
                  %RoseTree{term: 9, children: []},
                  %RoseTree{term: 10, children: []},
                  %RoseTree{
                    term: 11,
                    children: [
                      %RoseTree{
                        term: 23,
                        children: [
                          %RoseTree{term: 36, children: []},
                          %RoseTree{term: 37, children: []}
                        ]
                      },
                      %RoseTree{term: 24, children: []},
                      %RoseTree{
                        term: 25,
                        children: [%RoseTree{term: 38, children: []}]
                      }
                    ]
                  },
                  %RoseTree{term: 12, children: []}
                ]
              },
              %RoseTree{term: 3, children: []},
              %RoseTree{
                term: 4,
                children: [
                  %RoseTree{term: 13, children: []},
                  %RoseTree{
                    term: 14,
                    children: [
                      %RoseTree{term: 26, children: []},
                      %RoseTree{term: 27, children: []},
                      %RoseTree{
                        term: 28,
                        children: [
                          %RoseTree{term: 39, children: []},
                          %RoseTree{term: 40, children: []}
                        ]
                      },
                      %RoseTree{
                        term: 29,
                        children: [%RoseTree{term: 41, children: []}]
                      },
                      %RoseTree{term: 30, children: []}
                    ]
                  },
                  %RoseTree{term: 15, children: []}
                ]
              },
              %RoseTree{term: 5, children: [%RoseTree{term: 16, children: []}]},
              %RoseTree{term: 6, children: []},
              %RoseTree{
                term: 7,
                children: [
                  %RoseTree{
                    term: 17,
                    children: [
                      %RoseTree{term: 31, children: []},
                      %RoseTree{term: 32, children: []}
                    ]
                  },
                  %RoseTree{term: 18, children: []},
                  %RoseTree{term: 19, children: [%RoseTree{term: 33, children: []}]}
                ]
              }
            ]
          },
          %RoseTree{term: 1, children: []}
        ],
        path: []
      }

      expected_acc = Enum.to_list(-1..41)

      assert {^expected_z, ^expected_acc} = Zipper.backward_accumulate(z, [], acc_fn)
    end
  end

  ## Descend Traversal

  describe "descend/1" do
    test "should return nil if given an empty Zipper with no siblings", %{empty_z: z} do
      assert Zipper.descend(z) == nil
    end

    test "should return nil if given a leaf Zipper with no siblings", %{leaf_z: z} do
      assert Zipper.descend(z) == nil
    end

    test "should return the first child if given a Zipper with children", %{simple_z: z} do
      assert %Zipper{focus: focus} = Zipper.descend(z)
      assert 2 == focus.term
    end

    test "should return the next sibling if given a Zipper with no children but with next siblings",
         %{z_with_siblings: z} do
      assert %Zipper{focus: focus} = Zipper.descend(z)
      assert 6 == focus.term
    end

    test "should return the next ancestral pibling if given a Zipper with no children or siblings, but with next piblings",
         %{z_with_ancestral_piblings: z} do
      assert %Zipper{focus: focus} = Zipper.descend(z)
      assert 6 == focus.term
    end
  end

  describe "descend_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_z: z} do
      for reps <- 0..-5 do
        assert Zipper.descend_for(z, reps) == nil
      end
    end

    test "should return nil if given a Zipper with no depth-first descendants", %{leaf_z: z} do
      for reps <- 1..5 do
        assert Zipper.descend_for(z, reps) == nil
      end
    end

    test "should return correct result of descending x number of times", %{
      z_with_grandchildren: z
    } do
      expected_results = [1, 4, 5, 6, 2, 7, 8, 9, 3, 10]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Zipper{focus: focus} = Zipper.descend_for(z, reps),
                 "Expected a new Zipper for #{reps} reps "

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "descend_if/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.descend_if(z, not_a_predicate)
    end

    test "should return nil if there are no descendants", %{leaf_z: z} do
      assert Zipper.descend_if(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.descend_if(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate matches", %{simple_z: z} do
      assert %Zipper{focus: focus} = Zipper.descend_if(z, &(&1.focus.term == 2))
      assert focus.term == 2
    end
  end

  describe "descend_until/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.descend_until(z, not_a_predicate)
    end

    test "should return nil if there are no descendants", %{leaf_z: z} do
      assert Zipper.descend_until(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{simple_z: z} do
      assert Zipper.descend_until(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate is eventually matched", %{
      z_with_grandchildren: z
    } do
      assert %Zipper{focus: focus} = Zipper.descend_until(z, &(&1.focus.term == 12))
      assert focus.term == 12
    end
  end

  describe "descend_while/2" do
    test "should return unchanged when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert z == Zipper.descend_while(z, not_a_predicate)
    end

    test "should return unchanged when no depth-first descendants", %{leaf_z: z} do
      assert z == Zipper.descend_while(z, &Util.always/1)
    end

    test "should return unchanged if predicate fails at the start", %{z_depth_first_siblings: z} do
      predicate = &(&1.focus.term == :no_match)

      assert z == Zipper.descend_while(z, predicate)
    end

    test "should descend the Zipper depth-first until the last node is reached when the default predicate is used",
         %{
           z_depth_first_siblings: z
         } do
      assert %Zipper{focus: actual} = Zipper.descend_while(z)
      assert actual.term == 41
    end

    test "should descend the Zipper depth-first until the predicate returns false", %{
      z_depth_first_siblings: z
    } do
      assert %Zipper{focus: actual} = Zipper.descend_while(z, &(&1.focus.term < 20))
      assert actual.term == 20
    end
  end

  describe "descend_to_last/1" do
    test "should return the current Zipper if already at the last depth-first descendant", %{leaf_z: z} do
      assert ^z = Zipper.descend_to_last(z)
    end

    test "should descend the Zipper depth-first until the last node is reached", %{
      z_depth_first_siblings: z
    } do
      assert %Zipper{focus: actual} = Zipper.descend_to_last(z)
      assert actual.term == 41
    end
  end

  describe "descend_find/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.descend_find(z, not_a_predicate)
    end

    test "should return nil when no depth-first descendants", %{leaf_z: z} do
      assert nil == Zipper.descend_find(z, &Util.never/1)
    end

    test "should return nil if predicate never matches", %{z_depth_first_siblings: z} do
      predicate = &(&1.focus.term == :no_match)

      assert nil == Zipper.descend_find(z, predicate)
    end

    test "should return unmoved if predicate matches at starting focus", %{z_depth_first_siblings: z} do
      predicate = &(&1.focus.term == 0)

      assert z == Zipper.descend_find(z, predicate)
    end

    test "should move until the predicate matches if match isn't found at starting focus", %{z_depth_first_siblings: z} do
      predicate = &(&1.focus.term == 30)

      assert %Zipper{focus: actual} = Zipper.descend_find(z, predicate)
      assert actual.term == 30
    end
  end

  describe "descend_map/2" do
    test "should return new leaf Zipper if given an empty zipper with valid map_fn", %{empty_z: z} do
      map_fn = &RoseTree.set_term(&1, 2)

      assert %Zipper{focus: actual, prev: [], next: [], path: []} =
               Zipper.descend_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
    end

    test "should change only the focus and remain there if no depth-first descendants",
         %{leaf_z: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      assert %Zipper{focus: actual, prev: prev, next: next, path: path} =
               Zipper.descend_map(z, map_fn)

      assert actual.term == 2
      assert actual.children == z.focus.children
      assert prev == z.prev
      assert next == z.next
      assert path == z.path
    end

    test "should change every node of the Zipper that lies along the path, ending with a focus on last node visited",
         %{z_depth_first_siblings: z} do
      map_fn = &RoseTree.map_term(&1, fn t -> t * 2 end)

      expected_z = %RoseTree.Zipper{
        focus: %RoseTree{term: 82, children: []},
        prev: [
          %RoseTree{
            term: 0,
            children: [
              %RoseTree{
                term: 2,
                children: [
                  %RoseTree{
                    term: 4,
                    children: [
                      %RoseTree{term: 6, children: []},
                      %RoseTree{term: 8, children: []},
                      %RoseTree{
                        term: 10,
                        children: [
                          %RoseTree{term: 12, children: []},
                          %RoseTree{term: 14, children: []}
                        ]
                      }
                    ]
                  },
                  %RoseTree{term: 16, children: []},
                  %RoseTree{term: 18, children: []},
                  %RoseTree{
                    term: 20,
                    children: [
                      %RoseTree{
                        term: 22,
                        children: [
                          %RoseTree{term: 24, children: []},
                          %RoseTree{term: 26, children: []}
                        ]
                      },
                      %RoseTree{term: 28, children: []},
                      %RoseTree{
                        term: 30,
                        children: [%RoseTree{term: 32, children: []}]
                      }
                    ]
                  },
                  %RoseTree{term: 34, children: []}
                ]
              },
              %RoseTree{term: 36, children: []},
              %RoseTree{
                term: 38,
                children: [
                  %RoseTree{term: 40, children: []},
                  %RoseTree{
                    term: 42,
                    children: [
                      %RoseTree{term: 44, children: []},
                      %RoseTree{term: 46, children: []},
                      %RoseTree{
                        term: 48,
                        children: [
                          %RoseTree{term: 50, children: []},
                          %RoseTree{term: 52, children: []}
                        ]
                      },
                      %RoseTree{
                        term: 54,
                        children: [%RoseTree{term: 56, children: []}]
                      },
                      %RoseTree{term: 58, children: []}
                    ]
                  },
                  %RoseTree{term: 60, children: []}
                ]
              },
              %RoseTree{term: 62, children: [%RoseTree{term: 64, children: []}]},
              %RoseTree{term: 66, children: []},
              %RoseTree{
                term: 68,
                children: [
                  %RoseTree{
                    term: 70,
                    children: [
                      %RoseTree{term: 72, children: []},
                      %RoseTree{term: 74, children: []}
                    ]
                  },
                  %RoseTree{term: 76, children: []},
                  %RoseTree{term: 78, children: [%RoseTree{term: 80, children: []}]}
                ]
              }
            ]
          },
          %RoseTree{term: -1, children: []}
        ],
        next: [],
        path: []
      }

      assert expected_z == Zipper.descend_map(z, map_fn)
    end
  end

  describe "descend_accumulate/3" do
    test "should return the empty Zipper and accumulator if given an empty zipper with valid acc_fn", %{empty_z: z} do
      accumulate_terms = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term | acc]
          end
        end

      assert {^z, []} = Zipper.descend_accumulate(z, [], accumulate_terms)
    end

    test "should return unmoved Zipper and accumulator if no depth-first descendants",
         %{leaf_z: z} do
      acc_fn = fn next_z, acc ->
        case next_z.focus.term do
          nil ->
            acc

          term ->
            [term * 2 | acc]
        end
      end

      assert {^z, [2]} = Zipper.descend_accumulate(z, [], acc_fn)
    end

    test "should accumulate every node of the Zipper that lies along the path, ending with a focus on last node visited and the accumulated value",
         %{z_depth_first_siblings: z, z_depth_first_siblings_at_end: z_at_end} do
      acc_fn = fn next_z, acc ->
        [next_z.focus.term | acc]
      end

      expected_acc = Enum.to_list(0..41) |> Enum.reverse()

      assert {^z_at_end, ^expected_acc} = Zipper.descend_accumulate(z, [], acc_fn)
    end
  end

  ## Ascend Traversal

  describe "ascend/1" do
    test "should return nil if given a Zipper with no parents or siblings", %{simple_z: z} do
      assert Zipper.ascend(z) == nil
    end

    test "should return the parent if given a Zipper with parents and no previous siblings", %{
      z_with_parent: z
    } do
      assert %Zipper{focus: focus} = Zipper.ascend(z)
      assert 10 == focus.term
    end

    test "should return the previous sibling if given a Zipper with parent and previous siblings that have no children",
         %{z_with_siblings: z} do
      z = Generators.add_zipper_locations(z, num_locations: 1)
      assert %Zipper{focus: focus} = Zipper.ascend(z)
      assert 4 == focus.term
    end

    test "should return the previous descendant nibling if given a Zipper with parent and previous siblings with children",
         %{z_with_descendant_niblings: z} do
      assert %Zipper{focus: focus} = Zipper.ascend(z)
      assert 25 == focus.term
    end
  end

  describe "ascend_for/2" do
    test "should return nil if given a number of reps <= 0", %{simple_z: z} do
      for reps <- 0..-5 do
        assert Zipper.ascend_for(z, reps) == nil
      end
    end

    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_z: z
    } do
      for reps <- 1..5 do
        assert Zipper.ascend_for(z, reps) == nil
      end
    end

    test "should return correct result of ascending x number of times", %{
      z_with_descendant_niblings: z
    } do
      new_z = Zipper.descend_for(z, 10)

      expected_results = [32, 14, 31, 30, 38, 37, 29, 13, 7, 5]

      actual_results =
        1..10
        |> Enum.map(fn reps ->
          assert %Zipper{focus: focus} = Zipper.ascend_for(new_z, reps),
                 "Expected a new Zipper for #{reps} reps"

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "ascend_if/2" do
    test "should return nil when given a bad predicate", %{simple_z: z} do
      not_a_predicate = fn _ -> :anti_boolean end

      assert nil == Zipper.ascend_if(z, not_a_predicate)
    end

    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_z: z
    } do
      assert Zipper.ascend_if(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{
      z_with_descendant_niblings: z
    } do
      assert Zipper.ascend_if(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate matches", %{
      z_with_descendant_niblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.ascend_if(z, &(&1.focus.term == 25))
      assert focus.term == 25
    end
  end

  describe "ascend_until/2" do
    test "should return nil if no previous descendant niblings, siblings, or parent", %{
      simple_z: z
    } do
      assert Zipper.ascend_until(z, &(&1.focus.term == 5)) == nil
    end

    test "should return nil if the given predicate fails to match", %{
      z_with_descendant_niblings: z
    } do
      assert Zipper.ascend_until(z, &(&1.focus.term == :not_found)) == nil
    end

    test "should return the new zipper if the given predicate is eventually matched", %{
      z_with_descendant_niblings: z
    } do
      assert %Zipper{focus: focus} = Zipper.ascend_until(z, &(&1.focus.term == 12))
      assert focus.term == 12
    end
  end

  describe "ascend_while/2" do
    setup ctx do
      %{
        z_at_last_depth_first: Zipper.descend_to_last(ctx.z_depth_first_siblings)
      }
    end

    test "should ascend the Zipper depth-first until the root node is reached when the default predicate is used",
         %{
           z_at_last_depth_first: z
         } do
      assert %Zipper{focus: actual} = Zipper.ascend_while(z)
      assert actual.term == -1
    end

    test "should ascend the Zipper depth-first until the predicate returns false", %{
      z_at_last_depth_first: z
    } do
      assert %Zipper{focus: actual} = Zipper.ascend_while(z, &(&1.focus.term > 20))
      assert actual.term == 20
    end
  end

  describe "ascend_to_root/1" do
    test "should ascend the Zipper depth-first until the first sibling root node is reached", %{
      z_depth_first_siblings: z
    } do
      new_z = Zipper.descend_to_last(z)
      assert %Zipper{focus: actual} = Zipper.ascend_to_root(new_z)
      assert actual.term == -1
    end
  end
end
