defmodule RoseTree.TreeNode do
  @moduledoc """
  A Rose Tree Node
  """

  defstruct ~w(data children)a

  @type t() :: %__MODULE__{
    data: term() | nil,
    children: [t() | nil]
  }

  @spec tree_node?(t()) :: boolean()
  defguard tree_node?(value) when is_struct(value) and value.__struct__ == __MODULE__

  @spec empty?(t()) :: boolean()
  defguard empty?(value) when tree_node?(value) and value.data == nil and value.children == []

  @doc """
  Initializes an empty tree.

  ## Examples

      iex> RoseTree.TreeNode.empty()
      %RoseTree.TreeNode{data: nil, children: []}

  """
  @spec empty() :: t()
  def empty(), do: %__MODULE__{data: nil, children: []}

  @doc """
  Initializes a new tree with the given data.

  ## Examples

      iex> RoseTree.TreeNode.new("new data")
      %RoseTree.TreeNode{data: "new data", children: []}

      iex> RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 3, children: []},
          %RoseTree.TreeNode{data: 2, children: []},
          %RoseTree.TreeNode{data: 1, children: []}
        ]
      }

      iex> children = [
      ...>   %RoseTree.TreeNode{data: 4, children: []},
      ...>   3,
      ...>   %RoseTree.TreeNode{data: 2, children: []},
      ...>   %RoseTree.TreeNode{data: 1, children: []}
      ...> ]
      ...> RoseTree.TreeNode.new(5, children)
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 3, children: []},
          %RoseTree.TreeNode{data: 2, children: []},
          %RoseTree.TreeNode{data: 1, children: []}
        ]
      }

  """
  @spec new(term(), [t() | term()]) :: t()
  def new(data, children \\ [])

  def new(data, []), do: %__MODULE__{data: data, children: []}

  def new(data, children) when is_list(children) do
    new_children =
      children
      |> Enum.map(fn
          child when tree_node?(child) ->
            child

          child ->
            new(child)
        end)

    %__MODULE__{
      data: data,
      children: new_children
    }
  end

  @doc """
  Sets the tree data to the given data.

  ## Examples

    iex> tree = RoseTree.TreeNode.new(5)
    ...> RoseTree.TreeNode.set_data(tree, "five")
    %RoseTree.TreeNode{data: "five", children: []}

  """
  @spec set_data(t(), term()) :: t()
  def set_data(%__MODULE__{} = tree, data) do
    %{tree | data: data}
  end

  @doc """
  Applies the given function to the tree data.

  ## Examples

      iex> tree = RoseTree.TreeNode.new(5)
      ...> RoseTree.TreeNode.map_data(tree, fn x -> x * 2 end)
      %RoseTree.TreeNode{data: 10, children: []}

  """
  @spec map_data(t(), (term() -> term())) :: t()
  def map_data(%__MODULE__{data: data} = tree, map_fn)
      when is_function(map_fn) do
    new_data = map_fn.(data)

    %{tree | data: new_data}
  end

  @doc """
  Sets the tree children to the given list of children.

  ## Examples

      iex> tree = RoseTree.TreeNode.new(5)
      ...> RoseTree.TreeNode.set_children(tree, [4, 3, 2, 1])
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 3, children: []},
          %RoseTree.TreeNode{data: 2, children: []},
          %RoseTree.TreeNode{data: 1, children: []}
        ]
      }

  """
  @spec set_children(t(), [t() | term()]) :: t()
  def set_children(%__MODULE__{} = tree, children) do
    new_children = children |> Enum.map(&new(&1))

    %{tree | children: new_children}
  end

  @doc """
  Applies the given function to each child tree. The `map_fn` should
  return a valid `RoseTree.TreeNode` struct.

  ## Examples

      iex> tree = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.map_children(tree, fn child ->
      ...>   RoseTree.TreeNode.map_data(child, fn x -> x * 2 end)
      ...> end)
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 8, children: []},
          %RoseTree.TreeNode{data: 6, children: []},
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 2, children: []}
        ]
      }

  """
  @spec map_children(t(), (t() -> t())) :: t()
  def map_children(%__MODULE__{children: children} = tree, map_fn)
      when is_function(map_fn) do
    new_children =
      children
      |> Enum.map(fn child -> map_fn.(child) end)

    if check_children(new_children) do
      %{tree | children: new_children}
    else
      raise("`map_fn` must return a valid `RoseTree.TreeNode` struct")
    end
  end

  @doc """
  Prepends the given child to the tree's children.

  ## Examples

      iex> tree = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.prepend_child(tree, 0)
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 0, children: []},
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 3, children: []},
          %RoseTree.TreeNode{data: 2, children: []},
          %RoseTree.TreeNode{data: 1, children: []}
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
  Appends the given child to the tree's children.

  ## Examples

      iex> tree = RoseTree.TreeNode.new(5, [4, 3, 2, 1])
      ...> RoseTree.TreeNode.append_child(tree, 0)
      %RoseTree.TreeNode{
        data: 5,
        children: [
          %RoseTree.TreeNode{data: 4, children: []},
          %RoseTree.TreeNode{data: 3, children: []},
          %RoseTree.TreeNode{data: 2, children: []},
          %RoseTree.TreeNode{data: 1, children: []},
          %RoseTree.TreeNode{data: 0, children: []}
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

  @doc false
  @spec check_children([term()]) :: boolean()
  defp check_children(children) when is_list(children) do
    children
    |> Enum.all?(fn child -> tree_node?(child) end)
  end

  defp check_children(_), do: false

  ## Implement Enumerable Protocol

  defimpl Enumerable do
    alias RoseTree.TreeNode

    def count(%TreeNode{data: nil, children: []}), do: {:ok, 0}
    def count(_tree), do: {:error, __MODULE__}

    def member?(%TreeNode{data: nil, children: []}, _value), do: {:ok, false}
    def member?(_tree, _value), do: {:error, __MODULE__}

    def slice(%TreeNode{} = _tree), do: {:error, __MODULE__}

    def reduce(%TreeNode{} = tree, acc, fun) do
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
           [%TreeNode{children: []} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.data, acc), fun, t, remaining_tree_sets)

    defp do_reduce(
           {:cont, acc},
           fun,
           [%TreeNode{children: children} = h | t],
           remaining_tree_sets
         ),
         do: do_reduce(fun.(h.data, acc), fun, children, t ++ remaining_tree_sets)
  end
end
