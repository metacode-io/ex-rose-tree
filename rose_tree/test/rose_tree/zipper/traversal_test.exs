defmodule RoseTree.Zipper.ZipperTest do
  use ExUnit.Case, async: true

  alias RoseTree.Support.{Generators, Zippers}
  alias RoseTree.Zipper
  alias RoseTree.Zipper.Location

  setup_all do
    %{
      empty_z: Zippers.empty_z(),
      leaf_z: Zippers.leaf_z(),
      simple_z: Zippers.simple_z(),
      z_with_parent: Zippers.z_with_parent(),
      z_with_grandchildren: Zippers.z_with_grandchildren(),
      z_with_siblings: Zippers.z_with_siblings(),
      z_with_ancestral_piblings: Zippers.z_with_ancestral_piblings(),
      z_with_descendant_niblings: Zippers.z_with_descendant_niblings(),
      z_depth_first: Zippers.z_depth_first()
    }
  end

  describe "rewind/1" do
    test "should return the current Zipper if already at the root" do
      root = %Zipper{focus: "root"}

      actual = Zipper.rewind(root)

      assert root == actual
    end

    test "should move the Zipper back to the root of the tree" do
      for _ <- 1..10 do
        num_locations = Enum.random(1..20)

        some_zipper =
          %Zipper{focus: "current"}
          |> Generators.add_zipper_locations(num_locations: num_locations)

        [root_location | _] = Enum.reverse(some_zipper.path)

        assert %Zipper{focus: focus, path: []} = Zipper.rewind(some_zipper)
        assert focus.term == root_location.term
      end
    end
  end

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
                 "Expected a new Zipper for #{reps} reps "

          focus.term
        end)

      assert actual_results == expected_results
    end
  end

  describe "ascend_if/2" do
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
end
