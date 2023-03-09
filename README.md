## ExRoseTree :: A Rose Tree with Functional Zipper in Elixir

[![Build Status](https://github.com/StoatPower/ex-rose-tree/actions/workflows/elixir.yml/badge.svg)](https://github.com/StoatPower/ex-rose-tree/actions/workflows/elixir.yml)

<!-- README START -->

### What's a Rose Tree?

A [Rose Tree](https://en.wikipedia.org/wiki/Rose_tree), also known as a multi-way or m-way tree
by some, is a general-purpose, recursively defined data structure where each position can have an 
an arbitrary value and an arbitrary number of children. Each child is, itself, another Rose Tree.

ExRoseTree is implemented as a very simple struct `defstruct ~w(term children)a` with an equally
simple typespec:

```elixir
@type t() :: %__MODULE__{
        term: term(),
        children: [t()]
      }
```

### What's it good for?

Practically speaking, a few good use cases for Rose Trees could be:

* outlines
* file systems
* parsing HTML/XML documents
* [abstract syntax trees](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
* decision trees
* data visualization (org chargs, family trees, taxonomies, nested menus)

This implementation also comes with a companion `ExRoseTree.Zipper` data structure, and greatly
enhances the usefulness of the standard Rose Tree. 

### So what's a Zipper? 

A [Zipper](https://en.wikipedia.org/wiki/Zipper_(data_structure)) of a given data structure can 
be thought of as taking the derivative of that data structure. It provides an efficient, context-aware 
approach to traversing and manipulating the contents of the Rose Tree.

In his foundational [paper](https://www.st.cs.uni-saarland.de/edu/seminare/2005/advanced-fp/docs/huet-zipper.pdf) 
formalizing the idea, Gerard Huet perhaps describes it best:

> The basic idea is simple: the tree is turned inside-out like a returned glove,
> pointers from the root to the current position being reversed in a path structure. The
> current location holds both the downward current subtree and the upward path. All
> navigation and modification primitives operate on the location structure. Going up
> and down in the structure is analogous to closing and opening a zipper in a piece
> of clothing, whence the name.

### And what's a Zipper of a Rose Tree good for?

In practice, `ExRoseTree.Zipper` can be used as an effective means of representing everything from a cursor
in a text editor to a selected item in a nested sidebar/dropdown menu in a UI which needs to maintain persistent
focus. Essentially, anything that has an arbitrary hierarchy and would necessitate or benefit from the capability of
being context-aware could be a candidate for a Rose Tree with Zipper.

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

## Example Usage

```elixir
alias ExRoseTree, as: Tree
alias ExRoseTree.Zipper    
    
Tree.new(1)
# %ExRoseTree{term: 1, children: []}

tree = Tree.new(1, [2,3,4,5])
# %ExRoseTree{term: 1, children: [
#   %ExRoseTree{term: 2, children: []},
#   %ExRoseTree{term: 3, children: []},
#   %ExRoseTree{term: 4, children: []},
#   %ExRoseTree{term: 5, children: []},
# ]}

zipper = Zipper.new(tree)
# %ExRoseTree.Zipper{
#   focus: %ExRoseTree{
#     term: 1,
#     children: [
#       %ExRoseTree{term: 2, children: []},
#       %ExRoseTree{term: 3, children: []},
#       %ExRoseTree{term: 4, children: []},
#       %ExRoseTree{term: 5, children: []}
#     ]
#   },
#   prev: [],
#   next: [],
#   path: []
# }

zipper = Zipper.last_child(zipper)
# %ExRoseTree.Zipper{
#   focus: %ExRoseTree{term: 5, children: []},
#   prev: [
#     %ExRoseTree{term: 4, children: []},
#     %ExRoseTree{term: 3, children: []},
#     %ExRoseTree{term: 2, children: []}
#   ],
#   next: [],
#   path: [%ExRoseTree.Zipper.Location{prev: [], term: 1, next: []}]
# }

zipper = Zipper.backward(zipper)

# %ExRoseTree.Zipper{
#   focus: %ExRoseTree{term: 4, children: []},
#   prev: [
#     %ExRoseTree{term: 3, children: []}, 
#     %ExRoseTree{term: 2, children: []}
#   ],
#   next: [%ExRoseTree{term: 5, children: []}],
#   path: [%ExRoseTree.Zipper.Location{prev: [], term: 1, next: []}]
# }

zipper = Zipper.rewind_map(zipper, &Tree.map_term(&1, fn t -> t * 10 end))
# %ExRoseTree.Zipper{
#   focus: %ExRoseTree{
#     term: 10,
#     children: [
#       %ExRoseTree{term: 1, children: []},
#       %ExRoseTree{term: 2, children: []},
#       %ExRoseTree{term: 3, children: []},
#       %ExRoseTree{term: 40, children: []},
#       %ExRoseTree{term: 5, children: []}
#     ]
#   },
#   prev: [],
#   next: [],
#   path: []
# }

Zipper.to_tree(zipper)
# %ExRoseTree{
#   term: 10,
#   children: [
#     %ExRoseTree{term: 1, children: []},
#     %ExRoseTree{term: 2, children: []},
#     %ExRoseTree{term: 3, children: []},
#     %ExRoseTree{term: 40, children: []},
#     %ExRoseTree{term: 5, children: []}
#   ]
# }
```

## Testing

While great pains have been taken to provide extensive test coverage--over 800 tests at present, this library is still in its infancy and
is not yet used in a production setting. 

## Contributions & Further Development

Additional functionality may be useful to add, including diffing algorithms, multiple cursor support (ie: multiple, concurrent
contexts on a Zipper), LiveBook examples, visualizations of the many traversal functions, improvements to the generators, more unit tests, performance improvements, and so on. I'm open to any and all ideas and contribution here, so don't hesitate to pipe in, and please be sure to follow our [Code of Conduct](./CODE_OF_CONDUCT.md).

## Copyright and License

Copyright (c) 2022-present, Paraclade, LLC.

ExRoseTree source code is licensed under the [Apache License 2.0](./LICENSE).

<!-- README END -->



