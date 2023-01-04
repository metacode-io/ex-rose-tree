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

  @doc """
  Moves the Context to the parent Location. If at the root, thus no
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
  @spec child_at(Context.t(), integer()) :: Context.t() | nil
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
  def first_sibling(%Context{prev: [], next: []}), do: nil

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
  def next_sibling(%Context{prev: [], next: []}), do: nil

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
  @spec sibling_at(Context.t(), integer()) :: Context.t() | nil
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
end
