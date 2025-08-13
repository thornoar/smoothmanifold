#set page("a4", margin: 0.5in, numbering: "1")
#set text(size: 11pt, font: "New Computer Modern")

#show link: it => {
  if (type(it.dest) == str) {
    set text(blue)
    it
  } else { it }
}

#set figure(gap: 1em)
#set footnote(numbering: "*")

#let rawblock = block.with(
  stroke: (left: 1pt),
  inset: (left: 10pt, top: 1pt, bottom: 3pt, right: 0pt),
  radius: 0pt,
  breakable: false,
)
#set raw(lang: "c")
#show raw.where(block: true): rawblock

#set grid(align: horizon, gutter: 2em)
#show grid: it => block(fill: color.rgb(100%, 100%, 85%), width: 100%, inset: 1em, it)
#show image: it => block(fill: color.white, it)

// #set list(marker: ([•], [#math.minus.circle], [–]))

#align(center)[
  #set text(size: 18pt)
  `smoothmanifold.asy - v6.3.0` \ #v(0pt)
  Diagrams in higher mathematics with Asymptote\
  #set text(size: 15pt)
  by Roman Maksimovich
  #v(1fr)
  #image("./resources/logo.svg")
  #v(1fr)
]
#pagebreak()

#set heading(numbering: none)
= Abstract

This document contains the full description and user manual to the `smoothmanifold` Asymptote module, home page https://github.com/thornoar/smoothmanifold.

#outline()

#set heading(numbering: "1.")
= Introduction

In higher mathematics, diagrams often take the form of "blobs" (representing sets and their subsets) placed on the plane, connected with paths or arrows. This is particularly true for set theory and topology, but other more advanced fields inherit this style. In differential geometry, one draws spheres, tori, and other surfaces in place of these "blobs". In category theory, commutative diagrams are commonplace, where the "blobs" are replaced by symbols. Here are a couple of examples, all drawn with `smoothmanifold`:

#v(1em)
#[
  #show: it => columns(2, gutter: 0%, it)
  #figure(
    image("./resources/injection.svg"),
    caption: [An illustration of non-injectivity\ (set theory)]
  ) <injection>
  #colbreak()
  #figure(
    image("./resources/tangent.svg"),
    caption: [Tangent space at a point on a manifold (diff. geometry)]
  ) <tangent>
]
#v(1em)
#figure(
  image("./resources/baire-category-theorem.svg"),
  caption: [The proof of the Baire category theorem (topology)]
) <baire>
#v(1em)

Take special note of the gaps that paths leave on already drawn paths upon every intersection. I find this feature quite hard to achieve in plain Asymptote, and module `smoothmanifold` uses some dark magic to implement it. Similarly, note the shaded areas on @baire. They represent _intersections_ of areas bounded by two paths. Finding the bounding path of such an intersection is non-trivial and also implemented in `smoothmanifold`. Lastly, @tangent shows a three-dimensional surface, while the picture was fully drawn in 2D. The illusion is achieved through these cross-sectional "rings" on the left of the diagram.\
To summarize, the most prominent features of module `smoothmanifold` are the following:

- *Gaps in overlapping paths*, achieved through a system of deferred drawing;
- *Set operations on paths bounding areas*, e.g. intersection, union, set difference, etc.;
- *Three-dimensional drawing*, achieved through an automatic (but configurable) addition of cross sections to smooth objects.

Do take a look at the #link("https://github.com/thornoar/smoothmanifold/tree/master/documentation/resources", [source code]) for the above diagrams, to get a feel for how much heavy lifting is done by the module, and what is required from the user. We will now consider each of the above mentioned features (and some others as well) in full detail.

= Deferred drawing and path overlapping

== The general mechanism

In the `picture` struct, the paths drawn to a picture are not stored in an array, but rather indirectly stored in a `void` callback. That is, when the `draw` function is called, the _instruction to draw_ the path is added to the picture, not the path itself. This makes it quite impossible to "modify the path after it is drawn". To go around this limitation, `smoothmanifold` introduces an auxiliary struct:
```
struct deferredPath {
    path[] g;
    pen p;
    int[] under;
    tarrow arrow;
    tbar bar;
}
``` <deferredPath>
It stores the path(s) to draw later, and how to draw them. Now, `smoothmanifold` executes the following steps to draw a "mutable" path `p` to a picture `pic` and then draw it for real:
+ Construct a `deferredPath` based on `p`, say `dp`;
+ Exploit the `nodes` field of the `picture` struct to store an integer. Retrieve this integer, say `n`, from `pic`, with #v(-5pt)
  ```
  int extractdeferredindex (picture pic) { ... }
  ```
+ Store the deferred path `dp` in a global two-dimensional array, under index `n`;
+ Modify the deferred path `dp` as needed, e.g. add gaps;
+ At shipout time, when processing the picture `pic`, retrieve the index `n` from its `nodes` field and draw all `deferredPath` objects in the two-dimensional array at index `n`.
All these steps require no extra input from the user, since the shipout function is redefined to do them automatically. One only needs to use the `fitpath` function instead of `draw`.

== The `tarrow` and `tbar` structs

Similarly to drawing paths to a picture, arrows and bars are implemented through a function type `bool(picture, path, pen, margin)`, typedef'ed as `arrowbar`. Moreover, when this arrowbar is called, it automatically draws not only itself, but also the path is was attached to. This makes it impossible to attach an arrowbar to a path and then mutate the path --- the arrowbar will remember the path's original state. Hence, `smoothmanifold` implements custom arrow/bar implementations:
#[
  #show: it => columns(2, gutter: 0pt, it)
  ```
  struct tarrow {
      arrowhead head;
      real size;
      real angle;
      filltype ftype;
      bool begin;
      bool end;
      bool arc;
  }
  ```
  #colbreak()
  ```
  struct tbar {
      real size;
      bool begin;
      bool end;
  }
  ```
]

These structs store information about the arrow/bar, and are converted to regular arrowbars when the corresponding path is drawn to the picture. For creating new `tarrow`/`tbar` instances and converting them to arrowbars, the following functions are available:

#[
  #show: it => columns(2, gutter: 0pt, it)
  ```
  tarrow DeferredArrow(
      arrowhead head = DefaultHead,
      real size = 0,
      real angle = arrowangle,
      bool begin = false,
      bool end = true,
      bool arc = false,
      filltype filltype = null
  )

  arrowbar convertarrow(
      tarrow arrow,
      bool overridebegin = false,
      bool overrideend = false
  )
  ```
  #colbreak()
  ```
  tbar DeferredBar(
      real size = 0,
      bool begin = false,
      bool end = false
  )

  arrowbar convertbar(
      tbar bar,
      bool overridebegin = false,
      bool overrideend = false
  )
  ```
]

The `overridebegin` and `overrideend` options let the user force disable the arrow/bar at the beginning/end of the path.

== The `fitpath` function

This is a substitute for the plain `draw` function. The `fitpath` function implements steps 1-4 of the deferred drawing system describes above.

```
void fitpath (picture pic, path gs, bool overlap, int covermode, bool drawnow, Label L, pen p, tarrow arrow, tbar bar)
``` <fitpath>
Arguments:
- `pic` --- the picture to fit the path to;
- `gs` --- the path to fit;
- `overlap` --- whether to let the path overlap the previously fit paths. A value of `false` will lead to gaps being left in all paths that `gs` intersects;
- `covermode` --- if the path `gs` is cyclic, this option lets you decide what happens to the parts of previously fit paths that fall "inside" of `gs`. Suppose a portion `s` of another path falls inside the cyclic path `gs`. Then
  - `covermode == 2`: The portion `s` will be erased completely;
  - `covermode == 1`: The portion `s` will be "demoted to the background" --- either temporarily removed or drawn with dashes;
  - `covermode == 0`: The portion `s` will be drawn like the rest of the path;
  - `covermode == -1`: If the portion `s` is "demoted", it will be brought "back to the surface", i.e. drawn with solid pen. Otherwise, it will be draw as-is.
  Consider the following example:
  #grid(
    columns: 2,
    image("resources/fitpath-showcase.svg"),
    [
      ```
      import smoothmanifold;
      config.drawing.gaplength = .12;

      path l = (-1.2,-1.2) -- (1.2,1.2);
      path c1 = unitcircle;
      path c2 = scale(.7) * unitcircle;
      path c3 = scale(.4) * unitcircle;

      fitpath(l, red);
      fitpath(c1, blue, covermode = 1);
      fitpath(c2, blue, covermode = -1);
      fitpath(c3, blue, covermode = 0);
      ```
    ]
  )
- `drawnow` --- whether to draw the path `gs` immediately to the picture. When `drawnow == true`, the path `gs` leaves gaps in other paths, but is immutable itself, i.e. later fit paths will not leave any gaps in it. When `drawnow == false`, the path `gs` is not immediately drawn, but rather saved to be mutated and finally drawn at shipout time;
- `L` --- the label to attach to `gs`. This label is drawn to `pic` immediately on call of `fitpath`, unlike `gs`;
- `p` --- the pen to draw `gs` with;
- `arrow` --- the arrow to attach to the path. A custom `tarrow` struct is used;
- `bar` --- the bar to attach to the path. A custom `tbar` struct is used;
