defmodule RoseTree.Zipper.Context do
  @moduledoc """
  Data structure representing a Zipper's positional context within
  the RoseTree.
  """

  require RoseTree.TreeNode
  require RoseTree.Zipper.Location

  alias RoseTree.TreeNode
  alias RoseTree.Zipper.Location

  @enforce_keys [:focus]
  defstruct [
    :focus,
    prev: [],
    next: [],
    path: []
  ]

  @type t :: %__MODULE__{
          focus: TreeNode.t(),
          prev: [TreeNode.t()],
          next: [TreeNode.t()],
          path: [Location.t()]
        }

  defguard context?(value)
           when is_struct(value) and
                  value.__struct__ == __MODULE__ and
                  TreeNode.tree_node?(value.focus) and
                  is_list(value.prev) and
                  is_list(value.next) and
                  is_list(value.path)

  defguard empty?(value)
           when context?(value) and
                  TreeNode.empty?(value.focus) and
                  value.prev == [] and
                  value.next == [] and
                  value.path == []

  defguard at_root?(value)
           when context?(value) and value.path == []

  defguard has_children?(value)
           when context?(value) and not TreeNode.leaf?(value.focus)

  defguard has_siblings?(value)
           when context?(value) and (value.prev != [] or value.next != [])

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
      ...> node = RoseTree.TreeNode.new(5)
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
      ...> node = RoseTree.TreeNode.new(5)
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
    case {TreeNode.all_tree_nodes?(prev), TreeNode.all_tree_nodes?(next),
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
  Returns the children of the Context's current focus.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4,3,2,1])
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Context.focused_children(ctx)
      [
        %RoseTree.TreeNode{term: 4, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 1, children: []}
      ]

  """
  @spec focused_children(t()) :: [TreeNode.t()]
  def focused_children(%__MODULE__{focus: focus}),
    do: TreeNode.get_children(focus)

  @doc """
  Returns the siblings that come before the current focus.

  ## Examples

      iex> prev = for t <- [1,2,3,4], do: RoseTree.TreeNode.new(t)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev)
      ...> RoseTree.Zipper.Context.prev_siblings(ctx)
      [
        %RoseTree.TreeNode{term: 4, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 1, children: []}
      ]

  """
  @spec prev_siblings(t()) :: [TreeNode.t()]
  def prev_siblings(%__MODULE__{prev: prev}),
    do: Enum.reverse(prev)

  @doc """
  Returns the siblings that come after the current focus.

  ## Examples

      iex> next = for t <- [6,7,8,9], do: RoseTree.TreeNode.new(t)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, next: next)
      ...> RoseTree.Zipper.Context.next_siblings(ctx)
      [
        %RoseTree.TreeNode{term: 6, children: []},
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 9, children: []}
      ]

  """
  @spec next_siblings(t()) :: [TreeNode.t()]
  def next_siblings(%__MODULE__{next: next}),
    do: next

  @doc """
  Returns the depth (as zero-based index) of the current focus.

  ## Examples
      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> RoseTree.Zipper.Context.depth_of_focus(ctx)
      4

  """
  @spec depth_of_focus(t()) :: non_neg_integer()
  def depth_of_focus(%__MODULE__{path: path}),
    do: Enum.count(path)

  @doc """
  Returns the index (zero-based) of the current focus with respect to
  any potential siblings it may have.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev)
      ...> RoseTree.Zipper.Context.index_of_focus(ctx)
      4

  """
  @spec index_of_focus(t()) :: non_neg_integer()
  def index_of_focus(%__MODULE__{prev: prev}),
    do: Enum.count(prev)

  @doc """
  Returns the index (zero-based) of the current focus' parent with
  respect to any potentital siblings it may have. If the current
  focus has no parent, returns nil.

  ## Examples

      iex> parent_siblings = for n <- [3,2,1], do: RoseTree.TreeNode.new(n)
      ...> parent_loc = RoseTree.Zipper.Location.new(4, prev: parent_siblings)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: [parent_loc])
      ...> RoseTree.Zipper.Context.index_of_parent(ctx)
      3

  """
  @spec index_of_parent(t()) :: non_neg_integer() | nil
  def index_of_parent(%__MODULE__{path: []}), do: nil

  def index_of_parent(%__MODULE__{path: [parent | _]}),
    do: Location.index_of_term(parent)

  @doc """
  Returns the current context's parent location.

  ## Examples
      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> RoseTree.Zipper.Context.parent_location(ctx)
      %RoseTree.Zipper.Location{prev: [], term: 4, next: []}

  """
  @spec parent_location(t()) :: Location.t() | nil
  def parent_location(%__MODULE__{path: []}), do: nil

  def parent_location(%__MODULE__{path: [parent | _]}), do: parent

  @doc """
  Returns the term in the current context's parent location.

  ## Examples
      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> RoseTree.Zipper.Context.parent_term(ctx)
      4

  """
  @spec parent_term(t()) :: TreeNode.t() | nil
  def parent_term(%__MODULE__{path: []}), do: nil

  def parent_term(%__MODULE__{path: [parent | _]}), do: parent.term

  @doc """
  Sets the current focus of the context to the given tree node.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.empty()
      ...> RoseTree.Zipper.Context.set_focus(ctx, node)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @spec set_focus(t(), TreeNode.t()) :: t()
  def set_focus(ctx, new_focus)

  def set_focus(%__MODULE__{} = ctx, new_focus) when TreeNode.tree_node?(new_focus),
    do: %{ctx | focus: new_focus}

  @doc """
  Applies the given function to the current focus.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> map_fn = &RoseTree.TreeNode.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.Context.map_focus(ctx, &map_fn.(&1))
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 10, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @spec map_focus(t(), (TreeNode.t() -> TreeNode.t())) :: t()
  def map_focus(%__MODULE__{focus: focus} = ctx, map_fn) when is_function(map_fn) do
    case map_fn.(focus) do
      new_focus when TreeNode.tree_node?(new_focus) ->
        set_focus(ctx, new_focus)

      err ->
        raise ArgumentError, "map_fn must return a valid RoseTree.TreeNode struct"
    end
  end

  @doc """
  Applies the given function to all previous siblings of the current focus without
  moving the context.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev)
      ...> map_fn = &RoseTree.TreeNode.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.Context.map_prev_siblings(ctx, &map_fn.(&1))
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 6, children: []},
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 2, children: []}
        ],
        next: [],
        path: []
      }

  """
  @spec map_prev_siblings(t(), (TreeNode.t() -> TreeNode.t())) :: t()
  def map_prev_siblings(%__MODULE__{prev: prev} = ctx, map_fn) when is_function(map_fn) do
    new_siblings =
      prev
      |> Enum.map(fn sibling -> map_fn.(sibling) end)

    if TreeNode.all_tree_nodes?(new_siblings) do
      %{ctx | prev: new_siblings}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree.TreeNode struct"
    end
  end

  @doc """
  Applies the given function to all next siblings of the current focus without
  moving the context.

  ## Examples

      iex> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, next: next)
      ...> map_fn = &RoseTree.TreeNode.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.Context.map_next_siblings(ctx, &map_fn.(&1))
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [],
        next: [
          %RoseTree.TreeNode{term: 12, children: []},
          %RoseTree.TreeNode{term: 14, children: []},
          %RoseTree.TreeNode{term: 16, children: []},
          %RoseTree.TreeNode{term: 18, children: []}
        ],
        path: []
      }

  """
  @spec map_next_siblings(t(), (TreeNode.t() -> TreeNode.t())) :: t()
  def map_next_siblings(%__MODULE__{next: next} = ctx, map_fn) when is_function(map_fn) do
    new_siblings =
      next
      |> Enum.map(fn sibling -> map_fn.(sibling) end)

    if TreeNode.all_tree_nodes?(new_siblings) do
      %{ctx | next: new_siblings}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree.TreeNode struct"
    end
  end

  @doc """
  Applies the given function to path of locations from the current focus back to the root
  without moving the context.

  ## Examples

      iex> path = for n <- [4,3,2,1], do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: path)
      ...> map_fn = &RoseTree.Zipper.Location.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.Context.map_path(ctx, &map_fn.(&1))
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 5, children: []},
        prev: [],
        next: [],
        path: [
          %RoseTree.Zipper.Location{prev: [], term: 8, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 6, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 4, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 2, next: []}]
      }

  """
  @spec map_path(t(), (Location.t() -> Location.t())) :: t()
  def map_path(%__MODULE__{path: path} = ctx, map_fn) when is_function(map_fn) do
    new_locations =
      path
      |> Enum.map(fn location -> map_fn.(location) end)

    if Location.all_locations?(new_locations) do
      %{ctx | path: new_locations}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree.Zipper.Location struct"
    end
  end

  @doc """
  Builds a new location out of the current context.

  ## Examples

      iex> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, next: next)
      ...> RoseTree.Zipper.Context.new_location(ctx)
      %RoseTree.Zipper.Location{
        prev: [],
        term: 5,
        next: [
          %RoseTree.TreeNode{term: 6, children: []},
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 9, children: []}
        ]
      }

  """
  @spec new_location(t()) :: Location.t()
  def new_location(%__MODULE__{focus: focus, prev: prev, next: next}) do
    Location.new(focus, prev: prev, next: next)
  end

  @doc """
  Builds a new Context from a list of Locations.

  ## Examples

      iex> locs = for loc <- [3,2,1], do: RoseTree.Zipper.Location.new(loc)
      ...> RoseTree.Zipper.Context.from_locations(locs)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 3, children: []},
        prev: [],
        next: [],
        path: [
          %RoseTree.Zipper.Location{
            prev: [],
            term: 2,
            next: []
          },
          %RoseTree.Zipper.Location{
            prev: [],
            term: 1,
            next: []
          }
        ]
      }

  """
  @spec from_locations([Location.t()]) :: Context.t()
  def from_locations([%Location{} = loc | locs]) when Location.location?(loc) do
    loc.term
    |> TreeNode.new()
    |> new(prev: loc.prev, next: loc.next, path: locs)
  end
end
