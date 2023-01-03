defmodule RoseTree.Util do
  @moduledoc """
  Various utility functions.
  """

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

  def split_at(elements, index)
      when is_list(elements) and
           is_integer(index), do: {[], []}
end
