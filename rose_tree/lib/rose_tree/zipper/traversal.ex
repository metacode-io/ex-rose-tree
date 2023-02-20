# defmodule RoseTree.Zipper.Traversal do
#   @moduledoc """
#   High-level traversal functions for the zipper context. Builds off
#   of semantic "kinship" functions in `RoseTree.Zipper.Kin`.
#   """

#   require RoseTree.TreeNode
#   require RoseTree.Zipper.Context
#   import RoseTree.Zipper.Kin
#   import RoseTree.Util
#   alias URI.Error
#   alias RoseTree.TreeNode
#   alias RoseTree.Zipper.Context

#   @typep predicate() :: (term() -> boolean())

#   ###
#   ### FORWARD, BREADTH-FIRST TRAVERSAL
#   ###

#   @doc """
#   Traverses forward through the zipper in a breadth-first manner.
#   """
#   @spec forward(Context.t()) :: Context.t() | nil
#   def forward(%Context{} = ctx) do
#     funs = [
#       &next_sibling/2,
#       &next_extended_cousin/2,
#       &first_extended_nibling/2,
#       &first_nibling/2,
#       &first_child/2
#     ]

#     ctx
#     |> first_of_with_args(funs, [&always/1])
#   end

#   @doc """
#   Repeats a call to `forward/1` by the given number of `reps`.
#   """
#   @spec forward_for(Context.t(), pos_integer()) :: Context.t() | nil
#   def forward_for(%Context{} = ctx, reps) when reps > 0,
#     do: move_for(ctx, reps, &forward/1)

#   def forward_for(%Context{}, _reps), do: nil

#   @doc """
#   Moves forward in the Zipper if the provided predicate function
#   returns true when applied to the next Context. Otherwise,
#   returns nil.
#   """
#   @spec forward_if(Context.t(), predicate()) :: Context.t() | nil
#   def forward_if(%Context{} = ctx, predicate) when is_function(predicate) do
#     case forward(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           nil
#         end
#     end
#   end

#   @doc """
#   Moves forward in the Zipper continuously until the provided predicate
#   function returns true when applied to the Context. Otherwise,
#   returns nil.
#   """
#   @spec forward_until(Context.t(), predicate()) :: Context.t() | nil
#   def forward_until(%Context{} = ctx, predicate) when is_function(predicate) do
#     case forward(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           forward_until(next_ctx, predicate)
#         end
#     end
#   end

#   ###
#   ### BACKWARD, BREADTH-FIRST TRAVERSAL
#   ###

#   @doc """
#   Traverses backward through the zipper in a breadth-first manner.
#   """
#   @spec backward(Context.t()) :: Context.t()
#   def backward(%Context{path: []}), do: nil

#   def backward(%Context{} = ctx) do
#     funs = [
#       fn x -> previous_sibling(x) end,
#       fn x -> previous_extended_cousin(x) end,
#       fn x -> last_extended_pibling(x) end,
#       &parent/1
#     ]

#     ctx
#     |> first_of(funs)
#   end

#   @doc """
#   Repeats a call to `backward/1` by the given number of `reps`.
#   """
#   @spec backward_for(Context.t(), pos_integer()) :: Context.t() | nil
#   def backward_for(%Context{} = ctx, reps) when reps > 0,
#     do: move_for(ctx, reps, &backward/1)

#   def backward_for(%Context{}, _reps), do: nil

#   @doc """
#   Moves backward in the Zipper if the provided predicate function
#   returns true when applied to the next Context. Otherwise,
#   returns nil.
#   """
#   @spec backward_if(Context.t(), predicate()) :: Context.t() | nil
#   def backward_if(%Context{} = ctx, predicate) when is_function(predicate) do
#     case backward(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           nil
#         end
#     end
#   end

#   @doc """
#   Moves backward in the Zipper continuously until the provided predicate
#   function returns true when applied to the Context. Otherwise,
#   returns nil.
#   """
#   @spec backward_until(Context.t(), predicate()) :: Context.t() | nil
#   def backward_until(%Context{} = ctx, predicate) when is_function(predicate) do
#     case backward(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           backward_until(next_ctx, predicate)
#         end
#     end
#   end

#   ###
#   ### DESCEND, DEPTH-FIRST TRAVERSAL
#   ###

#   @doc """
#   Traverses forward through the zipper in a depth-first manner.
#   """
#   @spec descend(Context.t()) :: Context.t() | nil
#   def descend(%Context{} = ctx) do
#     funs = [
#       &first_child/2,
#       &next_sibling/2,
#       &next_ancestral_pibling/2
#     ]

#     ctx
#     |> first_of_with_args(funs, [&always/1])
#   end

#   @doc """
#   Repeats a call to `descend/1` by the given number of `reps`.
#   """
#   @spec descend_for(Context.t(), pos_integer()) :: Context.t() | nil
#   def descend_for(%Context{} = ctx, reps) when reps > 0,
#     do: move_for(ctx, reps, &descend/1)

#   def descend_for(%Context{}, _reps), do: nil

#   @doc """
#   Descends into the Zipper if the provided predicate function
#   returns true when applied to the next Context. Otherwise,
#   returns nil.
#   """
#   @spec descend_if(Context.t(), predicate()) :: Context.t() | nil
#   def descend_if(%Context{} = ctx, predicate) when is_function(predicate) do
#     case descend(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           nil
#         end
#     end
#   end

#   @doc """
#   Descends into the Zipper continuously until the provided predicate
#   function returns true when applied to the Context. Otherwise,
#   returns nil.
#   """
#   @spec descend_until(Context.t(), predicate()) :: Context.t() | nil
#   def descend_until(%Context{} = ctx, predicate) when is_function(predicate) do
#     case descend(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           descend_until(next_ctx, predicate)
#         end
#     end
#   end

#   ###
#   ### ASCEND, DEPTH-FIRST TRAVERSAL
#   ###

#   @doc """
#   Traverses back through the zipper in a depth-first manner.
#   """
#   @spec ascend(Context.t()) :: Context.t()
#   def ascend(%Context{} = ctx) do
#     funs = [
#       fn x -> previous_descendant_nibling(x) end,
#       fn x -> previous_sibling(x) end,
#       &parent/1
#     ]

#     ctx
#     |> first_of(funs)
#   end

#   @doc """
#   Repeats a call to `ascend/1` by the given number of `reps`.
#   """
#   @spec ascend_for(Context.t(), pos_integer()) :: Context.t() | nil
#   def ascend_for(%Context{} = ctx, reps) when reps > 0,
#     do: move_for(ctx, reps, &ascend/1)

#   def ascend_for(%Context{}, _reps), do: nil

#   @doc """
#   Ascends the Zipper if the provided predicate function
#   returns true when applied to the next Context. Otherwise,
#   returns nil.
#   """
#   @spec ascend_if(Context.t(), predicate()) :: Context.t() | nil
#   def ascend_if(%Context{} = ctx, predicate) when is_function(predicate) do
#     case ascend(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           nil
#         end
#     end
#   end

#   @doc """
#   Ascends the Zipper continuously until the provided predicate
#   function returns true when applied to the Context. Otherwise,
#   returns nil.
#   """
#   @spec ascend_until(Context.t(), predicate()) :: Context.t() | nil
#   def ascend_until(%Context{} = ctx, predicate) when is_function(predicate) do
#     case ascend(ctx) do
#       nil ->
#         nil

#       %Context{} = next_ctx ->
#         if predicate.(next_ctx) do
#           next_ctx
#         else
#           ascend_until(next_ctx, predicate)
#         end
#     end
#   end

#   ###
#   ### SEARCHING
#   ###

#   @doc """
#   Using the designated move function, `move_fn`, searches for the first
#   node that satisfies the given `predicate` function.
#   """
#   @spec find(
#           Context.t(),
#           (Context.t() -> boolean()),
#           (Context.t(), keyword() -> Context.t() | nil)
#         ) :: Context.t() | nil
#   def find(%Context{} = ctx, predicate, move_fn)
#       when is_function(predicate) and is_function(move_fn) do
#     if predicate.(ctx) do
#       ctx
#     else
#       case move_fn.(ctx) do
#         nil ->
#           nil

#         %Context{} = new_focus ->
#           find(new_focus, predicate, move_fn)
#       end
#     end
#   end

#   def find(%Context{}, _predicate, _move_fn), do: nil
# end
