defmodule RoseTree.Zipper.Kin do
  @moduledoc """
  This module serves as a home for many common traversal functions based
  on the idea of kinship: parent, child, grandchild, sibling, cousin, etc.

  More high-level traversal functions are located in `RoseTree.Zipper.Traversal`.
  """

  require Logger
  require RoseTree.TreeNode
  require RoseTree.Zipper.Context
  alias RoseTree.{TreeNode, Util}
  alias RoseTree.Zipper.Context

  @typep predicate() :: (term() -> boolean())

  ###
  ### GENERIC
  ###

  @doc """
  Rewinds a zipper back to the root.

  ## Examples

      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> ctx = RoseTree.Zipper.Kin.to_root(ctx)
      ...> RoseTree.Zipper.Context.root?(ctx)
      true

  """
  @spec to_root(Context.t()) :: Context.t()
  def to_root(%Context{} = ctx) do
    case parent(ctx) do
      nil ->
        ctx

      parent ->
        to_root(parent)
    end
  end

  @doc """
  Moves the focus back to the root and accumulates an additional value using the
  provided `acc_fn`. Returns a tuple including the root Context and the accumulated
  value.
  """
  @spec accumulate_to_root(Context.t(), term(), (Context.t(), term() -> term())) ::
          {Context.t(), term()}
  def accumulate_to_root(%Context{} = ctx, acc, acc_fn) do
    case parent(ctx) do
      nil ->
        {ctx, acc_fn.(ctx, acc)}

      %Context{} = parent ->
        accumulate_to_root(parent, acc_fn.(ctx, acc), acc_fn)
    end
  end

  @doc """
  Repeats a call to the given move function, `move_fn`, by the
  given number of `reps`.

  ## Examples

      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> move_fn = &RoseTree.Zipper.Kin.parent/1
      ...> ctx = RoseTree.Zipper.Kin.move_for(ctx, 2, move_fn)
      ...> RoseTree.Zipper.Context.current_focus(ctx).term
      3

  """
  @spec move_for(
          Context.t(),
          pos_integer(),
          (Context.t() -> Context.t() | nil)
        ) :: Context.t() | nil
  def move_for(%Context{} = ctx, 0, _move_fn), do: ctx

  def move_for(%Context{} = ctx, reps, move_fn) when reps > 0 and is_function(move_fn) do
    1..reps
    |> Enum.reduce_while(ctx, fn _rep, context ->
      case move_fn.(context) do
        nil ->
          {:halt, nil}

        %Context{} = next ->
          {:cont, next}
      end
    end)
  end

  def move_for(%Context{}, _reps, _move_fn), do: nil

  ###
  ### DIRECT ANCESTORS (PARENTS, GRANDPARENTS, ETC)
  ###

  @doc """
  Moves the focus to the parent Location. If at the root, thus no
  parent, returns nil.

  ## Examples

      iex> prev = for n <- [4,3], do: RoseTree.TreeNode.new(n)
      ...> loc_nodes = for n <- [2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, path: locs)
      ...> RoseTree.Zipper.Kin.parent(ctx)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{
          term: 2,
          children: [
            %RoseTree.TreeNode{term: 3, children: []},
            %RoseTree.TreeNode{term: 4, children: []},
            %RoseTree.TreeNode{term: 5, children: []}
          ]
        },
        prev: [],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 1, next: []}]
      }

  """
  @spec parent(Context.t()) :: Context.t() | nil
  def parent(%Context{path: []}), do: nil

  def parent(%Context{path: [parent | g_parents]} = ctx) do
    combined_ctx = Enum.reverse(ctx.prev) ++ [ctx.focus | ctx.next]

    focused_parent =
      parent.term
      |> TreeNode.new(combined_ctx)

    %{ctx | prev: parent.prev, next: parent.next, path: g_parents}
    |> Context.set_focus(focused_parent)
  end

  @doc """
  Moves the focus to the grandparent -- the parent of the parent -- of
  the focus, if possible. If there is no grandparent, returns nil.
  """
  @spec grandparent(Context.t()) :: Context.t() | nil
  def grandparent(%Context{} = ctx) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = grandparent <- parent(parent) do
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
  @spec great_grandparent(Context.t()) :: Context.t() | nil
  def great_grandparent(%Context{} = ctx) do
    with %Context{} = grandparent <- grandparent(ctx),
         %Context{} = great_grandparent <- parent(grandparent) do
      great_grandparent
    else
      nil ->
        nil
    end
  end

  @doc """
  Searches the list of parents comparing at each step to the given predicate,
  stopping either when the match is successful, or no more parents exist.
  """
  @spec find_parent(Context.t(), predicate()) :: Context.t() | nil
  def find_parent(%Context{} = ctx, predicate) when is_function(predicate) do
    case parent(ctx) do
      nil ->
        nil

      %Context{} = parent ->
        if predicate.(parent) do
          parent
        else
          find_parent(parent, predicate)
        end
    end
  end

  ###
  ### DESCENDANTS (CHILDREN, GRAND-CHILDREN, ETC.)
  ###

  @doc """
  Moves focus to the first child. If there are no children, and this is
  a leaf, returns nil.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [6,7,8,9])
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Kin.first_child(ctx)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 6, children: []},
        prev: [],
        next: [
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 9, children: []}
        ],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

      iex> node = RoseTree.TreeNode.new(5, [6,7,8,9])
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Kin.first_child(ctx, fn x -> x.term == 9 end)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 9, children: []},
        prev: [
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 6, children: []}
        ],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @spec first_child(Context.t(), predicate()) :: Context.t() | nil
  def first_child(context, predicate \\ &Util.always/1)

  def first_child(%Context{focus: focus}, _predicate)
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def first_child(%Context{} = ctx, predicate) when is_function(predicate) do
    children = Context.focused_children(ctx)

    case Util.split_when(children, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          ctx
          | focus: focus,
            prev: prev,
            next: next,
            path: [Context.new_location(ctx) | ctx.path]
        }
    end
  end

  @doc """
  Moves focus to the last child. If there are no children, and this is
  a leaf, returns nil.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [6,7,8,9])
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Kin.last_child(ctx)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 9, children: []},
        prev: [
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 6, children: []}
        ],
        next: [],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @spec last_child(Context.t(), predicate()) :: Context.t() | nil
  def last_child(context, predicate \\ &Util.always/1)

  def last_child(%Context{focus: focus}, _predicate)
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def last_child(%Context{} = ctx, predicate) when is_function(predicate) do
    children =
      ctx
      |> Context.focused_children()
      |> Enum.reverse()

    case Util.split_when(children, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          ctx
          | focus: focus,
            prev: prev,
            next: next,
            path: [Context.new_location(ctx) | ctx.path]
        }
    end
  end

  @doc """
  Moves focus to the child at the specified index. If there are no children,
  or if the child does not exist at the index, returns nil.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [6,7,8,9])
      ...> ctx = RoseTree.Zipper.Context.new(node)
      ...> RoseTree.Zipper.Kin.child_at(ctx, 2)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 8, children: []},
        prev: [
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 6, children: []}
        ],
        next: [%RoseTree.TreeNode{term: 9, children: []}],
        path: [%RoseTree.Zipper.Location{prev: [], term: 5, next: []}]
      }

  """
  @spec child_at(Context.t(), non_neg_integer()) :: Context.t() | nil
  def child_at(%Context{focus: focus}, _index)
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def child_at(%Context{} = ctx, index) when is_integer(index) do
    children = Context.focused_children(ctx)

    case Util.split_at(children, index) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %Context{
          focus: focus,
          prev: prev,
          next: next,
          path: [Context.new_location(ctx) | ctx.path]
        }
    end
  end

  @doc """
  Moves the focus to the first grandchild -- the first child of the
  first child -- of the focus. If there are no grandchildren, moves to
  the next sibling of the first child and looks for that node's first
  child. This repeats until the first grandchild is found or it returns
  nil if none are found.
  """
  @spec first_grandchild(Context.t(), predicate()) :: Context.t() | nil
  def first_grandchild(context, predicate \\ &Util.always/1)

  def first_grandchild(%Context{} = ctx, predicate) when is_function(predicate) do
    case first_child(ctx) do
      nil ->
        nil

      %Context{} = first_child ->
        do_first_grandchild(first_child, predicate)
    end
  end

  defp do_first_grandchild(%Context{} = ctx, predicate) do
    case first_child(ctx, predicate) do
      nil ->
        ctx
        |> next_sibling()
        |> do_first_grandchild(predicate)

      %Context{} = first_grandchild ->
        first_grandchild
    end
  end

  defp do_first_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the last grandchild -- the last child of the
  last child -- of the focus. If there are no grandchildren, moves to
  the previous sibling of the last child and looks for that node's last
  child. This repeats until the first grandchild is found or it returns
  nil if none are found.
  """
  @spec last_grandchild(Context.t(), predicate()) :: Context.t() | nil
  def last_grandchild(context, predicate \\ &Util.always/1)

  def last_grandchild(%Context{} = ctx, predicate) when is_function(predicate) do
    case last_child(ctx) do
      nil ->
        nil

      %Context{} = last_child ->
        do_last_grandchild(last_child, predicate)
    end
  end

  defp do_last_grandchild(%Context{} = ctx, predicate) do
    case last_child(ctx, predicate) do
      nil ->
        ctx
        |> previous_sibling()
        |> do_last_grandchild(predicate)

      %Context{} = last_grandchild ->
        last_grandchild
    end
  end

  defp do_last_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the first great-grandchild -- the first child of the
  first grandchild -- of the focus. If there are no great-grandchildren, moves to
  the next sibling of the first grandchild and looks for that node's first
  child. This repeats until the first great-grandchild is found or it returns
  nil if none are found.
  """
  @spec first_great_grandchild(Context.t(), predicate()) :: Context.t() | nil
  def first_great_grandchild(context, predicate \\ &Util.always/1)

  def first_great_grandchild(%Context{} = ctx, predicate) when is_function(predicate) do
    # first grandchild with children
    case first_grandchild(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = first_grandchild ->
        do_first_great_grandchild(first_grandchild, predicate)
    end
  end

  defp do_first_great_grandchild(%Context{} = ctx, predicate) do
    case first_child(ctx, predicate) do
      nil ->
        ctx
        |> next_sibling()
        |> do_first_great_grandchild(predicate)

      %Context{} = first_great_grandchild ->
        first_great_grandchild
    end
  end

  defp do_first_great_grandchild(nil, _predicate), do: nil

  @doc """
  Moves the focus to the last great-grandchild -- the last child of the
  last grandchild -- of the focus. If there are no great-grandchildren,
  moves to the previous sibling of the last grandchild and looks for that node's
  last child. This repeats until the last great-grandchild is found or it
  returns nil if none are found.
  """
  @spec last_great_grandchild(Context.t(), predicate()) :: Context.t() | nil
  def last_great_grandchild(context, predicate \\ &Util.always/1)

  def last_great_grandchild(%Context{} = ctx, predicate) when is_function(predicate) do
    # last grandchild with children
    case last_grandchild(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = last_grandchild ->
        do_last_great_grandchild(last_grandchild, predicate)
    end
  end

  defp do_last_great_grandchild(%Context{} = ctx, predicate) do
    case last_child(ctx, predicate) do
      nil ->
        ctx
        |> previous_sibling()
        |> do_last_great_grandchild(predicate)

      %Context{} = last_great_grandchild ->
        last_great_grandchild
    end
  end

  defp do_last_great_grandchild(nil, _predicate), do: nil

  @doc """
  Descend the right-most edge until it can go no further or until
  the optional predicate matches.
  """
  @spec rightmost_descendant(Context.t(), predicate()) :: Context.t() | nil
  def rightmost_descendant(context, predicate \\ nil)

  def rightmost_descendant(%Context{focus: focus}, _predicate) when TreeNode.leaf?(focus),
    do: nil

  def rightmost_descendant(%Context{} = ctx, nil),
    do: do_rightmost_descendant(ctx)

  def rightmost_descendant(%Context{} = ctx, predicate) when is_function(predicate),
    do: do_rightmost_descendant_until(ctx, predicate)

  @spec do_rightmost_descendant(Context.t()) :: Context.t()
  defp do_rightmost_descendant(%Context{} = ctx) do
    case last_child(ctx) do
      nil ->
        ctx

      %Context{} = last_child ->
        do_rightmost_descendant(last_child)
    end
  end

  @spec do_rightmost_descendant_until(Context.t(), predicate()) :: Context.t() | nil
  defp do_rightmost_descendant_until(%Context{} = ctx, predicate) do
    case last_child(ctx) do
      nil ->
        ctx

      %Context{} = last_child ->
        if predicate.(last_child) do
          last_child
        else
          do_rightmost_descendant_until(last_child, predicate)
        end
    end
  end

  @doc """
  Descend the left-most edge until it can go no further or until
  the optional predicate matches.
  """
  @spec leftmost_descendant(Context.t(), predicate()) :: Context.t() | nil
  def leftmost_descendant(context, predicate \\ nil)

  def leftmost_descendant(%Context{focus: focus}, _predicate) when TreeNode.leaf?(focus),
    do: nil

  def leftmost_descendant(%Context{} = ctx, nil),
    do: do_leftmost_descendant(ctx)

  def leftmost_descendant(%Context{} = ctx, predicate) when is_function(predicate),
    do: do_leftmost_descendant_until(ctx, predicate)

  @spec do_leftmost_descendant(Context.t()) :: Context.t()
  defp do_leftmost_descendant(%Context{} = ctx) do
    case first_child(ctx) do
      nil ->
        ctx

      %Context{} = first_child ->
        do_leftmost_descendant(first_child)
    end
  end

  @spec do_leftmost_descendant_until(Context.t(), predicate()) :: Context.t() | nil
  defp do_leftmost_descendant_until(%Context{} = ctx, predicate) do
    case first_child(ctx) do
      nil ->
        ctx

      %Context{} = first_child ->
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
  Moves focus to the first sibling from the current focus. If there are
  no more siblings before the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
    ...> node = RoseTree.TreeNode.new(5)
    ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, next: next)
    ...> RoseTree.Zipper.Kin.first_sibling(ctx)
    %RoseTree.Zipper.Context{
      focus: %RoseTree.TreeNode{term: 1, children: []},
      prev: [],
      next: [
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 4, children: []},
        %RoseTree.TreeNode{term: 5, children: []},
        %RoseTree.TreeNode{term: 6, children: []},
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 9, children: []}
      ],
      path: []
    }

  """
  @spec first_sibling(Context.t(), predicate()) :: Context.t() | nil
  def first_sibling(context, predicate \\ &Util.always/1)

  def first_sibling(%Context{prev: []}, _predicate), do: nil

  def first_sibling(%Context{prev: prev} = ctx, predicate) when is_function(predicate) do
    previous_siblings = Enum.reverse(prev)

    case Util.split_when(previous_siblings, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          ctx
          | focus: focus,
            prev: prev,
            next: next ++ [ctx.focus | ctx.next],
            path: ctx.path
        }
    end
  end

  @doc """
  Moves focus to the previous sibling to the current focus. If there are
  no more siblings before the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
    ...> node = RoseTree.TreeNode.new(5)
    ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, next: next)
    ...> RoseTree.Zipper.Kin.previous_sibling(ctx)
    %RoseTree.Zipper.Context{
      focus: %RoseTree.TreeNode{term: 4, children: []},
      prev: [
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 1, children: []}
      ],
      next: [
        %RoseTree.TreeNode{term: 5, children: []},
        %RoseTree.TreeNode{term: 6, children: []},
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 9, children: []}
      ],
      path: []
    }

  """
  @spec previous_sibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_sibling(context, predicate \\ &Util.always/1)

  def previous_sibling(%Context{prev: []}, _predicate), do: nil

  def previous_sibling(%Context{prev: prev} = ctx, predicate) when is_function(predicate) do
    case Util.split_when(prev, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          ctx
          | focus: focus,
            prev: prev,
            next: next ++ [ctx.focus | ctx.next],
            path: ctx.path
        }
    end
  end

  @doc """
  Moves focus to the last sibling from the current focus. If there are
  no more siblings after the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
    ...> node = RoseTree.TreeNode.new(5)
    ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, next: next)
    ...> RoseTree.Zipper.Kin.last_sibling(ctx)
    %RoseTree.Zipper.Context{
      focus: %RoseTree.TreeNode{term: 9, children: []},
      prev: [
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 6, children: []},
        %RoseTree.TreeNode{term: 5, children: []},
        %RoseTree.TreeNode{term: 4, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 1, children: []}
      ],
      next: [],
      path: []
    }

  """
  @spec last_sibling(Context.t(), predicate()) :: Context.t() | nil
  def last_sibling(context, predicate \\ &Util.always/1)

  def last_sibling(%Context{next: []}, _predicate), do: nil

  def last_sibling(%Context{next: next} = ctx, predicate) when is_function(predicate) do
    last_siblings = Enum.reverse(next)

    case Util.split_when(last_siblings, predicate) do
      {[], []} ->
        nil

      {next, [focus | prev]} ->
        %{
          ctx
          | focus: focus,
            prev: prev ++ [ctx.focus | ctx.prev],
            next: next,
            path: ctx.path
        }
    end
  end

  @doc """
  Moves focus to the next sibling of the current focus. If there are
  no more siblings after the current focus, returns nil.

  ## Examples

    iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
    ...> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
    ...> node = RoseTree.TreeNode.new(5)
    ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, next: next)
    ...> RoseTree.Zipper.Kin.next_sibling(ctx)
    %RoseTree.Zipper.Context{
      focus: %RoseTree.TreeNode{term: 6, children: []},
      prev: [
        %RoseTree.TreeNode{term: 5, children: []},
        %RoseTree.TreeNode{term: 4, children: []},
        %RoseTree.TreeNode{term: 3, children: []},
        %RoseTree.TreeNode{term: 2, children: []},
        %RoseTree.TreeNode{term: 1, children: []}
      ],
      next: [
        %RoseTree.TreeNode{term: 7, children: []},
        %RoseTree.TreeNode{term: 8, children: []},
        %RoseTree.TreeNode{term: 9, children: []}
      ],
      path: []
    }

  """
  @spec next_sibling(Context.t(), predicate()) :: Context.t() | nil
  def next_sibling(context, predicate \\ &Util.always/1)

  def next_sibling(%Context{next: []}, _predicate), do: nil

  def next_sibling(%Context{next: next} = ctx, predicate) when is_function(predicate) do
    case Util.split_when(next, predicate) do
      {[], []} ->
        nil

      {prev, [focus | next]} ->
        %{
          ctx
          | focus: focus,
            prev: prev ++ [ctx.focus | ctx.prev],
            next: next,
            path: ctx.path
        }
    end
  end

  @doc """
  Moves focus to the sibling of the current focus at the given index.
  If no sibling is found at that index, or if the provided index
  is the index for the current focus, returns nil.

  ## Examples

      iex> prev = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> next = for n <- [6,7,8,9], do: RoseTree.TreeNode.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, prev: prev, next: next)
      ...> RoseTree.Zipper.Kin.sibling_at(ctx, 2)
      %RoseTree.Zipper.Context{
        focus: %RoseTree.TreeNode{term: 3, children: []},
        prev: [
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
        ],
        next: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 5, children: []},
          %RoseTree.TreeNode{term: 6, children: []},
          %RoseTree.TreeNode{term: 7, children: []},
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 9, children: []}
        ],
        path: []
      }

  """
  @spec sibling_at(Context.t(), non_neg_integer()) :: Context.t() | nil
  def sibling_at(%Context{prev: [], next: []} = ctx, index), do: nil

  def sibling_at(%Context{} = ctx, index) when is_integer(index) do
    current_idx = Context.index_of_focus(ctx)

    if current_idx == index do
      nil
    else
      siblings = Enum.reverse(ctx.prev) ++ [ctx.focus | ctx.next]

      case Util.split_at(siblings, index) do
        {[], []} ->
          nil

        {prev, [focus | next]} ->
          %Context{
            focus: focus,
            prev: prev,
            next: next,
            path: ctx.path
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
  @spec first_nibling(Context.t(), predicate()) :: Context.t() | nil
  def first_nibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = first_sibling <- first_sibling(ctx, &TreeNode.parent?/1),
         %Context{} = first_child <- first_child(first_sibling, predicate) do
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
  @spec last_nibling(Context.t(), predicate()) :: Context.t() | nil
  def last_nibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = last_sibling <- last_sibling(ctx, &TreeNode.parent?/1),
         %Context{} = last_child <- last_child(last_sibling, predicate) do
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
  @spec previous_nibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_nibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = previous_sibling <- previous_sibling(ctx, &TreeNode.parent?/1),
         %Context{} = last_child <- last_child(previous_sibling, predicate) do
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
  @spec next_nibling(Context.t(), predicate()) :: Context.t() | nil
  def next_nibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = next_sibling <- next_sibling(ctx, &TreeNode.parent?/1),
         %Context{} = first_child <- first_child(next_sibling, predicate) do
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
  @spec first_nibling_at_sibling(Context.t(), non_neg_integer(), predicate()) :: Context.t() | nil
  def first_nibling_at_sibling(%Context{} = ctx, index, predicate \\ &Util.always/1)
      when is_integer(index) and is_function(predicate) do
    with %Context{} = sibling_at <- sibling_at(ctx, index),
         %Context{} = first_child <- first_child(sibling_at, predicate) do
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
  @spec last_nibling_at_sibling(Context.t(), non_neg_integer(), predicate()) :: Context.t() | nil
  def last_nibling_at_sibling(%Context{} = ctx, index, predicate \\ &Util.always/1)
      when is_integer(index) and is_function(predicate) do
    with %Context{} = sibling_at <- sibling_at(ctx, index),
         %Context{} = last_child <- last_child(sibling_at, predicate) do
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
  @spec previous_grandnibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_grandnibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_sibling(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = previous_sibling ->
        do_previous_grandnibling(previous_sibling, predicate)
    end
  end

  defp do_previous_grandnibling(%Context{} = ctx, predicate) do
    case last_grandchild(ctx, predicate) do
      nil ->
        previous_grandnibling(ctx, predicate)

      %Context{} = last_grandchild ->
        last_grandchild
    end
  end

  @doc """
  Moves the focus to the next grand-nibling -- the first grandchild of
  the next sibling -- of the current focus. If not found, returns nil.
  """
  @spec next_grandnibling(Context.t(), predicate()) :: Context.t() | nil
  def next_grandnibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_sibling(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = next_sibling ->
        do_next_grandnibling(next_sibling, predicate)
    end
  end

  defp do_next_grandnibling(%Context{} = ctx, predicate) do
    case first_grandchild(ctx, predicate) do
      nil ->
        next_grandnibling(ctx, predicate)

      %Context{} = first_grandchild ->
        first_grandchild
    end
  end

  @doc """
  Recursively searches the descendant branches of the first sibling for the
  first "descendant nibling" of the current focus. That is, if a first
  nibling is found, it will then look for the first child of that node (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @spec first_descendant_nibling(Context.t(), predicate()) :: Context.t() | nil
  def first_descendant_nibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case first_sibling(ctx) do
      nil ->
        nil

      %Context{} = first_sibling ->
        do_first_descendant_nibling(first_sibling, predicate, nil)
    end
  end

  defp do_first_descendant_nibling(%Context{} = ctx, predicate, last_match) do
    case first_child(ctx) do
      nil ->
        last_match

      %Context{} = first_child ->
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
  nibling is found, it will then look for the last child of that node (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @spec last_descendant_nibling(Context.t(), predicate()) :: Context.t() | nil
  def last_descendant_nibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case last_sibling(ctx) do
      nil ->
        nil

      %Context{} = last_sibling ->
        do_last_descendant_nibling(last_sibling, predicate, nil)
    end
  end

  defp do_last_descendant_nibling(%Context{} = ctx, predicate, last_match) do
    case last_child(ctx) do
      nil ->
        last_match

      %Context{} = last_child ->
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
  nibling is found, it will then look for the last child of that node (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @spec previous_descendant_nibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_descendant_nibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_sibling(ctx) do
      nil ->
        nil

      %Context{} = previous_sibling ->
        do_previous_descendant_nibling(previous_sibling, predicate, nil)
    end
  end

  defp do_previous_descendant_nibling(%Context{} = ctx, predicate, last_match) do
    case last_child(ctx) do
      nil ->
        last_match

      %Context{} = last_child ->
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
  nibling is found, it will then look for the first child of that node (the
  "descendant nibling"). It will repeat the search if one is found, and it will
  continue until no more are found, returning the last one visited.
  """
  @spec next_descendant_nibling(Context.t(), predicate()) :: Context.t() | nil
  def next_descendant_nibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_sibling(ctx) do
      nil ->
        nil

      %Context{} = next_sibling ->
        do_next_descendant_nibling(next_sibling, predicate, nil)
    end
  end

  defp do_next_descendant_nibling(%Context{} = ctx, predicate, last_match) do
    case first_child(ctx) do
      nil ->
        last_match

      %Context{} = first_child ->
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
  extended nibling--of the focused node.
  """
  @spec first_extended_nibling(Context.t(), predicate()) :: Context.t() | nil
  def first_extended_nibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = first_extended_cousin <-
           first_extended_cousin(ctx, &Context.has_children?/1),
         %Context{} = first_child <- first_child(first_extended_cousin, predicate) do
      first_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last child of the last extended cousin--aka, the last
  extended nibling--of the focused node.
  """
  @spec last_extended_nibling(Context.t(), predicate()) :: Context.t() | nil
  def last_extended_nibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = last_extended_cousin <- last_extended_cousin(ctx, &Context.has_children?/1),
         %Context{} = last_child <- last_child(last_extended_cousin, predicate) do
      last_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last child of the previous extended cousin--aka, the previous
  extended nibling--of the focused node.
  """
  @spec previous_extended_nibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_extended_nibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = prev_extended_cousin <-
           previous_extended_cousin(ctx, &Context.has_children?/1),
         %Context{} = last_child <- last_child(prev_extended_cousin, predicate) do
      last_child
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the first child of the next extended cousin--aka, the next
  extended nibling--of the focused node.
  """
  @spec next_extended_nibling(Context.t(), predicate()) :: Context.t() | nil
  def next_extended_nibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = next_extended_cousin <- next_extended_cousin(ctx, &Context.has_children?/1),
         %Context{} = first_child <- first_child(next_extended_cousin, predicate) do
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
  @spec first_pibling(Context.t(), predicate()) :: Context.t() | nil
  def first_pibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = first_sibling <- first_sibling(parent, predicate) do
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
  @spec last_pibling(Context.t(), predicate()) :: Context.t() | nil
  def last_pibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = last_sibling <- last_sibling(parent, predicate) do
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
  @spec previous_pibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_pibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = previous_sibling <- previous_sibling(parent, predicate) do
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
  @spec next_pibling(Context.t(), predicate()) :: Context.t() | nil
  def next_pibling(%Context{} = ctx, predicate \\ &Util.always/1) when is_function(predicate) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = next_sibling <- next_sibling(parent, predicate) do
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
  @spec pibling_at(Context.t(), non_neg_integer()) :: Context.t() | nil
  def pibling_at(%Context{} = ctx, index) when is_integer(index) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = sibling_at <- sibling_at(parent, index) do
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
  @spec first_grandpibling(Context.t(), predicate()) :: Context.t() | nil
  def first_grandpibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = grandparent <- grandparent(ctx),
         %Context{} = first_sibling <- first_sibling(grandparent, predicate) do
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
  @spec last_grandpibling(Context.t(), predicate()) :: Context.t() | nil
  def last_grandpibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = grandparent <- grandparent(ctx),
         %Context{} = last_sibling <- last_sibling(grandparent, predicate) do
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
  @spec previous_grandpibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_grandpibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = grandparent <- grandparent(ctx),
         %Context{} = previous_sibling <- previous_sibling(grandparent, predicate) do
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
  @spec next_grandpibling(Context.t(), predicate()) :: Context.t() | nil
  def next_grandpibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = grandparent <- grandparent(ctx),
         %Context{} = next_sibling <- next_sibling(grandparent, predicate) do
      next_sibling
    else
      nil ->
        nil
    end
  end

  @doc """
  Searches for the first extended cousin of the parent--aka, the
  first extended pibling--of the focused node.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @spec first_extended_pibling(Context.t(), predicate()) :: Context.t() | nil
  def first_extended_pibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = first_extended_cousin <- first_extended_cousin(parent, predicate) do
      first_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the last extended cousin of the parent--aka, the
  last extended pibling--of the focused node.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @spec last_extended_pibling(Context.t(), predicate()) :: Context.t() | nil
  def last_extended_pibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = last_extended_cousin <- last_extended_cousin(parent, predicate) do
      last_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the previous extended cousin of the parent--aka, the
  previous extended pibling--of the focused node.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @spec previous_extended_pibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_extended_pibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = previous_extended_cousin <- previous_extended_cousin(parent, predicate) do
      previous_extended_cousin
    else
      nil -> nil
    end
  end

  @doc """
  Searches for the next extended cousin of the parent--aka, the
  next extended pibling--of the focused node.

  Note: Extended Pibling here really means parent-cousin n-times removed,
  and is a bit of a neolism, since pibling technically means parent-sibling.
  """
  @spec next_extended_pibling(Context.t(), predicate()) :: Context.t() | nil
  def next_extended_pibling(%Context{} = ctx, predicate \\ &Util.always/1) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = next_extended_cousin <- next_extended_cousin(parent, predicate) do
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
  @spec first_ancestral_pibling(Context.t(), predicate()) :: Context.t() | nil
  def first_ancestral_pibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case first_pibling(ctx, predicate) do
      nil ->
        ctx
        |> parent()
        |> first_ancestral_pibling(predicate)

      %Context{} = first_ancestral_pibling ->
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
  @spec previous_ancestral_pibling(Context.t(), predicate()) :: Context.t() | nil
  def previous_ancestral_pibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case previous_pibling(ctx, predicate) do
      nil ->
        ctx
        |> parent()
        |> previous_ancestral_pibling(predicate)

      %Context{} = previous_ancestral_pibling ->
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
  @spec next_ancestral_pibling(Context.t(), predicate()) :: Context.t() | nil
  def next_ancestral_pibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case next_pibling(ctx, predicate) do
      nil ->
        ctx
        |> parent()
        |> next_ancestral_pibling(predicate)

      %Context{} = next_ancestral_pibling ->
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
  @spec last_ancestral_pibling(Context.t(), predicate()) :: Context.t() | nil
  def last_ancestral_pibling(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    case last_pibling(ctx, predicate) do
      nil ->
        ctx
        |> parent()
        |> last_ancestral_pibling(predicate)

      %Context{} = last_ancestral_pibling ->
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
  @spec first_first_cousin(Context.t(), predicate()) :: Context.t() | nil
  def first_first_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- Context.index_of_parent(ctx),
         %Context{} = first_pibling <- first_pibling(ctx, &TreeNode.parent?/1),
         %Context{} = first_first_cousin <-
           do_first_first_cousin(first_pibling, predicate, starting_idx) do
      first_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_first_first_cousin(%Context{} = ctx, predicate, starting_idx) do
    current_idx = Context.index_of_focus(ctx)

    if current_idx < starting_idx do
      case first_child(ctx, predicate) do
        nil ->
          ctx
          |> next_sibling(&TreeNode.parent?/1)
          |> do_first_first_cousin(predicate, starting_idx)

        %Context{} = first_child ->
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
  @spec last_first_cousin(Context.t(), predicate()) :: Context.t() | nil
  def last_first_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- Context.index_of_parent(ctx),
         %Context{} = last_pibling <- last_pibling(ctx, &TreeNode.parent?/1),
         %Context{} = last_first_cousin <-
           do_last_first_cousin(last_pibling, predicate, starting_idx) do
      last_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_last_first_cousin(%Context{} = ctx, predicate, starting_idx) do
    current_idx = Context.index_of_focus(ctx)

    if current_idx > starting_idx do
      case last_child(ctx, predicate) do
        nil ->
          ctx
          |> previous_sibling(&TreeNode.parent?/1)
          |> do_last_first_cousin(predicate, starting_idx)

        %Context{} = last_child ->
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
  @spec previous_first_cousin(Context.t(), predicate()) :: Context.t() | nil
  def previous_first_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = previous_pibling <- previous_pibling(ctx, &TreeNode.parent?/1),
         %Context{} = previous_first_cousin <-
           do_previous_first_cousin(previous_pibling, predicate) do
      previous_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_previous_first_cousin(%Context{} = ctx, predicate) do
    case last_child(ctx, predicate) do
      nil ->
        ctx
        |> previous_sibling(&TreeNode.parent?/1)
        |> do_previous_first_cousin(predicate)

      %Context{} = last_child ->
        last_child
    end
  end

  defp do_previous_first_cousin(nil, _predicate), do: nil

  @doc """
  Moves the focus to the next first-cousin -- the first child of the
  next pibling with children -- of the current focus. If not found, returns nil.
  """
  @spec next_first_cousin(Context.t(), predicate()) :: Context.t() | nil
  def next_first_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = next_pibling <- next_pibling(ctx, &TreeNode.parent?/1),
         %Context{} = next_first_cousin <-
           do_next_first_cousin(next_pibling, predicate) do
      next_first_cousin
    else
      _ ->
        nil
    end
  end

  defp do_next_first_cousin(%Context{} = ctx, predicate) do
    case first_child(ctx, predicate) do
      nil ->
        ctx
        |> next_sibling(&TreeNode.parent?/1)
        |> do_next_first_cousin(predicate)

      %Context{} = first_child ->
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
  @spec first_second_cousin(Context.t(), predicate()) :: Context.t() | nil
  def first_second_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- Context.index_of_grandparent(ctx),
         %Context{} = first_grandpibling <- first_grandpibling(ctx, &TreeNode.parent?/1),
         %Context{} = first_second_cousin <-
           do_first_second_cousin(first_grandpibling, predicate, starting_idx) do
      first_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_first_second_cousin(%Context{} = ctx, predicate, starting_idx) do
    current_idx = Context.index_of_focus(ctx)

    if current_idx < starting_idx do
      case first_grandchild(ctx, predicate) do
        nil ->
          ctx
          |> next_sibling(&TreeNode.parent?/1)
          |> do_first_second_cousin(predicate, starting_idx)

        %Context{} = first_grandchild ->
          first_grandchild
      end
    else
      nil
    end
  end

  @spec last_second_cousin(Context.t(), predicate()) :: Context.t() | nil
  def last_second_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with starting_idx <- Context.index_of_grandparent(ctx),
         %Context{} = last_grandpibling <- last_grandpibling(ctx, &TreeNode.parent?/1),
         %Context{} = last_second_cousin <-
           do_last_second_cousin(last_grandpibling, predicate, starting_idx) do
      last_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_last_second_cousin(%Context{} = ctx, predicate, starting_idx) do
    current_idx = Context.index_of_focus(ctx)

    if current_idx > starting_idx do
      case last_grandchild(ctx, predicate) do
        nil ->
          ctx
          |> previous_sibling(&TreeNode.parent?/1)
          |> do_last_second_cousin(predicate, starting_idx)

        %Context{} = last_grandchild ->
          last_grandchild
      end
    else
      nil
    end
  end

  @spec previous_second_cousin(Context.t(), predicate()) :: Context.t() | nil
  def previous_second_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = previous_grandpibling <- previous_grandpibling(ctx, &TreeNode.parent?/1),
         %Context{} = previous_second_cousin <-
           do_previous_second_cousin(previous_grandpibling, predicate) do
      previous_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_previous_second_cousin(%Context{} = ctx, predicate) do
    case last_grandchild(ctx, predicate) do
      nil ->
        ctx
        |> previous_sibling(&TreeNode.parent?/1)
        |> do_previous_second_cousin(predicate)

      %Context{} = last_grandchild ->
        last_grandchild
    end
  end

  defp do_previous_second_cousin(nil, _predicate), do: nil

  @spec next_second_cousin(Context.t(), predicate()) :: Context.t() | nil
  def next_second_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    with %Context{} = next_grandpibling <- next_grandpibling(ctx, &TreeNode.parent?/1),
         %Context{} = next_second_cousin <-
           do_next_second_cousin(next_grandpibling, predicate) do
      next_second_cousin
    else
      _ ->
        nil
    end
  end

  defp do_next_second_cousin(%Context{} = ctx, predicate) do
    case first_grandchild(ctx, predicate) do
      nil ->
        ctx
        |> next_sibling(&TreeNode.parent?/1)
        |> do_next_second_cousin(predicate)

      %Context{} = first_grandchild ->
        first_grandchild
    end
  end

  defp do_next_second_cousin(nil, _opts), do: nil

  ###
  ### EXTENDED COUSINS
  ###

  @doc """
  Searches for the first extended cousin or the first first-cousin of the focused node.

  High level steps:

  1. Ascend `path` to find highest location with `prev` siblings.
  2. Starting with the first sibling, check each subtree from left to right,
      and if you reach the target depth and find a node that satisifies any
      given predicate, stop there. Otherwise, continue left to right.
  3. If you return back to the starting Location, descend the `path` to next
      deepest Location and set as starting Location. Goto step 2.
  4. If you return back to starting Location, and it is also the ending Location,
      and you have not found a suitable note at the right depth, you will not find one.
  """
  @spec first_extended_cousin(Context.t(), keyword()) :: Context.t() | nil
  def first_extended_cousin(ctx, predicate \\ &Util.always/1)

  def first_extended_cousin(%Context{path: []} = ctx, _predicate), do: nil

  def first_extended_cousin(%Context{} = ctx, predicate) when is_function(predicate) do
    target_depth = Context.depth_of_focus(ctx)

    # IO.inspect(target_depth, label: "Target Depth")

    {starting_point_on_path, path_details} =
      ctx
      |> parent()
      |> first_extended_cousin_starting_point()

    case starting_point_on_path do
      nil ->
        nil

      %Context{} ->
        starting_sibling = first_sibling(starting_point_on_path)

        current_details = %{
          # remove
          term: starting_sibling.focus.term,
          index: 0,
          depth: Context.depth_of_focus(starting_sibling)
        }

        starting_sibling
        |> do_first_extended_cousin(current_details, path_details, target_depth, predicate)
    end
  end

  @spec first_extended_cousin_starting_point(Context.t()) :: {Context.t(), non_neg_integer()}
  def first_extended_cousin_starting_point(%Context{} = ctx) do
    {_root, {candidate_depth, candidate_ctx, path_details}} =
      accumulate_to_root(ctx, {0, nil, []}, fn
        %Context{prev: []} = next_ctx, {candidate_depth, candidate_ctx, details} ->
          new_details = %{
            # remove
            term: next_ctx.focus.term,
            index: Context.index_of_focus(next_ctx),
            depth: Context.depth_of_focus(next_ctx)
          }

          {candidate_depth, candidate_ctx, [new_details | details]}

        %Context{} = next_ctx, {_, _, details} ->
          new_depth = Context.depth_of_focus(next_ctx)

          new_details = %{
            # remove
            term: next_ctx.focus.term,
            index: Context.index_of_focus(next_ctx),
            depth: new_depth
          }

          {new_depth, next_ctx, [new_details | details]}
      end)

    # drop any erroneous accumulated path details, i.e. -
    # we don't care about the details that were gathered
    # about path locations that preceed our final candidate
    pruned_path_details = Enum.drop(path_details, candidate_depth)

    # IO.inspect(candidate_ctx.focus.term, label: "Starting Term")
    # IO.inspect(pruned_path_details, label: "Starting Path Details")

    {candidate_ctx, pruned_path_details}
  end

  @spec first_extended_cousin_descend_path(Context.t(), [map()]) :: {Context.t(), [map()]}
  defp first_extended_cousin_descend_path(%Context{} = ctx, []), do: {ctx, []}

  defp first_extended_cousin_descend_path(%Context{} = ctx, [
         %{index: 0} = loc_details | path_details
       ]) do
    ctx
    |> first_child()
    |> do_first_extended_cousin_descend_path(loc_details, path_details)
  end

  defp first_extended_cousin_descend_path(%Context{} = ctx, [%{index: index} | _] = path_details) do
    {child_at(ctx, index), path_details}
  end

  @spec do_first_extended_cousin_descend_path(Context.t(), map(), [map()]) ::
          {Context.t(), [map()]}
  defp do_first_extended_cousin_descend_path(%Context{} = ctx, %{index: 0}, [
         %{index: 0} = loc_details | path_details
       ]) do
    ctx
    |> first_child()
    |> do_first_extended_cousin_descend_path(loc_details, path_details)
  end

  defp do_first_extended_cousin_descend_path(
         %Context{} = ctx,
         %{index: 0},
         [%{index: index} | _] = path_details
       ) do
    {child_at(ctx, index), path_details}
  end

  defp do_first_extended_cousin_descend_path(%Context{} = ctx, _, path_details) do
    {ctx, path_details}
  end

  @spec do_first_extended_cousin(Context.t(), map(), [map()], non_neg_integer(), predicate()) ::
          Context.t() | nil
  # Path Details have been exhausted, thus no match
  defp do_first_extended_cousin(
         %Context{} = ctx,
         current_details,
         [] = _path_details,
         _target_depth,
         _predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Path Fully Explored - No Match")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(nil, label: "\tLoc Details")
    nil
  end

  # Subtrees for all previous siblings have been explored, thus descend path to next location
  defp do_first_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | path_details],
         target_depth,
         predicate
       )
       when current_details.index == loc_details.index and
              current_details.depth == loc_details.depth do
    # IO.inspect(ctx.focus.term, label: "Subtrees Fully Explored for Location, Descend Path")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case first_extended_cousin_descend_path(ctx, path_details) do
      {_, []} ->
        nil

      {new_path_ctx, new_path_details} ->
        new_ctx = first_sibling(new_path_ctx)

        new_details = %{
          index: 0,
          depth: Context.depth_of_focus(new_ctx)
        }

        do_first_extended_cousin(new_ctx, new_details, new_path_details, target_depth, predicate)
    end
  end

  # We've reached the Target Depth and there's no more next siblings. If predicate is true, we've found
  # our match, otherwise, we need to look for the next ancestral pibling. If there is no next ancestral
  # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search.
  defp do_first_extended_cousin(
         %Context{next: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(ctx.focus.term, label: "Target Depth Reached - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(ctx) do
      # IO.puts("\tTarget Found")
      ctx
    else
      # IO.puts("\tTarget Not Found")
      case next_ancestral_pibling(ctx) do
        nil ->
          # IO.puts("\tNo Next Ancestral Pibling Found")
          nil

        %Context{} = next_ancestral_pibling ->
          new_depth = Context.depth_of_focus(next_ancestral_pibling)

          if new_depth < loc_details.depth do
            # IO.puts("\tNext Ancestral Pibling Found Exceeds Boundary")
            nil
          else
            new_details = %{
              depth: new_depth,
              index: Context.index_of_focus(next_ancestral_pibling)
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
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(ctx.focus.term, label: "Target Depth Reached - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(ctx) do
      # IO.puts("\tTarget Found")
      ctx
    else
      # IO.puts("\tTarget Not Found")
      new_details = %{current_details | index: current_details.index + 1}

      ctx
      |> next_sibling()
      |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # We're in the middle of a sub tree search and are focused on a node without children, nor next siblings, thus
  # we need to look for the next ancestral pibling. If there is no next ancestral
  # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search.
  defp do_first_extended_cousin(
         %Context{next: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not TreeNode.parent?(ctx.focus) do
    # IO.inspect(ctx.focus.term, label: "No Children to Explore - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case next_ancestral_pibling(ctx) do
      nil ->
        # IO.puts("\tNo Next Ancestral Pibling Found")
        nil

      %Context{} = next_ancestral_pibling ->
        new_depth = Context.depth_of_focus(next_ancestral_pibling)

        if new_depth < loc_details.depth do
          # IO.inspect({new_depth, loc_details.depth}, label: "\tNext Ancestral Pibling Found Exceeds Boundary")
          nil
        else
          new_details = %{
            depth: new_depth,
            index: Context.index_of_focus(next_ancestral_pibling)
          }

          next_ancestral_pibling
          |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
        end
    end
  end

  # We're in the middle of a sub tree search and are focused on a node without children but that does have next siblings.
  # If predicate is true we've found our match. Otherwise, search next sibling.
  defp do_first_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not TreeNode.parent?(ctx.focus) do
    # IO.inspect(ctx.focus.term, label: "No Children to Explore - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    new_details = %{current_details | index: current_details.index + 1}

    ctx
    |> next_sibling()
    |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
  end

  # We're in the middle of a sub tree search  and are focused on a node with children but without next siblings.
  # Find it's leftmost descendant next. If none exists, we need to look for the next ancestral pibling. If there
  # is no next ancestral pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # we also have no match. Otherwise, continue the search. If there is a leftmost descendant, continue the search from
  # that node.
  defp do_first_extended_cousin(
         %Context{next: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Exploring Subtree Of - Next Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case leftmost_descendant(ctx, &(Context.depth_of_focus(&1) == target_depth)) do
      nil ->
        case next_ancestral_pibling(ctx) do
          nil ->
            # IO.puts("\tNo Next Ancestral Pibling Found")
            nil

          %Context{} = next_ancestral_pibling ->
            new_depth = Context.depth_of_focus(next_ancestral_pibling)

            if new_depth < loc_details.depth do
              # IO.puts("\tNext Ancestral Pibling Found Exceeds Boundary")
              nil
            else
              new_details = %{
                depth: new_depth,
                index: Context.index_of_focus(next_ancestral_pibling)
              }

              next_ancestral_pibling
              |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
            end
        end

      %Context{} = descendant ->
        new_details = %{
          depth: Context.depth_of_focus(descendant),
          index: Context.index_of_focus(descendant)
        }

        descendant
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # We're in the middle of a sub tree search  and are focused on a node with children and next siblings.
  # Find it's leftmost descendant next. If none exists, we need to look for the contineu search from next sibling.
  # If there is a leftmost descendant, continue the search from that node.
  defp do_first_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Exploring Subtree Of - Next Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case leftmost_descendant(ctx, &(Context.depth_of_focus(&1) == target_depth)) do
      nil ->
        new_details = %{current_details | index: current_details.index + 1}

        ctx
        |> next_sibling()
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)

      %Context{} = descendant ->
        new_details = %{
          depth: Context.depth_of_focus(descendant),
          index: Context.index_of_focus(descendant)
        }

        descendant
        |> do_first_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  @doc """
  Searches for the last extended cousin or the last first-cousin of the focused node.
  """
  @spec last_extended_cousin(Context.t(), keyword()) :: Context.t() | nil
  def last_extended_cousin(ctx, predicate \\ &Util.always/1)

  def last_extended_cousin(%Context{path: []} = ctx, _predicate), do: nil

  def last_extended_cousin(%Context{} = ctx, predicate)
      when is_function(predicate) do
    target_depth = Context.depth_of_focus(ctx)

    # IO.inspect(target_depth, label: "Target Depth")

    {starting_point_on_path, path_details} =
      ctx
      |> parent()
      |> last_extended_cousin_starting_point()

    case starting_point_on_path do
      nil ->
        nil

      %Context{} ->
        starting_sibling = last_sibling(starting_point_on_path)

        current_details = %{
          # remove
          term: starting_sibling.focus.term,
          index: Context.index_of_focus(starting_sibling),
          num_next: Enum.count(starting_sibling.next),
          depth: Context.depth_of_focus(starting_sibling)
        }

        starting_sibling
        |> do_last_extended_cousin(current_details, path_details, target_depth, predicate)
    end
  end

  @spec last_extended_cousin_starting_point(Context.t()) :: {Context.t(), non_neg_integer()}
  def last_extended_cousin_starting_point(%Context{} = ctx) do
    {_root, {candidate_depth, candidate_ctx, path_details}} =
      accumulate_to_root(ctx, {0, nil, []}, fn
        %Context{next: []} = next_ctx, {candidate_depth, candidate_ctx, details} ->
          new_details = %{
            # remove
            term: next_ctx.focus.term,
            index: Context.index_of_focus(next_ctx),
            num_next: Enum.count(next_ctx.next),
            depth: Context.depth_of_focus(next_ctx)
          }

          {candidate_depth, candidate_ctx, [new_details | details]}

        %Context{} = next_ctx, {_, _, details} ->
          new_depth = Context.depth_of_focus(next_ctx)

          new_details = %{
            # remove
            term: next_ctx.focus.term,
            index: Context.index_of_focus(next_ctx),
            num_next: Enum.count(next_ctx.next),
            depth: new_depth
          }

          {new_depth, next_ctx, [new_details | details]}
      end)

    # drop any erroneous accumulated path details, i.e. -
    # we don't care about the details that were gathered
    # about path locations that preceed our final candidate
    pruned_path_details = Enum.drop(path_details, candidate_depth)

    # IO.inspect(candidate_ctx.focus.term, label: "Starting Term")
    # IO.inspect(pruned_path_details, label: "Starting Path Details")

    {candidate_ctx, pruned_path_details}
  end

  @spec last_extended_cousin_descend_path(Context.t(), [map()]) :: {Context.t(), [map()]}
  defp last_extended_cousin_descend_path(%Context{} = ctx, []), do: {ctx, []}

  defp last_extended_cousin_descend_path(%Context{} = ctx, [
         %{num_next: 0} = loc_details | path_details
       ]) do
    ctx
    |> first_child()
    |> do_last_extended_cousin_descend_path(loc_details, path_details)
  end

  defp last_extended_cousin_descend_path(%Context{} = ctx, [%{index: index} | _] = path_details) do
    {child_at(ctx, index), path_details}
  end

  @spec do_last_extended_cousin_descend_path(Context.t(), map(), [map()]) ::
          {Context.t(), [map()]}
  defp do_last_extended_cousin_descend_path(%Context{} = ctx, %{num_next: 0}, [
         %{num_next: 0} = loc_details | path_details
       ]) do
    ctx
    |> first_child()
    |> do_last_extended_cousin_descend_path(loc_details, path_details)
  end

  defp do_last_extended_cousin_descend_path(
         %Context{} = ctx,
         %{num_next: 0},
         [%{index: index} | _] = path_details
       ) do
    {child_at(ctx, index), path_details}
  end

  defp do_last_extended_cousin_descend_path(%Context{} = ctx, _, path_details) do
    {ctx, path_details}
  end

  @spec do_last_extended_cousin(Context.t(), map(), [map()], non_neg_integer(), predicate()) ::
          Context.t() | nil
  # Path Details have been exhausted, thus no match
  defp do_last_extended_cousin(
         %Context{} = ctx,
         current_details,
         [] = _path_details,
         _target_depth,
         _predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Path Fully Explored - No Match")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(nil, label: "\tLoc Details")
    nil
  end

  # # Subtrees for all previous siblings have been explored, thus descend path to next location
  defp do_last_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | path_details],
         target_depth,
         predicate
       )
       when current_details.index == loc_details.index and
              current_details.depth == loc_details.depth do
    # IO.inspect(ctx.focus.term, label: "Subtrees Fully Explored for Location, Descend Path")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case last_extended_cousin_descend_path(ctx, path_details) do
      {_, []} ->
        nil

      {new_path_ctx, new_path_details} ->
        new_ctx = last_sibling(new_path_ctx)

        new_details = %{
          index: Context.index_of_focus(new_ctx),
          depth: Context.depth_of_focus(new_ctx)
        }

        do_last_extended_cousin(new_ctx, new_details, new_path_details, target_depth, predicate)
    end
  end

  # # We've reached the Target Depth and there's no more previous siblings. If predicate is true, we've found
  # # our match, otherwise, we need to look for the previous ancestral pibling. If there is no previous ancestral
  # # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search.
  defp do_last_extended_cousin(
         %Context{prev: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(ctx.focus.term, label: "Target Depth Reached - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(ctx) do
      # IO.puts("\tTarget Found")
      ctx
    else
      # IO.puts("\tTarget Not Found")
      case previous_ancestral_pibling(ctx) do
        nil ->
          # IO.puts("\tNo Previous Ancestral Pibling Found")
          nil

        %Context{} = previous_ancestral_pibling ->
          new_depth = Context.depth_of_focus(previous_ancestral_pibling)

          if new_depth < loc_details.depth do
            # IO.puts("\tPrevious Ancestral Pibling Found Exceeds Boundary")
            nil
          else
            new_details = %{
              index: Context.index_of_focus(previous_ancestral_pibling),
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
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when current_details.depth == target_depth do
    # IO.inspect(ctx.focus.term, label: "Target Depth Reached - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    if predicate.(ctx) do
      # IO.puts("\tTarget Found")
      ctx
    else
      # IO.puts("\tTarget Not Found")
      new_details = %{current_details | index: current_details.index - 1}

      ctx
      |> previous_sibling()
      |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # # We're in the middle of a sub tree search and are focused on a node without children, nor previous siblings, thus
  # # we need to look for the previous ancestral pibling. If there is no previous ancestral
  # # pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search.
  defp do_last_extended_cousin(
         %Context{prev: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not TreeNode.parent?(ctx.focus) do
    # IO.inspect(ctx.focus.term, label: "No Children to Explore - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case previous_ancestral_pibling(ctx) do
      nil ->
        # IO.puts("\tNo Previous Ancestral Pibling Found")
        nil

      %Context{} = previous_ancestral_pibling ->
        new_depth = Context.depth_of_focus(previous_ancestral_pibling)

        if new_depth < loc_details.depth do
          # IO.inspect({new_depth, loc_details.depth}, label: "\tPrevious Ancestral Pibling Found Exceeds Boundary")
          nil
        else
          new_details = %{
            depth: new_depth,
            index: Context.index_of_focus(previous_ancestral_pibling)
          }

          previous_ancestral_pibling
          |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
        end
    end
  end

  # # We're in the middle of a sub tree search and are focused on a node without children but that does have previous siblings.
  # # If predicate is true we've found our match. Otherwise, search previous sibling.
  defp do_last_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       )
       when not TreeNode.parent?(ctx.focus) do
    # IO.inspect(ctx.focus.term, label: "No Children to Explore - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    new_details = %{current_details | index: current_details.index - 1}

    ctx
    |> previous_sibling()
    |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
  end

  # # We're in the middle of a sub tree search  and are focused on a node with children but without previous siblings.
  # # Find it's rightmost descendant next. If none exists, we need to look for the previous ancestral pibling. If there
  # # is no previous ancestral pibling, we have no match. If there is one, but it is shallower that our current loc_details depth,
  # # we also have no match. Otherwise, continue the search. If there is a rightmost descendant, continue the search from
  # # that node.
  defp do_last_extended_cousin(
         %Context{prev: []} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Exploring Subtree Of - Previous Empty")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case rightmost_descendant(ctx, &(Context.depth_of_focus(&1) == target_depth)) do
      nil ->
        case previous_ancestral_pibling(ctx) do
          nil ->
            # IO.puts("\tNo Previous Ancestral Pibling Found")
            nil

          %Context{} = previous_ancestral_pibling ->
            new_depth = Context.depth_of_focus(previous_ancestral_pibling)

            if new_depth < loc_details.depth do
              # IO.puts("\tPrevious Ancestral Pibling Found Exceeds Boundary")
              nil
            else
              new_details = %{
                depth: new_depth,
                index: Context.index_of_focus(previous_ancestral_pibling)
              }

              previous_ancestral_pibling
              |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
            end
        end

      %Context{} = descendant ->
        new_details = %{
          depth: Context.depth_of_focus(descendant),
          index: Context.index_of_focus(descendant)
        }

        descendant
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  # # We're in the middle of a sub tree search  and are focused on a node with children and previous siblings.
  # # Find it's rightmost descendant next. If none exists, we need to look for the continue search from previous sibling.
  # # If there is a rightmost descendant, continue the search from that node.
  defp do_last_extended_cousin(
         %Context{} = ctx,
         current_details,
         [loc_details | _] = path_details,
         target_depth,
         predicate
       ) do
    # IO.inspect(ctx.focus.term, label: "Exploring Subtree Of - Previous Remaining")
    # IO.inspect(current_details, label: "\tCurrent Details")
    # IO.inspect(loc_details, label: "\tLoc Details")
    case rightmost_descendant(ctx, &(Context.depth_of_focus(&1) == target_depth)) do
      nil ->
        new_details = %{current_details | index: current_details.index - 1}

        ctx
        |> previous_sibling()
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)

      %Context{} = descendant ->
        new_details = %{
          depth: Context.depth_of_focus(descendant),
          index: Context.index_of_focus(descendant)
        }

        descendant
        |> do_last_extended_cousin(new_details, path_details, target_depth, predicate)
    end
  end

  @doc """
  Searches for the previous extended cousin or the previous first-cousin of the focused node.
  """
  @spec previous_extended_cousin(Context.t(), keyword()) :: Context.t() | nil
  def previous_extended_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    target_depth = Context.depth_of_focus(ctx)

    ctx
    |> find_previous_extended_cousin(target_depth, predicate)
  end

  @spec find_previous_extended_cousin(Context.t(), non_neg_integer(), predicate()) ::
          Context.t() | nil
  defp find_previous_extended_cousin(%Context{} = ctx, target_depth, predicate) do
    case previous_ancestral_pibling(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = ancestral_pibling ->
        new_depth = Context.depth_of_focus(ancestral_pibling)

        ancestral_pibling
        |> find_previous_extended_cousin_at_depth(new_depth, target_depth, predicate)
    end
  end

  @spec find_previous_extended_cousin_at_depth(
          Context.t(),
          non_neg_integer(),
          non_neg_integer(),
          predicate()
        ) ::
          Context.t() | nil
  defp find_previous_extended_cousin_at_depth(
         %Context{path: [], prev: []} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      nil
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %Context{prev: []} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      find_previous_extended_cousin(ctx, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %Context{} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      ctx
      |> previous_sibling()
      |> find_previous_extended_cousin_at_depth(current_depth, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %Context{path: [], prev: []} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(ctx) do
      nil ->
        nil

      %Context{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %Context{prev: []} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(ctx) do
      nil ->
        find_previous_extended_cousin(ctx, target_depth, predicate)

      %Context{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_previous_extended_cousin_at_depth(
         %Context{} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case last_child(ctx) do
      nil ->
        ctx
        |> previous_sibling()
        |> find_previous_extended_cousin_at_depth(current_depth, target_depth, predicate)

      %Context{} = child ->
        find_previous_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  @doc """
  Searches for the next extended cousin or the next first-cousin of the focused node.
  """
  @spec next_extended_cousin(Context.t(), keyword()) :: Context.t() | nil
  def next_extended_cousin(%Context{} = ctx, predicate \\ &Util.always/1)
      when is_function(predicate) do
    target_depth = Context.depth_of_focus(ctx)

    ctx
    |> find_next_extended_cousin(target_depth, predicate)
  end

  @spec find_next_extended_cousin(Context.t(), non_neg_integer(), predicate()) ::
          Context.t() | nil
  def find_next_extended_cousin(%Context{} = ctx, target_depth, predicate) do
    case next_ancestral_pibling(ctx, &TreeNode.parent?/1) do
      nil ->
        nil

      %Context{} = ancestral_pibling ->
        new_depth = Context.depth_of_focus(ancestral_pibling)

        ancestral_pibling
        |> find_next_extended_cousin_at_depth(new_depth, target_depth, predicate)
    end
  end

  @spec find_next_extended_cousin_at_depth(
          Context.t(),
          non_neg_integer(),
          non_neg_integer(),
          predicate()
        ) ::
          Context.t() | nil
  defp find_next_extended_cousin_at_depth(
         %Context{path: [], next: []} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      nil
    end
  end

  defp find_next_extended_cousin_at_depth(
         %Context{next: []} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      find_next_extended_cousin(ctx, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %Context{} = ctx,
         current_depth,
         target_depth,
         predicate
       )
       when current_depth == target_depth do
    if predicate.(ctx.focus) do
      ctx
    else
      ctx
      |> next_sibling()
      |> find_next_extended_cousin_at_depth(current_depth, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %Context{path: [], next: []} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(ctx) do
      nil ->
        nil

      %Context{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %Context{next: []} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(ctx) do
      nil ->
        find_next_extended_cousin(ctx, target_depth, predicate)

      %Context{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end

  defp find_next_extended_cousin_at_depth(
         %Context{} = ctx,
         current_depth,
         target_depth,
         predicate
       ) do
    case first_child(ctx) do
      nil ->
        ctx
        |> next_sibling()
        |> find_next_extended_cousin_at_depth(current_depth, target_depth, predicate)

      %Context{} = child ->
        find_next_extended_cousin_at_depth(child, current_depth + 1, target_depth, predicate)
    end
  end
end
