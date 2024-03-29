defmodule ExRoseTree.Zipper.Zipper.SiblingTest do
  use ExUnit.Case, async: true
  use ZipperCase

  describe "prepend_first_sibling/2" do
    test "should increase the number of previous siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{prev: actual} = Zipper.prepend_first_sibling(z, new_tree)
        assert Enum.count(actual) == Enum.count(z.prev) + 1
      end
    end

    test "should add the new ExRoseTree to the end of the previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.prepend_first_sibling(z, new_tree)
      assert [^new_tree | _] = Enum.reverse(actual)
    end

    test "should add the term as a new ExRoseTree to the end of the previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{prev: actual} = Zipper.prepend_first_sibling(z, new_term)
      assert [^expected_tree | _] = Enum.reverse(actual)
    end
  end

  describe "append_last_sibling/2" do
    test "should increase the number of next siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{next: actual} = Zipper.append_last_sibling(z, new_tree)
        assert Enum.count(actual) == Enum.count(z.next) + 1
      end
    end

    test "should add the new ExRoseTree to the end of the next siblings", %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: actual} = Zipper.append_last_sibling(z, new_tree)
      assert [^new_tree | _] = Enum.reverse(actual)
    end

    test "should add the term as a new ExRoseTree to the end of the next siblings", %{
      z_with_siblings: z
    } do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{next: actual} = Zipper.append_last_sibling(z, new_term)
      assert [^expected_tree | _] = Enum.reverse(actual)
    end
  end

  describe "append_previous_sibling/2" do
    test "should increase the number of previous siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{prev: actual} = Zipper.append_previous_sibling(z, new_tree)
        assert Enum.count(actual) == Enum.count(z.prev) + 1
      end
    end

    test "should add the new ExRoseTree to the head of the previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.append_previous_sibling(z, new_tree)
      assert [^new_tree | _] = actual
    end

    test "should add the term as a new ExRoseTree to the head of the previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{prev: actual} = Zipper.append_previous_sibling(z, new_term)
      assert [^expected_tree | _] = actual
    end
  end

  describe "prepend_next_sibling/2" do
    test "should increase the number of next siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{next: actual} = Zipper.prepend_next_sibling(z, new_tree)
        assert Enum.count(actual) == Enum.count(z.next) + 1
      end
    end

    test "should add the new ExRoseTree to the head of the next siblings", %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: actual} = Zipper.prepend_next_sibling(z, new_tree)
      assert [^new_tree | _] = actual
    end

    test "should add the term as a new ExRoseTree to the next of the next siblings", %{
      z_with_siblings: z
    } do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{next: actual} = Zipper.prepend_next_sibling(z, new_term)
      assert [^expected_tree | _] = actual
    end
  end

  describe "insert_previous_sibling_at/3" do
    test "should increase the number of previous siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, 0)
        assert Enum.count(actual) == Enum.count(z.prev) + 1
      end
    end

    test "should insert a new ExRoseTree to previous siblings", %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, 0)
      assert [^new_tree | _] = Enum.reverse(actual)
    end

    test "should insert a term as a new ExRoseTree to previous siblings", %{z_with_siblings: z} do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_term, 0)
      assert [^expected_tree | _] = Enum.reverse(actual)
    end

    test "should insert a new ExRoseTree at the correct index, starting from the back since its reversed, when given a positive index",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, 3)
      assert new_tree == Enum.at(Enum.reverse(actual), 3)
    end

    test "should insert a new ExRoseTree at the head when given a positive index greater than count of previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, 10)
      assert [^new_tree | _] = actual
    end

    test "should insert a new ExRoseTree at the correct index, starting from from the front esince its reversed, when given a negative index",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, -2)
      assert new_tree == Enum.at(actual, 2)
    end

    test "should insert a new ExRoseTree at the end when given a negatve index greater than count of previous siblings since they are reversed",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{prev: actual} = Zipper.insert_previous_sibling_at(z, new_tree, -10)
      assert [^new_tree | _] = Enum.reverse(actual)
    end
  end

  describe "insert_next_sibling_at/3" do
    test "should increase the number of next siblings by 1", %{z_with_siblings: z} do
      new_term = :anything
      new_tree = ExRoseTree.new(new_term)

      for _ <- [new_term, new_tree] do
        assert %Zipper{next: actual} = Zipper.insert_next_sibling_at(z, new_tree, 0)
        assert Enum.count(actual) == Enum.count(z.prev) + 1
      end
    end

    test "should insert a new ExRoseTree to next siblings", %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: [^new_tree | _]} = Zipper.insert_next_sibling_at(z, new_tree, 0)
    end

    test "should insert a term as a new ExRoseTree to next siblings", %{z_with_siblings: z} do
      new_term = :anything

      expected_tree = ExRoseTree.new(new_term)

      assert %Zipper{next: [^expected_tree | _]} = Zipper.insert_next_sibling_at(z, new_term, 0)
    end

    test "should insert a new ExRoseTree at the correct index when given a positive index", %{
      z_with_siblings: z
    } do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: actual} = Zipper.insert_next_sibling_at(z, new_tree, 3)
      assert new_tree == Enum.at(actual, 3)
    end

    test "should insert a new ExRoseTree at the end when given a positive index greater than count of next siblings",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: actual} = Zipper.insert_next_sibling_at(z, new_tree, 10)
      assert [^new_tree | _] = Enum.reverse(actual)
    end

    test "should insert a new ExRoseTree at the correct index, starting from the back, when given a negative index",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: actual} = Zipper.insert_next_sibling_at(z, new_tree, -2)
      assert new_tree == Enum.at(actual, 2)
    end

    test "should insert a new ExRoseTree at the head when given a negative index greater than count of next siblings",
         %{z_with_siblings: z} do
      new_tree = ExRoseTree.new(:anything)

      assert %Zipper{next: [^new_tree | _]} = Zipper.insert_next_sibling_at(z, new_tree, -10)
    end
  end

  describe "pop_first_sibling/1" do
    test "should return unchanged Zipper and nil when no previous siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_first_sibling(z)
    end

    test "should return Zipper with one less previous sibling", %{z_with_siblings: z} do
      assert {%Zipper{prev: actual}, %ExRoseTree{} = _removed} = Zipper.pop_first_sibling(z)
      assert Enum.count(actual) == Enum.count(z.prev) - 1
    end

    test "should return Zipper with first sibling removed", %{z_with_siblings: z} do
      {expected_remainder, [expected_removal | []]} = Enum.split(z.prev, -1)

      assert {%Zipper{prev: ^expected_remainder}, ^expected_removal} = Zipper.pop_first_sibling(z)
    end
  end

  describe "pop_previous_sibling/1" do
    test "should return unchanged Zipper and nil when no previous siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_previous_sibling(z)
    end

    test "should return Zipper with one less previous sibling", %{z_with_siblings: z} do
      assert {%Zipper{prev: actual}, %ExRoseTree{} = _removed} = Zipper.pop_previous_sibling(z)
      assert Enum.count(actual) == Enum.count(z.prev) - 1
    end

    test "should return Zipper with previous sibling removed", %{z_with_siblings: z} do
      [expected_removal | expected_remainder] = z.prev

      assert {%Zipper{prev: ^expected_remainder}, ^expected_removal} =
               Zipper.pop_previous_sibling(z)
    end
  end

  describe "pop_last_sibling/1" do
    test "should return unchanged Zipper and nil when no next siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_last_sibling(z)
    end

    test "should return Zipper with one less next sibling", %{z_with_siblings: z} do
      assert {%Zipper{next: actual}, %ExRoseTree{} = _removed} = Zipper.pop_last_sibling(z)
      assert Enum.count(actual) == Enum.count(z.next) - 1
    end

    test "should return Zipper with last sibling removed", %{z_with_siblings: z} do
      {expected_remainder, [expected_removal | []]} = Enum.split(z.next, -1)

      assert {%Zipper{next: ^expected_remainder}, ^expected_removal} = Zipper.pop_last_sibling(z)
    end
  end

  describe "pop_next_sibling/1" do
    test "should return unchanged Zipper and nil when no next siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_next_sibling(z)
    end

    test "should return Zipper with one less next sibling", %{z_with_siblings: z} do
      assert {%Zipper{next: actual}, %ExRoseTree{} = _removed} = Zipper.pop_next_sibling(z)
      assert Enum.count(actual) == Enum.count(z.next) - 1
    end

    test "should return Zipper with next sibling removed", %{z_with_siblings: z} do
      [expected_removal | expected_remainder] = z.next

      assert {%Zipper{next: ^expected_remainder}, ^expected_removal} = Zipper.pop_next_sibling(z)
    end
  end

  describe "pop_previous_sibling_at/3" do
    test "should return unchanged Zipper and nil when no previous siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_previous_sibling_at(z, 0)
    end

    test "should decrease the number of previous siblings by 1", %{z_with_siblings: z} do
      assert {%Zipper{prev: actual}, %ExRoseTree{} = _removed} =
               Zipper.pop_previous_sibling_at(z, 0)

      assert Enum.count(actual) == Enum.count(z.prev) - 1
    end

    test "should remove the sibling at the correct index, starting from the back since its reversed, when given a positive index",
         %{z_with_siblings: z} do
      assert {%Zipper{prev: actual}, removed} = Zipper.pop_previous_sibling_at(z, 1)
      assert removed == Enum.at(z.prev, 2)
      assert [4, 3, 1] = Enum.map(actual, & &1.term)
    end

    test "should not remove any sibling when given a positive index greater than count of previous siblings",
         %{z_with_siblings: z} do
      assert {^z, nil} = Zipper.pop_previous_sibling_at(z, 10)
    end

    test "should remove the sibling at the correct index, starting from from the front since its reversed, when given a negative index",
         %{z_with_siblings: z} do
      assert {%Zipper{prev: actual}, removed} = Zipper.pop_previous_sibling_at(z, -3)
      assert removed == Enum.at(z.prev, 2)
      assert [4, 3, 1] = Enum.map(actual, & &1.term)
    end

    test "should not remove any sibling when given a negative index greater than count of previous siblings",
         %{z_with_siblings: z} do
      assert {^z, nil} = Zipper.pop_previous_sibling_at(z, -10)
    end
  end

  describe "pop_next_sibling_at/3" do
    test "should return unchanged Zipper and nil when no next siblings exist", %{simple_z: z} do
      assert {^z, nil} = Zipper.pop_next_sibling_at(z, 0)
    end

    test "should decrease the number of next siblings by 1", %{z_with_siblings: z} do
      assert {%Zipper{next: actual}, %ExRoseTree{} = _removed} = Zipper.pop_next_sibling_at(z, 0)
      assert Enum.count(actual) == Enum.count(z.next) - 1
    end

    test "should remove the sibling at the correct index when given a positive index", %{
      z_with_siblings: z
    } do
      assert {%Zipper{next: actual}, removed} = Zipper.pop_next_sibling_at(z, 1)
      assert removed == Enum.at(z.next, 1)
      assert [6, 8, 9] = Enum.map(actual, & &1.term)
    end

    test "should not remove any sibling when given a positive index greater than count of next siblings",
         %{z_with_siblings: z} do
      assert {^z, nil} = Zipper.pop_next_sibling_at(z, 10)
    end

    test "should remove the sibling at the correct index, starting from from the back, when given a negative index",
         %{z_with_siblings: z} do
      assert {%Zipper{next: actual}, removed} = Zipper.pop_next_sibling_at(z, -3)
      assert removed == Enum.at(z.next, 1)
      assert [6, 8, 9] = Enum.map(actual, & &1.term)
    end

    test "should not remove any sibling when given a negative index greater than count of next siblings",
         %{z_with_siblings: z} do
      assert {^z, nil} = Zipper.pop_next_sibling_at(z, -10)
    end
  end

  describe "first_sibling/2" do
    test "should return nil if Zipper has no previous siblings", %{simple_z: z} do
      assert Zipper.first_sibling(z) == nil
    end

    test "should return nil if no previous sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.first_sibling(z, predicate) == nil
    end

    test "should return the first sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.first_sibling(z)
      assert 1 == actual.focus.term
    end

    test "should return the first sibling node for Zipper that matches the predicate", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 3)

      actual = Zipper.first_sibling(z, predicate)
      assert 3 == actual.focus.term
    end

    test "should return nil and not seek past the original Zipper for a predicate match", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 7)

      assert Zipper.first_sibling(z, predicate) == nil
    end
  end

  describe "previous_sibling/2" do
    test "should return nil if Zipper has no previous siblings", %{simple_z: z} do
      assert Zipper.previous_sibling(z) == nil
    end

    test "should return nil if no previous sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.previous_sibling(z, predicate) == nil
    end

    test "should return the previous sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.previous_sibling(z)
      assert 4 == actual.focus.term
    end

    test "should return the first previous sibling node for Zipper that matches the predicate",
         %{
           z_with_siblings: z
         } do
      predicate = &(&1.term == 2)

      actual = Zipper.previous_sibling(z, predicate)
      assert 2 == actual.focus.term
    end
  end

  describe "last_sibling/2" do
    test "should return nil if Zipper has no next siblings", %{simple_z: z} do
      assert Zipper.last_sibling(z) == nil
    end

    test "should return nil if no next sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.last_sibling(z, predicate) == nil
    end

    test "should return the last sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.last_sibling(z)
      assert 9 == actual.focus.term
    end

    test "should return the last next sibling node for Zipper that matches the predicate", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 7)

      actual = Zipper.last_sibling(z, predicate)
      assert 7 == actual.focus.term
    end

    test "should return nil and not seek before the original Zipper for a predicate match", %{
      z_with_siblings: z
    } do
      predicate = &(&1.term == 3)

      assert Zipper.last_sibling(z, predicate) == nil
    end
  end

  describe "next_sibling/2" do
    test "should return nil if Zipper has no next siblings", %{simple_z: z} do
      assert Zipper.next_sibling(z) == nil
    end

    test "should return nil if no next sibling is found for Zipper that matches the predicate",
         %{z_with_siblings: z} do
      predicate = &(&1.term == :not_found)

      assert Zipper.next_sibling(z, predicate) == nil
    end

    test "should return the next sibling node for Zipper", %{
      z_with_siblings: z
    } do
      actual = Zipper.next_sibling(z)
      assert 6 == actual.focus.term
    end

    test "should return the first next sibling node for Zipper that matches the predicate",
         %{
           z_with_siblings: z
         } do
      predicate = &(&1.term == 8)

      actual = Zipper.next_sibling(z, predicate)
      assert 8 == actual.focus.term
    end
  end

  describe "sibling_at/2" do
    test "should return nil when given a Zipper with no siblings", %{simple_z: z} do
      for _ <- 0..5 do
        idx = Enum.random(0..10)
        assert Zipper.sibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that is out of bounds for the siblings of the Zipper",
         %{z_with_siblings: z} do
      num_siblings = Enum.count(z.prev) + Enum.count(z.next) + 1

      for _ <- 0..5 do
        idx = Enum.random(num_siblings..20)
        assert Zipper.sibling_at(z, idx) == nil
      end
    end

    test "should return nil when given an index that matches the current Zipper's index",
         %{z_with_siblings: z} do
      current_idx = Enum.count(z.prev)

      assert Zipper.sibling_at(z, current_idx) == nil
    end
  end
end
