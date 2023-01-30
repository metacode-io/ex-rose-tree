defmodule RoseTree.Support.Generators do
  require Logger

  alias RoseTree.TreeNode

  @typep default_seed() :: %{
    current_depth: non_neg_integer(),
    num_children: non_neg_integer(),
    shares_for_children: non_neg_integer()
  }

  @spec random_tree(keyword()) :: RoseTree.TreeNode.t()
  def random_tree(options \\ []) do
    total_nodes = Keyword.get(options, :total_nodes, random_number_of_nodes())

    max_children = Keyword.get(options, :max_children, total_nodes - 1)

    root_children = if max_children == 0 do 0 else :rand.uniform(max_children) end

    initial_seed = new_seed(0, root_children, total_nodes - root_children - 1)

    # Logger.debug("Total Nodes: #{total_nodes}")
    # Logger.debug("Max Children Per Node: #{max_children}")
    # Logger.debug("Num Root Children: #{root_children}")

    unfolder_fn = &default_unfolder(&1, max_children)

    TreeNode.unfold(initial_seed, unfolder_fn)
  end

  def default_unfolder(seed, max_children) do
    range = 10_000

    case seed do
      # stop if we run out of total remaining seeds
      %{current_depth: current_depth,
        num_children: num_children,
        shares_for_children: _} when num_children <= 0 ->
        {:rand.uniform(range), []}

      %{current_depth: current_depth,
        num_children: num_children,
        shares_for_children: shares_for_children} ->
        new_depth = current_depth + 1

        {new_seeds, remaining_shares} =
          1..num_children
          |> Enum.reduce({[], shares_for_children}, fn
            _, {new_children, remaining_shares} when remaining_shares <= 0 ->
              new_child = new_seed(new_depth, 0, 0)
              {[new_child | new_children], 0}

            _, {new_children, remaining_shares} ->
              num_grandchildren = :rand.uniform(remaining_shares)
              num_grandchildren =
                if num_grandchildren > max_children do
                  max_children
                else
                  num_grandchildren
                end

              new_child = new_seed(new_depth, num_grandchildren, 0)
              {[new_child | new_children], remaining_shares - num_grandchildren}
          end)

        new_seeds =
          new_seeds
          |> allot_remaining_shares(remaining_shares)
          |> Enum.shuffle()

        {:rand.uniform(range), new_seeds}
    end
  end

  @spec allot_remaining_shares([default_seed()], non_neg_integer()) :: [default_seed()]
  def allot_remaining_shares(seeds, shares) do
    do_allot_remaining_shares([], seeds, shares)
  end

  defp do_allot_remaining_shares(processed, todo, shares) when shares <= 0,
    do: processed ++ todo

  defp do_allot_remaining_shares(processed, [] = _todo, shares),
    do: do_allot_remaining_shares([], processed, shares)

  defp do_allot_remaining_shares(processed, [seed | seeds] = _todo, shares) do
    allotted = :rand.uniform(shares)
    [%{seed | shares_for_children: seed.shares_for_children + allotted} | processed]
    |> do_allot_remaining_shares(seeds, shares - allotted)
  end

  @spec new_seed(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: default_seed()
  def new_seed(current_depth, num_children, shares_for_children) do
    %{current_depth: current_depth, num_children: num_children, shares_for_children: shares_for_children}
  end

  @spec random_number_of_nodes() :: 1..100
  def random_number_of_nodes(), do: :rand.uniform(100)
end
