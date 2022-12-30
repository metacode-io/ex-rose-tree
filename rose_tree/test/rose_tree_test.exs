defmodule RoseTreeTest do
  use ExUnit.Case
  doctest RoseTree

  test "greets the world" do
    assert RoseTree.hello() == :world
  end
end
