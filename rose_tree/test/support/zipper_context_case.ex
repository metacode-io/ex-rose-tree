defmodule RoseTree.ZipperContextCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to pre-populated `RoseTree.Zipper.Context`
  structs.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      require RoseTree.TreeNode
      require RoseTree.Zipper.Context

      alias RoseTree.{TreeNode, Util}
      alias RoseTree.Zipper.{Context, Location}
    end
  end

  setup do
  end
end
