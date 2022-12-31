defmodule RoseTree.Zipper.Context do
  @moduledoc """
  Data structure representing a Zipper's positional context.
  """

  require RoseTree.TreeNode
  require RoseTree.Zipper.Location

  alias RoseTree.TreeNode
  alias RoseTree.Zipper.Location

  @enforce_keys [:focus, :prev, :next, :path]
  defstruct ~w(focus prev next path)a

  @type t :: %__MODULE__{
    focus: TreeNode.t(),
    prev: [TreeNode.t()],
    next: [TreeNode.t()],
    path: [Location.t()]
  }

  @spec context?(term()) :: boolean()
  defguard context?(value) when is_struct(value) and value.__struct__ == __MODULE__

  @spec empty?(term()) :: boolean()
  defguard empty?(value)
           when context?(value) and
                  TreeNode.empty?(value.focus) and
                  value.prev == [] and
                  value.next == [] and
                  value.path == []

  @doc """
  Returns an empty Context.

  ## Examples

      iex> RoseTree.Zipper.Context.empty()
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: nil, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @spec empty() :: t()
  def empty() do
    %__MODULE__{
      focus: TreeNode.empty(),
      prev: [],
      next: [],
      path: []
    }
  end

  @doc """
  Returns a new `Context` with its focus on the given `RoseTree.TreeNode`.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> RoseTree.Zipper.Context.new(node)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [],
        next: [],
        path: []
      }

      iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5, [])
      ...> RoseTree.Zipper.Context.new(node, prev: prev)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
        ],
        next: [],
        path: []
      }

      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5, [])
      ...> RoseTree.Zipper.Context.new(node, path: locs)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [],
        next: [],
        path: [
          %RoseTree.Zipper.Location{prev: [], term: 4, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 3, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 2, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 1, next: []}
        ]
      }

  """
  @spec new(TreeNode.t(), keyword()) :: t()
  def new(focus, opts \\ [])

  def new(focus, opts) do
    prev = Keyword.get(opts, :prev, [])
    next = Keyword.get(opts, :next, [])
    path = Keyword.get(opts, :path, [])

    do_new(focus, prev, next, path)
  end

  @doc false
  @spec do_new(TreeNode.t(), [TreeNode.t()], [TreeNode.t()], [Location.t()]) :: t()
  defp do_new(focus, prev, next, path)
      when TreeNode.tree_node?(focus) and
            is_list(prev) and
            is_list(next) and
            is_list(path) do
    case {TreeNode.all_tree_nodes?(prev),
          TreeNode.all_tree_nodes?(next),
          Location.all_locations?(path)} do
      {true, true, true} ->
        %__MODULE__{
          focus: focus,
          prev: prev,
          next: next,
          path: path
        }

      {true, true, false} ->
        raise ArgumentError, message: "invalid element in path"

      {true, false, _} ->
        raise ArgumentError, message: "invalid element in next"

      {false, _, _} ->
        raise ArgumentError, message: "invalid element in prev"
    end
  end

  @doc """
  Returns whether or not the current Context is at the root of the tree.
  A Context is considered at the root when it has no Locations in its path.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Context.root?(ctx)
      true

  """
  @spec root?(t()) :: boolean()
  def root?(%__MODULE__{path: []}), do: true
  def root?(_), do: false

  @doc """
  Returns the current focus of the Context.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Context.current_focus(ctx)
      %RoseTree.TreeNode{term: 5, children: []}

  """
  @spec current_focus(t()) :: TreeNode.t()
  def current_focus(%__MODULE__{focus: focus}),
    do: focus

  @doc """
  Returns the siblings that come before the current focus.

  ## Examples

      iex> prev = for t <- [4,3,2,1], do: RoseTree.TreeNode.new(t)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev)
      ...> RoseTree.Zipper.Context.siblings_before_focus(ctx)
      [
        %RoseTree.TreeNode{term: 1, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 4, children: []}
      ]

  """
  @spec siblings_before_focus(t()) :: [TreeNode.t()]
  def siblings_before_focus(%__MODULE__{prev: prev}),
    do: Enum.reverse(prev)

  @doc """
  Returns the siblings that come after the current focus.

  ## Examples

      iex> next = for t <- [6,7,8,9], do: RoseTree.TreeNode.new(t)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, next: next)
      ...> RoseTree.Zipper.Context.siblings_after_focus(ctx)
      [
        %RoseTree.TreeNode{term: 6, children: []},
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 9, children: []}
      ]

  """
  @spec siblings_after_focus(t()) :: [TreeNode.t()]
  def siblings_after_focus(%__MODULE__{next: next}),
    do: next

  @doc """
  Returns the depth (as zero-based index) of the current focus.

  ## Examples
      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5, [])
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> RoseTree.Zipper.Context.depth_of_focus(ctx)
      4

  """
  @spec depth_of_focus(t()) :: integer()
  def depth_of_focus(%__MODULE__{path: path}),
    do: Enum.count(path)

end
