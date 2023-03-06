<!-- README START -->

# ExRoseTree

### What's a Rose Tree?

A [Rose Tree](https://en.wikipedia.org/wiki/Rose_tree), also known as a multi-way or m-way tree
by some, is a general-purpose, recursively defined data structure where each position can have an 
an arbitrary value and an arbitrary number of children. Each child is, itself, another Rose Tree.

ExRoseTree is implemented as a very simple struct `defstruct ~w(term children)a` with an equally
simple typespec:

```
@type t() :: %__MODULE__{
        term: term(),
        children: [t()]
      }
```

### What's it good for?

Practically speaking, a few good use cases for Rose Trees could be:

* outlines
* file systems
* HTML/XML documents
* [abstract syntax trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
* decision trees
* data visualization (org chargs, family trees, taxonomies, nested menus)

This implementation also comes with a companion `ExRoseTree.Zipper` data structure, and greatly
enhances the usefulness of the standard Rose Tree. 

### So what's a Zipper? 

A [Zipper](https://en.wikipedia.org/wiki/Zipper_(data_structure)) of a given data structure can 
be thought of as taking the derivative of that data structure. It provides a context-aware approach to 
traversing and manipulating the contents of the Rose Tree.

In his foundational [paper](https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf) 
formalizing the idea, Gerard Huet perhaps describes it best:

> The basic idea is simple: the tree is turned inside-out like a returned glove,
> pointers from the root to the current position being reversed in a path structure. The
> current location holds both the downward current subtree and the upward path. All
> navigation and modification primitives operate on the location structure. Going up
> and down in the structure is analogous to closing and opening a zipper in a piece
> of clothing, whence the name.

### And what's a Zipper of a Rose Tree good for?

In practice, `ExRoseTree.Zipper` can be used as an efficient means of representing everything from a cursor
in a text editor to a selected item in a nested sidebar/dropdown menu in a UI which needs to maintain persistent
focus. Essentially, anything that has an arbitrary hierarchy and would necessitate or benefit from the capability of
being context-aware could be a candidate for a Rose Tree with Zipper.

Finally, while great pains have been taken to provide extensive test coverage, this library is still in its infancy and
is not yet used in a production setting. Feedback and contributions are more than welcome in all regards, but particularly
in the realms of making the documentation more friendly and comprehensive, the testing ever more thorough, and the
performance analysed for improvements.

Additional functionality may be useful to add, including diffing algorithms, multiple cursor support (ie: multiple, concurrent
contexts on a Zipper), LiveBook examples, visualizations of the many traversal functions, and so on. I'm open to any and all
ideas and contribution here, so don't hesitate to pipe in.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_rose_tree` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_rose_tree, "~> 0.1.0"}
  ]
end
```

<!-- README END -->



