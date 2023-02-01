defmodule RoseTree.Support.Generators do
  require Logger

  alias RoseTree.{TreeNode, Util}
  alias RoseTree.Zipper.{Context, Location}

  @typep default_seed() :: %{
    current_depth: non_neg_integer(),
    num_children: non_neg_integer(),
    shares_for_children: non_neg_integer()
  }

  @spec random_tree(keyword()) :: TreeNode.t()
  def random_tree(options \\ []) do
    {initial_seed, unfolder_fn} = default_init(options)

    TreeNode.unfold(initial_seed, unfolder_fn)
  end

  @spec random_zipper(keyword()) :: Context.t()
  def random_zipper(options \\ []) do
    focus = random_tree(options)

    %Context{
      focus: focus,
      prev: [],
      next: [],
      path: []
    }
    |> add_zipper_siblings(options)
    |> add_zipper_locations(options)
  end

  @spec add_zipper_siblings(Context.t(), keyword()) :: Context.t()
  def add_zipper_siblings(%Context{} = ctx, options \\ []) do
    num_siblings = Keyword.get(options, :num_siblings, Enum.random(0..5))

    if num_siblings == 0 do
      ctx

    else
      random_trees = for _ <- 0..num_siblings-1, do: random_tree(options)

      {prev, next} =
        random_trees
        |> Util.split_at(Enum.random(0..num_siblings-1))

      %Context{ctx | prev: prev, next: next}
    end
  end

  @spec add_zipper_locations(Context.t(), keyword()) :: Context.t()
  def add_zipper_locations(%Context{} = ctx, options \\ []) do
    num_locations = Keyword.get(options, :num_locations, Enum.random(0..5))

    if num_locations == 0 do
      ctx

    else
      random_locations =
        for _ <- 0..num_locations-1 do
           ctx = random_zipper(num_locations: 0)
           %Location{prev: ctx.prev, term: ctx.focus.term, next: ctx.next}
        end

      %Context{ctx | path: random_locations}
    end
  end

  @spec default_unfolder(default_seed(), non_neg_integer()) :: {pos_integer(), [default_seed()]}
  def default_unfolder(seed, max_children) do
    range = 10_000

    case seed do
      # stop if we run out of total remaining seeds
      %{current_depth: _current_depth,
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

  @spec default_init(keyword()) :: {default_seed(), TreeNode.unfold_fn()}
  def default_init(options \\ []) do
    total_nodes = Keyword.get(options, :total_nodes, random_number_of_nodes())

    max_children = Keyword.get(options, :max_children, total_nodes - 1)

    root_children = if max_children == 0 do 0 else :rand.uniform(max_children) end

    initial_seed = new_seed(0, root_children, total_nodes - root_children - 1)

    unfolder_fn = &default_unfolder(&1, max_children)

    {initial_seed, unfolder_fn}
  end

  @spec new_seed(non_neg_integer(), non_neg_integer(), non_neg_integer()) :: default_seed()
  def new_seed(current_depth, num_children, shares_for_children) do
    %{current_depth: current_depth, num_children: num_children, shares_for_children: shares_for_children}
  end

  @spec random_number_of_nodes() :: 1..100
  def random_number_of_nodes(), do: :rand.uniform(100)
end
