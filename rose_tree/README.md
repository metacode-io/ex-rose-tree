<!-- README START -->

# RoseTree

A [Rose Tree](https://en.wikipedia.org/wiki/Rose_tree), also known as a multi-way or m-way tree
by some, is a recursively defined tree where each position can have an arbitrary number of `children`.
In this implementation, there is no restriction on the type of value contained by each `term`. Indeed,
the field is labelled `term` to reflect the fact that it can be any valid Erlang `term()` type.
Practically speaking, a good use case for a Rose Tree is as the foundation for an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree).

This implementation also comes with a companion `RoseTree.Zipper` data structure, and greatly
enhances the usefulness of the standard Rose Tree. A [Zipper](https://en.wikipedia.org/wiki/Zipper_(data_structure)) 
of a given data structure can be thought of as taking the derivative of that data structure. 
It provides a context-aware approach to traversing and manipulating the contents of the Rose Tree.

Gerard Huet, in his foundational [paper](https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf) 
formalizing the idea, describes it best:

> The basic idea is simple: the tree is turned inside-out like a returned glove,
> pointers from the root to the current position being reversed in a path structure. The
> current location holds both the downward current subtree and the upward path. All
> navigation and modification primitives operate on the location structure. Going up
> and down in the structure is analogous to closing and opening a zipper in a piece
> of clothing, whence the name.

Accompanying the `RoseTree.Zipper` are a large number of both navigation primitives and more complex
navigational and traversal functions built out of said primitives. An attempt has been made at providing
semantically meaningful names for these primitives, drawing from gender-neutral, familial taxonomy (with a few
liberties taken in creating neolisms to better suit the domain here), with the aim of establishing a sort of
_navigational pattern language_. The words `first`, `last`, `next`, and `previous` are ubiquitous and commonly
paired with the likes of `child`, `sibling`, `pibling` (non-binary form of aunt/uncle), `nibling`
(non-binary form of niece/nephew), and `cousin` to label specific navigation primitives. Other, less common
words used for more specialized navigations include `ancestral`, `descendant`, and `extended`. Care has been
taken to make naming conventions reflect the expected operations as closely as possible, though there are a
few cases where it might not be entirely obvious, particularly for some of the more specialized operations,
so be sure to read the documentation closely and test for your use case when using a navigational function
for the first time.

Many of these functions take an optional `predicate()` function which can be used to perform a navigational
function until said predicate is satisfied. For example, `RoseTree.Zipper.first_sibling(zipper, &(&1.term == 5))`
will search, starting from the 0-th (first) index, the list of siblings that occur _before but not after_ the current
context for the first occurrence of a sibling with a `term` value equal to `5`. If none are found, the
context will not have been moved, and the function returns `nil`. Note, the predicate function will default
to `Util.always/1`, which always returns true. When using the default predicate (in essence, not using a
predicate) with this example, `RoseTree.Zipper.first_sibling(zipper)`, the function will simply move the context
to the first sibling of the initial context. If the are no previous siblings, it will return `nil`. In general, most
of the navigation primitives take constant time, while mutation is done at the current position and is a local operation.

In practice, a `RoseTree.Zipper` can be used as an efficient means of representing everything from a cursor
in a text editor to an item in a nested sidebar or dropdown menu in a user interface that needs to maintain persistent
focus. Essentially, anything that has an arbitary hierarchy and would necessitate or benefit from the capability of
being context-aware could be a candidate for a Rose Tree with Zipper.

Finally, while great pains have been taken to provide extensive test coverage, this library is still in its infancy and
is not yet used in a production setting. Feedback and contributions are more than welcome in all regards, but particularly
in the realms of making the documentation more friendly and comprehensive, the testing ever more thorough, and the
performance analysed for improvements.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rose_tree` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rose_tree, "~> 0.1.0"}
  ]
end
```

<!-- README END -->



