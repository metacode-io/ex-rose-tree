defmodule RoseTree.TreeNode do
  @moduledoc """
  A Rose Tree Node
  """

  defstruct ~w(term children)a

  @type t() :: %__MODULE__{
          term: term(),
          children: [t() | nil]
        }

  defguard tree_node?(value)
           when is_struct(value) and value.__struct__ == __MODULE__ and is_list(value.children)

  defguard empty?(value) when tree_node?(value) and value.term == nil and value.children == []

  defguard leaf?(value) when tree_node?(value) and value.children == []

  defguard parent?(value)
           when tree_node?(value) and is_list(value.children) and value.children != []

  @doc """
  Initializes an empty tree.

  ## Examples

      iex> RoseTree.TreeNode.empty()
      %RoseTree.TreeNode{term: nil, children: []}

  """
  @spec empty() :: t()
  def empty(), do: %__MODULE__{term: nil, children: []}

  @doc """
  Initializes a new tree with the given term.

  ## Examples

      iex> RoseTree.TreeNode.new("new term")
      %RoseTree.TreeNode{term: "new term", children: []}

      iex> RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
        ]
      }

      iex> children = [
      ...>   %RoseTree.TreeNode{term: 4, children: []},
      ...>   3,
      ...>   %RoseTree.TreeNode{term: 2, children: []},
      ...>   %RoseTree.TreeNode{term: 1, children: []}
      ...> ]
      ...> RoseTree.TreeNode.new(5, children)
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
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
        child when tree_node?(child) ->
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
  Returns the inner term of a tree node.

  ## Examples

    iex> node = RoseTree.TreeNode.new(5)
    ...> RoseTree.TreeNode.get_term(node)
    5

  """

  @spec get_term(t()) :: term()
  def get_term(node) when tree_node?(node), do: node.term

  @doc """
  Sets the tree term to the given term.

  ## Examples

    iex> node = RoseTree.TreeNode.new(5)
    ...> RoseTree.TreeNode.set_term(node, "five")
    %RoseTree.TreeNode{term: "five", children: []}

  """
  @spec set_term(t(), term()) :: t()
  def set_term(%__MODULE__{} = tree, term) do
    %{tree | term: term}
  end

  @doc """
  Applies the given function to the tree term.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> RoseTree.TreeNode.map_term(node, fn x -> x * 2 end)
      %RoseTree.TreeNode{term: 10, children: []}

  """
  @spec map_term(t(), (term() -> term())) :: t()
  def map_term(%__MODULE__{term: term} = tree, map_fn)
      when is_function(map_fn) do
    new_term = map_fn.(term)

    %{tree | term: new_term}
  end

  @doc """
  Returns the children of a tree node.

  ## Examples

    iex> node = RoseTree.TreeNode.new(5, [4,3,2,1])
    ...> RoseTree.TreeNode.get_children(node)
    [
      %RoseTree.TreeNode{term: 4, children: []},
      %RoseTree.TreeNode{term: 3, children: []},
      %RoseTree.TreeNode{term: 2, children: []},
      %RoseTree.TreeNode{term: 1, children: []}
    ]

  """
  @spec get_children(t()) :: [t()]
  def get_children(node) when tree_node?(node), do: node.children

  @doc """
  Sets the tree children to the given list of children.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5)
      ...> RoseTree.TreeNode.set_children(node, [4, 3, 2, 1])
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
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
  return a valid `RoseTree.TreeNode` struct.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.map_children(node, fn child ->
      ...>   RoseTree.TreeNode.map_term(child, fn x -> x * 2 end)
      ...> end)
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 8, children: []},
          %RoseTree.TreeNode{term: 6, children: []},
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 2, children: []}
        ]
      }

  """
  @spec map_children(t(), (t() -> t())) :: t()
  def map_children(%__MODULE__{children: children} = tree, map_fn)
      when is_function(map_fn) do
    new_children =
      children
      |> Enum.map(fn child -> map_fn.(child) end)

    if all_tree_nodes?(new_children) do
      %{tree | children: new_children}
    else
      raise ArgumentError, "map_fn must return a valid RoseTree.TreeNode struct"
    end
  end

  @doc """
  Prepends the given child to the tree's children.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.prepend_child(node, 0)
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 0, children: []},
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
        ]
      }

  """
  @spec prepend_child(t(), t() | term()) :: t()
  def prepend_child(%__MODULE__{children: children} = tree, child)
      when tree_node?(child) do
    %{tree | children: [child | children]}
  end

  def prepend_child(%__MODULE__{children: children} = tree, child) do
    %{tree | children: [new(child) | children]}
  end

  @doc """
  Removes the first child of the tree's children.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.pop_first_child(node)
      {
        %RoseTree.TreeNode{
          term: 5,
          children: [
            %RoseTree.TreeNode{term: 3, children: []},
            %RoseTree.TreeNode{term: 2, children: []},
            %RoseTree.TreeNode{term: 1, children: []}
          ]
        }, %RoseTree.TreeNode{term: 4, children: []}
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

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.append_child(node, 0)
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []},
          %RoseTree.TreeNode{term: 0, children: []}
        ]
      }

  """
  @spec append_child(t(), t() | term()) :: t()
  def append_child(%__MODULE__{children: children} = tree, child)
      when tree_node?(child) do
    %{tree | children: children ++ [child]}
  end

  def append_child(%__MODULE__{children: children} = tree, child) do
    %{tree | children: children ++ [new(child)]}
  end

  @doc """
  Removes the last child of the tree's children.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.pop_last_child(node)
      {
        %RoseTree.TreeNode{
          term: 5,
          children: [
            %RoseTree.TreeNode{term: 4, children: []},
            %RoseTree.TreeNode{term: 3, children: []},
            %RoseTree.TreeNode{term: 2, children: []}
          ]
        }, %RoseTree.TreeNode{term: 1, children: []}
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

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.insert_child(node, 3.5, 2)
      %RoseTree.TreeNode{
        term: 5,
        children: [
          %RoseTree.TreeNode{term: 4, children: []},
          %RoseTree.TreeNode{term: 3, children: []},
          %RoseTree.TreeNode{term: 3.5, children: []},
          %RoseTree.TreeNode{term: 2, children: []},
          %RoseTree.TreeNode{term: 1, children: []}
        ]
      }

  """
  @spec insert_child(t(), t() | term(), integer()) :: t()
  def insert_child(%__MODULE__{} = tree, child, index) when tree_node?(child),
    do: do_insert_child(tree, child, index)

  def insert_child(%__MODULE__{children: children} = tree, child, index),
    do: do_insert_child(tree, new(child), index)

  defp do_insert_child(%__MODULE__{children: children} = tree, child, index)
      when tree_node?(child) and is_integer(index) do
    {previous_children, next_children} = Enum.split(children, index)
    new_children = previous_children ++ [child | next_children]
    %{tree | children: new_children}
  end

  @doc """
  Removes a child from the tree's children at the given index.

  ## Examples

      iex> node = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.remove_child(node, 2)
      {
        %RoseTree.TreeNode{
          term: 5,
          children: [
            %RoseTree.TreeNode{term: 4, children: []},
            %RoseTree.TreeNode{term: 3, children: []},
            %RoseTree.TreeNode{term: 1, children: []}
          ]
        },
        %RoseTree.TreeNode{term: 2, children: []}
      }

  """
  @spec remove_child(t(), integer()) :: {t(), t() | nil}
  def remove_child(%__MODULE__{children: []} = tree, _index), do: {tree, nil}

  def remove_child(%__MODULE__{children: children} = tree, index) when is_integer(index) do
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
  A function that takes a seed value and returns a new node and a
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
      ...> TreeNode.unfold(3, unfolder)
      %RoseTree.TreeNode{
        term: "3",
        children: [
          %RoseTree.TreeNode{term: "0", children: []},
          %RoseTree.TreeNode{
            term: "1",
            children: [%RoseTree.TreeNode{term: "0", children: []}]
          },
          %RoseTree.TreeNode{
            term: "2",
            children: [
              %RoseTree.TreeNode{term: "0", children: []},
              %RoseTree.TreeNode{
                term: "1",
                children: [%RoseTree.TreeNode{term: "0", children: []}]
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
    node = new(acc.current, Enum.reverse(acc.done))

    %{top | done: [node | top.done]}
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
  Returns whether a list of values are all TreeNodes or not. Will return
  true if passed an empty list.

  ## Examples

      iex> nodes = for t <- [5,4,3,2,1], do: RoseTree.TreeNode.new(t)
      ...> RoseTree.TreeNode.all_tree_nodes?(nodes)
      true

  """
  @spec all_tree_nodes?([term()]) :: boolean()
  def all_tree_nodes?(values) when is_list(values) do
    Enum.all?(values, &tree_node?(&1))
  end

  ## Implement Enumerable Protocol

  defimpl Enumerable do
    alias RoseTree.TreeNode

    def count(%TreeNode{term: nil, children: []}), do: {:ok, 0}
    def count(_tree), do: {:error, __MODULE__}

    def member?(%TreeNode{term: nil, children: []}, _value), do: {:ok, false}
    def member?(_tree, _value), do: {:error, __MODULE__}

    def slice(%TreeNode{} = _tree), do: {:error, __MODULE__}

    def reduce(%TreeNode{} = tree, acc, fun) do
      do_reduce(acc, fun, [tree], [])
    end

    defp do_reduce({:halt, acc}, _fun, _nodes, _remaining_tree_sets),
      do: {:halted, acc}

    defp do_reduce({:suspend, acc}, fun, nodes, remaining_tree_sets),
      do: {:suspended, acc, &do_reduce(&1, fun, nodes, remaining_tree_sets)}

    defp do_reduce({:cont, acc}, _fun, [] = _nodes, [] = _remaining_tree_sets),
      do: {:done, acc}

    defp do_reduce({:cont, acc}, fun, [] = _nodes, [h | t] = _remaining_tree_sets),
      do: do_reduce({:cont, acc}, fun, [h], t)

    defp do_reduce(
           {:cont, acc},
           fun,
           [%TreeNode{children: []} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.term, acc), fun, t, remaining_tree_sets)

    defp do_reduce(
           {:cont, acc},
           fun,
           [%TreeNode{children: children} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.term, acc), fun, children, t ++ remaining_tree_sets)
  end
end
