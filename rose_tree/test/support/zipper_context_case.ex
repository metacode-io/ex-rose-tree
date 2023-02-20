# defmodule RoseTree.ZipperZipperCase do
#   @moduledoc """
#   This module defines the setup for tests requiring
#   access to pre-populated `RoseTree.Zipper.Zipper`
#   structs.
#   """

#   use ExUnit.CaseTemplate

#   alias RoseTree.TreeNode
#   alias RoseTree.Zipper.Location
#   alias RoseTree.Support.Generators

#   using do
#     quote do
#       import ExUnit.CaptureLog

#       require RoseTree
#       require RoseTree.Zipper.Zipper

#       alias RoseTree.{TreeNode, Util}
#       alias RoseTree.Zipper.{Zipper, Location}
#       alias RoseTree.Support.Generators
#     end
#   end

#   setup_all do
#     # basic trees
#     empty_tree = %TreeNode{term: nil, children: []}
#     leaf_tree = %TreeNode{term: 1, children: []}

#     simple_tree = %TreeNode{
#       term: 1,
#       children: [
#         %TreeNode{term: 2, children: []},
#         %TreeNode{term: 3, children: []},
#         %TreeNode{term: 4, children: []}
#       ]
#     }

#     # random trees

#     tree_x5 = Generators.random_tree(total_nodes: 5)
#     tree_x25 = Generators.random_tree(total_nodes: 25)
#     tree_x100 = Generators.random_tree(total_nodes: 100)
#     tree_x = Generators.random_tree()

#     # basic zipper contexts
#     empty_z = %Zipper{focus: empty_tree, prev: [], next: [], path: []}
#     leaf_z = %Zipper{focus: leaf_tree, prev: [], next: [], path: []}
#     simple_z = %Zipper{focus: simple_tree, prev: [], next: [], path: []}

#     # random zipper contexts
#     z_x5 = %Zipper{focus: tree_x5, prev: [], next: [], path: []}
#     z_x25 = %Zipper{focus: tree_x25, prev: [], next: [], path: []}
#     z_x100 = %Zipper{focus: tree_x100, prev: [], next: [], path: []}
#     z_x = %Zipper{focus: tree_x, prev: [], next: [], path: []}

#     all_trees_with_idx =
#       [
#         empty_tree,
#         leaf_tree,
#         simple_tree,
#         tree_x5,
#         tree_x25,
#         tree_x100,
#         tree_x
#       ]
#       |> Enum.with_index()

#     all_zippers_with_idx =
#       [
#         empty_z,
#         leaf_z,
#         simple_z,
#         z_x5,
#         z_x25,
#         z_x100,
#         z_x
#       ]
#       |> Enum.with_index()

#     %{
#       # trees
#       all_trees_with_idx: all_trees_with_idx,
#       empty_tree: empty_tree,
#       leaf_tree: leaf_tree,
#       simple_tree: simple_tree,
#       tree_x: tree_x,
#       tree_x5: tree_x5,
#       tree_x25: tree_x25,
#       tree_x100: tree_x100,
#       # contexts
#       all_zippers_with_idx: all_zippers_with_idx,
#       empty_z: empty_z,
#       leaf_z: leaf_z,
#       simple_z: simple_z,
#       z_x5: z_x5,
#       z_x25: z_x25,
#       z_x100: z_x100,
#       z_x: z_x
#     }
#   end
# end
