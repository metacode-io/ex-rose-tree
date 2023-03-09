## ExRoseTree :: A Rose Tree and Zipper in Elixir with a slew of navigation primitives.

[![Build Status](https://github.com/StoatPower/ex-rose-tree/actions/workflows/elixir.yml/badge.svg)](https://github.com/StoatPower/ex-rose-tree/actions/workflows/elixir.yml)

### Documentation

API documentation is available at https://hexdocs.pm/ex_rose_tree.

<!-- README START -->

A Rose Tree with Functional Zipper in Elixir

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
* data visualization (org charts, family trees, taxonomies, nested menus)

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

## Testing and Disclaimer

While great pains have been taken to provide extensive test coverage--over 800 
tests at present, this library is still pre-1.0, so be sure to do your due diligence 
for your own use case. 

To run the test suite:

```bash
$ mix deps.get
$ mix test
```

To run test coverage with [excoveralls](https://github.com/parroty/excoveralls):

```bash
$ mix deps.get
$ mix coveralls
```

or for HTML output:

```bash
$ mix deps.get
$ MIX_ENV=test mix coveralls.html
```

<!-- README END -->

## Contributions, Issues, and Further Development

Additional functionality and work to explore adding include:

* Tree diffing and merging algorithms
* Multiple cursor support (i.e.: multiple, concurrent contexts on a Zipper)
* LiveBook examples
* Visualizations of the many traversal functions
* Improvements to the generators
* Even more unit tests, including property tests
* Performance improvements and benchmarks
* Change tracking and pluggable backends for persistence
* Documentation, guide, and example improvement, clarification, and cohesion

We're open to any and all ideas and thoughtful [contribution](/CONTRIBUTING.md) here, 
so don't hesitate to pipe in, but please be sure to follow our [Code of Conduct](/CODE_OF_CONDUCT.md). 
If you find a bug or it doesn't quite meet your needs without feature X, consider 
opening an issue in the issues tracker. 

## Thanks

A big thanks to [@zwilias](https://github.com/zwilias) and his Elm package 
[elm-rosetree](https://github.com/zwilias/elm-rosetree/tree/1.5.0) for the 
initial inspiration in building this library. 

## Copyright and License

Copyright (c) 2022-present, Paraclade, LLC.

ExRoseTree source code is licensed under the [Apache License 2.0](/LICENSE).



