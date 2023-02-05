defmodule RoseTree.Util do
  @moduledoc """
  Various utility functions.
  """

  @type result() :: {:ok, term()} | {:error, term()} | :error

  @type result_fn() :: (... -> result())

  @doc """
  Given a term and a list of potential functions to apply to the term,
  will return with the result of the first one that succeeds when
  applied to the subject term. If no functions succeed, returns nil.

  The list of functions should each be of type `RoseTree.Util.result_fn()`,
  in other words, they should return a `RoseTree.Util.result()` type.

  ## Examples

      iex> funs = for n <- [4,3,2,1], do: &(if n == &1 do {:ok, n} else :error end)
      ...> RoseTree.Util.first_of(3, funs)
      3

      iex> funs = for n <- [4,3,2,1], do: &(if n == &1 do {:ok, n} else :error end)
      ...> RoseTree.Util.first_of(6, funs)
      nil

  """
  @spec first_of(term(), [result_fn()]) :: term() | nil
  def first_of(_term, []), do: nil

  def first_of(term, [h | t] = _funs) when is_function(h) do
    case h.(term) do
      {:ok, result} -> result
      {:error, error} -> first_of(term, t)
      :error -> first_of(term, t)
      nil -> first_of(term, t)
      result -> result
    end
  end

  @doc """
  Given a term, a list of potential functions to apply to the term,
  and a keyword list of options to apply to each function, will return
  with the result of the first one that succeeds when applied to the
  subject term. If no functions succeed, returns nil.

  The list of functions should each be of type `RoseTree.Util.result_fn()`,
  in other words, they should return a `RoseTree.Util.result()` type.

  ## Examples

      iex> fun = fn x, y, z ->
      ...>   mult_by = Keyword.get(z, :mult_by, 1)
      ...>   if x == y do {:ok, x * mult_by} else :error end
      ...> end
      ...> funs = for n <- [4,3,2,1], do: &fun.(n, &1, &2)
      ...> RoseTree.Util.first_of_with_opts(3, funs, [mult_by: 2])
      6

  """
  @spec first_of_with_opts(term(), [function()], keyword()) :: term() | nil
  def first_of_with_opts(_term, [], _opts), do: nil

  def first_of_with_opts(term, [h | t] = _funs, opts)
      when is_function(h) and
             is_list(opts) do
    case h.(term, opts) do
      {:ok, result} -> result
      {:error, error} -> first_of_with_opts(term, t, opts)
      :error -> first_of_with_opts(term, t, opts)
      nil -> first_of_with_opts(term, t, opts)
      result -> result
    end
  end

  @doc """
  Given a term, a list of potential functions to apply to the term,
  and a list of arguments to apply to each function, will return
  with the result of the first one that succeeds when applied to the
  subject term. If no functions succeed, returns nil.

  The list of functions should each be of type `RoseTree.Util.result_fn()`,
  in other words, they should return a `RoseTree.Util.result()` type.

  ## Examples

      iex> fun = fn x, y, add_by, sub_by ->
      ...>   if x == y do {:ok, x + add_by - sub_by} else :error end
      ...> end
      ...> funs = for n <- [4,3,2,1], do: &fun.(n, &1, &2, &3)
      ...> RoseTree.Util.first_of_with_args(3, funs, [2, 1])
      4

  """
  @spec first_of_with_args(term(), [function()], [term()]) :: term() | nil
  def first_of_with_args(_term, [], _args), do: nil

  def first_of_with_args(term, [h | t] = _funs, args)
      when is_function(h) and
             is_list(args) do
    case apply(h, [term | args]) do
      {:ok, result} -> result
      {:error, error} -> first_of_with_args(term, t, args)
      :error -> first_of_with_args(term, t, args)
      nil -> first_of_with_args(term, t, args)
      result -> result
    end
  end

  @doc """
  A function that always returns true, regardless of what is passed to it.

  ## Examples

      iex> RoseTree.Util.always(5)
      true

      iex> RoseTree.Util.always(false)
      true

  """
  @spec always(term()) :: true
  def always(_term), do: true

  @doc """
  Similar to `Enum.split/2` but is optimized to return the
  list of elements that come before the index in reverse order.
  This is ideal for the context-aware nature of Zippers.

  ## Examples

      iex> RoseTree.Util.split_at([1,2,3,4,5], 2)
      {[2, 1], [3, 4, 5]}

  """
  @spec split_at(list(), non_neg_integer()) :: {[term()], [term()]}
  def split_at([], _), do: {[], []}

  def split_at(elements, index)
      when is_list(elements) and
             is_integer(index) and
             index >= 0 do
    if index >= Enum.count(elements) do
      {[], []}
    else
      {_current_idx, prev, next} =
        elements
        |> Enum.reduce(
          {0, [], []},
          fn entry, {current_idx, prev, next} ->
            if current_idx >= index do
              {current_idx + 1, prev, [entry | next]}
            else
              {current_idx + 1, [entry | prev], next}
            end
          end
        )

      {prev, Enum.reverse(next)}
    end
  end

  def split_at(elements, index)
      when is_list(elements) and
             is_integer(index),
      do: {[], []}

  @doc """
  Similar to `Enum.split/2`, `Enum.split_while/2`, and `Enum.split_with/2`, `split_when/2`
  instead takes a list of elements and a predicate to apply to each element. The first
  element that passes the predicate is where the list of elements will be split, with
  the target element as the head of the second list in the return value. Like
  with `split_at/2`, the first list of elements are returned in reverse order.

  ## Examples

      iex> RoseTree.Util.split_when([1,2,3,4,5], fn x -> x == 3 end)
      {[2, 1], [3, 4, 5]}

  """
  @spec split_when(list(), predicate :: (term() -> boolean())) :: {[term()], [term()]}
  def split_when([], predicate) when is_function(predicate), do: {[], []}

  def split_when(elements, predicate)
      when is_list(elements) and is_function(predicate) do
    do_split_when([], elements, predicate)
  end

  def do_split_when(_acc, [] = remaining, predicate), do: {[], []}

  def do_split_when(acc, [head | tail] = remaining, predicate) do
    if predicate.(head) do
      {acc, remaining}
    else
      do_split_when([head | acc], tail, predicate)
    end
  end

  @doc """
  A combination of `Enum.split/2` and `Enum.take_random/2`, `split_random/2` takes
  a random selection of elements from the list up to the given number, and returns
  two lists: the first is the randomly selected elements, and the latter is the
  remainder from the original list. An important note is that the remainder list
  does not preserve the original order of the list.
  """
  @spec split_random(list(), take :: non_neg_integer()) ::
          {[taken :: term()], [remainder :: term()]}
  def split_random([], _), do: {[], []}

  def split_random(list, take) when is_list(list) and is_integer(take) and take >= 0 do
    list
    |> Enum.shuffle()
    |> Enum.split(take)
  end
end
