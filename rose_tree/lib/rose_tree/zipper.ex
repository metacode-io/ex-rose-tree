defmodule RoseTree.Zipper do
  @moduledoc """
  Includes both basic and highly specialized functionality for both manipulation
  of a Zipper's current context and traversal across the data.
  """

  require Logger
  require RoseTree
  require RoseTree.Zipper.Location

  alias RoseTree
  alias RoseTree.Util
  alias RoseTree.Zipper.Location

  @enforce_keys [:focus]
  defstruct [
    :focus,
    prev: [],
    next: [],
    path: []
  ]

  @typedoc """
  The Zipper struct represents a contextual position within a `RoseTree`.

  It includes the following important pieces:
  * `focus` - the current _focus_ or _context_ within the `RoseTree.Zipper`. Its
    type is that of a `RoseTree`.
  * `prev` - all siblings occurring before the current `focus`. It's type is a list of
    `RoseTree`s and is maintained in reverse order, so that the immediately previous
    sibling to the `focus` is at the head of the list.
  * `next` - all siblings occurring after the current `focus`. It's type is a list of
    `RoseTree`s and is maintained in standard order.
  * `path` - all direct ancestors of the the current `focus` back to the root node.
    It's type is a list of `RoseTree.Zipper.Location`s and is maintained in standard order.
    If the `path` is an empty list, then the Zipper is focused at the root node.
  """
  @type t :: %__MODULE__{
          focus: RoseTree.t(),
          prev: [RoseTree.t()],
          next: [RoseTree.t()],
          path: [Location.t()]
        }

  @typep predicate() :: (term() -> boolean())

  ###
  ### GUARDS
  ###

  @doc section: :guards
  defguard zipper?(value)
           when is_struct(value) and
                  value.__struct__ == __MODULE__ and
                  RoseTree.rose_tree?(value.focus) and
                  is_list(value.prev) and
                  is_list(value.next) and
                  is_list(value.path)

  @doc section: :guards
  defguard empty?(value)
           when zipper?(value) and
                  RoseTree.empty?(value.focus) and
                  value.prev == [] and
                  value.next == [] and
                  value.path == []

  @doc section: :guards
  defguard at_root?(value)
           when zipper?(value) and value.path == []

  @doc section: :guards
  defguard has_children?(value)
           when zipper?(value) and not RoseTree.leaf?(value.focus)

  @doc section: :guards
  defguard has_siblings?(value)
           when zipper?(value) and (value.prev != [] or value.next != [])

  ###
  ### BASIC
  ###

  @doc """
  Returns an empty Zipper.

  ## Examples

      iex> RoseTree.Zipper.empty()
      %RoseTree.Zipper{
        focus: %RoseTree{term: nil, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @doc section: :basic
  @spec empty() :: t()
  def empty() do
    %__MODULE__{
      focus: RoseTree.empty(),
      prev: [],
      next: [],
      path: []
    }
  end

  @doc """
  Returns a new `Zipper` with its focus on the given `RoseTree`.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> RoseTree.Zipper.new(tree)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [],
        next: [],
        path: []
      }

      iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> RoseTree.Zipper.new(tree, prev: prev)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ],
        next: [],
        path: []
      }

      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> RoseTree.Zipper.new(tree, path: locs)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
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
  @doc section: :basic
  @spec new(RoseTree.t(), keyword()) :: t()
  def new(focus, opts \\ [])

  def new(focus, opts) do
    prev = Keyword.get(opts, :prev, [])
    next = Keyword.get(opts, :next, [])
    path = Keyword.get(opts, :path, [])

    do_new(focus, prev, next, path)
  end

  @doc false
  @spec do_new(RoseTree.t(), [RoseTree.t()], [RoseTree.t()], [Location.t()]) :: t()
  defp do_new(focus, prev, next, path)
       when RoseTree.rose_tree?(focus) and
              is_list(prev) and
              is_list(next) and
              is_list(path) do
    case {RoseTree.all_rose_trees?(prev), RoseTree.all_rose_trees?(next),
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
  Returns whether or not the current Zipper is at the root of the tree.
  A Zipper is considered at the root when it has no Locations in its path.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.root?(z)
      true

  """
  @doc section: :basic
  @spec root?(t()) :: boolean()
  def root?(%__MODULE__{path: []}), do: true
  def root?(_), do: false

  @doc """
  Returns the current focus of the Zipper.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.current_focus(z)
      %RoseTree{term: 5, children: []}

  """
  @doc section: :basic
  @spec current_focus(t()) :: RoseTree.t()
  def current_focus(%__MODULE__{focus: focus}),
    do: focus

  @doc """
  Returns the depth (as zero-based index) of the current focus.

  ## Examples
      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: locs)
      ...> RoseTree.Zipper.depth_of_focus(z)
      4

  """
  @doc section: :basic
  @spec depth_of_focus(t()) :: non_neg_integer()
  def depth_of_focus(%__MODULE__{path: path}),
    do: Enum.count(path)

  @doc """
  Returns the index (zero-based) of the current focus with respect to
  any potential siblings it may have.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, prev: prev)
      ...> RoseTree.Zipper.index_of_focus(z)
      4

  """
  @doc section: :basic
  @spec index_of_focus(t()) :: non_neg_integer()
  def index_of_focus(%__MODULE__{prev: prev}),
    do: Enum.count(prev)

  @doc """
  Sets the current focus of the zipper to the given RoseTree.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.empty()
      ...> RoseTree.Zipper.set_focus(z, tree)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @doc section: :basic
  @spec set_focus(t(), RoseTree.t()) :: t()
  def set_focus(z, new_focus)

  def set_focus(%__MODULE__{} = z, new_focus) when RoseTree.rose_tree?(new_focus),
    do: %{z | focus: new_focus}

  @doc """
  Applies the given function to the current focus.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree)
      ...> map_fn = &RoseTree.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.map_focus(z, &map_fn.(&1))
      %RoseTree.Zipper{
        focus: %RoseTree{term: 10, children: []},
        prev: [],
        next: [],
        path: []
      }

  """
  @doc section: :basic
  @spec map_focus(t(), (RoseTree.t() -> RoseTree.t())) :: t()
  def map_focus(%__MODULE__{focus: focus} = z, map_fn) when is_function(map_fn) do
    case map_fn.(focus) do
      new_focus when RoseTree.rose_tree?(new_focus) ->
        set_focus(z, new_focus)

      _ ->
        raise ArgumentError, "map_fn must return a valid RoseTree struct"
    end
  end

  @doc """
  Removes the current focus and then moves the focus to one of three places:
  1. the next sibling, if one exists,
  2. else the previous sibling, if one exists,
  3. else the parent, if one exists

  If none of those conditions exist, it will return an empty zipper. In any case,
  the new zipper will be returned as the first item in a tuple, while the removed
  focus will be returned as the second item.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> prev_siblings = for n <- [4,3], do: RoseTree.new(n)
      ...> next_siblings = for n <- [6,7], do: RoseTree.new(n)
      ...> z = RoseTree.Zipper.new(tree, prev: prev_siblings, next: next_siblings)
      ...> RoseTree.Zipper.remove_focus(z)
      {%RoseTree.Zipper{
        focus: %RoseTree{term: 6, children: []},
        prev: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []}
        ],
        next: [
          %RoseTree{term: 7, children: []}
        ],
        path: []
      },
      %RoseTree{term: 5, children: []}}

  """
  @doc section: :basic
  @spec remove_focus(t()) :: {t(), RoseTree.t() | nil}
  def remove_focus(%__MODULE__{} = z) when empty?(z), do: {z, nil}

  def remove_focus(%__MODULE__{prev: [], next: [], path: []} = z), do: {empty(), nil}

  def remove_focus(%__MODULE__{prev: [], next: []} = z),
    do: {do_parental_shift(z, []), z.focus}

  def remove_focus(%__MODULE__{prev: [new_focus | new_prev], next: []} = z) do
    shift_previous = %{
      z
      | focus: new_focus,
        prev: new_prev,
        next: [],
        path: z.path
    }

    {shift_previous, z.focus}
  end

  def remove_focus(%__MODULE__{next: [new_focus | new_next]} = z) do
    shift_next = %{
      z
      | focus: new_focus,
        prev: z.prev,
        next: new_next,
        path: z.path
    }

    {shift_next, z.focus}
  end

  @doc """
  Applies the given function to path of locations from the current focus back to the root
  without moving the zipper.

  ## Examples

      iex> path = for n <- [4,3,2,1], do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: path)
      ...> map_fn = &RoseTree.Zipper.Location.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.map_path(z, &map_fn.(&1))
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [],
        next: [],
        path: [
          %RoseTree.Zipper.Location{prev: [], term: 8, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 6, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 4, next: []},
          %RoseTree.Zipper.Location{prev: [], term: 2, next: []}]
      }

  """
  @doc section: :basic
  @spec map_path(t(), (Location.t() -> Location.t())) :: t()
  def map_path(%__MODULE__{path: path} = z, map_fn) when is_function(map_fn) do
    new_locations =
      path
      |> Enum.map(fn location -> map_fn.(location) end)

    if Location.all_locations?(new_locations) do
      %{z | path: new_locations}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree.Zipper.Location struct"
    end
  end

  @doc """
  Builds a new location out of the current zipper.

  ## Examples

      iex> next = for n <- [6,7,8,9], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, next: next)
      ...> RoseTree.Zipper.new_location(z)
      %RoseTree.Zipper.Location{
        prev: [],
        term: 5,
        next: [
          %RoseTree{term: 6, children: []},
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 9, children: []}
        ]
      }

  """
  @doc section: :basic
  @spec new_location(t()) :: Location.t()
  def new_location(%__MODULE__{focus: focus, prev: prev, next: next}) do
    Location.new(focus, prev: prev, next: next)
  end

  @doc """
  Builds a new Zipper from a list of Locations.

  ## Examples

      iex> locs = for loc <- [3,2,1], do: RoseTree.Zipper.Location.new(loc)
      ...> RoseTree.Zipper.from_locations(locs)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 3, children: []},
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
  @doc section: :basic
  @spec from_locations([Location.t()]) :: t()
  def from_locations([%Location{} = loc | locs]) when Location.location?(loc) do
    loc.term
    |> RoseTree.new()
    |> new(prev: loc.prev, next: loc.next, path: locs)
  end

  ###
  ### DIRECT ANCESTORS (PARENTS, GRANDPARENTS, ETC)
  ###

  @doc """
  Returns the index (zero-based) of the current focus' parent with
  respect to any potentital siblings it may have. If the current
  focus has no parent, returns nil.

  ## Examples

      iex> parent_siblings = for n <- [3,2,1], do: RoseTree.new(n)
      ...> parent_loc = RoseTree.Zipper.Location.new(4, prev: parent_siblings)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: [parent_loc])
      ...> RoseTree.Zipper.index_of_parent(z)
      3

  """
  @doc section: :ancestors
  @spec index_of_parent(t()) :: non_neg_integer() | nil
  def index_of_parent(%__MODULE__{path: []}), do: nil

  def index_of_parent(%__MODULE__{path: [parent | _]}),
    do: Location.index_of_term(parent)

  @doc """
  Returns the index (zero-based) of the current focus' grandparent with
  respect to any potentital siblings it may have. If the current
  focus has no grandparent, returns nil.

  ## Examples

      iex> grandparent_siblings = for n <- [3,2,1], do: RoseTree.new(n)
      ...> grandparent_loc = RoseTree.Zipper.Location.new(4, prev: grandparent_siblings)
      ...> parent_loc = RoseTree.Zipper.Location.new(5)
      ...> tree = RoseTree.new(6)
      ...> z = RoseTree.Zipper.new(tree, path: [parent_loc, grandparent_loc])
      ...> RoseTree.Zipper.index_of_grandparent(z)
      3

  """
  @doc section: :ancestors
  @spec index_of_grandparent(t()) :: non_neg_integer() | nil
  def index_of_grandparent(%__MODULE__{path: []}), do: nil

  def index_of_grandparent(%__MODULE__{path: [_parent | []]}), do: nil

  def index_of_grandparent(%__MODULE__{path: [_parent | [grandparent | _]]}),
    do: Location.index_of_term(grandparent)

  @doc """
  Returns the current zipper's parent location.

  ## Examples
      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: locs)
      ...> RoseTree.Zipper.parent_location(z)
      %RoseTree.Zipper.Location{prev: [], term: 4, next: []}

  """
  @doc section: :ancestors
  @spec parent_location(t()) :: Location.t() | nil
  def parent_location(%__MODULE__{path: []}), do: nil

  def parent_location(%__MODULE__{path: [parent | _]}), do: parent

  @doc """
  Returns the term in the current zipper's parent location.

  ## Examples
      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: locs)
      ...> RoseTree.Zipper.parent_term(z)
      4

  """
  @doc section: :ancestors
  @spec parent_term(t()) :: RoseTree.t() | nil
  def parent_term(%__MODULE__{path: []}), do: nil

  def parent_term(%__MODULE__{path: [parent | _]}), do: parent.term

  @doc """
  Moves the focus to the parent Location. If at the root, thus no
  parent, returns nil.

  ## Examples

      iex> prev = for n <- [4,3], do: RoseTree.new(n)
      ...> loc_trees = for n <- [2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, prev: prev, path: locs)
      ...> RoseTree.Zipper.parent(z)
      %RoseTree.Zipper{
        focus: %RoseTree{
          term: 2,
          children: [
            %RoseTree{term: 3, children: []},
            %RoseTree{term: 4, children: []},
            %RoseTree{term: 5, children: []}
          ]
        },
        prev: [],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 1, next: []}]
      }

  """
  @doc section: :ancestors
  @spec parent(t()) :: t() | nil
  def parent(%__MODULE__{path: []}), do: nil

  def parent(%__MODULE__{path: [parent | g_parents]} = z) do
    combined_siblings = Enum.reverse(z.prev) ++ [z.focus | z.next]

    z
    |> do_parental_shift(combined_siblings)
  end

  @spec do_parental_shift(t(), [RoseTree.t()]) :: t()
  defp do_parental_shift(%__MODULE__{path: []}), do: nil

  defp do_parental_shift(%__MODULE__{path: [parent | g_parents]} = z, combined_siblings)
       when is_list(combined_siblings) do
    focused_parent =
      parent.term
      |> RoseTree.new(combined_siblings)

    %{z | prev: parent.prev, next: parent.next, path: g_parents}
    |> set_focus(focused_parent)
  end

  @doc """
  Moves the focus to the grandparent -- the parent of the parent -- of
  the focus, if possible. If there is no grandparent, returns nil.
  """
  @doc section: :ancestors
  @spec grandparent(t()) :: t() | nil
  def grandparent(%__MODULE__{} = z) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = grandparent <- parent(parent) do
      grandparent
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the great-grandparent -- parent of the grand-parent -- of
  the focus, if available. If there is no great-grandparent, returns nil.
  """
  @doc section: :ancestors
  @spec great_grandparent(t()) :: t() | nil
  def great_grandparent(%__MODULE__{} = z) do
    with %__MODULE__{} = grandparent <- grandparent(z),
         %__MODULE__{} = great_grandparent <- parent(grandparent) do
      great_grandparent
    else
      nil ->
        nil
    end
  end

  ###
  ### DESCENDANTS (CHILDREN, GRAND-CHILDREN, ETC.)
  ###

  @doc """
  Returns the children of the Zipper's current focus.

  ## Examples

      iex> tree = RoseTree.new(5, [4,3,2,1])
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.children(z)
      [
        %RoseTree{term: 4, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 1, children: []}
      ]

  """
  @doc section: :descendants
  @spec children(t()) :: [RoseTree.t()]
  def children(%__MODULE__{focus: focus}),
    do: RoseTree.get_children(focus)

  @doc """
  Moves focus to the first child. If there are no children, and this is
  a leaf, returns nil.

  ## Examples

      iex> tree = RoseTree.new(5, [6,7,8,9])
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.first_child(z)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 6, children: []},
        prev: [],
        next: [
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 9, children: []}
        ],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

      iex> tree = RoseTree.new(5, [6,7,8,9])
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.first_child(z, fn x -> x.term == 9 end)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 9, children: []},
        prev: [
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 6, children: []}
        ],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @doc section: :descendants
  @spec first_child(t(), predicate()) :: t() | nil
  def first_child(zipper, predicate \\ &Util.always/1)

  def first_child(%__MODULE__{focus: focus}, _predicate)
      when RoseTree.empty?(focus) or RoseTree.leaf?(focus),
      do: nil

  def first_child(%__MODULE__{} = z, predicate) when is_function(predicate) do
    children = children(z)

    case Util.split_when(children, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          z
          | focus: focus,
            prev: prev,
            next: next,
            path: [new_location(z) | z.path]
        }
    end
  end

  @doc """
  Moves focus to the last child. If there are no children, and this is
  a leaf, returns nil.

  ## Examples

      iex> tree = RoseTree.new(5, [6,7,8,9])
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.last_child(z)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 9, children: []},
        prev: [
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 6, children: []}
        ],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @doc section: :descendants
  @spec last_child(t(), predicate()) :: t() | nil
  def last_child(zipper, predicate \\ &Util.always/1)

  def last_child(%__MODULE__{focus: focus}, _predicate)
      when RoseTree.empty?(focus) or RoseTree.leaf?(focus),
      do: nil

  def last_child(%__MODULE__{} = z, predicate) when is_function(predicate) do
    children =
      z
      |> children()
      |> Enum.reverse()

    case Util.split_when(children, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          z
          | focus: focus,
            prev: prev,
            next: next,
            path: [new_location(z) | z.path]
        }
    end
  end

  @doc """
  Moves focus to the child at the specified index. If there are no children,
  or if the child does not exist at the index, returns nil.

  ## Examples

      iex> tree = RoseTree.new(5, [6,7,8,9])
      ...> z = RoseTree.Zipper.new(tree)
      ...> RoseTree.Zipper.child_at(z, 2)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 8, children: []},
        prev: [
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 6, children: []}
        ],
        next: [%RoseTree{term: 9, children: []}],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @doc section: :descendants
  @spec child_at(t(), non_neg_integer()) :: t() | nil
  def child_at(%__MODULE__{focus: focus}, _index)
      when RoseTree.empty?(focus) or RoseTree.leaf?(focus),
      do: nil

  def child_at(%__MODULE__{} = z, index) when is_integer(index) do
    children = children(z)

    case Util.split_at(children, index) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %__MODULE__{
          focus: focus,
          prev: prev,
          next: next,
          path: [new_location(z) | z.path]
        }
    end
  end

  @doc """
  Moves the focus to the first grandchild -- the first child of the
  first child -- of the focus. If there are no grandchildren, moves to
  the next sibling of the first child and looks for that tree's first
  child. This repeats until the first grandchild is found or it returns
  nil if none are found.
  """
  @doc section: :descendants
  @spec first_grandchild(t(), predicate()) :: t() | nil
  def first_grandchild(zipper, predicate \\ &Util.always/1)

  def first_grandchild(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case first_child(z) do
      nil ->
        nil

      %__MODULE__{} = first_child ->
        do_first_grandchild(first_child, predicate)
    end
  end

  defp do_first_grandchild(%__MODULE__{} = z, predicate) do
    case first_child(z, predicate) do
      nil ->
        z
        |> next_sibling()
        |> do_first_grandchild(predicate)

      %__MODULE__{} = first_grandchild ->
        first_grandchild
    end
  end

  defp do_first_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the last grandchild -- the last child of the
  last child -- of the focus. If there are no grandchildren, moves to
  the previous sibling of the last child and looks for that tree's last
  child. This repeats until the first grandchild is found or it returns
  nil if none are found.
  """
  @doc section: :descendants
  @spec last_grandchild(t(), predicate()) :: t() | nil
  def last_grandchild(zipper, predicate \\ &Util.always/1)

  def last_grandchild(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case last_child(z) do
      nil ->
        nil

      %__MODULE__{} = last_child ->
        do_last_grandchild(last_child, predicate)
    end
  end

  defp do_last_grandchild(%__MODULE__{} = z, predicate) do
    case last_child(z, predicate) do
      nil ->
        z
        |> previous_sibling()
        |> do_last_grandchild(predicate)

      %__MODULE__{} = last_grandchild ->
        last_grandchild
    end
  end

  defp do_last_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the first great-grandchild -- the first child of the
  first grandchild -- of the focus. If there are no great-grandchildren, moves to
  the next sibling of the first grandchild and looks for that tree's first
  child. This repeats until the first great-grandchild is found or it returns
  nil if none are found.
  """
  @doc section: :descendants
  @spec first_great_grandchild(t(), predicate()) :: t() | nil
  def first_great_grandchild(zipper, predicate \\ &Util.always/1)

  def first_great_grandchild(%__MODULE__{} = z, predicate) when is_function(predicate) do
    # first grandchild with children
    case first_grandchild(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = first_grandchild ->
        do_first_great_grandchild(first_grandchild, predicate)
    end
  end

  defp do_first_great_grandchild(%__MODULE__{} = z, predicate) do
    case first_child(z, predicate) do
      nil ->
        z
        |> next_sibling()
        |> do_first_great_grandchild(predicate)

      %__MODULE__{} = first_great_grandchild ->
        first_great_grandchild
    end
  end

  defp do_first_great_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the last great-grandchild -- the last child of the
  last grandchild -- of the focus. If there are no great-grandchildren,
  moves to the previous sibling of the last grandchild and looks for that tree's
  last child. This repeats until the last great-grandchild is found or it
  returns nil if none are found.
  """
  @doc section: :descendants
  @spec last_great_grandchild(t(), predicate()) :: t() | nil
  def last_great_grandchild(zipper, predicate \\ &Util.always/1)

  def last_great_grandchild(%__MODULE__{} = z, predicate) when is_function(predicate) do
    # last grandchild with children
    case last_grandchild(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = last_grandchild ->
        do_last_great_grandchild(last_grandchild, predicate)
    end
  end

  defp do_last_great_grandchild(%__MODULE__{} = z, predicate) do
    case last_child(z, predicate) do
      nil ->
        z
        |> previous_sibling()
        |> do_last_great_grandchild(predicate)

      %__MODULE__{} = last_great_grandchild ->
        last_great_grandchild
    end
  end

  defp do_last_great_grandchild(nil, _predicate), do: nil

  @doc """
  Descend the right-most edge until it can go no further or until
  the optional predicate matches. Does not include siblings of
  starting focus.
  """
  @doc section: :descendants
  @spec rightmost_descendant(t(), predicate()) :: t() | nil
  def rightmost_descendant(zipper, predicate \\ nil)

  def rightmost_descendant(%__MODULE__{focus: focus}, _predicate) when RoseTree.leaf?(focus),
    do: nil

  def rightmost_descendant(%__MODULE__{} = z, nil),
    do: do_rightmost_descendant(z)

  def rightmost_descendant(%__MODULE__{} = z, predicate) when is_function(predicate),
    do: do_rightmost_descendant_until(z, predicate)

  @spec do_rightmost_descendant(t()) :: t()
  defp do_rightmost_descendant(%__MODULE__{} = z) do
    case last_child(z) do
      nil ->
        z

      %__MODULE__{} = last_child ->
        do_rightmost_descendant(last_child)
    end
  end

  @spec do_rightmost_descendant_until(t(), predicate()) :: t() | nil
  defp do_rightmost_descendant_until(%__MODULE__{} = z, predicate) do
    case last_child(z) do
      nil ->
        z

      %__MODULE__{} = last_child ->
        if predicate.(last_child) do
          last_child
        else
          do_rightmost_descendant_until(last_child, predicate)
        end
    end
  end

  @doc """
  Descend the left-most edge until it can go no further or until
  the optional predicate matches. Does not include siblings of
  starting focus.
  """
  @doc section: :descendants
  @spec leftmost_descendant(t(), predicate()) :: t() | nil
  def leftmost_descendant(zipper, predicate \\ nil)

  def leftmost_descendant(%__MODULE__{focus: focus}, _predicate) when RoseTree.leaf?(focus),
    do: nil

  def leftmost_descendant(%__MODULE__{} = z, nil),
    do: do_leftmost_descendant(z)

  def leftmost_descendant(%__MODULE__{} = z, predicate) when is_function(predicate),
    do: do_leftmost_descendant_until(z, predicate)

  @spec do_leftmost_descendant(t()) :: t()
  defp do_leftmost_descendant(%__MODULE__{} = z) do
    case first_child(z) do
      nil ->
        z

      %__MODULE__{} = first_child ->
        do_leftmost_descendant(first_child)
    end
  end

  @spec do_leftmost_descendant_until(t(), predicate()) :: t() | nil
  defp do_leftmost_descendant_until(%__MODULE__{} = z, predicate) do
    case first_child(z) do
      nil ->
        z

      %__MODULE__{} = first_child ->
        if predicate.(first_child) do
          first_child
        else
          do_leftmost_descendant_until(first_child, predicate)
        end
    end
  end

  ###
  ### SIBLINGS
  ###

  @doc """
  Returns the siblings that come before the current focus.

  ## Examples

      iex> prev = for t <- [1,2,3,4], do: RoseTree.new(t)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, prev: prev)
      ...> RoseTree.Zipper.prev_siblings(z)
      [
        %RoseTree{term: 4, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 1, children: []}
      ]

  """
  @doc section: :siblings
  @spec prev_siblings(t()) :: [RoseTree.t()]
  def prev_siblings(%__MODULE__{prev: prev}),
    do: Enum.reverse(prev)

  @doc """
  Returns the siblings that come after the current focus.

  ## Examples

      iex> next = for t <- [6,7,8,9], do: RoseTree.new(t)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, next: next)
      ...> RoseTree.Zipper.next_siblings(z)
      [
        %RoseTree{term: 6, children: []},
        %RoseTree{term: 7, children: []},
        %RoseTree{term: 8, children: []},
        %RoseTree{term: 9, children: []}
      ]

  """
  @doc section: :siblings
  @spec next_siblings(t()) :: [RoseTree.t()]
  def next_siblings(%__MODULE__{next: next}),
    do: next

  @doc """
  Applies the given function to all previous siblings of the current focus without
  moving the zipper.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, prev: prev)
      ...> map_fn = &RoseTree.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.map_prev_siblings(z, &map_fn.(&1))
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 6, children: []},
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 2, children: []}
        ],
        next: [],
        path: []
      }

  """
  @doc section: :siblings
  @spec map_prev_siblings(t(), (RoseTree.t() -> RoseTree.t())) :: t()
  def map_prev_siblings(%__MODULE__{prev: prev} = z, map_fn) when is_function(map_fn) do
    new_siblings =
      prev
      |> Enum.map(fn sibling -> map_fn.(sibling) end)

    if RoseTree.all_rose_trees?(new_siblings) do
      %{z | prev: new_siblings}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree struct"
    end
  end

  @doc """
  Applies the given function to all next siblings of the current focus without
  moving the zipper.

  ## Examples

      iex> next = for n <- [6,7,8,9], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, next: next)
      ...> map_fn = &RoseTree.map_term(&1, fn term -> term * 2 end)
      ...> RoseTree.Zipper.map_next_siblings(z, &map_fn.(&1))
      %RoseTree.Zipper{
        focus: %RoseTree{term: 5, children: []},
        prev: [],
        next: [
          %RoseTree{term: 12, children: []},
          %RoseTree{term: 14, children: []},
          %RoseTree{term: 16, children: []},
          %RoseTree{term: 18, children: []}
        ],
        path: []
      }

  """
  @doc section: :siblings
  @spec map_next_siblings(t(), (RoseTree.t() -> RoseTree.t())) :: t()
  def map_next_siblings(%__MODULE__{next: next} = z, map_fn) when is_function(map_fn) do
    new_siblings =
      next
      |> Enum.map(fn sibling -> map_fn.(sibling) end)

    if RoseTree.all_rose_trees?(new_siblings) do
      %{z | next: new_siblings}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree struct"
    end
  end

  @doc section: :siblings
  @spec prepend_first_sibling(t(), term()) :: t()
  def prepend_first_sibling(%__MODULE__{} = z, sibling) when RoseTree.rose_tree?(sibling),
    do: %{z | prev: z.prev ++ [sibling]}

  def prepend_first_sibling(%__MODULE__{} = z, sibling),
    do: %{z | prev: z.prev ++ [RoseTree.new(sibling)]}

  @doc section: :siblings
  @spec append_last_sibling(t(), term()) :: t()
  def append_last_sibling(%__MODULE__{} = z, sibling) when RoseTree.rose_tree?(sibling),
    do: %{z | next: z.next ++ [sibling]}

  def append_last_sibling(%__MODULE__{} = z, sibling),
    do: %{z | next: z.next ++ [RoseTree.new(sibling)]}

  @doc section: :siblings
  @spec append_previous_sibling(t(), term()) :: t()
  def append_previous_sibling(%__MODULE__{} = z, sibling) when RoseTree.rose_tree?(sibling),
    do: %{z | prev: [sibling | z.prev]}

  def append_previous_sibling(%__MODULE__{} = z, sibling),
    do: %{z | prev: [RoseTree.new(sibling) | z.prev]}

  @doc section: :siblings
  @spec prepend_next_sibling(t(), term()) :: t()
  def prepend_next_sibling(%__MODULE__{} = z, sibling) when RoseTree.rose_tree?(sibling),
    do: %{z | next: [sibling | z.next]}

  def prepend_next_sibling(%__MODULE__{} = z, sibling),
    do: %{z | next: [RoseTree.new(sibling) | z.next]}

  @doc section: :siblings
  @spec insert_previous_sibling_at(t(), term(), integer()) :: t()
  def insert_previous_sibling_at(%__MODULE__{} = z, sibling, index) when RoseTree.rose_tree?(sibling),
    do: do_insert_previous_sibling_at(z, sibling, index)

  def insert_previous_sibling_at(%__MODULE__{} = z, sibling, index),
    do: do_insert_previous_sibling_at(z, RoseTree.new(sibling), index)

  @spec do_insert_previous_sibling_at(t(), RoseTree.t(), integer()) :: t()
  def do_insert_previous_sibling_at(%__MODULE__{} = z, sibling, index)
      when RoseTree.rose_tree?(sibling) and is_integer(index) do
    {siblings_before, siblings_after} =
      z.prev
      |> Enum.reverse()
      |> Enum.split(index)
    new_siblings = siblings_before ++ [sibling | siblings_after]
    %{z | prev: Enum.reverse(new_siblings)}
  end

  @doc section: :siblings
  @spec insert_next_sibling_at(t(), term(), integer()) :: t()
  def insert_next_sibling_at(%__MODULE__{} = z, sibling, index) when RoseTree.rose_tree?(sibling),
    do: do_insert_next_sibling_at(z, sibling, index)

  def insert_next_sibling_at(%__MODULE__{} = z, sibling, index),
    do: do_insert_next_sibling_at(z, RoseTree.new(sibling), index)

  def do_insert_next_sibling_at(%__MODULE__{} = z, sibling, index)
      when RoseTree.rose_tree?(sibling) and is_integer(index) do
    {siblings_before, siblings_after} = Enum.split(z.next, index)
    new_siblings = siblings_before ++ [sibling | siblings_after]
    %{z | next: new_siblings}
  end

  @doc section: :siblings
  @spec pop_first_sibling(t()) :: {t(), RoseTree.t() | nil}
  def pop_first_sibling(%__MODULE__{prev: []} = z), do: {z, nil}

  def pop_first_sibling(%__MODULE__{} = z) do
    {new_siblings, [first_sibling | []]} = Enum.split(z.prev, -1)
    {%{z | prev: new_siblings}, first_sibling}
  end

  @doc section: :siblings
  @spec pop_previous_sibling(t()) :: {t(), RoseTree.t() | nil}
  def pop_previous_sibling(%__MODULE__{prev: []} = z), do: {z, nil}

  def pop_previous_sibling(%__MODULE__{prev: [previous | new_siblings]} = z),
    do: {%{z | prev: new_siblings}, previous}

  @doc section: :siblings
  @spec pop_last_sibling(t()) :: {t(), RoseTree.t() | nil}
  def pop_last_sibling(%__MODULE__{next: []} = z), do: {z, nil}

  def pop_last_sibling(%__MODULE__{} = z) do
    {new_siblings, [last_sibling | []]} = Enum.split(z.next, -1)
    {%{z | next: new_siblings}, last_sibling}
  end

  @doc section: :siblings
  @spec pop_next_sibling(t()) :: {t(), RoseTree.t() | nil}
  def pop_next_sibling(%__MODULE__{next: []} = z), do: {z, nil}

  def pop_next_sibling(%__MODULE__{next: [next | new_siblings]} = z),
    do: {%{z | next: new_siblings}, next}

  @doc section: :siblings
  @spec pop_previous_sibling_at(t(), integer()) :: {t(), RoseTree.t() | nil}
  def pop_previous_sibling_at(%__MODULE__{} = z, index) when is_integer(index) do

  end

  @doc section: :siblings
  @spec pop_next_sibling_at(t(), integer()) :: {t(), RoseTree.t() | nil}
  def pop_next_sibling_at(%__MODULE__{} = z, index) when is_integer(index) do

  end


  @doc """
  Moves focus to the first sibling from the current focus. If there are
  no more siblings before the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.new(n)
    ...> tree = RoseTree.new(5)
    ...> z = RoseTree.Zipper.new(tree, prev: prev, next: next)
    ...> RoseTree.Zipper.first_sibling(z)
    %RoseTree.Zipper{
      focus: %RoseTree{term: 1, children: []},
      prev: [],
      next: [
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 4, children: []},
        %RoseTree{term: 5, children: []},
        %RoseTree{term: 6, children: []},
        %RoseTree{term: 7, children: []},
        %RoseTree{term: 8, children: []},
        %RoseTree{term: 9, children: []}
      ],
      path: []
    }

  """
  @doc section: :siblings
  @spec first_sibling(t(), predicate()) :: t() | nil
  def first_sibling(zipper, predicate \\ &Util.always/1)

  def first_sibling(%__MODULE__{prev: []}, _predicate), do: nil

  def first_sibling(%__MODULE__{prev: prev} = z, predicate) when is_function(predicate) do
    previous_siblings = Enum.reverse(prev)

    case Util.split_when(previous_siblings, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          z
          | focus: focus,
            prev: prev,
            next: next ++ [z.focus | z.next],
            path: z.path
        }
    end
  end

  @doc """
  Moves focus to the previous sibling to the current focus. If there are
  no more siblings before the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.new(n)
    ...> tree = RoseTree.new(5)
    ...> z = RoseTree.Zipper.new(tree, prev: prev, next: next)
    ...> RoseTree.Zipper.previous_sibling(z)
    %RoseTree.Zipper{
      focus: %RoseTree{term: 4, children: []},
      prev: [
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 1, children: []}
      ],
      next: [
        %RoseTree{term: 5, children: []},
        %RoseTree{term: 6, children: []},
        %RoseTree{term: 7, children: []},
        %RoseTree{term: 8, children: []},
        %RoseTree{term: 9, children: []}
      ],
      path: []
    }

  """
  @doc section: :siblings
  @spec previous_sibling(t(), predicate()) :: t() | nil
  def previous_sibling(zipper, predicate \\ &Util.always/1)

  def previous_sibling(%__MODULE__{prev: []}, _predicate), do: nil

  def previous_sibling(%__MODULE__{prev: prev} = z, predicate) when is_function(predicate) do
    case Util.split_when(prev, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          z
          | focus: focus,
            prev: prev,
            next: next ++ [z.focus | z.next],
            path: z.path
        }
    end
  end

  @doc """
  Moves focus to the last sibling from the current focus. If there are
  no more siblings after the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.new(n)
    ...> tree = RoseTree.new(5)
    ...> z = RoseTree.Zipper.new(tree, prev: prev, next: next)
    ...> RoseTree.Zipper.last_sibling(z)
    %RoseTree.Zipper{
      focus: %RoseTree{term: 9, children: []},
      prev: [
        %RoseTree{term: 8, children: []},
        %RoseTree{term: 7, children: []},
        %RoseTree{term: 6, children: []},
        %RoseTree{term: 5, children: []},
        %RoseTree{term: 4, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 1, children: []}
      ],
      next: [],
      path: []
    }

  """
  @doc section: :siblings
  @spec last_sibling(t(), predicate()) :: t() | nil
  def last_sibling(zipper, predicate \\ &Util.always/1)

  def last_sibling(%__MODULE__{next: []}, _predicate), do: nil

  def last_sibling(%__MODULE__{next: next} = z, predicate) when is_function(predicate) do
    last_siblings = Enum.reverse(next)

    case Util.split_when(last_siblings, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          z
          | focus: focus,
            prev: prev ++ [z.focus | z.prev],
            next: next,
            path: z.path
        }
    end
  end

  @doc """
  Moves focus to the next sibling of the current focus. If there are
  no more siblings after the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.new(n)
    ...> tree = RoseTree.new(5)
    ...> z = RoseTree.Zipper.new(tree, prev: prev, next: next)
    ...> RoseTree.Zipper.next_sibling(z)
    %RoseTree.Zipper{
      focus: %RoseTree{term: 6, children: []},
      prev: [
        %RoseTree{term: 5, children: []},
        %RoseTree{term: 4, children: []},
        %RoseTree{term: 3, children: []},
        %RoseTree{term: 2, children: []},
        %RoseTree{term: 1, children: []}
      ],
      next: [
        %RoseTree{term: 7, children: []},
        %RoseTree{term: 8, children: []},
        %RoseTree{term: 9, children: []}
      ],
      path: []
    }

  """
  @doc section: :siblings
  @spec next_sibling(t(), predicate()) :: t() | nil
  def next_sibling(zipper, predicate \\ &Util.always/1)

  def next_sibling(%__MODULE__{next: []}, _predicate), do: nil

  def next_sibling(%__MODULE__{next: next} = z, predicate) when is_function(predicate) do
    case Util.split_when(next, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          z
          | focus: focus,
            prev: prev ++ [z.focus | z.prev],
            next: next,
            path: z.path
        }
    end
  end

  @doc """
  Moves focus to the sibling of the current focus at the given index.
  If no sibling is found at that index, or if the provided index
  is the index for the current focus, returns nil.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> next = for n <- [6,7,8,9], do: RoseTree.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, prev: prev, next: next)
      ...> RoseTree.Zipper.sibling_at(z, 2)
      %RoseTree.Zipper{
        focus: %RoseTree{term: 3, children: []},
        prev: [
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ],
        next: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 5, children: []},
          %RoseTree{term: 6, children: []},
          %RoseTree{term: 7, children: []},
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 9, children: []}
        ],
        path: []
      }

  """
  @doc section: :siblings
  @spec sibling_at(t(), non_neg_integer()) :: t() | nil
  def sibling_at(%__MODULE__{prev: [], next: []} = z, index), do: nil

  def sibling_at(%__MODULE__{} = z, index) when is_integer(index) do
    current_idx = index_of_focus(z)

    if current_idx == index do
      nil
    else
      siblings = Enum.reverse(z.prev) ++ [z.focus | z.next]

      case Util.split_at(siblings, index) do
        {[], []} ->
          nil

        {prev, [focus | next]} ->
          %__MODULE__{
            focus: focus,
            prev: prev,
            next: next,
            path: z.path
          }
      end
    end
  end

  ###
  ### NIBLINGS (NIECES + NEPHEWS)
  ###

  @doc """
  Moves the focus to the first nibling -- the first child of the
  first sibling with children -- before the current focus. If not
  found, returns nil.
  """
  @doc section: :niblings
  @spec first_nibling(t(), predicate()) :: t() | nil
  def first_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = first_sibling <- first_sibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = first_child <- first_child(first_sibling, predicate) do
      first_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last nibling -- the last child of the
  last sibling  with children -- before the current focus. If not
  found, returns nil.
  """
  @doc section: :niblings
  @spec last_nibling(t(), predicate()) :: t() | nil
  def last_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = last_sibling <- last_sibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = last_child <- last_child(last_sibling, predicate) do
      last_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the previous nibling -- the last child of the
  first previous sibling with children -- before the current focus.
  If not found, returns nil.
  """
  @doc section: :niblings
  @spec previous_nibling(t(), predicate()) :: t() | nil
  def previous_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = previous_sibling <- previous_sibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = last_child <- last_child(previous_sibling, predicate) do
      last_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the next nibling -- the first child of the
  first next sibling with children -- before the current focus.
  If not found, returns nil.
  """
  @doc section: :niblings
  @spec next_nibling(t(), predicate()) :: t() | nil
  def next_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = next_sibling <- next_sibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = first_child <- first_child(next_sibling, predicate) do
      first_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the first nibling for a specific sibling -- the
  first child of the sibling at the given index -- of the current focus.
  If not found, returns nil.
  """
  @doc section: :niblings
  @spec first_nibling_at_sibling(t(), non_neg_integer(), predicate()) :: t() | nil
  def first_nibling_at_sibling(%__MODULE__{} = z, index, predicate \\ &Util.always/1)
      when is_integer(index) and is_function(predicate) do
    with %__MODULE__{} = sibling_at <- sibling_at(z, index),
         %__MODULE__{} = first_child <- first_child(sibling_at, predicate) do
      first_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last nibling for a specific sibling -- the
  last child of the sibling at the given index -- of the current focus.
  If not found, returns nil.
  """
  @doc section: :niblings
  @spec last_nibling_at_sibling(t(), non_neg_integer(), predicate()) :: t() | nil
  def last_nibling_at_sibling(%__MODULE__{} = z, index, predicate \\ &Util.always/1)
      when is_integer(index) and is_function(predicate) do
    with %__MODULE__{} = sibling_at <- sibling_at(z, index),
         %__MODULE__{} = last_child <- last_child(sibling_at, predicate) do
      last_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the previous grand-nibling -- the last grandchild of
  the previous sibling -- of the current focus. If not found, returns nil.
  """
  @doc section: :niblings
  @spec previous_grandnibling(t(), predicate()) :: t() | nil
  def previous_grandnibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_sibling(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = previous_sibling ->
        do_previous_grandnibling(previous_sibling, predicate)
    end
  end

  defp do_previous_grandnibling(%__MODULE__{} = z, predicate) do
    case last_grandchild(z, predicate) do
      nil ->
        previous_grandnibling(z, predicate)

      %__MODULE__{} = last_grandchild ->
        last_grandchild
    end
  end

  @doc """
  Moves the focus to the next grand-nibling -- the first grandchild of
  the next sibling -- of the current focus. If not found, returns nil.
  """
  @doc section: :niblings
  @spec next_grandnibling(t(), predicate()) :: t() | nil
  def next_grandnibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_sibling(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = next_sibling ->
        do_next_grandnibling(next_sibling, predicate)
    end
  end

  defp do_next_grandnibling(%__MODULE__{} = z, predicate) do
    case first_grandchild(z, predicate) do
      nil ->
        next_grandnibling(z, predicate)

      %__MODULE__{} = first_grandchild ->
        first_grandchild
    end
  end

  @doc """
  Recursively searches the descendant branches of the first sibling for the
  first "descendant nibling" of the current focus. That is, if a first
  nibling is found, it will then look for the first child of that tree (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @doc section: :niblings
  @spec first_descendant_nibling(t(), predicate()) :: t() | nil
  def first_descendant_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case first_sibling(z) do
      nil ->
        nil

      %__MODULE__{} = first_sibling ->
        do_first_descendant_nibling(first_sibling, predicate, nil)
    end
  end

  defp do_first_descendant_nibling(%__MODULE__{} = z, predicate, last_match) do
    case first_child(z) do
      nil ->
        last_match

      %__MODULE__{} = first_child ->
        last_match =
          if predicate.(first_child) do
            first_child
          else
            last_match
          end

        do_first_descendant_nibling(first_child, predicate, last_match)
    end
  end

  @doc """
  Recursively searches the descendant branches of the last sibling for the
  last "descendant nibling" of the current focus. That is, if a last
  nibling is found, it will then look for the last child of that tree (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @doc section: :niblings
  @spec last_descendant_nibling(t(), predicate()) :: t() | nil
  def last_descendant_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case last_sibling(z) do
      nil ->
        nil

      %__MODULE__{} = last_sibling ->
        do_last_descendant_nibling(last_sibling, predicate, nil)
    end
  end

  defp do_last_descendant_nibling(%__MODULE__{} = z, predicate, last_match) do
    case last_child(z) do
      nil ->
        last_match

      %__MODULE__{} = last_child ->
        last_match =
          if predicate.(last_child) do
            last_child
          else
            last_match
          end

        do_last_descendant_nibling(last_child, predicate, last_match)
    end
  end

  @doc """
  Recursively searches the descendant branches of the previous sibling for the
  previous "descendant nibling" of the current focus. That is, if a previous
  nibling is found, it will then look for the last child of that tree (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @doc section: :niblings
  @spec previous_descendant_nibling(t(), predicate()) :: t() | nil
  def previous_descendant_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_sibling(z) do
      nil ->
        nil

      %__MODULE__{} = previous_sibling ->
        do_previous_descendant_nibling(previous_sibling, predicate, nil)
    end
  end

  defp do_previous_descendant_nibling(%__MODULE__{} = z, predicate, last_match) do
    case last_child(z) do
      nil ->
        last_match

      %__MODULE__{} = last_child ->
        last_match =
          if predicate.(last_child) do
            last_child
          else
            last_match
          end

        do_previous_descendant_nibling(last_child, predicate, last_match)
    end
  end

  @doc """
  Recursively searches the descendant branches of the next sibling for the
  next "descendant nibling" of the current focus. That is, if a next
  nibling is found, it will then look for the first child of that tree (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @doc section: :niblings
  @spec next_descendant_nibling(t(), predicate()) :: t() | nil
  def next_descendant_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_sibling(z) do
      nil ->
        nil

      %__MODULE__{} = next_sibling ->
        do_next_descendant_nibling(next_sibling, predicate, nil)
    end
  end

  defp do_next_descendant_nibling(%__MODULE__{} = z, predicate, last_match) do
    case first_child(z) do
      nil ->
        last_match

      %__MODULE__{} = first_child ->
        last_match =
          if predicate.(first_child) do
            first_child
          else
            last_match
          end

        do_next_descendant_nibling(first_child, predicate, last_match)
    end
  end

  @doc """
  Searches for the first child of the first extended cousin--aka, the first
  extended nibling--of the focused tree.
  """
  @doc section: :niblings
  @spec first_extended_nibling(t(), predicate()) :: t() | nil
  def first_extended_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = first_extended_cousin <-
           first_extended_cousin(z, &has_children?/1),
         %__MODULE__{} = first_child <- first_child(first_extended_cousin, predicate) do
      first_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last child of the last extended cousin--aka, the last
  extended nibling--of the focused tree.
  """
  @doc section: :niblings
  @spec last_extended_nibling(t(), predicate()) :: t() | nil
  def last_extended_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = last_extended_cousin <- last_extended_cousin(z, &has_children?/1),
         %__MODULE__{} = last_child <- last_child(last_extended_cousin, predicate) do
      last_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last child of the previous extended cousin--aka, the previous
  extended nibling--of the focused tree.
  """
  @doc section: :niblings
  @spec previous_extended_nibling(t(), predicate()) :: t() | nil
  def previous_extended_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = prev_extended_cousin <-
           previous_extended_cousin(z, &has_children?/1),
         %__MODULE__{} = last_child <- last_child(prev_extended_cousin, predicate) do
      last_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the first child of the next extended cousin--aka, the next
  extended nibling--of the focused tree.
  """
  @doc section: :niblings
  @spec next_extended_nibling(t(), predicate()) :: t() | nil
  def next_extended_nibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = next_extended_cousin <- next_extended_cousin(z, &has_children?/1),
         %__MODULE__{} = first_child <- first_child(next_extended_cousin, predicate) do
      first_child
    else
      nil -> nil
    end
  end

  ###
  ### PIBLINGS (UNCLES + AUNTS)
  ###

  @doc """
  Moves the focus to the first pibling -- the first sibling of the parent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec first_pibling(t(), predicate()) :: t() | nil
  def first_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = first_sibling <- first_sibling(parent, predicate) do
      first_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last pibling -- the last sibling of the parent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec last_pibling(t(), predicate()) :: t() | nil
  def last_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = last_sibling <- last_sibling(parent, predicate) do
      last_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the previous pibling -- the previous sibling of the parent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec previous_pibling(t(), predicate()) :: t() | nil
  def previous_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = previous_sibling <- previous_sibling(parent, predicate) do
      previous_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the next pibling -- the next sibling of the parent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec next_pibling(t(), predicate()) :: t() | nil
  def next_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) when is_function(predicate) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = next_sibling <- next_sibling(parent, predicate) do
      next_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the pibling of the current focus at the given index.
  If no pibling is found at that index, returns nil.
  """
  @doc section: :piblings
  @spec pibling_at(t(), non_neg_integer()) :: t() | nil
  def pibling_at(%__MODULE__{} = z, index) when is_integer(index) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = sibling_at <- sibling_at(parent, index) do
      sibling_at
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the first grandpibling -- the first sibling of the grandparent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec first_grandpibling(t(), predicate()) :: t() | nil
  def first_grandpibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = grandparent <- grandparent(z),
         %__MODULE__{} = first_sibling <- first_sibling(grandparent, predicate) do
      first_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last grandpibling -- the last sibling of the grandparent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec last_grandpibling(t(), predicate()) :: t() | nil
  def last_grandpibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = grandparent <- grandparent(z),
         %__MODULE__{} = last_sibling <- last_sibling(grandparent, predicate) do
      last_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the previous grandpibling -- the previous sibling of the grandparent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec previous_grandpibling(t(), predicate()) :: t() | nil
  def previous_grandpibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = grandparent <- grandparent(z),
         %__MODULE__{} = previous_sibling <- previous_sibling(grandparent, predicate) do
      previous_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the next grandpibling -- the next sibling of the grandparent --
  of the current focus. If not found, returns nil.
  """
  @doc section: :piblings
  @spec next_grandpibling(t(), predicate()) :: t() | nil
  def next_grandpibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = grandparent <- grandparent(z),
         %__MODULE__{} = next_sibling <- next_sibling(grandparent, predicate) do
      next_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Searches for the first extended cousin of the parent--aka, the
  first extended pibling--of the focused tree.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @doc section: :piblings
  @spec first_extended_pibling(t(), predicate()) :: t() | nil
  def first_extended_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = first_extended_cousin <- first_extended_cousin(parent, predicate) do
      first_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last extended cousin of the parent--aka, the
  last extended pibling--of the focused tree.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @doc section: :piblings
  @spec last_extended_pibling(t(), predicate()) :: t() | nil
  def last_extended_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = last_extended_cousin <- last_extended_cousin(parent, predicate) do
      last_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the previous extended cousin of the parent--aka, the
  previous extended pibling--of the focused tree.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @doc section: :piblings
  @spec previous_extended_pibling(t(), predicate()) :: t() | nil
  def previous_extended_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = previous_extended_cousin <- previous_extended_cousin(parent, predicate) do
      previous_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the next extended cousin of the parent--aka, the
  next extended pibling--of the focused tree.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @doc section: :piblings
  @spec next_extended_pibling(t(), predicate()) :: t() | nil
  def next_extended_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1) do
    with %__MODULE__{} = parent <- parent(z),
         %__MODULE__{} = next_extended_cousin <- next_extended_cousin(parent, predicate) do
      next_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Recursively searches the `path` for the first, first "ancestral" pibling. That is,
  if a first pibling is not found for the parent, it will search the grandparent. If
  one is not found for the grandparent, it will search the great-grandparent. And so on,
  until it reaches the root. If the root is reached and it does not have a first pibling,
  the function returns nil.
  """
  @doc section: :piblings
  @spec first_ancestral_pibling(t(), predicate()) :: t() | nil
  def first_ancestral_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case first_pibling(z, predicate) do
      nil ->
        z
        |> parent()
        |> first_ancestral_pibling(predicate)

      %__MODULE__{} = first_ancestral_pibling ->
        first_ancestral_pibling
    end
  end

  def first_ancestral_pibling(nil, _predicate), do: nil

  @doc """
  Recursively searches the `path` for the first, previous "ancestral" pibling. That is,
  if a previous pibling is not found for the parent, it will search the grandparent. If
  one is not found for the grandparent, it will search the great-grandparent. And so on,
  until it reaches the root. If the root is reached and it does not have a previous pibling,
  the function returns nil.
  """
  @doc section: :piblings
  @spec previous_ancestral_pibling(t(), predicate()) :: t() | nil
  def previous_ancestral_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_pibling(z, predicate) do
      nil ->
        z
        |> parent()
        |> previous_ancestral_pibling(predicate)

      %__MODULE__{} = previous_ancestral_pibling ->
        previous_ancestral_pibling
    end
  end

  def previous_ancestral_pibling(nil, _predicate), do: nil

  @doc """
  Recursively searches the `path` for the first, next "ancestral" pibling. That is,
  if a next pibling is not found for the parent, it will search the grandparent. If
  one is not found for the grandparent, it will search the great-grandparent. And so on,
  until it reaches the root. If the root is reached and it does not have a next pibling,
  the function returns nil.
  """
  @doc section: :piblings
  @spec next_ancestral_pibling(t(), predicate()) :: t() | nil
  def next_ancestral_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_pibling(z, predicate) do
      nil ->
        z
        |> parent()
        |> next_ancestral_pibling(predicate)

      %__MODULE__{} = next_ancestral_pibling ->
        next_ancestral_pibling
    end
  end

  def next_ancestral_pibling(nil, _predicate), do: nil

  @doc """
  Recursively searches the `path` for the first, last "ancestral" pibling. That is,
  if a last pibling is not found for the parent, it will search the grandparent. If
  one is not found for the grandparent, it will search the great-grandparent. And so on,
  until it reaches the root. If the root is reached and it does not have a last pibling,
  the function returns nil.
  """
  @doc section: :piblings
  @spec last_ancestral_pibling(t(), predicate()) :: t() | nil
  def last_ancestral_pibling(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case last_pibling(z, predicate) do
      nil ->
        z
        |> parent()
        |> last_ancestral_pibling(predicate)

      %__MODULE__{} = last_ancestral_pibling ->
        last_ancestral_pibling
    end
  end

  def last_ancestral_pibling(nil, _predicate), do: nil

  ###
  ### FIRST COUSINS
  ###

  @doc """
  Moves the focus to the first first-cousin -- the first child of the first
  pibling with children -- of the current focus. If not found, returns nil.
  """
  @doc section: :first_cousins
  @spec first_first_cousin(t(), predicate()) :: t() | nil
  def first_first_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- index_of_parent(z),
         %__MODULE__{} = first_pibling <- first_pibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = first_first_cousin <-
           do_first_first_cousin(first_pibling, predicate, starting_idx) do
      first_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_first_first_cousin(%__MODULE__{} = z, predicate, starting_idx) do
    current_idx = index_of_focus(z)

    if current_idx < starting_idx do
      case first_child(z, predicate) do
        nil ->
          z
          |> next_sibling(&RoseTree.parent?/1)
          |> do_first_first_cousin(predicate, starting_idx)

        %__MODULE__{} = first_child ->
          first_child
      end
    else
      nil
    end
  end

  @doc """
  Moves the focus to the last first-cousin -- the last child of the last
  pibling with children -- of the current focus. If not found, returns nil.
  """
  @doc section: :first_cousins
  @spec last_first_cousin(t(), predicate()) :: t() | nil
  def last_first_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- index_of_parent(z),
         %__MODULE__{} = last_pibling <- last_pibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = last_first_cousin <-
           do_last_first_cousin(last_pibling, predicate, starting_idx) do
      last_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_last_first_cousin(%__MODULE__{} = z, predicate, starting_idx) do
    current_idx = index_of_focus(z)

    if current_idx > starting_idx do
      case last_child(z, predicate) do
        nil ->
          z
          |> previous_sibling(&RoseTree.parent?/1)
          |> do_last_first_cousin(predicate, starting_idx)

        %__MODULE__{} = last_child ->
          last_child
      end
    else
      nil
    end
  end

  @doc """
  Moves the focus to the previous first-cousin -- the last child of the
  previous pibling with children -- of the current focus. If not found, returns nil.
  """
  @doc section: :first_cousins
  @spec previous_first_cousin(t(), predicate()) :: t() | nil
  def previous_first_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = previous_pibling <- previous_pibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = previous_first_cousin <-
           do_previous_first_cousin(previous_pibling, predicate) do
      previous_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_previous_first_cousin(%__MODULE__{} = z, predicate) do
    case last_child(z, predicate) do
      nil ->
        z
        |> previous_sibling(&RoseTree.parent?/1)
        |> do_previous_first_cousin(predicate)

      %__MODULE__{} = last_child ->
        last_child
    end
  end

  defp do_previous_first_cousin(nil, _predicate), do: nil

  @doc """
  Moves the focus to the next first-cousin -- the first child of the
  next pibling with children -- of the current focus. If not found, returns nil.
  """
  @doc section: :first_cousins
  @spec next_first_cousin(t(), predicate()) :: t() | nil
  def next_first_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = next_pibling <- next_pibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = next_first_cousin <-
           do_next_first_cousin(next_pibling, predicate) do
      next_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_next_first_cousin(%__MODULE__{} = z, predicate) do
    case first_child(z, predicate) do
      nil ->
        z
        |> next_sibling(&RoseTree.parent?/1)
        |> do_next_first_cousin(predicate)

      %__MODULE__{} = first_child ->
        first_child
    end
  end

  defp do_next_first_cousin(nil, _opts), do: nil

  ###
  ### SECOND COUSINS
  ###

  @doc """
  Moves the focus to the first second-cousin -- the first grandchild of
  the first grandpibling with grandchildren -- of the current focus. If not
  found, returns nil.
  """
  @doc section: :second_cousins
  @spec first_second_cousin(t(), predicate()) :: t() | nil
  def first_second_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- index_of_grandparent(z),
         %__MODULE__{} = first_grandpibling <- first_grandpibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = first_second_cousin <-
           do_first_second_cousin(first_grandpibling, predicate, starting_idx) do
      first_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_first_second_cousin(%__MODULE__{} = z, predicate, starting_idx) do
    current_idx = index_of_focus(z)

    if current_idx < starting_idx do
      case first_grandchild(z, predicate) do
        nil ->
          z
          |> next_sibling(&RoseTree.parent?/1)
          |> do_first_second_cousin(predicate, starting_idx)

        %__MODULE__{} = first_grandchild ->
          first_grandchild
      end
    else
      nil
    end
  end

  @doc """
  Moves the focus to the last second-cousin -- the last grandchild of
  the last grandpibling with grandchildren -- of the current focus. If not
  found, returns nil.
  """
  @doc section: :second_cousins
  @spec last_second_cousin(t(), predicate()) :: t() | nil
  def last_second_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- index_of_grandparent(z),
         %__MODULE__{} = last_grandpibling <- last_grandpibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = last_second_cousin <-
           do_last_second_cousin(last_grandpibling, predicate, starting_idx) do
      last_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_last_second_cousin(%__MODULE__{} = z, predicate, starting_idx) do
    current_idx = index_of_focus(z)

    if current_idx > starting_idx do
      case last_grandchild(z, predicate) do
        nil ->
          z
          |> previous_sibling(&RoseTree.parent?/1)
          |> do_last_second_cousin(predicate, starting_idx)

        %__MODULE__{} = last_grandchild ->
          last_grandchild
      end
    else
      nil
    end
  end

  @doc """
  Moves the focus to the previous second-cousin -- the last grandchild of the
  previous grandpibling with grandchildren -- of the current focus. If not found, returns nil.
  """
  @doc section: :second_cousins
  @spec previous_second_cousin(t(), predicate()) :: t() | nil
  def previous_second_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = previous_grandpibling <- previous_grandpibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = previous_second_cousin <-
           do_previous_second_cousin(previous_grandpibling, predicate) do
      previous_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_previous_second_cousin(%__MODULE__{} = z, predicate) do
    case last_grandchild(z, predicate) do
      nil ->
        z
        |> previous_sibling(&RoseTree.parent?/1)
        |> do_previous_second_cousin(predicate)

      %__MODULE__{} = last_grandchild ->
        last_grandchild
    end
  end

  defp do_previous_second_cousin(nil, _predicate), do: nil

  @doc """
  Moves the focus to the next second-cousin -- the first grandchild of the
  next grandpibling with grandchildren -- of the current focus. If not found, returns nil.
  """
  @doc section: :second_cousins
  @spec next_second_cousin(t(), predicate()) :: t() | nil
  def next_second_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %__MODULE__{} = next_grandpibling <- next_grandpibling(z, &RoseTree.parent?/1),
         %__MODULE__{} = next_second_cousin <-
           do_next_second_cousin(next_grandpibling, predicate) do
      next_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_next_second_cousin(%__MODULE__{} = z, predicate) do
    case first_grandchild(z, predicate) do
      nil ->
        z
        |> next_sibling(&RoseTree.parent?/1)
        |> do_next_second_cousin(predicate)

      %__MODULE__{} = first_grandchild ->
        first_grandchild
    end
  end

  defp do_next_second_cousin(nil, _opts), do: nil

  ###
  ### EXTENDED COUSINS
  ###

  @doc """
  Searches for the first extended cousin or the first first-cousin of the focused tree.

  High level steps:

  1. Ascend `path` to find highest location with `prev` siblings.
  2. Starting with the first sibling, check each subtree from left to right,
      and if you reach the target depth and find a tree that satisifies any
      given predicate, stop there. Otherwise, continue left to right.
  3. If you return back to the starting Location, descend the `path` to next
      deepest Location and set as starting Location. Goto step 2.
  4. If you return back to starting Location, and it is also the ending Location,
      and you have not found a suitable note at the right depth, you will not find one.
  """
  @doc section: :extended_cousins
  @spec first_extended_cousin(t(), keyword()) :: t() | nil
  def first_extended_cousin(z, predicate \\ &Util.always/1)

  def first_extended_cousin(%__MODULE__{path: []} = z, _predicate), do: nil

  def first_extended_cousin(%__MODULE__{} = z, predicate) when is_function(predicate) do
    target_depth = depth_of_focus(z)

    # IO.inspect(target_depth, label: "Target Depth")

    {starting_point_on_path, path_details} =
      z
      |> parent()
      |> first_extended_cousin_starting_point()

    case starting_point_on_path do
      nil ->
        nil

      %__MODULE__{} ->
        starting_sibling = first_sibling(starting_point_on_path)

        current_details = %{
          # remove
          term: starting_sibling.focus.term,
          index: 0,
          depth: depth_of_focus(starting_sibling)
        }

        starting_sibling
        |> do_first_extended_cousin(current_details, path_details, target_depth, predicate)
    end
  end

  @spec first_extended_cousin_starting_point(t()) :: {t(), non_neg_integer()}
  defp first_extended_cousin_starting_point(%__MODULE__{} = z) do
    {_root, {candidate_depth, candidate_z, path_details}} =
      accumulate_to_root(z, {0, nil, []}, fn
        %__MODULE__{prev: []} = next_z, {candidate_depth, candidate_z, details} ->
          new_details = %{
            # remove
            term: next_z.focus.term,
            index: index_of_focus(next_z),
            depth: depth_of_focus(next_z)
          }

          {candidate_depth, candidate_z, [new_details | details]}

        %__MODULE__{} = next_z, {_, _, details} ->
          new_depth = depth_of_focus(next_z)

          new_details = %{
            # remove
            term: next_z.focus.term,
            index: index_of_focus(next_z),
            depth: new_depth
          }

          {new_depth, next_z, [new_details | details]}
      end)

    # drop any erroneous accumulated path details, i.e. -
    # we don't care about the details that were gathered
    # about path locations that preceed our final candidate
    pruned_path_details = Enum.drop(path_details, candidate_depth)

    # IO.inspect(candidate_z.focus.term, label: "Starting Term")
    # IO.inspect(pruned_path_details, label: "Starting Path Details")

    {candidate_z, pruned_path_details}
  end

  @spec first_extended_cousin_descend_path(t(), [map()]) :: {t(), [map()]}
  defp first_extended_cousin_descend_path(%__MODULE__{} = z, []), do: {z, []}

  defp first_extended_cousin_descend_path(%__MODULE__{} = z, [
         %{index: 0} = loc_details | path_details
       ]) do
    z
    |> first_child()
    |> do_first_extended_cousin_descend_path(loc_details, path_details)
  end

  defp first_extended_cousin_descend_path(%__MODULE__{} = z, [%{index: index} | _] = path_details) do
    {child_at(z, index), path_details}
  end

  @spec do_first_extended_cousin_descend_path(t(), map(), [map()]) ::
          {t(), [map()]}
  defp do_first_extended_cousin_descend_path(%__MODULE__{} = z, %{index: 0}, [
         %{index: 0} = loc_details | path_details
       ]) do
    z
    |> first_child()
    |> do_first_extended_cousin_descend_path(loc_details, path_details)
  end

  defp do_first_extended_cousin_descend_path(
         %__MODULE__{} = z,
         %{index: 0},
         [%{index: index} | _] = path_details
       ) do
    {child_at(z, index), path_details}
  end

  defp do_first_extended_cousin_descend_path(%__MODULE__{} = z, _, path_details) do
    {z, path_details}
  end

  @spec do_first_extended_cousin(t(), map(), [map()], non_neg_integer(), predicate()) ::
          t() | nil
  # Path Details have been exhausted, thus no match
  defp do_first_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [] = _path_details,
         _target_depth,
         _predicate
       ) do
    # IO.inspect(z.focus.term, label: "Path Fully Explored - No Match")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(nil, label: "\tLoc Details")
    nil
  end

  # Subtrees for all previous siblings have been explored, thus descend path to next location
  defp do_first_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | path_details],
         target_depth,
         predicate
       )
       when current_details.index == loc_details.index and
              current_details.depth == loc_details.depth do
    # IO.inspect(z.focus.term, label: "Subtrees Fully Explored for Location, Descend Path")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case first_extended_cousin_descend_path(z, path_details) do
      {_, []} ->
        nil

      {new_path_z, new_path_details} ->
        new_z = first_sibling(new_path_z)

        new_details = %{
          index: 0,
          depth: depth_of_focus(new_z)
        }

        do_first_extended_cousin(new_z, new_details, new_path_details, target_depth, predicate)
    end
  end

  # We've reached the Target Depth and there's no more next siblings. If predicate is true, we've found
  # our match, otherwise, we need to look for the next ancestral pibling. If there is no next ancestral
  # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search.
  defp do_first_extended_cousin(
         %__MODULE__{next: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(z.focus.term, label: "Target Depth Reached - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(z) do
      # IO.puts("\tTarget Found")
      z
    else
      # IO.puts("\tTarget Not Found")
      case next_ancestral_pibling(z) do
        nil ->
          # IO.puts("\tNo Next Ancestral Pibling Found")
          nil

        %__MODULE__{} = next_ancestral_pibling ->
          new_depth = depth_of_focus(next_ancestral_pibling)

          if new_depth < loc_details.depth do
            # IO.puts("\tNext Ancestral Pibling Found Exceeds Boundary")
            nil
          else
            new_details = %{
              depth: new_depth,
              index: index_of_focus(next_ancestral_pibling)
            }

            next_ancestral_pibling
            |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
          end
      end
    end
  end

  # We've reached the Target Depth and there are more next siblings to examine. If predicate is true, however,
  # we've found our match. Otherwise, search next sibling.
  defp do_first_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(z.focus.term, label: "Target Depth Reached - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(z) do
      # IO.puts("\tTarget Found")
      z
    else
      # IO.puts("\tTarget Not Found")
      new_details = %{current_details | index: current_details.index + 1}

      z
      |> next_sibling()
      |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # We're in the middle of a sub tree search and are focused on a tree without children, nor next siblings, thus
  # we need to look for the next ancestral pibling. If there is no next ancestral
  # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search.
  defp do_first_extended_cousin(
         %__MODULE__{next: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not RoseTree.parent?(z.focus) do
    # IO.inspect(z.focus.term, label: "No Children to Explore - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case next_ancestral_pibling(z) do
      nil ->
        # IO.puts("\tNo Next Ancestral Pibling Found")
        nil

      %__MODULE__{} = next_ancestral_pibling ->
        new_depth = depth_of_focus(next_ancestral_pibling)

        if new_depth < loc_details.depth do
          # IO.inspect({new_depth, loc_details.depth}, label: "\tNext Ancestral Pibling Found Exceeds Boundary")
          nil
        else
          new_details = %{
            depth: new_depth,
            index: index_of_focus(next_ancestral_pibling)
          }

          next_ancestral_pibling
          |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
        end
    end
  end

  # We're in the middle of a sub tree search and are focused on a tree without children but that does have next siblings.
  # If predicate is true we've found our match. Otherwise, search next sibling.
  defp do_first_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not RoseTree.parent?(z.focus) do
    # IO.inspect(z.focus.term, label: "No Children to Explore - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    new_details = %{current_details | index: current_details.index + 1}

    z
    |> next_sibling()
    |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
  end

  # We're in the middle of a sub tree search  and are focused on a tree with children but without next siblings.
  # Find it's leftmost descendant next. If none exists, we need to look for the next ancestral pibling. If there
  # is no next ancestral pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search. If there is a leftmost descendant, continue the search from
  # that tree.
  defp do_first_extended_cousin(
         %__MODULE__{next: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(z.focus.term, label: "Exploring Subtree Of - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case leftmost_descendant(z, &(depth_of_focus(&1) == target_depth)) do
      nil ->
        case next_ancestral_pibling(z) do
          nil ->
            # IO.puts("\tNo Next Ancestral Pibling Found")
            nil

          %__MODULE__{} = next_ancestral_pibling ->
            new_depth = depth_of_focus(next_ancestral_pibling)

            if new_depth < loc_details.depth do
              # IO.puts("\tNext Ancestral Pibling Found Exceeds Boundary")
              nil
            else
              new_details = %{
                depth: new_depth,
                index: index_of_focus(next_ancestral_pibling)
              }

              next_ancestral_pibling
              |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
            end
        end

      %__MODULE__{} = descendant ->
        new_details = %{
          depth: depth_of_focus(descendant),
          index: index_of_focus(descendant)
        }

        descendant
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # We're in the middle of a sub tree search  and are focused on a tree with children and next siblings.
  # Find it's leftmost descendant next. If none exists, we need to look for the contineu search from next sibling.
  # If there is a leftmost descendant, continue the search from that tree.
  defp do_first_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(z.focus.term, label: "Exploring Subtree Of - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case leftmost_descendant(z, &(depth_of_focus(&1) == target_depth)) do
      nil ->
        new_details = %{current_details | index: current_details.index + 1}

        z
        |> next_sibling()
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)

      %__MODULE__{} = descendant ->
        new_details = %{
          depth: depth_of_focus(descendant),
          index: index_of_focus(descendant)
        }

        descendant
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  @doc """
  Searches for the last extended cousin or the last first-cousin of the focused tree.
  """
  @doc section: :extended_cousins
  @spec last_extended_cousin(t(), keyword()) :: t() | nil
  def last_extended_cousin(z, predicate \\ &Util.always/1)

  def last_extended_cousin(%__MODULE__{path: []} = z, _predicate), do: nil

  def last_extended_cousin(%__MODULE__{} = z, predicate)
      when is_function(predicate) do
    target_depth = depth_of_focus(z)

    # IO.inspect(target_depth, label: "Target Depth")

    {starting_point_on_path, path_details} =
      z
      |> parent()
      |> last_extended_cousin_starting_point()

    case starting_point_on_path do
      nil ->
        nil

      %__MODULE__{} ->
        starting_sibling = last_sibling(starting_point_on_path)

        current_details = %{
          # remove
          term: starting_sibling.focus.term,
          index: index_of_focus(starting_sibling),
          num_next: Enum.count(starting_sibling.next),
          depth: depth_of_focus(starting_sibling)
        }

        starting_sibling
        |> do_last_extended_cousin(current_details, path_details, target_depth, predicate)
    end
  end

  @spec last_extended_cousin_starting_point(t()) :: {t(), non_neg_integer()}
  defp last_extended_cousin_starting_point(%__MODULE__{} = z) do
    {_root, {candidate_depth, candidate_z, path_details}} =
      accumulate_to_root(z, {0, nil, []}, fn
        %__MODULE__{next: []} = next_z, {candidate_depth, candidate_z, details} ->
          new_details = %{
            # remove
            term: next_z.focus.term,
            index: index_of_focus(next_z),
            num_next: Enum.count(next_z.next),
            depth: depth_of_focus(next_z)
          }

          {candidate_depth, candidate_z, [new_details | details]}

        %__MODULE__{} = next_z, {_, _, details} ->
          new_depth = depth_of_focus(next_z)

          new_details = %{
            # remove
            term: next_z.focus.term,
            index: index_of_focus(next_z),
            num_next: Enum.count(next_z.next),
            depth: new_depth
          }

          {new_depth, next_z, [new_details | details]}
      end)

    # drop any erroneous accumulated path details, i.e. -
    # we don't care about the details that were gathered
    # about path locations that preceed our final candidate
    pruned_path_details = Enum.drop(path_details, candidate_depth)

    # IO.inspect(candidate_z.focus.term, label: "Starting Term")
    # IO.inspect(pruned_path_details, label: "Starting Path Details")

    {candidate_z, pruned_path_details}
  end

  @spec last_extended_cousin_descend_path(t(), [map()]) :: {t(), [map()]}
  defp last_extended_cousin_descend_path(%__MODULE__{} = z, []), do: {z, []}

  defp last_extended_cousin_descend_path(%__MODULE__{} = z, [
         %{num_next: 0} = loc_details | path_details
       ]) do
    z
    |> first_child()
    |> do_last_extended_cousin_descend_path(loc_details, path_details)
  end

  defp last_extended_cousin_descend_path(%__MODULE__{} = z, [%{index: index} | _] = path_details) do
    {child_at(z, index), path_details}
  end

  @spec do_last_extended_cousin_descend_path(t(), map(), [map()]) ::
          {t(), [map()]}
  defp do_last_extended_cousin_descend_path(%__MODULE__{} = z, %{num_next: 0}, [
         %{num_next: 0} = loc_details | path_details
       ]) do
    z
    |> first_child()
    |> do_last_extended_cousin_descend_path(loc_details, path_details)
  end

  defp do_last_extended_cousin_descend_path(
         %__MODULE__{} = z,
         %{num_next: 0},
         [%{index: index} | _] = path_details
       ) do
    {child_at(z, index), path_details}
  end

  defp do_last_extended_cousin_descend_path(%__MODULE__{} = z, _, path_details) do
    {z, path_details}
  end

  @spec do_last_extended_cousin(t(), map(), [map()], non_neg_integer(), predicate()) ::
          t() | nil
  # Path Details have been exhausted, thus no match
  defp do_last_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [] = _path_details,
         _target_depth,
         _predicate
       ) do
    # IO.inspect(z.focus.term, label: "Path Fully Explored - No Match")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(nil, label: "\tLoc Details")
    nil
  end

  # # Subtrees for all previous siblings have been explored, thus descend path to next location
  defp do_last_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | path_details],
         target_depth,
         predicate
       )
       when current_details.index == loc_details.index and
              current_details.depth == loc_details.depth do
    # IO.inspect(z.focus.term, label: "Subtrees Fully Explored for Location, Descend Path")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case last_extended_cousin_descend_path(z, path_details) do
      {_, []} ->
        nil

      {new_path_z, new_path_details} ->
        new_z = last_sibling(new_path_z)

        new_details = %{
          index: index_of_focus(new_z),
          depth: depth_of_focus(new_z)
        }

        do_last_extended_cousin(new_z, new_details, new_path_details, target_depth, predicate)
    end
  end

  # # We've reached the Target Depth and there's no more previous siblings. If predicate is true, we've found
  # # our match, otherwise, we need to look for the previous ancestral pibling. If there is no previous ancestral
  # # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search.
  defp do_last_extended_cousin(
         %__MODULE__{prev: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(z.focus.term, label: "Target Depth Reached - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(z) do
      # IO.puts("\tTarget Found")
      z
    else
      # IO.puts("\tTarget Not Found")
      case previous_ancestral_pibling(z) do
        nil ->
          # IO.puts("\tNo Previous Ancestral Pibling Found")
          nil

        %__MODULE__{} = previous_ancestral_pibling ->
          new_depth = depth_of_focus(previous_ancestral_pibling)

          if new_depth < loc_details.depth do
            # IO.puts("\tPrevious Ancestral Pibling Found Exceeds Boundary")
            nil
          else
            new_details = %{
              index: index_of_focus(previous_ancestral_pibling),
              depth: new_depth
            }

            previous_ancestral_pibling
            |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
          end
      end
    end
  end

  # # We've reached the Target Depth and there are more previous siblings to examine. If predicate is true, however,
  # # we've found our match. Otherwise, search previous sibling.
  defp do_last_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(z.focus.term, label: "Target Depth Reached - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(z) do
      # IO.puts("\tTarget Found")
      z
    else
      # IO.puts("\tTarget Not Found")
      new_details = %{current_details | index: current_details.index - 1}

      z
      |> previous_sibling()
      |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # # We're in the middle of a sub tree search and are focused on a tree without children, nor previous siblings, thus
  # # we need to look for the previous ancestral pibling. If there is no previous ancestral
  # # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search.
  defp do_last_extended_cousin(
         %__MODULE__{prev: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not RoseTree.parent?(z.focus) do
    # IO.inspect(z.focus.term, label: "No Children to Explore - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case previous_ancestral_pibling(z) do
      nil ->
        # IO.puts("\tNo Previous Ancestral Pibling Found")
        nil

      %__MODULE__{} = previous_ancestral_pibling ->
        new_depth = depth_of_focus(previous_ancestral_pibling)

        if new_depth < loc_details.depth do
          # IO.inspect({new_depth, loc_details.depth}, label: "\tPrevious Ancestral Pibling Found Exceeds Boundary")
          nil
        else
          new_details = %{
            depth: new_depth,
            index: index_of_focus(previous_ancestral_pibling)
          }

          previous_ancestral_pibling
          |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
        end
    end
  end

  # # We're in the middle of a sub tree search and are focused on a tree without children but that does have previous siblings.
  # # If predicate is true we've found our match. Otherwise, search previous sibling.
  defp do_last_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not RoseTree.parent?(z.focus) do
    # IO.inspect(z.focus.term, label: "No Children to Explore - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    new_details = %{current_details | index: current_details.index - 1}

    z
    |> previous_sibling()
    |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
  end

  # # We're in the middle of a sub tree search  and are focused on a tree with children but without previous siblings.
  # # Find it's rightmost descendant next. If none exists, we need to look for the previous ancestral pibling. If there
  # # is no previous ancestral pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search. If there is a rightmost descendant, continue the search from
  # # that tree.
  defp do_last_extended_cousin(
         %__MODULE__{prev: []} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(z.focus.term, label: "Exploring Subtree Of - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case rightmost_descendant(z, &(depth_of_focus(&1) == target_depth)) do
      nil ->
        case previous_ancestral_pibling(z) do
          nil ->
            # IO.puts("\tNo Previous Ancestral Pibling Found")
            nil

          %__MODULE__{} = previous_ancestral_pibling ->
            new_depth = depth_of_focus(previous_ancestral_pibling)

            if new_depth < loc_details.depth do
              # IO.puts("\tPrevious Ancestral Pibling Found Exceeds Boundary")
              nil
            else
              new_details = %{
                depth: new_depth,
                index: index_of_focus(previous_ancestral_pibling)
              }

              previous_ancestral_pibling
              |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
            end
        end

      %__MODULE__{} = descendant ->
        new_details = %{
          depth: depth_of_focus(descendant),
          index: index_of_focus(descendant)
        }

        descendant
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # # We're in the middle of a sub tree search  and are focused on a tree with children and previous siblings.
  # # Find it's rightmost descendant next. If none exists, we need to look for the continue search from previous sibling.
  # # If there is a rightmost descendant, continue the search from that tree.
  defp do_last_extended_cousin(
         %__MODULE__{} = z,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(z.focus.term, label: "Exploring Subtree Of - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case rightmost_descendant(z, &(depth_of_focus(&1) == target_depth)) do
      nil ->
        new_details = %{current_details | index: current_details.index - 1}

        z
        |> previous_sibling()
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)

      %__MODULE__{} = descendant ->
        new_details = %{
          depth: depth_of_focus(descendant),
          index: index_of_focus(descendant)
        }

        descendant
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  @doc """
  Searches for the previous extended cousin or the previous first-cousin of the focused tree.
  """
  @doc section: :extended_cousins
  @spec previous_extended_cousin(t(), keyword()) :: t() | nil
  def previous_extended_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    target_depth = depth_of_focus(z)

    z
    |> find_previous_extended_cousin(target_depth, predicate)
  end

  @spec find_previous_extended_cousin(t(), non_neg_integer(), predicate()) ::
          t() | nil
  defp find_previous_extended_cousin(%__MODULE__{} = z, target_depth, predicate) do
    case previous_ancestral_pibling(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = ancestral_pibling ->
        new_depth = depth_of_focus(ancestral_pibling)

        ancestral_pibling
        |> find_previous_extended_cousin_at_depth(new_depth, target_depth, predicate)
    end
  end

  @spec find_previous_extended_cousin_at_depth(
          t(),
          non_neg_integer(),
          non_neg_integer(),
          predicate()
        ) ::
          t() | nil
  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{path: [], prev: []} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      nil
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{prev: []} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      find_previous_extended_cousin(z, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      z
      |> previous_sibling()
      |> find_previous_extended_cousin_at_depth(current_depth, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{path: [], prev: []} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(z) do
      nil ->
        nil

      %__MODULE__{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{prev: []} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(z) do
      nil ->
        find_previous_extended_cousin(z, target_depth, predicate)

      %__MODULE__{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %__MODULE__{} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(z) do
      nil ->
        z
        |> previous_sibling()
        |> find_previous_extended_cousin_at_depth(current_depth, target_depth, predicate)

      %__MODULE__{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  @doc """
  Searches for the next extended cousin or the next first-cousin of the focused tree.
  """
  @doc section: :extended_cousins
  @spec next_extended_cousin(t(), keyword()) :: t() | nil
  def next_extended_cousin(%__MODULE__{} = z, predicate \\ &Util.always/1)
      when is_function(predicate) do
    target_depth = depth_of_focus(z)

    z
    |> find_next_extended_cousin(target_depth, predicate)
  end

  @spec find_next_extended_cousin(t(), non_neg_integer(), predicate()) ::
          t() | nil
  defp find_next_extended_cousin(%__MODULE__{} = z, target_depth, predicate) do
    case next_ancestral_pibling(z, &RoseTree.parent?/1) do
      nil ->
        nil

      %__MODULE__{} = ancestral_pibling ->
        new_depth = depth_of_focus(ancestral_pibling)

        ancestral_pibling
        |> find_next_extended_cousin_at_depth(new_depth, target_depth, predicate)
    end
  end

  @spec find_next_extended_cousin_at_depth(
          t(),
          non_neg_integer(),
          non_neg_integer(),
          predicate()
        ) ::
          t() | nil
  defp find_next_extended_cousin_at_depth(
         %__MODULE__{path: [], next: []} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      nil
    end
  end

  defp find_next_extended_cousin_at_depth(
         %__MODULE__{next: []} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      find_next_extended_cousin(z, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %__MODULE__{} = z,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(z.focus) do
      z
    else
      z
      |> next_sibling()
      |> find_next_extended_cousin_at_depth(current_depth, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %__MODULE__{path: [], next: []} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(z) do
      nil ->
        nil

      %__MODULE__{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %__MODULE__{next: []} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(z) do
      nil ->
        find_next_extended_cousin(z, target_depth, predicate)

      %__MODULE__{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %__MODULE__{} = z,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(z) do
      nil ->
        z
        |> next_sibling()
        |> find_next_extended_cousin_at_depth(current_depth, target_depth, predicate)

      %__MODULE__{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  ###
  ### GENERAL TRAVERSAL
  ###

  @doc """
  Rewinds a zipper back to the root.

  ## Examples

      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: locs)
      ...> z = RoseTree.Zipper.to_root(z)
      ...> RoseTree.Zipper.root?(z)
      true

  """
  @doc section: :traversal
  @spec to_root(t()) :: t()
  def to_root(%__MODULE__{} = z) do
    case parent(z) do
      nil ->
        z

      parent ->
        to_root(parent)
    end
  end

  @doc """
  Moves the focus back to the root and accumulates an additional value using the
  provided `acc_fn`. Returns a tuple including the root Zipper and the accumulated
  value.
  """
  @doc section: :traversal
  @spec accumulate_to_root(t(), term(), (t(), term() -> term())) ::
          {t(), term()}
  def accumulate_to_root(%__MODULE__{} = z, acc, acc_fn) do
    case parent(z) do
      nil ->
        {z, acc_fn.(z, acc)}

      %__MODULE__{} = parent ->
        accumulate_to_root(parent, acc_fn.(z, acc), acc_fn)
    end
  end

  @doc """
  Repeats a call to the given move function, `move_fn`, by the
  given number of `reps`.

  ## Examples

      iex> loc_trees = for n <- [4,3,2,1], do: RoseTree.new(n)
      ...> locs = for n <- loc_trees, do: RoseTree.Zipper.Location.new(n)
      ...> tree = RoseTree.new(5)
      ...> z = RoseTree.Zipper.new(tree, path: locs)
      ...> move_fn = &RoseTree.Zipper.parent/1
      ...> z = RoseTree.Zipper.move_for(z, 2, move_fn)
      ...> RoseTree.Zipper.current_focus(z).term
      3

  """
  @doc section: :traversal
  @spec move_for(
          t(),
          pos_integer(),
          (t() -> t() | nil)
        ) :: t() | nil
  def move_for(%__MODULE__{} = z, 0, _move_fn), do: z

  def move_for(%__MODULE__{} = z, reps, move_fn) when reps > 0 and is_function(move_fn) do
    1..reps
    |> Enum.reduce_while(z, fn _rep, zipper ->
      case move_fn.(zipper) do
        nil ->
          {:halt, nil}

        %__MODULE__{} = next ->
          {:cont, next}
      end
    end)
  end

  def move_for(%__MODULE__{}, _reps, _move_fn), do: nil

  ###
  ### FORWARD, BREADTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses forward through the zipper in a breadth-first manner.
  """
  @doc section: :breadth_first
  @spec forward(t()) :: t() | nil
  def forward(%__MODULE__{} = z) do
    funs = [
      &next_sibling/2,
      &next_extended_cousin/2,
      &first_extended_nibling/2,
      &first_nibling/2,
      &first_child/2
    ]

    z
    |> Util.first_of_with_args(funs, [&Util.always/1])
  end

  @doc """
  Repeats a call to `forward/1` by the given number of `reps`.
  """
  @doc section: :breadth_first
  @spec forward_for(t(), pos_integer()) :: t() | nil
  def forward_for(%__MODULE__{} = z, reps) when reps > 0,
    do: move_for(z, reps, &forward/1)

  def forward_for(%__MODULE__{}, _reps), do: nil

  @doc """
  Moves forward in the Zipper if the provided predicate function
  returns true when applied to the next  Otherwise,
  returns nil.
  """
  @doc section: :breadth_first
  @spec forward_if(t(), predicate()) :: t() | nil
  def forward_if(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case forward(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          nil
        end
    end
  end

  @doc """
  Moves forward in the Zipper continuously until the provided predicate
  function returns true when applied to the  Otherwise,
  returns nil.
  """
  @doc section: :breadth_first
  @spec forward_until(t(), predicate()) :: t() | nil
  def forward_until(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case forward(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          forward_until(next_z, predicate)
        end
    end
  end

  ###
  ### BACKWARD, BREADTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses backward through the zipper in a breadth-first manner.
  """
  @doc section: :breadth_first
  @spec backward(t()) :: t()
  def backward(%__MODULE__{path: []}), do: nil

  def backward(%__MODULE__{} = z) do
    funs = [
      fn x -> previous_sibling(x) end,
      fn x -> previous_extended_cousin(x) end,
      fn x -> last_extended_pibling(x) end,
      &parent/1
    ]

    z
    |> Util.first_of(funs)
  end

  @doc """
  Repeats a call to `backward/1` by the given number of `reps`.
  """
  @doc section: :breadth_first
  @spec backward_for(t(), pos_integer()) :: t() | nil
  def backward_for(%__MODULE__{} = z, reps) when reps > 0,
    do: move_for(z, reps, &backward/1)

  def backward_for(%__MODULE__{}, _reps), do: nil

  @doc """
  Moves backward in the Zipper if the provided predicate function
  returns true when applied to the next  Otherwise,
  returns nil.
  """
  @doc section: :breadth_first
  @spec backward_if(t(), predicate()) :: t() | nil
  def backward_if(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case backward(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          nil
        end
    end
  end

  @doc """
  Moves backward in the Zipper continuously until the provided predicate
  function returns true when applied to the  Otherwise,
  returns nil.
  """
  @doc section: :breadth_first
  @spec backward_until(t(), predicate()) :: t() | nil
  def backward_until(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case backward(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          backward_until(next_z, predicate)
        end
    end
  end

  ###
  ### DESCEND, DEPTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses forward through the zipper in a depth-first manner.
  """
  @doc section: :depth_first
  @spec descend(t()) :: t() | nil
  def descend(%__MODULE__{} = z) do
    funs = [
      &first_child/2,
      &next_sibling/2,
      &next_ancestral_pibling/2
    ]

    z
    |> Util.first_of_with_args(funs, [&Util.always/1])
  end

  @doc """
  Repeats a call to `descend/1` by the given number of `reps`.
  """
  @doc section: :depth_first
  @spec descend_for(t(), pos_integer()) :: t() | nil
  def descend_for(%__MODULE__{} = z, reps) when reps > 0,
    do: move_for(z, reps, &descend/1)

  def descend_for(%__MODULE__{}, _reps), do: nil

  @doc """
  Descends into the Zipper if the provided predicate function
  returns true when applied to the next  Otherwise,
  returns nil.
  """
  @doc section: :depth_first
  @spec descend_if(t(), predicate()) :: t() | nil
  def descend_if(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case descend(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          nil
        end
    end
  end

  @doc """
  Descends into the Zipper continuously until the provided predicate
  function returns true when applied to the  Otherwise,
  returns nil.
  """
  @doc section: :depth_first
  @spec descend_until(t(), predicate()) :: t() | nil
  def descend_until(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case descend(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          descend_until(next_z, predicate)
        end
    end
  end

  ###
  ### ASCEND, DEPTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses back through the zipper in a depth-first manner.
  """
  @doc section: :depth_first
  @spec ascend(t()) :: t()
  def ascend(%__MODULE__{} = z) do
    funs = [
      fn x -> previous_descendant_nibling(x) end,
      fn x -> previous_sibling(x) end,
      &parent/1
    ]

    z
    |> Util.first_of(funs)
  end

  @doc """
  Repeats a call to `ascend/1` by the given number of `reps`.
  """
  @doc section: :depth_first
  @spec ascend_for(t(), pos_integer()) :: t() | nil
  def ascend_for(%__MODULE__{} = z, reps) when reps > 0,
    do: move_for(z, reps, &ascend/1)

  def ascend_for(%__MODULE__{}, _reps), do: nil

  @doc """
  Ascends the Zipper if the provided predicate function
  returns true when applied to the next  Otherwise,
  returns nil.
  """
  @doc section: :depth_first
  @spec ascend_if(t(), predicate()) :: t() | nil
  def ascend_if(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case ascend(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          nil
        end
    end
  end

  @doc """
  Ascends the Zipper continuously until the provided predicate
  function returns true when applied to the  Otherwise,
  returns nil.
  """
  @doc section: :depth_first
  @spec ascend_until(t(), predicate()) :: t() | nil
  def ascend_until(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case ascend(z) do
      nil ->
        nil

      %__MODULE__{} = next_z ->
        if predicate.(next_z) do
          next_z
        else
          ascend_until(next_z, predicate)
        end
    end
  end

  ###
  ### SEARCHING
  ###

  @doc """
  Using the designated move function, `move_fn`, searches for the first
  tree that satisfies the given `predicate` function.
  """
  @doc section: :searching
  @spec find(
          t(),
          (t() -> boolean()),
          (t(), keyword() -> t() | nil)
        ) :: t() | nil
  def find(%__MODULE__{} = z, predicate, move_fn)
      when is_function(predicate) and is_function(move_fn) do
    if predicate.(z) do
      z
    else
      case move_fn.(z) do
        nil ->
          nil

        %__MODULE__{} = new_focus ->
          find(new_focus, predicate, move_fn)
      end
    end
  end

  def find(%__MODULE__{}, _predicate, _move_fn), do: nil

  @doc """
  Searches the list of parents comparing at each step to the given predicate,
  stopping either when the match is successful, or no more parents exist.
  """
  @doc section: :searching
  @spec find_parent(t(), predicate()) :: t() | nil
  def find_parent(%__MODULE__{} = z, predicate) when is_function(predicate) do
    case parent(z) do
      nil ->
        nil

      %__MODULE__{} = parent ->
        if predicate.(parent) do
          parent
        else
          find_parent(parent, predicate)
        end
    end
  end
end
