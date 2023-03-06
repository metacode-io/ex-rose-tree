defmodule ExRoseTree.Zipper.Location do
  @moduledoc """
  A Location in the Path from the root of the ExRoseTree Zipper to its
  current context.
  """

  require ExRoseTree

  defstruct ~w(prev term next)a

  @typedoc """
  A `Location` is made up of three fields, the `term` of a `ExRoseTree`,
  and `prev` siblings and `next` siblings, both of which are lists of
  `ExRoseTree`.

  * `term` is a `ExRoseTree` `term`.
  * `prev` is a list of `ExRoseTree`s. They are the siblings that
      occur prior the `term`. It is reversed such that the
      head of the list is the nearest previous sibling.
  * `next` is a list of `ExRoseTree`s. They are the siblings that
      occur after the `term`.
  """
  @type t :: %__MODULE__{
          prev: [ExRoseTree.t()],
          term: term(),
          next: [ExRoseTree.t()]
        }

  @doc section: :guards
  defguard location?(value)
           when is_struct(value) and
                  value.__struct__ == __MODULE__ and
                  is_list(value.prev) and
                  is_list(value.next)

  @doc """
  Builds a new `Location` given a `term()` or a `ExRoseTree` as the first
  argument, and optional `:prev` and `:next` keywords of lists of `ExRoseTree`s.

  If the first argument is a `ExRoseTree`, it will unwrap its `term` element.

  ## Examples

      iex> ExRoseTree.Zipper.Location.new(5, prev: [], next: [])
      %ExRoseTree.Zipper.Location{prev: [], term: 5, next: []}

      iex> tree = ExRoseTree.new(4)
      ...> ExRoseTree.Zipper.Location.new(5, prev: [tree], next: [])
      %ExRoseTree.Zipper.Location{
        prev: [
          %ExRoseTree{term: 4, children: []}
        ],
        term: 5,
        next: []
      }

  """
  @spec new(ExRoseTree.t() | term(), keyword()) :: t() | nil
  def new(item, opts \\ [])

  def new(item, opts) when ExRoseTree.rose_tree?(item) do
    new(item.term, opts)
  end

  def new(item, opts) do
    prev = Keyword.get(opts, :prev, [])
    next = Keyword.get(opts, :next, [])

    do_new(item, prev, next)
  end

  @doc false
  @spec do_new(ExRoseTree.t() | term(), [ExRoseTree.t()], [ExRoseTree.t()]) :: t() | nil
  defp do_new(item, prev, next) when is_list(prev) and is_list(next) do
    case {ExRoseTree.all_rose_trees?(prev), ExRoseTree.all_rose_trees?(next)} do
      {true, true} ->
        %__MODULE__{
          prev: prev,
          term: item,
          next: next
        }

      {true, false} ->
        raise ArgumentError, "invalid element in prev"

      {false, true} ->
        raise ArgumentError, "invalid element in next"
    end
  end

  @doc """
  Returns whether a list of values are all Locations or not. Will return
  true if passed an empty list.

  ## Examples

      iex> locs = for loc <- [5,4,3,2,1], do: ExRoseTree.Zipper.Location.new(loc)
      ...> ExRoseTree.Zipper.Location.all_locations?(locs)
      true

  """
  @spec all_locations?([t()]) :: boolean()
  def all_locations?(values) when is_list(values) do
    Enum.all?(values, &location?(&1))
  end

  @doc """
  Applies the given function to the Location's `term` field.

  ## Examples

      iex> loc = ExRoseTree.Zipper.Location.new(5, prev: [], next: [])
      ...> ExRoseTree.Zipper.Location.map_term(loc, &(&1*2))
      %ExRoseTree.Zipper.Location{prev: [], term: 10, next: []}

  """
  @spec map_term(t(), (term() -> term())) :: t()
  def map_term(%__MODULE__{term: term} = loc, map_fn) when is_function(map_fn) do
    %{loc | term: map_fn.(term)}
  end

  @doc """
  Returns the index of the Location in relation to its siblings.

  ## Examples

      iex> trees = for t <- [5,4,3,2,1], do: ExRoseTree.new(t)
      ...> loc = ExRoseTree.Zipper.Location.new(6, prev: trees, next: [])
      ...> ExRoseTree.Zipper.Location.index_of_term(loc)
      5

  """
  @spec index_of_term(t()) :: non_neg_integer()
  def index_of_term(%__MODULE__{prev: prev}),
    do: Enum.count(prev)
end
