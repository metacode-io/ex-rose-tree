defmodule RoseTree do
  @moduledoc """
  Documentation for `RoseTree`.
  """

  defstruct ~w(term children)a

  @type t() :: %__MODULE__{
          term: term(),
          children: [t() | nil]
        }

  defguard rose_tree?(value)
           when is_struct(value) and value.__struct__ == __MODULE__ and is_list(value.children)

  defguard empty?(value) when rose_tree?(value) and value.term == nil and value.children == []

  defguard leaf?(value) when rose_tree?(value) and value.children == []

  defguard parent?(value)
           when rose_tree?(value) and is_list(value.children) and value.children != []

  @doc """
  Initializes an empty tree.

  ## Examples

      iex> RoseTree.empty()
      %RoseTree{term: nil, children: []}

  """
  @spec empty() :: t()
  def empty(), do: %__MODULE__{term: nil, children: []}

  @doc """
  Initializes a new tree with the given term.

  ## Examples

      iex> RoseTree.new("new term")
      %RoseTree{term: "new term", children: []}

      iex> RoseTree.new(5, [4, 3, 2, 1])
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ]
      }

      iex> children = [
      ...>   %RoseTree{term: 4, children: []},
      ...>   3,
      ...>   %RoseTree{term: 2, children: []},
      ...>   %RoseTree{term: 1, children: []}
      ...> ]
      ...> RoseTree.new(5, children)
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ]
      }

  """
  @spec new(term(), [t() | term()]) :: t()
  def new(term, children \\ [])

  def new(term, []), do: %__MODULE__{term: term, children: []}

  def new(term, children) when is_list(children) do
    new_children =
      children
      |> Enum.map(fn
        child when rose_tree?(child) ->
          child

        child ->
          new(child)
      end)

    %__MODULE__{
      term: term,
      children: new_children
    }
  end

  @doc """
  Returns the inner term of a RoseTree.

  ## Examples

    iex> tree = RoseTree.new(5)
    ...> RoseTree.get_term(tree)
    5

  """

  @spec get_term(t()) :: term()
  def get_term(tree) when rose_tree?(tree), do: tree.term

  @doc """
  Sets the tree term to the given term.

  ## Examples

    iex> tree = RoseTree.new(5)
    ...> RoseTree.set_term(tree, "five")
    %RoseTree{term: "five", children: []}

  """
  @spec set_term(t(), term()) :: t()
  def set_term(%__MODULE__{} = tree, term) do
    %{tree | term: term}
  end

  @doc """
  Applies the given function to the tree term.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> RoseTree.map_term(tree, fn x -> x * 2 end)
      %RoseTree{term: 10, children: []}

  """
  @spec map_term(t(), (term() -> term())) :: t()
  def map_term(%__MODULE__{term: term} = tree, map_fn)
      when is_function(map_fn) do
    new_term = map_fn.(term)

    %{tree | term: new_term}
  end

  @doc """
  Returns the children of a RoseTree.

  ## Examples

    iex> tree = RoseTree.new(5, [4,3,2,1])
    ...> RoseTree.get_children(tree)
    [
      %RoseTree{term: 4, children: []},
      %RoseTree{term: 3, children: []},
      %RoseTree{term: 2, children: []},
      %RoseTree{term: 1, children: []}
    ]

  """
  @spec get_children(t()) :: [t()]
  def get_children(tree) when rose_tree?(tree), do: tree.children

  @doc """
  Sets the tree children to the given list of children.

  ## Examples

      iex> tree = RoseTree.new(5)
      ...> RoseTree.set_children(tree, [4, 3, 2, 1])
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ]
      }

  """
  @spec set_children(t(), [t() | term()]) :: t()
  def set_children(%__MODULE__{} = tree, children) when is_list(children) do
    new_children =
      children
      |> Enum.map(fn
        %__MODULE__{} = child ->
          child

        child ->
          new(child)
      end)

    %{tree | children: new_children}
  end

  @doc """
  Applies the given function to each child tree. The `map_fn` should
  return a valid `RoseTree` struct.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.map_children(tree, fn child ->
      ...>   RoseTree.map_term(child, fn x -> x * 2 end)
      ...> end)
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 8, children: []},
          %RoseTree{term: 6, children: []},
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 2, children: []}
        ]
      }

  """
  @spec map_children(t(), (t() -> t())) :: t()
  def map_children(%__MODULE__{children: children} = tree, map_fn)
      when is_function(map_fn) do
    new_children =
      children
      |> Enum.map(fn child -> map_fn.(child) end)

    if all_rose_trees?(new_children) do
      %{tree | children: new_children}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree struct"
    end
  end

  @doc """
  Prepends the given child to the tree's children.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.prepend_child(tree, 0)
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 0, children: []},
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ]
      }

  """
  @spec prepend_child(t(), t() | term()) :: t()
  def prepend_child(%__MODULE__{children: children} = tree, child)
      when rose_tree?(child) do
    %{tree | children: [child | children]}
  end

  def prepend_child(%__MODULE__{children: children} = tree, child) do
    %{tree | children: [new(child) | children]}
  end

  @doc """
  Removes the first child of the tree's children.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.pop_first_child(tree)
      {
        %RoseTree{
          term: 5,
          children: [
            %RoseTree{term: 3, children: []},
            %RoseTree{term: 2, children: []},
            %RoseTree{term: 1, children: []}
          ]
        }, %RoseTree{term: 4, children: []}
      }

  """
  @spec pop_first_child(t()) :: {t(), t() | nil}
  def pop_first_child(%__MODULE__{children: []} = tree), do: {tree, nil}

  def pop_first_child(%__MODULE__{children: [child | children]} = tree) do
    {%{tree | children: children}, child}
  end

  @doc """
  Appends the given child to the tree's children.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.append_child(tree, 0)
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []},
          %RoseTree{term: 0, children: []}
        ]
      }

  """
  @spec append_child(t(), t() | term()) :: t()
  def append_child(%__MODULE__{children: children} = tree, child)
      when rose_tree?(child) do
    %{tree | children: children ++ [child]}
  end

  def append_child(%__MODULE__{children: children} = tree, child) do
    %{tree | children: children ++ [new(child)]}
  end

  @doc """
  Removes the last child of the tree's children.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.pop_last_child(tree)
      {
        %RoseTree{
          term: 5,
          children: [
            %RoseTree{term: 4, children: []},
            %RoseTree{term: 3, children: []},
            %RoseTree{term: 2, children: []}
          ]
        }, %RoseTree{term: 1, children: []}
      }

  """
  @spec pop_last_child(t()) :: {t(), t() | nil}
  def pop_last_child(%__MODULE__{children: []} = tree), do: {tree, nil}

  def pop_last_child(%__MODULE__{children: children} = tree) do
    {new_children, [popped_child | []]} = Enum.split(children, length(children) - 1)
    {%{tree | children: new_children}, popped_child}
  end

  @doc """
  Inserts a new child into the tree's children at the given index.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.insert_child(tree, 3.5, 2)
      %RoseTree{
        term: 5,
        children: [
          %RoseTree{term: 4, children: []},
          %RoseTree{term: 3, children: []},
          %RoseTree{term: 3.5, children: []},
          %RoseTree{term: 2, children: []},
          %RoseTree{term: 1, children: []}
        ]
      }

  """
  @spec insert_child(t(), t() | term(), integer()) :: t()
  def insert_child(%__MODULE__{} = tree, child, index) when rose_tree?(child),
    do: do_insert_child(tree, child, index)

  def insert_child(%__MODULE__{children: children} = tree, child, index),
    do: do_insert_child(tree, new(child), index)

  @spec do_insert_child(t(), t() | term(), integer()) :: t()
  defp do_insert_child(%__MODULE__{children: children} = tree, child, index)
       when rose_tree?(child) and is_integer(index) do
    {previous_children, next_children} = Enum.split(children, index)
    new_children = previous_children ++ [child | next_children]
    %{tree | children: new_children}
  end

  @doc """
  Removes a child from the tree's children at the given index.

  ## Examples

      iex> tree = RoseTree.new(5, [4, 3, 2, 1])
      ...> RoseTree.remove_child(tree, 2)
      {
        %RoseTree{
          term: 5,
          children: [
            %RoseTree{term: 4, children: []},
            %RoseTree{term: 3, children: []},
            %RoseTree{term: 1, children: []}
          ]
        },
        %RoseTree{term: 2, children: []}
      }

  """
  @spec remove_child(t(), integer()) :: {t(), t() | nil}
  def remove_child(%__MODULE__{children: []} = tree, _index), do: {tree, nil}

  def remove_child(%__MODULE__{children: children} = tree, index)
      when is_integer(index) and index < 0 do
    if abs(index) > length(children) do
      {tree, nil}
    else
      do_remove_child(tree, index)
    end
  end

  def remove_child(%__MODULE__{children: children} = tree, index) when is_integer(index),
    do: do_remove_child(tree, index)

  @spec do_remove_child(t(), integer()) :: {t(), t() | nil}
  defp do_remove_child(%__MODULE__{children: children} = tree, index) when is_integer(index) do
    {new_children, removed_child} =
      case Enum.split(children, index) do
        {previous, []} ->
          {previous, nil}

        {previous, [removed | next]} ->
          {previous ++ next, removed}
      end

    {%{tree | children: new_children}, removed_child}
  end

  @typep unfold_acc() :: %{
           current: term(),
           todo: [term()],
           done: [t()]
         }

  @typedoc """
  A function that takes a seed value and returns a new RoseTree and a
  list of new seeds to use for children. Care must be taken that you
  don't create an function that inifinitely creates new seeds, in
  other words, the function should have a terminating base case.
  """
  @type unfold_fn() :: (seed :: term() -> {term(), [seed :: term()]})

  @doc """
  Given a seed value and an `unfold_fn`, generates a new rose tree.

  ## Examples

      iex> unfolder = fn
      ...>   x when x > 0 -> {Integer.to_string(x), Enum.to_list(0..x-1)}
      ...>   x -> {Integer.to_string(x), []}
      ...> end
      ...> RoseTree.unfold(3, unfolder)
      %RoseTree{
        term: "3",
        children: [
          %RoseTree{term: "0", children: []},
          %RoseTree{
            term: "1",
            children: [%RoseTree{term: "0", children: []}]
          },
          %RoseTree{
            term: "2",
            children: [
              %RoseTree{term: "0", children: []},
              %RoseTree{
                term: "1",
                children: [%RoseTree{term: "0", children: []}]
              }
            ]
          }
        ]
      }

  """
  @spec unfold(seed :: term(), unfold_fn()) :: t()
  def unfold(seed, unfold_fn) when is_function(unfold_fn) do
    {current, next} = unfold_fn.(seed)

    %{current: current, todo: next, done: []}
    |> do_unfold(_stack = [], unfold_fn)
  end

  @spec do_unfold(unfold_acc(), [term()], unfold_fn()) :: t()
  defp do_unfold(%{todo: []} = acc, [] = _stack, unfold_fn) when is_function(unfold_fn),
    do: new(acc.current, Enum.reverse(acc.done))

  defp do_unfold(%{todo: []} = acc, [top | rest] = _stack, unfold_fn)
       when is_function(unfold_fn) do
    tree = new(acc.current, Enum.reverse(acc.done))

    %{top | done: [tree | top.done]}
    |> do_unfold(rest, unfold_fn)
  end

  defp do_unfold(%{todo: [next | rest]} = acc, stack, unfold_fn)
       when is_list(stack) and is_function(unfold_fn) do
    case unfold_fn.(next) do
      {current, []} ->
        %{acc | todo: rest, done: [new(current) | acc.done]}
        |> do_unfold(stack, unfold_fn)

      {current, todo} ->
        %{current: current, todo: todo, done: []}
        |> do_unfold([%{acc | todo: rest} | stack], unfold_fn)
    end
  end

  @doc """
  Returns whether a list of values are all RoseTrees or not. Will return
  true if passed an empty list.

  ## Examples

      iex> trees = for t <- [5,4,3,2,1], do: RoseTree.new(t)
      ...> RoseTree.all_rose_trees?(trees)
      true

  """
  @spec all_rose_trees?([term()]) :: boolean()
  def all_rose_trees?(values) when is_list(values) do
    Enum.all?(values, &rose_tree?(&1))
  end

  ## Implement Enumerable Protocol

  defimpl Enumerable do
    alias RoseTree

    def count(%RoseTree{term: nil, children: []}), do: {:ok, 0}
    def count(_tree), do: {:error, __MODULE__}

    def member?(%RoseTree{term: nil, children: []}, _value), do: {:ok, false}
    def member?(_tree, _value), do: {:error, __MODULE__}

    def slice(%RoseTree{} = _tree), do: {:error, __MODULE__}

    def reduce(%RoseTree{} = tree, acc, fun) do
      do_reduce(acc, fun, [tree], [])
    end

    defp do_reduce({:halt, acc}, _fun, _trees, _remaining_tree_sets),
      do: {:halted, acc}

    defp do_reduce({:suspend, acc}, fun, trees, remaining_tree_sets),
      do: {:suspended, acc, &do_reduce(&1, fun, trees, remaining_tree_sets)}

    defp do_reduce({:cont, acc}, _fun, [] = _trees, [] = _remaining_tree_sets),
      do: {:done, acc}

    defp do_reduce({:cont, acc}, fun, [] = _trees, [h | t] = _remaining_tree_sets),
      do: do_reduce({:cont, acc}, fun, [h], t)

    defp do_reduce(
           {:cont, acc},
           fun,
           [%RoseTree{children: []} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.term, acc), fun, t, remaining_tree_sets)

    defp do_reduce(
           {:cont, acc},
           fun,
           [%RoseTree{children: children} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.term, acc), fun, children, t ++ remaining_tree_sets)
  end
end
