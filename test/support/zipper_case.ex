defmodule ZipperCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to pre-populated `ExRoseTree.Zipper`
  structs.
  """

  use ExUnit.CaseTemplate

  alias ExRoseTree.Zipper
  alias ExRoseTree.Zipper.Location
  alias ExRoseTree.Support.Zippers

  using do
    quote do
      import ExUnit.CaptureLog

      require ExRoseTree
      require ExRoseTree.Zipper

      alias ExRoseTree
      alias ExRoseTree.{Util, Zipper}
      alias ExRoseTree.Zipper.Location
      alias ExRoseTree.Support.{Generators, Zippers}
    end
  end

  setup_all do
    %{
      empty_z: Zippers.empty_z(),
      leaf_z: Zippers.leaf_z(),
      simple_z: Zippers.simple_z(),
      z_with_parent: Zippers.z_with_parent(),
      z_with_grandparent: Zippers.z_with_grandparent(),
      z_with_great_grandparent: Zippers.z_with_great_grandparent(),
      z_with_grandchildren: Zippers.z_with_grandchildren(),
      z_with_grandchildren_2: Zippers.z_with_grandchildren_2(),
      z_with_great_grandchildren: Zippers.z_with_great_grandchildren(),
      z_with_great_grandchildren_2: Zippers.z_with_great_grandchildren_2(),
      z_with_siblings: Zippers.z_with_siblings(),
      z_with_piblings: Zippers.z_with_piblings(),
      z_with_grandpiblings: Zippers.z_with_grandpiblings(),
      z_with_ancestral_piblings: Zippers.z_with_ancestral_piblings(),
      z_with_no_ancestral_piblings: Zippers.z_with_no_ancestral_piblings(),
      z_with_niblings: Zippers.z_with_niblings(),
      z_with_grand_niblings: Zippers.z_with_grand_niblings(),
      z_with_descendant_niblings: Zippers.z_with_descendant_niblings(),
      z_with_extended_niblings: Zippers.z_with_extended_niblings(),
      z_with_1st_cousins: Zippers.z_with_1st_cousins(),
      z_with_2nd_cousins: Zippers.z_with_2nd_cousins(),
      z_with_extended_cousins: Zippers.z_with_extended_cousins(),
      z_with_extended_cousins_2: Zippers.z_with_extended_cousins_2(),
      z_depth_first: Zippers.z_depth_first(),
      z_depth_first_siblings: Zippers.z_depth_first_siblings(),
      z_depth_first_siblings_at_end: Zipper.descend_to_last(Zippers.z_depth_first_siblings()),
      z_breadth_first: Zippers.z_breadth_first(),
      z_breadth_first_siblings: Zippers.z_breadth_first_siblings(),
      z_breadth_first_siblings_at_end: Zipper.forward_to_last(Zippers.z_breadth_first_siblings())
    }
  end
end
