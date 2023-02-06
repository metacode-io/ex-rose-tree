defmodule RoseTree.Zipper.Traversal do
  @moduledoc """
  High-level traversal functions for the zipper context. Builds off
  of semantic "kinship" functions in `RoseTree.Zipper.Kin`.
  """

  require RoseTree.TreeNode
  require RoseTree.Zipper.Context
  import RoseTree.Zipper.Kin
  import RoseTree.Util
  alias URI.Error
  alias RoseTree.TreeNode
  alias RoseTree.Zipper.Context

  @typep predicate() :: (term() -> boolean())

  ###
  ### BASIC TRAVERSAL
  ###

  @doc """
  Rewinds a zipper back to the root.

  ## Examples

      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> ctx = RoseTree.Zipper.Traversal.to_root(ctx)
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
  Repeats a call to the given move function, `move_fn`, by the
  given number of `reps`.

  ## Examples

      iex> loc_nodes = for n <- [4,3,2,1], do: RoseTree.TreeNode.new(n)
      ...> locs = for n <- loc_nodes, do: RoseTree.Zipper.Location.new(n)
      ...> node = RoseTree.TreeNode.new(5)
      ...> ctx = RoseTree.Zipper.Context.new(node, path: locs)
      ...> move_fn = &RoseTree.Zipper.Kin.parent/1
      ...> ctx = RoseTree.Zipper.Traversal.move_for(ctx, 2, move_fn)
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
  ### FORWARD, BREADTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses forward through the zipper in a breadth-first manner.
  """
  @spec forward(Context.t()) :: Context.t() | nil
  def forward(%Context{} = ctx) when Context.empty?(ctx), do: nil

  def forward(%Context{path: []} = ctx), do: first_child(ctx)

  def forward(%Context{} = ctx) do
    raise Error, "not yet implemented"
  end

  @doc """
  Repeats a call to `forward/1` by the given number of `reps`.
  """
  @spec forward_for(Context.t(), pos_integer()) :: Context.t() | nil
  def forward_for(%Context{} = ctx, reps) when reps > 0,
    do: move_for(ctx, reps, &forward/1)

  def forward_for(%Context{}, _reps), do: nil

  ###
  ### BACKWARD, BREADTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses backward through the zipper in a breadth-first manner.
  """
  @spec backward(Context.t()) :: Context.t()
  def backward(%Context{path: []}), do: nil

  def backward(%Context{} = ctx) do
    raise Error, "not yet implemented"
  end

  @doc """
  Repeats a call to `backward/1` by the given number of `reps`.
  """
  @spec backward_for(Context.t(), pos_integer()) :: Context.t() | nil
  def backward_for(%Context{} = ctx, reps) when reps > 0,
    do: move_for(ctx, reps, &backward/1)

  def backward_for(%Context{}, _reps), do: nil

  ###
  ### DESCEND, DEPTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses forward through the zipper in a depth-first manner.
  """
  @spec descend(Context.t()) :: Context.t() | nil
  def descend(%Context{} = ctx) do
    funs = [
      &first_child/2,
      &next_sibling/2,
      &next_ancestral_pibling/2
    ]

    ctx
    |> first_of_with_args(funs, [&always/1])
  end

  @doc """
  Repeats a call to `descend/1` by the given number of `reps`.
  """
  @spec descend_for(Context.t(), pos_integer()) :: Context.t() | nil
  def descend_for(%Context{} = ctx, reps)
      when reps > 0,
      do: move_for(ctx, reps, &descend/1)

  def descend_for(%Context{}, _reps), do: nil

  @doc """
  Descends into the Zipper if the provided predicate function
  returns true when applied to the next Context. Otherwise,
  returns nil.
  """
  @spec descend_if(Context.t(), predicate()) :: Context.t() | nil
  def descend_if(%Context{} = ctx, predicate) when is_function(predicate) do
    case descend(ctx) do
      nil ->
        nil

      %Context{} = next_ctx ->
        if predicate.(next_ctx) do
          next_ctx
        else
          nil
        end
    end
  end

  @doc """
  Descends into the Zipper continuously until the provided predicate
  function returns true when applied to the Context. Otherwise,
  returns nil.
  """
  @spec descend_until(Context.t(), predicate()) :: Context.t() | nil
  def descend_until(%Context{} = ctx, predicate) when is_function(predicate) do
    case descend(ctx) do
      nil ->
        nil

      %Context{} = next_ctx ->
        if predicate.(next_ctx) do
          next_ctx
        else
          descend_until(next_ctx, predicate)
        end
    end
  end

  ###
  ### ASCEND, DEPTH-FIRST TRAVERSAL
  ###

  @doc """
  Traverses back through the zipper in a depth-first manner.
  """
  @spec ascend(Context.t()) :: Context.t()
  def ascend(%Context{} = ctx) do
    funs = [
      fn x -> previous_descendant_nibling(x) end,
      fn x -> previous_sibling(x) end,
      &parent/1
    ]

    ctx
    |> first_of(funs)
  end

  @doc """
  Repeats a call to `ascend/1` by the given number of `reps`.
  """
  @spec ascend_for(Context.t(), pos_integer()) :: Context.t() | nil
  def ascend_for(%Context{} = ctx, reps) when reps > 0,
    do: move_for(ctx, reps, &ascend/1)

  def ascend_for(%Context{}, _reps), do: nil

  ###
  ### SEARCHING
  ###

  @doc """
  Using the designated move function, `move_fn`, searches for the first
  node that satisfies the given `predicate` function.
  """
  @spec find(
          Context.t(),
          (Context.t() -> boolean()),
          (Context.t(), keyword() -> Context.t() | nil)
        ) :: Context.t() | nil
  def find(%Context{} = ctx, predicate, move_fn)
      when is_function(predicate) and is_function(move_fn) do
    if predicate.(ctx) do
      ctx
    else
      case move_fn.(ctx) do
        nil ->
          nil

        %Context{} = new_focus ->
          find(new_focus, predicate, move_fn)
      end
    end
  end

  def find(%Context{}, _predicate, _move_fn), do: nil
end
