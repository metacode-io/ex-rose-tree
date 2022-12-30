defmodule RoseTree.Zipper.Location do
  @moduledoc """
  A Location in the Rose Tree Zipper.
  """

  require RoseTree.TreeNode

  alias RoseTree.TreeNode

  defstruct ~w(prev term next)a

  @typedoc """
  A `Location` is made up of three fields:
  * `term` is a `TreeNode.term`.
  * `prev` is a list of `TreeNode`s. They are the siblings that
      occur prior the `term`. It is reversed such that the
      head of the list is the nearest previous sibling.
  * `next` is a list of `TreeNode`s. They are the siblings that
      occur after the `term.
  """
  @type t :: %__MODULE__{
    prev: [TreeNode.t()],
    term: term(),
    next: [TreeNode.t()]
  }

  @doc """
  Builds a new `Location` given a `term()` or a `TreeNode` as the first
  argument, and a `prev` and `next` list of `TreeNode`s as the second and
  third argument.

  If the first argument is a `TreeNode`, it will unwrap its `term` element.
  """
  @spec new(TreeNode.t() | term(), [TreeNode.t()], [TreeNode.t()]) :: t() | nil
  def new(item, prev, next) when TreeNode.tree_node?(item) and is_list(prev) and is_list(next) do
    new(item.term, prev, next)
  end

  def new(item, prev, next) when is_list(prev) and is_list(next) do
    if Enum.all?(prev ++ next, &TreeNode.tree_node?(&1)) do
      %__MODULE__{
        prev: prev,
        term: item,
        next: next
      }
    else
      nil
    end
  end

  @doc """
  Applies the given function to the Location's `term` field.
  """
  @spec map_term(t(), (term() -> term())) :: t() | nil
  def map_term(%__MODULE__{term: term} = loc, map_fn) when is_function(map_fn) do
    %{loc | term: map_fn.(term)}
  end

  def map_data(%__MODULE__{}, _map_fn, _opts), do: nil

  @doc """
  Returns the index of the Location's `term`
  """
  @spec index_of_term(t()) :: non_neg_integer()
  def index_of_term(%__MODULE__{prev: prev}),
    do: Enum.count(prev)

end
