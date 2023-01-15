defmodule RoseTree.Zipper.Kin do
  @moduledoc """
  This module serves as a home for many common traversal functions based
  on the idea of kinship: parent, child, grandchild, sibling, cousin, etc.

  More high-level traversal functions are located in `RoseTree.Zipper.Traversal`.
  """

  require RoseTree.TreeNode
  require RoseTree.Zipper.Context
  alias RoseTree.{TreeNode, Util}
  alias RoseTree.Zipper.Context

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
    consolidated_ctx = Enum.reverse(ctx.prev) ++ [ctx.focus | ctx.next]

    focused_parent =
      parent.term
      |> TreeNode.new(consolidated_ctx)

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

  """
  @spec first_child(Context.t()) :: Context.t() | nil
  def first_child(%Context{focus: focus})
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def first_child(%Context{} = ctx) do
    [child | children] = Context.focused_children(ctx)

    %{
      ctx
      | focus: child,
        prev: [],
        next: children,
        path: [Context.new_location(ctx) | ctx.path]
    }
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
  @spec last_child(Context.t()) :: Context.t() | nil
  def last_child(%Context{focus: focus})
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def last_child(%Context{} = ctx) do
    [child | children] =
      ctx
      |> Context.focused_children()
      |> Enum.reverse()

    %{
      ctx
      | focus: child,
        prev: children,
        next: [],
        path: [Context.new_location(ctx) | ctx.path]
    }
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
  def child_at(%Context{focus: focus})
      when TreeNode.empty?(focus) or TreeNode.leaf?(focus),
      do: nil

  def child_at(%Context{} = ctx, index) when is_integer(index) do
    children = Context.focused_children(ctx)

    case Util.split_at(children, index) do
      {[], []} ->
        nil

      {[focus | prev], []} ->
        %Context{
          focus: focus,
          prev: prev,
          next: [],
          path: [Context.new_location(ctx) | ctx.path]
        }

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
  first child -- of the focus. If there are no grandchildren, returns nil.
  """
  @spec first_grandchild(Context.t()) :: Context.t() | nil
  def first_grandchild(%Context{} = ctx) do
    with %Context{} = first_child <- first_child(ctx),
         %Context{} = next_first_child <- first_child(first_child) do
      next_first_child
    else
      nil -> nil
    end
  end

  @doc """
  Moves the focus to the last grandchild -- the last child of the
  last child -- of the focus. If there are no grandchildren, returns nil.
  """
  @spec last_grandchild(Context.t()) :: Context.t() | nil
  def last_grandchild(%Context{} = ctx) do
    with %Context{} = first_child <- first_child(ctx),
         %Context{} = next_first_child <- first_child(first_child) do
      next_first_child
    else
      nil -> nil
    end
  end

  @doc """
  Moves the focus to the first grandchild repeated `reps` number of times.
  If any rep fails, returns `nil`.
  """
  @spec first_grandchild_at_rep(Context.t(), pos_integer()) :: Context.t() | nil
  def first_grandchild_at_rep(_ctx, reps)
      when is_integer(reps) and reps <= 0, do: nil

  def first_grandchild_at_rep(%Context{} = ctx, 1),
    do: first_grandchild(ctx)

  def first_grandchild_at_rep(%Context{} = ctx, reps)
      when is_integer(reps) do
    1..reps
    |> Enum.reduce_while(ctx, fn _i, context ->
      case first_grandchild(context) do
        nil ->
          {:halt, nil}

        %Context{} = grandchild ->
          {:cont, grandchild}
      end
    end)
  end

  @doc """
  Moves the focus to the last grandchild repeated `reps` number of times.
  If any rep fails, returns `nil`.
  """
  @spec last_grandchild_at_rep(Context.t(), pos_integer()) :: Context.t() | nil
  def last_grandchild_at_rep(_ctx, reps)
      when is_integer(reps) and reps <= 0, do: nil

  def last_grandchild_at_rep(%Context{} = ctx, 1),
    do: last_grandchild(ctx)

  def last_grandchild_at_rep(%Context{} = ctx, reps)
      when is_integer(reps) do
    1..reps
    |> Enum.reduce_while(ctx, fn _i, context ->
      case last_grandchild(context) do
        nil ->
          {:halt, nil}

        %Context{} = grandchild ->
          {:cont, grandchild}
      end
    end)
  end

  @doc """
  Moves the focus to the first great-grandchild -- the first child of the
  first grandchild -- of the focus. If there are no great-grandchildren,
  returns nil.
  """
  @spec first_great_grandchild(Context.t()) :: Context.t() | nil
  def first_great_grandchild(%Context{} = ctx) do
    with %Context{} = first_grandchild <- first_grandchild(ctx),
         %Context{} = first_child <- first_child(first_grandchild) do
      first_child
    else
      nil -> nil
    end
  end

  @doc """
  Moves the focus to the last great-grandchild -- the last child of the
  last grandchild -- of the focus. If there are no great-grandchildren,
  returns nil.
  """
  @spec last_great_grandchild(Context.t()) :: Context.t() | nil
  def last_great_grandchild(%Context{} = ctx) do
    with %Context{} = last_grandchild <- last_grandchild(ctx),
         %Context{} = last_child <- last_child(last_grandchild) do
      last_child
    else
      nil -> nil
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
  @spec first_sibling(Context.t()) :: Context.t() | nil
  def first_sibling(%Context{prev: []}), do: nil

  def first_sibling(%Context{} = ctx) do
    [first | rest] = ctx.prev |> Enum.reverse()

    %Context{
      focus: first,
      prev: [],
      next: rest ++ [ctx.focus | ctx.next],
      path: ctx.path
    }
  end

  @doc """
  Moves the focus to the first sibling with children from the current focus.
  If not found, returns nil.
  """
  @spec first_sibling_with_children(Context.t()) :: Context.t() | nil
  def first_sibling_with_children(%Context{prev: []}), do: nil

  def first_sibling_with_children(%Context{} = ctx) do
    prev_siblings = ctx.prev |> Enum.reverse()

    case do_first_sibling_with_children({[], prev_siblings}) do
      {new_prev, [new_focus | new_next]} ->
        %Context{
          focus: new_focus,
          prev: new_prev,
          next: new_next,
          path: ctx.path
        }

      _ -> nil
    end
  end

  defp do_first_sibling_with_children({_, []}), do: nil

  defp do_first_sibling_with_children({prev, [next | rest]})
      when not TreeNode.leaf?(next), do: {prev, [next | rest]}

  defp do_first_sibling_with_children({prev, [next | rest]}),
      do: do_first_sibling_with_children({[next | prev], rest})


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
  @spec previous_sibling(Context.t()) :: Context.t() | nil
  def previous_sibling(%Context{prev: [], next: []}), do: nil

  def previous_sibling(%Context{prev: []}), do: nil

  def previous_sibling(%Context{prev: [prev | rest]} = ctx) do
    %Context{
      focus: prev,
      prev: rest,
      next: [ctx.focus | ctx.next],
      path: ctx.path
    }
  end

  @doc """
  Moves the focus to the previous sibling with children of the current focus.
  If not found, returns nil.
  """
  @spec previous_sibling_with_children(Context.t()) :: Context.t() | nil
  def previous_sibling_with_children(%Context{prev: []}), do: nil

  def previous_sibling_with_children(%Context{prev: [prev | rest]} = ctx)
      when not TreeNode.leaf?(prev), do: previous_sibling(ctx)

  def previous_sibling_with_children(%Context{} = ctx),
      do: ctx |> previous_sibling() |> previous_sibling_with_children()

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
  @spec last_sibling(Context.t()) :: Context.t() | nil
  def last_sibling(%Context{prev: [], next: []}), do: nil

  def last_sibling(%Context{next: []}), do: nil

  def last_sibling(%Context{} = ctx) do
    [last | rest] = ctx.next |> Enum.reverse()

    %Context{
      focus: last,
      prev: rest ++ [ctx.focus | ctx.prev],
      next: [],
      path: ctx.path
    }
  end

  @doc """
  Moves the focus to the last sibling with children from the current focus.
  If not found, returns nil.
  """
  @spec last_sibling_with_children(Context.t()) :: Context.t() | nil
  def last_sibling_with_children(%Context{next: []}), do: nil

  def last_sibling_with_children(%Context{} = ctx) do
    case do_last_sibling_with_children({[ctx.focus | ctx.prev], ctx.next}) do
      {new_prev, [new_focus | new_next]} ->
        %Context{
          focus: new_focus,
          prev: new_prev,
          next: new_next,
          path: ctx.path
        }

      _ -> nil
    end
  end

  defp do_last_sibling_with_children({_, []}), do: nil

  defp do_last_sibling_with_children({prev, [next | rest]})
      when not TreeNode.leaf?(next), do: {prev, [next | rest]}

  defp do_last_sibling_with_children({prev, [next | rest]}),
      do: do_last_sibling_with_children({[next | prev], rest})

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
  @spec next_sibling(Context.t()) :: Context.t() | nil
  def next_sibling(%Context{next: []}), do: nil

  def next_sibling(%Context{next: [next | rest]} = ctx) do
    %Context{
      focus: next,
      prev: [ctx.focus | ctx.prev],
      next: rest,
      path: ctx.path
    }
  end

  @doc """
  Moves the focus to the next sibling with children of the current focus.
  If not found, returns nil.
  """
  @spec next_sibling_with_children(Context.t()) :: Context.t() | nil
  def next_sibling_with_children(%Context{next: []}), do: nil

  def next_sibling_with_children(%Context{next: [next | rest]} = ctx)
      when not TreeNode.leaf?(next), do: next_sibling(ctx)

  def next_sibling_with_children(%Context{} = ctx),
      do: ctx |> next_sibling() |> next_sibling_with_children()

  @doc """
  Moves focus to the sibling of the current focus at the given index.
  If no sibling is found at that index, returns nil.

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
    siblings = Enum.reverse(ctx.prev) ++ [ctx.focus | ctx.next]

    case Util.split_at(siblings, index) do
      {[], []} ->
        nil

      {[focus | prev], []} ->
        %Context{
          focus: focus,
          prev: prev,
          next: [],
          path: ctx.path
        }

      {prev, [focus | next]} ->
        %Context{
          focus: focus,
          prev: prev,
          next: next,
          path: ctx.path
        }
    end
  end

  ###
  ### NIBLINGS (NIECES + NEPHEWS)
  ###

  @doc """
  Moves the focus to the first nibling -- the first child of the
  first sibling -- before the current focus. If not found, returns
  nil.
  """
  @spec first_nibling(Context.t()) :: Context.t() | nil
  def first_nibling(%Context{} = ctx) do
    with %Context{} = first_sibling <- first_sibling(ctx),
         %Context{} = first_child <- first_child(first_sibling) do
      first_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last nibling -- the last child of the
  last sibling -- before the current focus. If not found, returns
  nil.
  """
  @spec last_nibling(Context.t()) :: Context.t() | nil
  def last_nibling(%Context{} = ctx) do
    with %Context{} = last_sibling <- last_sibling(ctx),
         %Context{} = last_child <- last_child(last_sibling) do
      last_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the previous nibling -- the last child of the
  previous sibling -- before the current focus. If not found, returns
  nil.
  """
  @spec previous_nibling(Context.t()) :: Context.t() | nil
  def previous_nibling(%Context{} = ctx) do
    with %Context{} = previous_sibling <- previous_sibling(ctx),
         %Context{} = last_child <- last_child(previous_sibling) do
      last_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the next nibling -- the first child of the
  next sibling -- before the current focus. If not found, returns
  nil.
  """
  @spec next_nibling(Context.t()) :: Context.t() | nil
  def next_nibling(%Context{} = ctx) do
    with %Context{} = next_sibling <- next_sibling(ctx),
         %Context{} = first_child <- first_child(next_sibling) do
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
  @spec first_nibling_at_sibling(Context.t(), non_neg_integer()) :: Context.t() | nil
  def first_nibling_at_sibling(%Context{} = ctx, index) when is_integer(index) do
    with %Context{} = sibling_at <- sibling_at(ctx, index),
         %Context{} = first_child <- first_child(sibling_at) do
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
  @spec last_nibling_at_sibling(Context.t(), non_neg_integer()) :: Context.t() | nil
  def last_nibling_at_sibling(%Context{} = ctx, index) when is_integer(index) do
    with %Context{} = sibling_at <- sibling_at(ctx, index),
         %Context{} = last_child <- last_child(sibling_at) do
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
  @spec previous_grandnibling(Context.t()) :: Context.t() | nil
  def previous_grandnibling(%Context{} = ctx) do
    with %Context{} = prev_sibling <- previous_sibling(ctx),
         %Context{} = last_gchild <- last_grandchild(prev_sibling) do
      last_gchild
    else
      nil -> nil
    end
  end

  @doc """
  Moves the focus to the next grand-nibling -- the first grandchild of
  the next sibling -- of the current focus. If not found, returns nil.
  """
  @spec next_grandnibling(Context.t()) :: Context.t() | nil
  def next_grandnibling(%Context{} = ctx) do
    with %Context{} = next_sibling <- next_sibling(ctx),
         %Context{} = first_grandchild <- first_grandchild(next_sibling) do
      first_grandchild
    else
      nil -> nil
    end
  end

  def first_extended_nibling(), do: raise Error, "not implemented"
  def last_extended_nibling(), do: raise Error, "not implemented"
  def previous_extended_nibling(), do: raise Error, "not implemented"
  def next_extended_nibling(), do: raise Error, "not implemented"


  ###
  ### PIBLINGS (UNCLES + AUNTS)
  ###

  @doc """
  Moves the focus to the first pibling -- the first sibling of the parent --
  of the current focus. If not found, returns nil.
  """
  @spec first_pibling(Context.t()) :: Context.t() | nil
  def first_pibling(%Context{} = ctx) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = first_sibling <- first_sibling(parent) do
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
  @spec last_pibling(Context.t()) :: Context.t() | nil
  def last_pibling(%Context{} = ctx) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = last_sibling <- last_sibling(parent) do
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
  @spec previous_pibling(Context.t()) :: Context.t() | nil
  def previous_pibling(%Context{} = ctx) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = previous_sibling <- previous_sibling(parent) do
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
  @spec next_pibling(Context.t()) :: Context.t() | nil
  def next_pibling(%Context{} = ctx) do
    with %Context{} = parent <- parent(ctx),
         %Context{} = next_sibling <- next_sibling(parent) do
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

  def first_extended_pibling(), do: raise Error, "not implemented"

  def last_extended_pibling(), do: raise Error, "not implemented"

  def previous_extended_pibling(), do: raise Error, "not implemented"

  def next_extended_pibling(), do: raise Error, "not implemented"

  def previous_ancestral_pibling(), do: raise Error, "not implemented"

  def next_ancestral_pibling(), do: raise Error, "not implemented"

  ###
  ### FIRST COUSINS
  ###

  @doc """
  Moves the focus to the first first-cousin -- the first child of the first
  pibling -- of the current focus. If not found, returns nil.
  """
  @spec first_first_cousin(Context.t()) :: Context.t() | nil
  def first_first_cousin(%Context{} = ctx) do
    with %Context{} = first_pibling <- first_pibling(ctx),
         %Context{} = first_child <- first_child(first_pibling) do
      first_child
    else
      nil ->
        nil
    end
  end

  @doc """
  Moves the focus to the last first-cousin -- the last child of the last
  pibling -- of the current focus. If not found, returns nil.
  """
  @spec last_first_cousin(Context.t()) :: Context.t() | nil
  def last_first_cousin(%Context{} = ctx) do
    with %Context{} = last_pibling <- last_pibling(ctx),
         %Context{} = last_child <- last_child(last_pibling) do
      last_child
    else
      nil ->
        nil
    end
  end

  # @doc """
  # Moves the focus to the previous first-cousin -- the last child of the previous
  # pibling -- of the current focus. If not found, returns nil.
  # """
  # @spec last_first_cousin(Context.t()) :: Context.t() | nil
  # def last_first_cousin(%Context{} = ctx) do
  #   with %Context{} = last_pibling <- last_pibling(ctx),
  #        %Context{} = last_child <- last_child(last_ext) do
  #     last_child
  #   else
  #     nil ->
  #       nil
  #   end
  # end

end
