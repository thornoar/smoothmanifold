#import "@preview/in-dexter:0.7.2": *
#let ind = index.with(fmt: raw, apply-casing: false)

#set page("a4", margin: 0.5in, numbering: "1")
#set text(size: 11pt, font: "New Computer Modern")
#show raw: it => context {
  set text(
    font: "New Computer Modern Mono",
    size: text.size * 1.25,
  )
  it
}

#show link: it => {
  if (type(it.dest) == str) {
    set text(blue)
    it
  } else { it }
}

#set figure(gap: 1em)
#set footnote(numbering: "*")

#let paleyellow = color.rgb(100%, 100%, 85%)

#let rawblock = block.with(
  stroke: (left: .7pt),
  fill: paleyellow,
  width: 100%,
  inset: (left: 8pt, top: 5pt, bottom: 6pt, right: 0pt),
  radius: 0pt,
  breakable: false,
)
#show raw.where(block: true): it => {
  set par(leading: 6pt)
  rawblock(it)
}

#show figure: it => { v(.5em); it; v(.5em) }

#let example(img, code, caption) = figure(
  gap: .7em,
  block(
    width: 100%,
    inset: 0em,
    grid(
      align: horizon + left,
      gutter: 1.5em,
      columns: 2,
      block(fill: color.white, img),
      code
    )
  ),
  caption: caption
)

#let vs = v(-6pt)
#let bl = block.with(breakable: false)
#let point = {
  set text(stroke: .2pt, size: 11pt)
  box(move(
    rotate(90deg, math.arrow.l.curve, origin: center + horizon),
    dx: 0pt, dy: -3pt
  ))
}
// #let point = image("resources/arrow.svg")
// #let point = [⤴]

#set ref(form: "page", supplement: "page")
#show ref.where(form: "page"): it => context {
  let inter = query(it.target)
  if (inter.len() == 0) {
    panic("Non-existent reference: " + str(it.target))
  }
  else if (query(it.target).first().func() == raw) {
    set text(color.rgb(100%,0%,0%))
    [\[#it\]]
  } else {
    ref(it.target, form: "normal", supplement: auto)
  }
}

#align(center)[
  #set text(size: 17pt)
  `smoothmanifold.asy - v6.3.1` \ #v(0pt)
  #set text(size: 18pt)
  Diagrams in higher mathematics with Asymptote\
  #set text(size: 14pt)
  by Roman Maksimovich
  #v(1fr)
  #image("./resources/logo.svg")
  #v(1fr)
]
#set raw(lang: "c")
// #show raw: set text(size: 11pt)
#pagebreak()

#set heading(numbering: none)
= Abstract

This document contains the full description and user manual to the `smoothmanifold` Asymptote module, home page https://github.com/thornoar/smoothmanifold.

#outline()
#pagebreak()

#set heading(numbering: "1.")
= Introduction <sc-intro>

In higher mathematics, diagrams often take the form of "blobs" (representing sets and their subsets) placed on the plane, connected with paths or arrows. This is particularly true for set theory and topology, but other more advanced fields inherit this style. In differential geometry and multivariate calculus, one draws spheres, tori, and other surfaces in place of these "blobs". In category theory, commutative diagrams are commonplace, where the "blobs" are replaced by symbols. Here are a couple of examples, all drawn with `smoothmanifold`:

#[
  #show: columns.with(2, gutter: 0%)
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
#v(-.5em)
#figure(
  image("./resources/baire-category-theorem.svg"),
  caption: [The proof of the Baire category theorem (topology)]
) <baire>

Take special note of the gaps that arrows leave on the boundaries of the ovals on @injection. I find this feature quite hard to achieve in plain Asymptote, and module `smoothmanifold` uses some dark magic to implement it. Similarly, note the shaded areas on @baire. They represent intersections of areas bounded by two paths. Finding the bounding path of such an intersection is non-trivial and also implemented in `smoothmanifold`. Lastly, @tangent shows a three-dimensional surface, while the picture was fully drawn in 2D. The illusion is achieved through these cross-sectional "rings" on the left of the diagram.\
To summarize, the most prominent features of module `smoothmanifold` are the following:

- *Gaps in overlapping paths*, achieved through a system of deferred drawing;
- *Set operations on paths bounding areas*, e.g. intersection, union, set difference, etc.;
- *Three-dimensional drawing*, achieved through an automatic (but configurable) addition of cross sections to smooth objects.

Do take a look at the #link("https://github.com/thornoar/smoothmanifold/tree/master/documentation/resources", [source code]) for the above diagrams, to get a feel for how much heavy lifting is done by the module, and what is required from the user. We will now consider each of the above mentioned features (and some others as well) in full detail.

= Deferred drawing and path overlapping <sc-def>

== The general mechanism <sc-def-general>

In the `picture` structure, the paths drawn on a picture are not stored in an array, but rather indirectly stored in a `void` callback. That is, when the `draw` function is called, the _instruction to draw_ the path is added to the picture, not the path itself. This makes it quite impossible to "modify the path after it is drawn". To go around this limitation, `smoothmanifold` introduces an auxiliary structure:
```
struct deferredPath {
    path[] g;
    pen p;
    int[] under;
    tarrow arrow;
    tbar bar;
}
``` <def-deferredPath>
It stores the path(s) to draw later, and how to draw them. Now, `smoothmanifold` executes the following steps to draw a "mutable" path `p` to a picture `pic` and then draw it for real:
+ Have a global two-dimensional array, say `arr`, of `deferredPath`'s;
+ Construct a `deferredPath` based on `p`, say `dp`;
+ Exploit the `nodes` field of the `picture` structure to store an integer. Retrieve this integer, say `n`, from `pic` (or create one if the `nodes` field doesn't contain it).
+ Store the deferred path `dp` in the one-dimensional array `arr[n]`;
+ Move on with the original code, perhaps modifying the deferred path `dp` in `arr` as needed, e.g. adding gaps;
+ At shipout time, when processing the picture `pic`, retrieve the index `n` from its `nodes` field and draw all `deferredPath` objects in the array `arr[n]`.
All these steps require no extra input from the user, since the shipout function is redefined to do them automatically. One only needs to use the `fitpath` function instead of `draw`.

== The `tarrow` and `tbar` structures <sc-def-tarrow-tbar>

Similarly to drawing paths to a picture, arrows and bars are implemented through a function type `bool(picture, path, pen, margin)`, typedef'ed as `arrowbar`. Moreover, when this arrowbar is called, it automatically draws not only itself, but also the path is was attached to. This makes it impossible to attach an arrowbar to a path and then mutate the path --- the arrowbar will remember the path's original state. Hence, `smoothmanifold` implements custom arrow/bar implementations:
#block(breakable: false)[
  #show: columns.with(2, gutter: 0pt)
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
  ``` <def-tarrow>
  #colbreak()
  ```
  struct tbar {
      real size;
      bool begin;
      bool end;
  }
  ``` <def-tbar>
]

These structures store information about the arrow/bar, and are converted to regular arrowbars when the corresponding path is drawn to the picture. For creating new `tarrow`/`tbar` instances and converting them to arrowbars, the following functions are available:

#bl[
  #show: columns.with(2, gutter: 0pt)
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
  ``` <def-tarrow-func>
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
  ``` <def-tbar-func>
]
The `overridebegin` and `overrideend` options let the user force disable the arrow/bar at the beginning/end of the path.

== The `fitpath` function <sc-def-fitpath>

This is a substitute for the plain `draw` function. The `fitpath` function implements steps 1-4 of the deferred drawing system describes above.

```
void fitpath (picture pic, path gs, bool overlap, int covermode, bool drawnow, Label L, pen p, tarrow arrow, tbar bar)
``` <def-fitpath>
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
  #example(
    image("resources/fitpath-showcase.svg"),
    [
      ```
      import smoothmanifold;
      path l = (-1.2,-1.2) -- (1.2,1.2);
      path c1 = unitcircle;
      path c2 = scale(.7) * unitcircle;
      path c3 = scale(.4) * unitcircle;
      fitpath(l, red);
      fitpath(c1, blue, covermode = 1);
      fitpath(c2, blue, covermode = -1);
      fitpath(c3, blue, covermode = 0);
      ```
    ],
    [A showcase of the `fitpath` function]
  )
- `drawnow` --- whether to draw the path `gs` immediately to the picture. When `drawnow == true`, the path `gs` leaves gaps in other paths, but is immutable itself, i.e. later fit paths will not leave any gaps in it. When `drawnow == false`, the path `gs` is not immediately drawn, but rather saved to be mutated and finally drawn at shipout time;
- `L` --- the label to attach to `gs`. This label is drawn to `pic` immediately on call of `fitpath`, unlike `gs`;
- `p` --- the pen to draw `gs` with;
- `arrow` --- the arrow to attach to the path. Note that the type is `tarrow`, not `arrowbar`;
- `bar` --- the bar to attach to the path. Note that the type is `tbar`, not `arrowbar`.

Apart from different types of the `arrow`/`bar` arguments, the `fitpath` function is identical to `draw` in type signature, and they can be used interchangeably. Moreover, there are overloaded versions of `fitpath`, where parameters are given default values (one of these versions is used in the example above):
#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  void fitpath (
      picture pic = currentpicture,
      path g,
      bool overlap = config.drawing.overlap,
      int covermode = 0,
      Label L = "",
      pen p = currentpen,
      bool drawnow = config.drawing.drawnow,
      tarrow arrow = null,
      tbar bar = config.arrow.currentbar
  )
  ```<def-fitpath-spec>
  #colbreak()
  ```
  void fitpath (
      picture pic = currentpicture,
      path[] g,
      bool overlap = config.drawing.overlap,
      int covermode = 0,
      Label L = "",
      pen p = currentpen,
      bool drawnow = config.drawing.drawnow
  )
  ```<def-fitpath-array>
]

Here, `config` is the global configuration structure, see @sc-config. Furthermore, there are corresponding `fillfitpath` <def-fillfitpath> functions that serve the same purpose as `filldraw`.

== Other related routines <deferred-misc>

```
int extractdeferredindex (picture pic)
```<def-extractdeferredindex> #vs
Inspect the `nodes` field of `pic` for a string in a particular format, and, if it exists, extract an integer from it.

```
deferredPath[] extractdeferredpaths (picture pic, bool createlink)
```<def-extractdeferredpaths> #vs
Extract the deferred paths associated with the picture `pic`. If `createlink` is set to `true` and `pic` has no integer stored in its `nodes` field, the routine will find the next available index and store it in `pic`.

```
path[] getdeferredpaths (picture pic = currentpicture)
```<def-getdeferredpaths> #vs
A wrapper around `extractdeferredpaths`, which concatenates the `path[] g` fields of the extracted deferred paths.

```
void purgedeferredunder (deferredPath[] curdeferred)
```<def-purgedeferredunder> #vs
For each deferred path in `curdeferred`, delete the segments that are "demoted" to the background (i.e. going under a cyclic path, drawn with dashed lines).

```
void drawdeferred (
    picture pic = currentpicture,
    bool flush = true
)
```<def-drawdeferred> #vs
Render the deferred paths associated with `pic`, to the picture `pic`. If `flush` is `true`, delete these deferred paths.

```
void flushdeferred (picture pic = currentpicture)
```<def-flushdeferred> #vs
Delete the deferred paths associated with `pic`.

```
void plainshipout (...) = shipout;
shipout = new void (...)
{
    drawdeferred(pic = pic, flush = false);
    draw(pic = pic, debugpaths, red+1);
    plainshipout(prefix, pic, orntn, format, wait, view, options, script, lt, P);
};
```<def-shipout> #vs
A redefinition of the `shipout` function to automatically draw the deferred paths at shipout time. For a definition of `debugpaths`, see @sc-smooth-subset.

The functions `erase`, `* (transform, picture)`, `add`, `save`, and `restore` are redefined to automatically handle deferred paths.

= Operations on paths <sc-path>

== Set operations on bounded regions <sc-path-set>

Module `smoothmanifold` defines a routine called `combination` which, given two _cyclic_ paths `p` and `q`, calculates a result path which encloses a region that is a combination of the regions `p` and `q`:

```
path[] combination (path p, path q, int mode, bool round, real roundcoeff)
``` <path-combination>

This function returns an array of paths because the combination of two bounded regions may be bounded by multiple paths. Rundown of the arguments:
- `p` and `q` --- cyclic paths bounding the regions to combine;
- `mode` --- an internal parameter which allows to specialize `combination` for different purposes;
- `round` and `roundcoeff` --- whether to round the sharp corners of the resulting bounding path(s).
  #example(
    image("resources/round-showcase.svg"),
    ```
    <...>
    filldraw(
        combination(p, q, 1, false, 0), // <- no rounding
        drawpen = linewidth(.7),
        fillpen = palegrey
    );
    <...>
    <...>
    filldraw(
        combination(p, q, 1, true, .04), // <- yes rounding
        drawpen = linewidth(.7),
        fillpen = palegrey
    );
    <...>
    ```,
    [A showcase of the `round` and `roundcoeff` parameters]
  )

Based on different values for the `mode` parameter, the module defines the following specializations:

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] difference (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-difference>
  #colbreak()
  ```
  path[] operator - (path p, path q)
  { return difference(p, q); }

  path[] operator - (path[] p, path q)
  { return difference(p, q); }
  ``` <path-set-difference-operator>
]#vs
Calculate the path(s) bounding the set difference of the regions bounded by `p` and `q`. The `correct` parameter determines whether the paths should be "corrected", i.e. oriented clockwise.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] symmetric (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-symmetric>
  #colbreak()
  ```
  path[] operator :: (path p, path q)
  { return symmetric(p, q); }
  ``` <path-set-symmetric-operator>
]#vs
Calculate the path(s) bounding the set symmetric difference of the regions bounded by `p` and `q`.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] intersection (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-intersection>
  #colbreak()
  ```
  path[] operator ^ (path p, path q)
  { return intersection(p, q); }
  ``` <path-set-intersection-operator>
]#vs
Calculate the path(s) bounding the set intersection of the regions bounded by `p` and `q`. The following array versions are also available:

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] intersection (
    path[] ps,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-intersection-array>
  #colbreak()
  ```
  path[] intersection (
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... path[] ps
  )
  ``` <path-set-intersection-array-dots>
]#vs

Inductively calculate the total intersection of an array of paths.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] union (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-union>
  #colbreak()
  ```
  path[] operator | (path p, path q)
  { return union(p, q); }
  ``` <path-set-union-operator>
]#vs
Calculate the path(s) bounding the set union of the regions bounded by `p` and `q`. The corresponding array versions are available:

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  path[] union (
    path[] ps,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
  )
  ``` <path-set-union-array>
  #colbreak()
  ```
  path[] union (
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... path[] ps
  )
  ``` <path-set-union-array-dots>
]#vs
Inductively calculate the total union of an array of paths. Here is an illustration of the specializations:

#v(-.5em)
#figure(
  [
    #let item(img, lab) = grid(
      align: center,
      gutter: 1em,
      img,
      lab
    )
    #let frame(lab) = block(inset: 3pt, fill: paleyellow, lab)
    #set raw(lang: none)
    #grid(
      columns: 4,
      gutter: 1fr,
      item(image("resources/combination-difference.svg"), frame(`difference(p,q)`)),
      item(image("resources/combination-symmetric.svg"), frame(`symmetric(p,q)`)),
      item(image("resources/combination-intersection.svg"), frame(`intersection(p,q)`)),
      item(image("resources/combination-union.svg"), frame(`union(p,q)`))
    )
  ],
  caption: [Different specializations of the `combination` function]
)

== Other path utilities <sc-path-misc>

Module `smoothmanifold` features dozens of useful auxiliary path utilities, all of which are listed below.

```
path[] convexpaths = { ... }
path[] concavepaths = { ... }
``` <path-defaultpaths> #vs
Predefined collections of convex and concave paths (14 and 7 paths respectively), added for user convenience.

```
path randomconvex ()
path randomconcave ()
``` <path-randomdefault> #vs
Allows the user to sample a random path from the above arrays.

```
path ucircle = reverse(unitcircle);
path usquare = (1,1) -- (1,-1) -- (-1,-1) -- (-1,1) -- cycle;
``` <path-upaths> #vs
Slightly changed versions of the `unitcircle` and `unitsquare` paths. Most notably, these are _clockwise,_ since most of this module-s functionality prefers to deal with clockwise paths.

```
pair center (path p, int n = 10, bool arc = true, bool force = false)
``` <path-center> #vs
Calculate the center of mass of the region bounded by the cyclic path `p`. If `force` is `false` and the center of mass is outside of `p`, the routine uses a heuristic to return another point, inside of `p`.

```
bool insidepath (path p, path q)
``` <path-insidepath> #vs
Check if path `q` is completely inside the cyclic path `p` (directions of `p` and `q` do not matter).

```
real xsize (path p) { return xpart(max(p)) - xpart(min(p)); }
real ysize (path p) { return ypart(max(p)) - ypart(min(p)); }
``` <path-size> #vs
Calculate the horizontal and vertical size of a path.

```
real radius (path p) { return (xsize(p) + ysize(p))*.25; }
``` <path-radius> #vs
Calculate the approximate radius of the region enclosed by `p`.

```
real arclength (path g, real a, real b) { return arclength(subpath(g, a, b)); }
``` <path-arclength> #vs
A more general version of `arclength`.

```
real relarctime (path g, real t0, real a)
``` <path-relarctime> #vs
Calculate the time at which arc length `a` will be traveled along the path `g`, starting from time `t0`.

```
path arcsubpath (path g, real arc1, real arc2)
``` <path-arcsubpath> #vs
Calculate the subpath of `g`, starting from arc length `arc1`, and ending with arc length `arc2`.

```
real intersectiontime (path g, pair point, pair dir)
``` <path-intersectiontime> #vs
Calculate the time of the intersection of `g` with a beam going from `point` in direction `dir`

```
pair intersection (path g, pair point, pair dir)
``` <path-intersection> #vs
Same as `intersectiontime`, but returns the point instead of the intersection time.

```
path reorient (path g, real time)
``` <path-reorient> #vs
Shift the starting point of the cyclic path `g` by time `time`. The resulting path will be same as `g`, but will start from time `time` along `g`.

```
path turn (path g, pair point, pair dir)
{ return reorient(g, intersectiontime(g, point, dir)); }
``` <path-turn> #vs
A combination of `reorient` and `intersectiontime`, that shifts the starting point of the cyclic path `g` to its intersection with the ray cast from `point` in the direction `dir`.

```
path subcyclic (path p, pair t)
``` <path-subcyclic> #vs
Calculate the subpath of the _cyclic_ path p, from time `t.x` to time `t.y`. If `t.y < t.x`, the subpath will still go in the direction of `g` instead of going backwards.

```
bool clockwise (path p)
``` <path-clockwise> #vs
Determine if the cyclic path `p` is going clockwise.

```
bool meet (path p, path q) { return (intersect(p, q).length > 0); }
bool meet (path p, path[] q) { ... }
bool meet (path[] p, path[] q) { ... }
``` <path-meet> #vs
A shorthand function to determine if two (or more) paths have an intersection point.

```
pair range (path g, pair center, pair dir, real ang, real orient = 1)
``` <path-range> #vs
Calculate the begin and end times of a subpath of `g`, based on `center`, `dir`, and `angle`, as such:

#figure(
  image("resources/range-showcase.svg"),
  caption: [An illustration of the `range` function]
)

If `orient` is set to `-1` instead of `1`, then the returned times are switched.

```
bool outsidepath (path p, path q)
``` <path-outsidepath> #vs
Check if `q` is completely outside (that is, inside the complement) of the region enclosed by `p`.

```
path ellipsepath (pair a, pair b, real curve = 0, bool abs = false)
``` <path-ellipsepath> #vs
Produce half of an ellipse connecting points `a` and `b`. Curvature may be relative or absolute.

```
path curvedpath (pair a, pair b, real curve = 0, bool abs = false)
``` <path-curvedpath> #vs
Construct a curved path between two points. Curvature may be relative (from $0$ to $1$) or absolute.

```
path cyclepath (pair a, real angle, real radius)
``` <path-cyclepath> #vs
A circle of radius `radius`, starting at `a` and turned at `angle`.

```
path midpath (path g, path h, int n = 20)
``` <path-midpath> #vs
Construct the path going "between" `g` and `h`. The parameter `n` is the number of sample points, the more the more precise the output.
#v(-.5em)
#figure(
  image("resources/midpath-showcase.svg"),
  gap: 1.5em,
  caption: [An illustration of the `midpath` function]
)

```
path connect (pair[] points)
path connect (... pair[] points)
``` <path-connect> #vs
Connect an array of points with a path.

```
path wavypath (real[] nums, bool normaldir = true, bool adjust = false)
path wavypath (... real[] nums)
``` <path-wavypath> #vs
Generate a clockwise cyclic path around the point `(0,0)`, based on the `nums` parameter. If `normaldir` is set to `true`, additional restrictions are imposed on the path. If `adjust` is `true`, then the path is shifted and scaled such that its `center` @path-center is `(0,0)`, and its `radius` @path-radius is `1`. Consider the following example:
#example(
  image("resources/wavypath-showcase.svg"),
  ```
  real[] nums = {1,2,1,3,2,3,4};
  bool normaldir = true;

  draw(wavypath(nums, normaldir));

  for (int i = 0; i < nums.length; ++i) {
    <...> // draw numbers
  }

  dot((0,0));
  ```,
  [A showcase of the `wavypath` function]
)

```
path connect (path p, path q)
``` <path-connect-pq> #vs
Connect the paths `p` and `q` smoothly.

```
pair randomdir (pair dir, real angle)
{ return dir(degrees(dir) + (unitrand()-.5)*angle); }
path randompath (pair[] controlpoints, real angle)
``` <path-randomdirpath> #vs
Create a pseudo-random path passing through the `controlpoints`. The `angle` parameter determines the "spread" of randomness. Here's an example:

#figure(
  image("resources/randompath-showcase.svg"),
  caption: [A showcase of the `randompath` function]
)

```
path neigharc (
    real x = 0,
    real h = config.paths.neighheight,
    int dir = 1,
    real w = config.paths.neighwidth
)
``` <path-neigharc> #vs
Draw an "open neighborhood bracket" on the real line, like so:
#figure(
  image("resources/neigharc-showcase.svg"),
  caption: [A showcase of the `neigharc` function]
)

= Smooth objects <sc-smooth>

== Definition of the `smooth`, `hole`, `subset`, and `element` structures <sc-smooth-ho-su-el>

The `smoothmanifold` module's original purpose was to introduce a suitable abstraction to simplify drawing blobs on the plane. The `smooth` structure is, perhaps, the oldest part of `smoothmanifold`, that has persisted through countless updates and changes. In its current form, here is how it's defined:

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  struct smooth {
      path contour;
      pair center;

      string label;
      pair labeldir;
      pair labelalign;

      hole[] holes;
      subset[] subsets;
      element[] elements;

      transform unitadjust;

      real[] hratios;
      real[] vratios;

      bool isderivative;

      smooth[] attached;

      void drawextra (dpar, smooth);

      static smooth[] cache;
  }
  ``` <smooth-smooth>
  #colbreak()
  ```
  struct hole {
      path contour;
      pair center;
      real[][] sections;
      int scnumber;
  }

  struct subset {
      path contour;
      pair center;
      string label;
      pair labeldir;
      pair labelalign;
      int layer;
      int[] subsets;
      bool isderivative;
      bool isonboundary;
  }

  struct element {
      pair pos;
      string label;
      pair labelalign;
  }
  ``` <smooth-ho-su-el>
]

Every `smooth` object has a:
- `contour` --- the clockwise cyclic path that serves as a boundary of the object;
- `center` --- the center of the object, usually inferred automatically with `center(contour)` @path-center;
- `label` --- a string label, e.g. `"$A$"` or `"$S$"`, that will be displayed when drawing the smooth object;
- `labeldir` and `labelalign` --- they determine where the label is to be drawn, namely at `intersection(contour, center, labeldir)` @path-intersection, with `labelalign` as `align`.
  #figure(
    image("resources/labeldir-showcase.svg"),
    caption: [A showcase of the `labeldir` and `labelalign` fields]
  )
- `holes` --- an array of `hole` structures, each of which has a:
  - `contour` --- the clockwise cyclic boundary of the hole;
  - `center` --- the center of the hole, typically calculated automatically by `center(contour)` @path-center;
  - `sections` --- a two-dimensional array that determines where to draw the cross sections seen on @tangent. For a detailed description, see @sc-smooth-modes-free;
  - `scnumber` --- the maximum amount of cross sections that the hole allows other holes to share with it. These are sections _between holes,_ not ones between a hole and the contour of the `smooth` object. For details, see @sc-smooth-modes-free;
- `subsets` --- an array of `subset` structures, each of which has a:
  - `contour` --- the clockwise cyclic boundary of the subset;
  - `center` --- the center of the subset, likewise usually determined by `center(contour)` @path-center;
  - `label`, `labeldir`, `labelalign` --- serve the same purpose as the respective fields of the `smooth` object;
  - `layer` --- an integer determining the "depth" of the subset. A toplevel subset will have `layer == 0`, its subsets will have `layer == 1`, their subsets will have `layer == 2`, etc. This way, a hierarchy of subsets is established. For details, see @sc-smooth-subset;
  - `subsets` --- an index `i` is an element of this array if and only if the subset `subsets[i]` (taken from the `subsets` field of the parent `smooth` object) is a subset of the current subset. For details, see @sc-smooth-subset;
  - `isderivative` --- a flag that marks all automatically created subsets (i.e. those that represent intersections of existing subsets). For details, see @sc-smooth-subset;
  - `isonboundary` --- a flag that marks if the current subset touches the boundary of another subset.
- `elements` --- an array of `element` structures, each of which has a:
  - `pos` --- the position of the element;
  - `label` --- the label attached to the element, e.g. `"$x$"` or `"$y_0$"`;
  - `labelalign` --- how to align the label when drawing the element;
- `unitadjust` --- a transform that converts from unit coordinates of the smooth object to the global user coordinates (see @sc-smooth-unit);
- `hratios` and `vratios` --- two arrays that determine where to draw cross sections in the `cartesian` mode. For details, see @sc-smooth-modes-cartesian;
- `isderivative` --- similarly to `subset`, this field marks those `smooth` objects which are obtained from preexisting objects through operations of intersection, union, etc.;
- `attached` --- this field allows to bind an array of smooth objects to the current one. Drawing the current object will trigger drawing all of its `attached` objects. For example, the tangent space seen on @tangent is `attached` to the main object;
- `drawextra` --- a callback to be executed _after the `smooth` object is drawn._ It takes as parameters a drawing configuration of type `dpar` (see @sc-config-drawing) and the current `smooth` object;
- `static cache` --- a global array of all `smooth` objects constructed so far. It is used mainly to search for smooth objects by label. See @sc-smooth-by-label.

== Construction <sc-smooth-init>

Each of the four structures is equipped with a sophisticated `void operator init` that will infer as much information as possible. To construct a `smooth`, `hole`, or `subset`, it is only necessary to pass a `contour`. All other fields can be set in the constructor, but they are optional. To construct an `element`, it is only necessary to pass a `pos`, the `label` and `labelalign` fields have default values.

== Query and mutation methods <sc-smooth-method>

Already constructed structures can be queried and modified in a plethora of ways. Most methods return `this` at the end of execution for convenience.

=== `smooth` objects

```
real xsize () { return xsize(this.contour); }
real ysize () { return ysize(this.contour); }
``` <smooth-size> #vs
Calculate the vertical and horizontal size of `this`.

```
bool inside (pair x)
``` <smooth-inside> #vs
Check if `x` lies inside the contour of `this`, but not inside any of its `holes`.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth move (
      pair shift = (0,0),
      real scale = 1,
      real rotate = 0,
      pair point = this.center,
      bool readjust = true,
      bool drag = true
  )
  ``` <smooth-move> #vs
  #colbreak()
  ```
  smooth shift (explicit pair shift)

  smooth shift
  (real xshift, real yshift = 0)

  smooth scale (real scale)

  smooth rotate (real rotate)
  ``` <smooth-move-sssr>
] #vs
Scale `this` by `scale` (with center at `point`), rotate by `rotate` around `point`, and then shift by `shift`. If `readjust` is `true`, also recalculate the `unitadjust` field. If `drag` is `true`, also apply the `move` to all smooth objects `attached` to `this`. In the end return `this`. The `shift`, `scale` and `rotate` methods on the right are all specializations of the `move` method.

```
void xscale (real s)
``` <smooth-xscale> #vs
Scale `this` by `s` along the x-axis.

```
smooth dirscale (pair dir, real s)
``` <smooth-dirscale> #vs
Scale `this` by `s` in the direction `dir`. Return `this`.

```
smooth setcenter (
    int index = -1,
    pair center = config.system.dummypair,
    bool unit = config.smooth.unit
)
``` <smooth-setcenter> #vs
Set the center of `this` if `index == -1`, and the center of `this.subsets[index]` otherwise. If `unit` is `true`, interpret `center` in the unit coordinates of `this` (i.e. apply `this.unitadjust` to `center`). For the definition of `config.system.dummypair`, see @sc-config-system.

```
smooth setlabel (
    int index = -1,
    string label = config.system.dummystring,
    pair dir = config.system.dummypair,
    pair align = config.system.dummypair
)
``` <smooth-setlabel> #vs
Set the `label`, `labeldir` and `labelalign` of `this` if `index == -1`, and set these fields of `this.subsets[index]` otherwise. For the definition of `config.system.dummystring`, see @sc-config-system.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth addelement (
      pair pos,
      string label = "",
      pair align = 1.5*S,
      int index = -1,
      bool unit = config.smooth.unit
  )
  ``` <smooth-addelement-spec> 
  #colbreak()
  ```
  smooth addelement (
      element elt,
      int index = -1,
      bool unit = config.smooth.unit
  )
  ``` <smooth-addelement>
] #vs
Add a new element to `this`. Return `this`. If `index >= 0`, then the function will additionally check if the `element` is contained within the contour of `this.subsets[index]`. If `unit` is true, then the position of the `element` is interpreted in `this` object's unit coordinates.

```
smooth setelement (
    int index,
    pair pos = config.system.dummypair,
    string label = config.system.dummystring,
    pair labelalign = config.system.dummypair,
    int sbindex = -1,
    bool unit = config.smooth.unit
)
``` <smooth-setelement> #vs
Change the fields of the element of `this` at index `index`. Return `this`. Slightly different versions of this routine are also defined in the source code, feel free to peruse it.

```
smooth rmelement (int index)
``` <smooth-rmelement> #vs
Delete an element at index `index`. Return `this`.

```
smooth movelement (int index, pair shift)
``` <smooth-movelement> #vs
Move the element at index `index` by `shift`. Return `this`.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth addhole (
      path contour,
      pair center = config.system.dummypair,
      real[][] sections = {},
      pair shift = (0,0),
      real scale = 1,
      real rotate = 0,
      pair point = center(contour),
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  ``` <smooth-addhole-spec>
  #colbreak()
  ```
  smooth addhole (
      hole hl,
      int insertindex = this.holes.length,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  ``` <smooth-addhole>
] #vs
Add a new hole to `this`. If `clip` is `true` and the hole's contour is _not_ contained within `this` object's contour, then clip `this` smooth object's contour using `difference` @path-set-difference, like so:
#figure(
  image("resources/addhole-clip.svg"),
  caption: [A showcase of the `clip` parameter]
)
If `unit` is `true`, then the hole contour will be treated in the unit coordinates, i.e. the `unitadjust` transform will be applied to it. See @sc-smooth-unit for more details.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth addholes (
      hole[] holes,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  smooth addholes (
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
      ... hole[] holes
  )
  ``` <smooth-addholes>
  #colbreak()
  ```
  smooth addholes (
      path[] contours,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  smooth addholes (
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
      ... path[] contours
  )
  ``` <smooth-addholes-spec>
] #vs
Auxiliary routines made for conveniently adding multiple holes at the same time.

```
smooth rmhole (int index = this.holes.length-1)
``` <smooth-rmhole> #vs
Delete the hole under index `index` from `this`.

```
smooth rmholes (int[] indices)
smooth rmholes (... int[] indices)
``` <smooth-rmholes> #vs
Delete a number of holes from `this`.

```
smooth movehole (
    int index,
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    pair point = this.holes[index].center,
    bool movesections = false
)
``` <smooth-movehole> #vs
Move the hole at index `index` by scaling and rotating it around `point`, and shifting it by `shift`. If `movesections` is `true`, the `sections` values of the hole are updated accordingly with the transform. This is only really necessary when `rotate` is non-zero.

#bl[
  #show: columns.with(3, gutter: 0pt)
  ```
  smooth addsection (
      int index,
      real[] section = {}
  )
    
  ``` <smooth-addsection>
  #colbreak()
  ```
  smooth setsection (
      int index,
      int scindex = 0,
      real[] section = {}
  )
  ``` <smooth-setsection>
  #colbreak()
  ```
  smooth rmsection (
      int index =
        this.holes.length-1,
      int scindex = 0
  )
  ``` <smooth-rmsection>
] #vs
Add, set or remove a section under `scindex`
in the hole under `index`. When adding, the section will have to pass the #vs
```
bool checksection (real[] section)
``` <smooth-checksection> #vs
check.

```
smooth addsubset (
    subset sb,
    int index = -1,
    bool inferlabels = config.smooth.inferlabels,
    bool clip = config.smooth.clip,
    bool unit = config.smooth.unit,
    bool checkintersection = true
)
``` <smooth-addsubset> #vs
Add a new subset to `this`. The meaning of the arguments is as follows:
- `sb` --- the subset to add;
- `index` --- the index of another, preexisting subset of `this`, such that `sb` should be made a subset of `this.subsets[index]`. If `index` is `-1`, then `sb` is considered a toplevel subset until found otherwise by containment checks. Essentially, the `index` parameter saves the algorithm some work figuring out where to fit `sb` in the subset hierarchy. See @sc-smooth-subset for more explanation;
- `inferlabels` --- if set to `true`, the intersection subsets arising from the addition of `sb` will be given labels like `"$A \cap B$"`, given that some subsets have labels `"$A$"` and `"$B$"`;
- `clip` --- if set to `false`, this leads to an error whenever `sb`'s contour is out of bounds with `this` object's contour. If `clip` is set to true, then `sb`'s contour is clipped instead, and its `isonboundary` field is set to `true`;
- `unit` --- as usual, setting this to `true` leads to `sb` being interpreted in `this` object's unit coordinates, see @sc-smooth-unit;
- `checkintersection` --- if set to `false`, the routine will _not_ perform out-of-bounds checks. This can significantly increase efficiency when the user is confident in the correctness of the call. But then you only have yourself to blame when your subsets are sticking out of your smooth objects!

```
smooth addsubset (
    int index = -1,
    path contour,
    pair center = config.system.dummypair,
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    pair point = center(contour),
    string label = "",
    pair dir = config.system.dummypair,
    pair align = config.system.dummypair,
    bool inferlabels = config.smooth.inferlabels,
    bool clip = config.smooth.clip,
    bool unit = config.smooth.unit
)
``` <smooth-addsubset-spec> #vs
A convenience routine that creates the subset from given parameters and calls `addsubset` @smooth-addsubset on it.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth addsubsets (
      subset[] sbs,
      int index = -1,
      bool inferlabels = config.smooth.inferlabels,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  smooth addsubsets (
      int index = -1,
      bool inferlabels = config.smooth.inferlabels,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
      ... subset[] sbs
  )
  ``` <smooth-addsubsets>
  #colbreak()
  ```
  smooth addsubsets (
      path[] contours,
      int index = -1,
      bool inferlabels = config.smooth.inferlabels,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
  )
  smooth addsubsets (
      int index = -1,
      bool inferlabels = config.smooth.inferlabels,
      bool clip = config.smooth.clip,
      bool unit = config.smooth.unit
      ... path[] contours
  )
  ``` <smooth-addsubsets-spec>
] #vs
Further convenience routines that allow adding multiple subsets.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth rmsubset (
      int index = this.subsets.length-1,
      bool recursive = true
  )
    
  ``` <smooth-rmsubset>
  #colbreak()
  ```
  smooth rmsubsets (
      int[] indices,
      bool recursive = true
  )
  // (... int[] indices)
  ``` <smooth-rmsubsets>
] #vs
Remove one or more subsets from `this`. If `recursive` is set to `true`, then all subsets of the removed subset shall also be removed.

```
smooth movesubset (
    int index = this.subsets.length-1,
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    pair point = config.system.dummypair,
    bool movelabel = false,
    bool recursive = true,
    bool bounded = true,
    bool clip = config.smooth.clip,
    bool inferlabels = config.smooth.inferlabels,
    bool keepview = true
)
``` <smooth-movesubset> #vs
Move the subset at index `index` (say, `sb`), scaling and rotating it around `point`, and then shifting it by `shift`. The meaning of the `bool` parameters is as follows:
- `movelabel` --- if set to `true`, the `labeldir` of `sb` is rotated with the subset itself;
- `recursive` --- if set to `true`, all subsets of `sb` are moved as well;
- `bounded` --- if set to `true`, the movement of `sb` is restricted by its subsets and supersets;
- `clip` --- if set to `true`, the contour of `sb` will be clipped if it becomes out-of-bounds as a result of the movement;
- `inferlabels` --- same as the corresponding parameter of the `addsubset` @smooth-addsubset function.

```
smooth attach (smooth sm)
``` <smooth-attach> #vs
Add the smooth object `sm` to the `attached` field of `this`. Return `this`.

```
smooth fit (
    int index = -1,
    picture pic = currentpicture,
    picture addpic,
    pair shift = (0,0)
)
``` <smooth-fit> #vs
Fit an entire picture `pic` into one of the subsets of `this`, namely one under index `index`. If `index` is `-1`, the picture is fit inside the contour of `this`.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth copy ()
  ``` <smooth-copy>
  #colbreak()
  ```
  smooth replicate (smooth sm)
  ``` <smooth-replicate>
] #vs
Perform a deep copy of `this` and return this copy, or deeply copy all fields from another smooth object `sm`, returning `this`.

=== `subset` objects

```
real xsize () { return xsize(this.contour); }
real ysize () { return ysize(this.contour); }
``` <subset-size> #vs
Calculate the vertical and horizontal size of `this`.

```
subset move (transform move)
``` <subset-move> #vs
Move `this` by applying `move` to its `contour`.

```
subset move (pair shift, real scale, real rotate, pair point, bool movelabel)
``` <subset-move-spec> #vs
A more sophisticated version of `move` @subset-move, which accepts the usual `shift`, `scale`, `rotate`, `point` arguments (see `smooth.move` @smooth-move), and moves the subset's `labeldir` based on the `movelabel` flag.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  subset copy ()
  ``` <subset-copy>
  #colbreak()
  ```
  subset replicate (subset s)
  ``` <subset-replicate>
] #vs
Perform a deep copy of `this` and return the copy, or deeply copy all fields of another subset, `s`, into `this`, returning `this`.

=== `hole` objects

```
hole move (transform move)
``` <hole-move> #vs
Move `this` by applying `move` to the hole's `contour`.

```
hole move (pair shift, real scale, real rotate, pair point, bool movesections)
``` <hole-move-spec> #vs
A more sophisticated version of `move` @hole-move, which accepts the usual `shift`, `scale`, `rotate`, `point` arguments (see `smooth.move` @smooth-move), and rotates the sections of `this` (see @sc-smooth-modes-free) if the `movesections` flag is set.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  hole copy ()
  ``` <hole-copy>
  #colbreak()
  ```
  hole replicate (hole h)
  ``` <hole-replicate>
] #vs
Perform a deep copy of `this` and return the copy, or deeply copy all fields of another hole, `h`, into `this`, returning `this`.

=== `element` objects

```
element move (transform move)
``` <element-move> #vs
Move `this` by applying `move` to the element's `contour`.

```
element move (pair shift, real scale, real rotate, pair point, bool movelabel)
``` <element-move-spec> #vs
A more sophisticated version of `move` @element-move, which accepts the usual `shift`, `scale`, `rotate`, `point` arguments (see `smooth.move` @smooth-move), and rotates this element's `labeldir` if the `movelabel` flag is set.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  element copy ()
  ``` <element-copy>
  #colbreak()
  ```
  element replicate (element elt)
  ``` <element-replicate>
] #vs
Perform a deep copy of `this` and return the copy, or deeply copy all fields of another element, `elt`, into `this`, returning `this`.

== The subset hierarchy <sc-smooth-subset>

In general, a system of subsets of a set can form a complicated network of intersections and inclusions. Consider the following example:
#figure(
  image("resources/subset-hierarchy.svg"),
  caption: [An example of many intersecting subsets]
) <subset-hierarchy>

To manage this mess (and to be able to draw the diagram above in under 30 lines of code), `smoothmanifold` employs a _hierarchy of subsets._ This is achieved through every subset having a `layer` field which specifies how deep in the hierarchy it lies (in @subset-hierarchy different layers are colored with different colors). Some points to note:
- The `int[] subsets` field of a subset `sb` structure contains all indices of subsets in the parent `smooth` object, that are direct subsets of `sb`;
- When adding a subset `sb` with `smooth.addsubset` @smooth-addsubset, the algorithm automatically checks its intersections with all other subsets of the smooth object, creating additional subsets, and fits `sb` on the appropriate `layer`.

There are two internally important methods of `smooth`, related to the subset hierarchy:

```
bool onlyprimary (int index)
``` <smooth-onlyprimary> #vs
Determine if the subset of `this` at index `index` only contains "proper" subsets (that is, those that are not intersections of other subsets).

```
bool onlysecondary (int index)
``` <smooth-onlysecondary> #vs
Same as `onlyprimary` @smooth-onlyprimary, but now check if all subsets of `this.subsets[index]` are intersections of other subsets.

You will not be able to `move` @smooth-movesubset a subset, if it contains both primary ("proper") and secondary subsets, since the situation becomes too complicated and I don't know how to resolve it algorithmically. This is the case because moving a subset should trigger a recalculation of the entire subset hierarchy, which is a generally difficult task.

== Unit coordinates in a `smooth` object <sc-smooth-unit>

Sometimes, when working with a `smooth` object, it is easier not to think about where it is located in user coordinates, and assume that its `center` @smooth-smooth is at `(0,0)`, and its `radius` @path-radius is approximately `1`. Module `smoothmanifold` supports a mechanism to allow this, namely the `unitadjust` @smooth-smooth field of the `smooth` structure. It establishes a bridge between the object's "unit coordinates" and the global user coordinates. This field is calculated via

```
transform selfadjust ()
{ return shift(this.center)*scale(radius(this.contour)); }
``` <smooth-selfadjust> #vs
Calculate the unit coordinates of `this`. See `unitadjust` @smooth-smooth for reference.

The unit coordinates of a subset can also be obtained: #vs

```
transform adjust (int index)
``` <smooth-adjust> #vs
Calculate the unit coordinates of the subset of `this` at index `index`. If `index` is set to `-1`, the `unitadjust` field of `this` is used instead.

Now, any method that accepts a `bool unit` parameter, can accept pairs/paths in the parent object's unit coordinates, since it will convert them to global coordinates by applying `unitadjust`.

Another unit-related method of the `smooth` structure is #vs
```
pair relative (pair point)
``` <smooth-relative> #vs
Convert `point` (given in unit coordinates) to a point in global coordinates.

== Reference by label <sc-smooth-by-label>

The global array `smooth.cache` @smooth-smooth gives many opportunities, and one of them is _reference by label._ Given a string `label`, one can loop over the `smooth.cache` array and search for a smooth object with this label. Moreover, one can inspect the subsets and elements of these smooth objects, and compare their labels to `label`. In this way, one can obtain a `smooth`, `subset`, or `element` from their `label`. This gives rise to the following versions of the already familiar `smooth` methods:



```
smooth setcenter (
    string destlabel,
    pair center,
    bool unit = config.smooth.unit
) { return this.setcenter(findlocalsubsetindex(destlabel), center, unit); }
``` <smooth-setcenter-label> #vs
An alternative to `setcenter` @smooth-setcenter, but finds the subset by label.

```
smooth setlabel (
    string destlabel,
    string label,
    pair dir = config.system.dummypair,
    pair align = config.system.dummypair
) { return this.setlabel(findlocalsubsetindex(destlabel), label, dir, align); }
``` <smooth-setlabel-label> #vs
An alternative to `setlabel` @smooth-setlabel, but finds the subset by label.

```
smooth setelement (
    string destlabel,
    pair pos = config.system.dummypair,
    string label = config.system.dummystring,
    pair labelalign = config.system.dummypair,
    bool unit = config.smooth.unit
)
``` <smooth-setelement-label> #vs
An alternative to `setelement` @smooth-setelement, but finds the element by label.

```
smooth rmelement (string destlabel)
``` <smooth-rmelement-label> #vs
An alternative to `rmelement` @smooth-rmelement, but finds the element by label.

```
smooth movelement (string destlabel, pair shift)
``` <smooth-movelement-label> #vs
An alternative to `movelement` @smooth-movelement, but finds the element by label.

```
smooth addsubset (
    string destlabel,
    subset sb,
    bool inferlabels = config.smooth.inferlabels,
    bool clip = config.smooth.clip,
    bool unit = config.smooth.unit
)
``` <smooth-addsubset-label> #vs
An alternative to `addsubset` @smooth-addsubset, but finds the destination subset by label. The specialized versions of `addsubset` also have a label version.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  smooth rmsubset (
      string destlabel,
      bool recursive = true
  )
    
  ``` <smooth-rmsubset-label>
  #colbreak()
  ```
  smooth rmsubsets (
      string[] destlabels,
      bool recursive = true
  )
  // (... string[] destlabels)
  ``` <smooth-rmsubsets-label>
] #vs
Label-based alternatives to `rmsubset` @smooth-rmsubset and `rmsubsets` @smooth-rmsubsets.

```
smooth movesubset (
    string destlabel,
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    pair point = config.system.dummypair,
    bool movelabel = false,
    bool recursive = true,
    bool bounded = true,
    bool clip = config.smooth.clip,
    bool inferlabels = config.smooth.inferlabels,
    bool keepview = true
)
``` <smooth-movesubset-label> #vs
A label-based alternative of `movesubset` @smooth-movesubset.

These are methods that facilitate the correct finding of objects by label:
```
static bool repeats (string label)
``` <smooth-repeats> #vs
Check if `label` already exists as a label of some `smooth`, `subset`, or `element` object.
#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  int findlocalsubsetindex (string label)
  ``` <smooth-findlocalsubsetindex>
  #colbreak()
  ```
  int findlocalelementindex (string label)
  ``` <smooth-findlocalelementindex>
] #vs
Locate a subset of `this` by its label and return its index.

As a final step, module `smoothmanifold` defines a number of conversion routines to find objects by label:

```
smooth findsm (string label)
``` <smooth-find> #vs
Find a `smooth` object by its `label`.

```
subset findsb (string label)
``` <subset-find> #vs
Find a `subset` by its `label`.

```
element findelt (string label)
``` <element-find> #vs
Find an `element` by its `label`.

These routines rely on the following auxiliary internal functions: #vs
```
int findsmoothindex (string label)
int[] findsubsetindex (string label)
int[] findelementindex (string label)
``` <smooth-findindex> #vs
Inspect the `smooth.cache` array for `label` and return the relevant index/indices.

Up until recently module `smoothmanifold` supported three `operator cast` routines that could cast strings to `smooth`, `subset`, and `element` structures. However, I have recently realized that this may easily lead to ambiguity in function calls, and so now the module encourages the direct use of the `findsm`, `findsb` and `findelt` routines.

== The modes of cross section drawing <sc-smooth-modes>

Cross sections (as seen in @tangent) are meant to create the illusion of 3D in a 2D diagram. They typically connect the contours of an object's holes with the contour of the object itself. These sections can be drawn in various modes. Compare:
#figure(
  [
    #let item(img, lab) = grid(
      align: center,
      gutter: 1em,
      img,
      lab
    )
    #let frame(lab) = block(inset: 3pt, fill: paleyellow, lab)
    #set raw(lang: none)
    #grid(
      columns: 4,
      gutter: 1fr,
      item(image("resources/mode-plain-showcase.svg"), frame([`plain` mode])),
      item(image("resources/mode-free-showcase.svg"), frame([`free` mode])),
      item(image("resources/mode-cartesian-showcase.svg"), frame([`cartesian` mode])),
      item(image("resources/mode-combined-showcase.svg"), frame([`combined` mode])),
    )
  ],
  caption: [Different modes of drawing cross sections]
) <modes-showcase>

We will now explain how each mode is implemented.

=== The `plain` mode <sc-smooth-modes-plain>

This is the simplest mode --- no sections at all. It is the default mode, since most of `smoothmanifold` diagrams (despite the name of the module) are purely 2D.

=== The `free` mode <sc-smooth-modes-free>

This mode makes use of the `real[][] sections` field of the `hole` @smooth-ho-su-el structure. Each member of this two-dimensional array is an array `{d, a, n}` of three `real` numbers, with the following meaning:
- `d` and `a` --- these numbers determine the region where the cross sections are to be drawn. This is done by calling `range(g, ctr, dir(d), a)` @path-range, where `g` is the contour of either the hole or the parent object, and `ctr` is the `center` of the hole;
- `n` --- the number of cross sections to draw. This is supposed to be an integer, and is converted to one with `floor(n)`.

Consider the following example:
#example(
  image("resources/section-showcase.svg"),
  ```
  smooth sm = smooth(
      contour = ucircle
  ).addhole(
      contour = ucircle,
      scale = .5,
      sections = new real[][]{
          {60, 120, 5}, {-90, 50, 3}
      }
  );

  draw(sm, dpar(help = true, mode = free, viewdir = dir(-40)));
  ```,
  [A showcase of the `sections` field of the `hole` structure and how it is used]
) <section-showcase>

(for an explanation of the `dpar` structure seen in the code in @section-showcase, see @sc-smooth-dpar).\
Now, as seen on the second picture in @modes-showcase, cross sections in `free` mode can connect not only the parent object's contour with the hole's contour, but also the contours of two holes. This is achieved through the `int scnumber` field of the `hole` @smooth-ho-su-el structure. It determines how many "inter-hole" sections a hole is willing to support with any other hole. If `hl1` has `hl1.scnumber = 4` and `hl2` has `hl2.scnumber = 2`, then there will be `2` cross sections drawn between `hl1` and `hl2`. In fact, there is a very neat trick. The expression to get the resulting number of holes is #vs
```
abs(min(hl1.scnumber, hl2.scnumber))
``` #vs
meaning that you can set, for example, `hl1.scnumber = -3`, and it will _force_ the number of sections to be `3`, _regardless_ of the value of `hl2.scnumber` (unless it is also negative). In other words,
- setting `hl1.scnumber = -n` guarantees that the number of sections is `n` _or more;_
- setting `hl1.scnumber = n` guarantees that the number of sections is `n` _or less;_

The `free` mode is usually the preferred mode for three-dimensional drawing. Its implementation relies heavily on the following technical routines:

```
path[] sectionellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir)
``` <smooth-sectionellipse> #vs
Return an array of two paths, together composing an ellipse whose center lies on `p1 -- p2`, such that both vectors `dir1`, `dir2`, when starting from `p1` and `p2` respectively, are tangent to the ellipse.
#example(
  image("resources/sectionellipse-showcase.svg"),
  ```
  pair p1 = (1,0), p2 = (4,0);
  pair dir1 = dir(55), dir2 = dir(140);
  pair viewdir = .2*dir(90);

  path[] ell = sectionellipse(
    p1, p2, dir1, dir2, viewdir
  );

  // Drawing it in pretty colors
  ```,
  [An illustration of the output of the `sectionellipse` function]
) <sectionellipse-showcase>
The `viewdir` parameter represents "direction of view", it helps coordinate the tilt angles of all section ellipses in a picture to maintain the illusion of 3D.\
This algorithm uses either an $O(1)$ formula, if `config.section.elprecision` (see @sc-config-section) is less than zero (which is true by default), or an $O(log n)$ binary search procedure, otherwise.

```
pair[][] sectionparams (path g, path h, int n, real r, int p)
``` <smooth-sectionparams> #vs
Search for potential section positions between paths `g` and `h`, aiming to construct `n` sections. The meanings of `r` and `p` are:
- `r` --- ranges from `0` to `1`, and can be interpreted as "freedom": when small, it restricts the section positions, but when large, the algorithm has more choice. The default value for `r` is captured by `config.section.freedom` (see @sc-config-section);
- `p` --- controls precision. The bigger the value of `p`, the more precise the search, but the longer it takes.

The algorithm runs in $O(n + p)$ time and produces an array of `pair` arrays, whose values can then be plugged into the `sectionellipse` @smooth-sectionellipse function.

```
void drawsections (picture pic, pair[][] sections, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
``` <smooth-drawsections> #vs
Draw the cross sections specified in `sections` by calling the `sectionellipse` @smooth-sectionellipse function. The meanings of the rest of the parameters is as follows:
- `viewdir` --- passed to `sectionellipse` @smooth-sectionellipse;
- `dash`, `dashpen` --- after obtaining a `path[]` array from `sectionellipse`, whether to draw its second member with `dashpen`;
- `shade`, `shadepen` --- whether to shade the region bounded by each ellipse with `shadepen`;
- `help` --- whether to draw auxiliary help information, e.g. mark all the parameters;
- `scale` --- an internal parameter that only matters when `help` is `true`;
- `sectionpen` --- the pen to draw the first member of the section ellipse with.

=== The `cartesian` mode <sc-smooth-modes-cartesian>

This is the alternative mode of drawing cross sections, mainly implemented to draw three-dimensional smooth objects without any holes (note that the `free` mode relies on the presence of holes). For the `cartesian` mode, the `real[] hratios` and `real[] vratios` fields of the `smooth` @smooth-smooth structure are used. These fields are completely similar, the only difference being that `hratios` deals with horizontal sections, where `vratios` deals with vertical. Both these arrays contain numbers ranging from `0` to `1`, and are used as follows:
#example(
  image("resources/hvratios-showcase.svg"),
  ```
  import contour;
  smooth sm = smooth(
      contour = contour(<...>),
      hratios = new real[] {0.15, 0.5},
      vratios = new real[] {0.2, 0.6, 0.9}
  );

  draw(sm, dpar(mode = cartesian, viewdir = .7*dir(45)));
  ```,
  [A showcase of the way the `hratios` and `vratios` fields are used]
)

In other words, horizontal sections are drawn `r` of the way through `sm`'s _height_ for every `r` in `sm.hratios`, and vertical sections are drawn `s` of the way through `sm`'s _width_ for every `s` in `sm.vratios`. The mode is enabled by writing `mode = cartesian` in the `dpar` @smooth-dpar structure.

The `cartesian` mode (so called because the sections are only vertical and horizontal) is implemented by means of the following technical routines:

```
real getyratio (real y)
real getxratio (real x)
real getypoint (real y)
real getxpoint (real x)
``` <smooth-get-ratio-point> #vs
Convert to and from relative lengths.

```
smooth setratios (real[] ratios, bool horiz)
``` <smooth-setratios> #vs
Set the horizontal/vertical Cartesian ratios of `this` smooth object.

```
pair[][] cartsectionpoints (path[] g, real r, bool horiz)
``` <smooth-cartsectionpoints> #vs
Construct an array of section points in `g` (which represents a contour and holes in it) at relative length `r`, either vertically or horizontally, depending on `horiz`.

```
pair[][] cartsections (path[] g, path[] avoid, real r, bool horiz)
``` <smooth-cartsections> #vs
A more refined version of `cartsectionpoints` @smooth-cartsectionpoints, which performs additional tests and selects suitable sections.

```
void drawcartsections (picture pic, path[] g, path[] avoid, real y, bool horiz, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
``` <smooth-drawcartsections> #vs
A wrapper drawing function for the `cartesian` mode, which calls `cartsections` @smooth-cartsections  and passes the result to `drawsections` @smooth-drawsections, along with other arguments.

Besides, the final section ellipses are, of course, still calculated via the `sectionellipse` @smooth-sectionellipse function.

=== The `combined` mode <sc-smooth-modes-combined>

As seen in @modes-showcase, the `combined` mode combines both `free` and `cartesian` modes together, drawing all sections at once. Maybe, sometimes this is useful.

== The `dpar` drawing configuration structure <sc-smooth-dpar>

You may have noticed that the `smooth` @smooth-smooth structure contains no information about _how to draw_ a smooth object (although historically it did). Now, all of this information is isolated into a separate structure called `dpar` <smooth-dpar> (short for "drawing parameters"), which has the following fields:
- `pen contourpen` --- the pen used to draw the contour of the smooth object, as well as those of its holes and subsets;
- `pen smoothfill` --- the pen used to fill the smooth object's interior;
- `pen[] subsetcontourpens` --- a list of pens to draw subset contours with (by layer). Subsets on layer `0` will be drawn with `subsetcontourpens[0]`, etc. If the array is empty, then `contourpen` will be used instead for all layers. If the number or layers is larger than the length of `subsetcontourpens`, then the last member of the array will be used for all subsequent layers that are not covered;
- `pen[] subsetfill` --- similarly, a list of pens to use to fill different layers of subsets. If the array is empty, then lightened versions of the corresponding `subsetcontourpens` pens are used instead. If some layers are not covered by `subsetfill`, then the last member of the array is used, getting progressively darker. Consider the following example:
  #example(
    image("resources/subsetfill-showcase.svg"),
    ```
    smooth sm = smooth(
        contour = ucircle
    ).addsubsets(<...>);

    draw(sm, dpar(
        subsetcontourpens = new pen[] {red, green, blue},
        subsetfill = new pen[] {cyan, magenta, yellow}
    ));
    ```,
    [A showcase of the interpretation of `subsetcontourpens` and `subsetfill`]
  ) <subsetfill-showcase>
- `pen sectionpen` --- the pen used to draw cross sections (their visible parts);
- `pen dashpen` --- the pen used to draw the "invisible" (dashed) parts of cross sections;
- `pen shadepen` --- the pen used to fill the section ellipses;
- `pen elementpen` --- the pen used to `dot` the elements of the smooth object;
- `pen labelpen` --- the pen used to `label` the label of the smooth object;
- `pen[] elementlabelpens` --- pens used to `label` the labels of the smooth object's elements. If the array is empty, then `labelpen` is used for all elements. If there are more elements than the length of `elementlabelpens`, then the last member of the array is used for all elements not covered;
- `pen[] subsetlabelpens` --- pens used to `label` the labels of the smooth object's subsets. `labelpen` is used in case `subsetlabelpens` is empty. All subsets not covered by the array use the last member thereof;
- `int mode` <mode-values> --- the drawing mode. Can be one of the four: `plain`, `free`, `cartesian`, `combined` (which have values of `0`, `1`, `2`, `3` respectively). Any other integer value would be accepted, but the consequences may be unpredictable;
- `pair viewdir` --- the `viewdir` parameter to pass to the `sectionellipse` @smooth-sectionellipse function;
- `bool drawlabels` --- whether to draw the label of the smooth object as well as those of its subsets and elements;
- `bool fill` --- whether to fill the region bounded by the contour of the smooth object;
- `bool fillsubsets` --- whether to fill the subsets of the smooth object;
- `bool drawcontour` --- whether to draw the smooth object's contour;
- `bool drawsubsetcontour` --- whether to draw the contours of subsets;
- `int subsetcovermode` --- the `covermode` to pass to `fitpath` @def-fitpath when drawing the contours of subsets;
- `bool help` --- whether to enable additional information being drawn with the smooth object. Useful for debugging;
- `bool dash` --- the `dash` parameter to pass to `drawsections` @smooth-drawsections or `drawcartsections` @smooth-drawcartsections;
- `bool shade` --- the `shade` parameter to pass to `drawsections` @smooth-drawsections or `drawcartsections` @smooth-drawcartsections;
- `bool avoidsubsets` --- whether to avoid drawing cross sections that intersect with the smooth object's subsets. You can see that on the diagram on the title page of this document, this option was disabled;
- `bool overlap` --- the `overlap` parameter to pass to `fitpath` @def-fitpath;
- `bool drawnow` --- the `drawnow` parameter to pass to `fitpath` @def-fitpath;
- `bool drawextraover` --- whether to apply the `drawextra` function of the smooth object "over" everything else (that is, after drawing the object itself). In other words, if `drawextraover` is `false`, then the `drawextra` will be called in the beginning of drawing the smooth object, otherwise in the end.

These are all the fields of `dpar`. The structure has a comprehensive `void operator init` constructor where all fields are given default values from the `config.drawing` @config-drawing global configuration structure. The `dpar` structure also supports a method #vs
```
dpar subs (
    pen contourpen = this.contourpen,
    pen smoothfill = this.smoothfill,
    <...>
)
``` <dpar-subs> #vs
which replaces some of the fields of `this` with new values.

Besides, there are two conveniently defined `dpar` instances:

```
dpar ghostpar (pen contourpen = currentpen)
``` <dpar-ghostpar> #vs
A `dpar` to draw a faint outline of a smooth object.

```
dpar emptypar ()
``` <dpar-emptypar> #vs
A `dpar` that doesn't draw any contours or fill any regions.

== The `draw` function <sc-smooth-draw>

One of the central functions of module `smoothmanifold` is the `draw` function which allows one to draw a `smooth` object:
```
void draw (
    picture pic = currentpicture,
    smooth sm,
    dpar dspec = null
)
``` <smooth-draw> #vs
Draw `sm` on picture `pic`, with drawing configuration `dspec`. This function follows all the drawing protocols described previously in @sc-smooth-subset, @sc-smooth-modes and @sc-smooth-dpar.

Moreover, there are overloaded versions of `draw`: #vs
#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  void draw (
      picture pic = currentpicture,
      smooth[] sms,
      dpar dspec = null
  )
  ``` <smooth-draw-spec>
  #colbreak()
  ```
  void draw (
      picture pic = currentpicture,
      dpar dspec = null
      ... smooth[] sms
  )
  ``` <smooth-draw-spec-dots>
]

== Set operations on `smooth` objects

Nobody asked, but module `smoothmanifold` implements a few very complicated functions dedicated to calculating unions and intersections of `smooth` objects.

```
smooth[] intersection (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
)
smooth[] intersection (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
)
// (... smooth[] sms)
``` <smooth-intersection> #vs
Calculate the intersection of two or more `smooth` objects. The `round` and `roundcoeff` parameters are passed to the `intersection` @path-intersection function. If `keepdata` is set to `true`, then references to old `hole` and `subset` objects will be used in the construction of the new `smooth` object. If `addsubsets` is set to `true`, the function will try to move the subsets of the given `smooth` objects to their intersection.

For convenience, `intersection` is available as an operator: #vs
```
smooth[] operator ^^ (smooth sm1, smooth sm2)
{ return intersection(sm1, sm2); }
``` <smooth-intersection-operator>

Furthermore, there is a specialized routine which only return one smooth object:

```
smooth intersect (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
)
// (... smooth[] sms)
``` <smooth-intersect> #vs
Apply `intersection` @smooth-intersection and return the 0-th element of the resulting `smooth[]` array. If the array is empty, raise an error. If the array contains more than one object, give a warning. See @sc-debug for details on errors and warnings.

For `intersect` there is also an operator version: #vs
```
smooth operator ^ (smooth sm1, smooth sm2)
{ return intersect(sm1, sm2); }
``` <smooth-intersect-operator>

Likewise, there are similarly defined `union` and `unite` routines:

```
smooth[] union (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
smooth[] union (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
// (... smooth[] sms)
``` <smooth-union> #vs
Calculate the union of one or more `smooth` objects. The meanings of `round`, `roundcoeff` and `keepdata` are as in `intersection` @smooth-intersection.

```
smooth[] operator ++ (smooth sm1, smooth sm2)
{ return union(sm1, sm2); }
``` <smooth-union-operator> #vs
An operator version of `union`.

```
smooth unite (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
// (... smooth[] sms)
``` <smooth-unite> #vs
A specialized version of `union` which returns only one `smooth` object. An error/warning is raised if the resulting `smooth[]` array contains any number of elements other than `1`.

```
smooth operator + (smooth sm1, smooth sm2)
{ return unite(sm1, sm2); }
``` <smooth-unite-operator> #vs
An operator version of `unite`.

== Drawing arrows and paths

One of many crucial features of module `smoothmanifold` is the ease with which arrows can be drawn between smooth objects, their subsets or elements. In plain Asymptote one can easily draw an arrow between two points, but not between two _areas._ This is mainly what the `drawarrow` routine takes care of.

```
void drawarrow (
    picture pic = currentpicture,
    smooth sm1 = null,
    int index1 = config.system.dummynumber,
    pair start = config.system.dummypair,
    smooth sm2 = sm1,
    int index2 = config.system.dummynumber,
    pair finish = config.system.dummypair,
    bool elements = false,
    real curve = 0,
    real angle = 0,
    real radius = config.system.dummynumber,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    tarrow arrow = config.arrow.currentarrow,
    tbar bar = config.arrow.currentbar,
    bool help = config.help.enable,
    bool overlap = config.drawing.overlap,
    bool drawnow = config.drawing.drawnow,
    real beginmargin = config.arrow.mar,
    real endmargin = config.system.dummynumber
)
``` <smooth-drawarrow> #vs
Draw an arrow. The routine is quite sophisticated in that it accepts many different types of arguments. You can start the arrow from:
- The `sm1` object;
- A subset of the `sm1` object, under index `index1`;
- An arbitrary point `start`.

Likewise, you can finish the arrow at:
- The same object `sm1` (by default), getting a cyclic arrow;
- The same `sm1`, but different subset, under index `index2`;
- A different smooth object, `sm2`, or its subset under `index2`;
- An arbitrary point `finish`.

The meaning of the remaining arguments is as follows:
- `elements` --- if set to `true`, then `index1` and `index2` will be treated as element indices instead of subset indices;
- `curve` --- for non-cyclic arrows, this argument is passed to the `curvedpath` @path-curvedpath function;
- `angle` and `radius` --- for cyclic arrows, these arguments are passed to the `cyclepath` @path-cyclepath function;
- `reverse` --- whether the arrow should be reversed;
- `points` --- an array of arbitrary points that the arrow should pass through. If this array is non-empty, the `connect` @path-connect function is used instead of `curvedpath` @path-curvedpath or `cyclepath` @path-cyclepath;
- `L` --- the label to attach to the arrow;
- `p` --- the pen to draw the arrow with;
- `arrow` and `bar` --- the arrow and bar to use with the arrow. Since `drawarrow` is integrated with `smoothmanifold`'s deferred drawing system, the custom `tarrow` @def-tarrow and `tbar` @def-tbar structures are used here;
- `help` --- if set to `true`, addition help/debug information will be drawn;
- `overlap` and `drawnow` --- these arguments are passed to `fitpath` @def-fitpath together with `arrow` and `bar`;
- `beginmargin` and `endmargin` --- the margins left at the beginning and end. If `endmargin` is not specified, `beginmargin` is used instead.

For the definitions of the default values of `drawarrow`'s parameters, see @sc-config.

There is a specialized overloaded version of `drawarrow`: #vs
```
void drawarrow (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
    real curve = 0,
    <...>
)
``` <smooth-drawarrow-label> #vs
A label-based version of `drawarrow`. It automatically detects if the labels belong to `smooth` objects/subsets/elements, and passes appropriate arguments to `drawarrow` @smooth-drawarrow.

Now, apart from arrows, one may want to draw a path connecting two points. This may be done with the `drawpath` routine: #vs
```
void drawpath (
    picture pic = currentpicture,
    smooth sm1,
    int index1,
    smooth sm2 = sm1,
    int index2 = index1,
    real range = config.paths.range,
    real angle = config.system.dummynumber,
    real radius = config.system.dummynumber,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    bool help = config.help.enable,
    bool random = config.drawing.pathrandom,
    bool overlap = config.drawing.overlap,
    bool drawnow = config.drawing.drawnow
)
``` <smooth-drawpath> #vs
Draw a surface path connecting `sm1.elements[index1]` and `sm2.elements[index2]`. By default, `sm1` and `sm2` coincide. All remaining arguments have the same meaning as in `drawarrow` @smooth-drawarrow, except for two:
- `range` --- this value is passed to `randomdir` @path-randomdirpath as `angle`;
- `random` --- if set to `true`, then the `randompath` @path-randomdirpath routine will be used for the path, instead of `connect` @path-connect or `cyclepath` @path-cyclepath.

Similarly to `drawarrow`, there is a label-based version of `drawpath`: #vs
```
void drawpath (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
    real range = config.paths.range,
    <...>
)
``` <smooth-drawpath-label> #vs
Draw a surface path between elements with labels `destlabel1` and `destlabel2`.

= Global configuration and the `config` structure <sc-config>

Throughout the document, we have seen references to a global `config` structure instance. It is defined as follows: #vs
```
struct globalconfig {
    systemconfig system;
    pathconfig paths;
    sectionconfig section;
    smoothconfig smooth;
    drawingconfig drawing;
    helpconfig help;
    arrowconfig arrow;
}

private globalconfig defaultconfig;
globalconfig config;
``` <config> #vs
The `defaultconfig` instance contains all default values, while `config` contains all _current_ values, which can be changed directly at any time in the Asymptote code. Functions and methods feature default argument values that borrow from `config`, never `defaultconfig`. This way, a convenient configuration system is created, where all functions are aware of the flexible current `config`, and the defaults can be easily restored by deeply copying `defaultconfig` to `config`, by means of the #vs
```
void defaults ()
``` <config-defaults> #vs
function. We will now define in detail the member structures of `config`.

== System variables <sc-config-system>

```
struct systemconfig {
    string version = "v6.3.1";
    int dummynumber = -10000;
    string dummystring = (string) dummynumber;
    pair dummypair = (dummynumber, dummynumber);
    bool repeatlabels = false;
    bool insertdollars = false;
}
``` <config-system> #vs
A structure containing system configuration variables. Their meanings are as follows:
- `version` --- the version of `smoothmanifold`, currently `6.3.1`;
- `dummynumber` <dummynumber> --- the number that "the program knows what to do with". It is often given as a default value in many functions, when the true default value requires additional computations that are better done in the body of the function. A shorthand `dn` is defined for it, for convenience;
- `dummypair` and `dummystring` --- versions of `dummynumber` with different types. Module `smoothmanifold` features four helper functions to check if a value is "dummy": #vs
  #bl[
    #show: columns.with(4, gutter: 0pt)
    ```
    bool dummy (int n)
    ``` <config-dummy-int>
    #colbreak()
    ```
    bool dummy (real r)
    ``` <config-dummy-real>
    #colbreak()
    ```
    bool dummy (pair p)
    ``` <config-dummy-pair>
    #colbreak()
    ```
    bool dummy(string s)
    ``` <config-dummy-string>
  ]
- `repeatlabel` --- whether to allow different objects to share the same label. If set to `false`, an error (see @sc-debug) will be raised on attempt to bestow an already existent label;
- `insertdollars` --- whether to automatically insert `$` characters around all labels (including those passed to `drawarrow` @smooth-drawarrow and `drawpath` @smooth-drawpath) right before drawing them. This is useful, but disabled by default to avoid confusion.

== Path variables <sc-config-path>

```
struct pathconfig {
    real roundcoeff = .03;
    real range = 30;
    real neighheight = .05;
    real neighwidth = .01;
}
``` <config-path> #vs
A structure containing global path-related variables. The meaning of the fields is as follows:
- `roundcoeff` --- default value to pass to `combination` @path-combination and its derivatives;
- `range` --- default value to pass to `drawpath` @smooth-drawpath;
- `neighheight` --- default value to pass to `neigharc` @path-neigharc as `h`;
- `neighwidth` --- default value to pass to `neigharc` @path-neigharc as `w`;

== Cross section variables <sc-config-section>

```
struct sectionconfig {
    real maxbreadth = .65;
    real freedom = .3;
    int precision = 20;
    real elprecision = -1;
    bool avoidsubsets = false;
    real[] default = new real[] {-10000,235,5};
}
``` <config-section> #vs
A structure to hold cross section-related configuration. The meanings of the fields are as follows:
- `maxbreadth` --- bound on how wide `dir1` and `dir2` can be spread in `sectionellipse` @smooth-sectionellipse (see @sectionellipse-showcase). There are two technical routines dedicated to controlling the "quality" of cross sections: #vs
  ```
  real sectionsymmetryrating (pair p1p2, pair dir1, pair dir2)
  bool sectiontoobroad (pair p1, pair p2, pair dir1, pair dir2)
  ``` <section-quality>
- `freedom` --- the default value to pass to the `sectionparams` @smooth-sectionparams function as `r`;
- `precision` --- the default value to pass to `sectionparams` @smooth-sectionparams as `p`;
- `elprecision` --- the default precision for the `ellipsepath` @path-ellipsepath binary search algorithm. Set to `-1` by default, to use the $O(1)$ formula;
- `avoidsubsets` --- the default value for the `avoidsubsets` field of the `dpar` @smooth-dpar structure;
- `default` --- the default section array used to substitute missing values in `addsection` @smooth-addsection and its related methods.

== Smooth object variables <sc-config-smooth>

```
struct smoothconfig {
    int interholenumber = 1;
    real interholeangle = 25;
    real maxsectionlength = -1;
    real rejectcurve = .15;
    real edgemargin = .07;
    real stepdistance = .15;
    real nodesize = 1;
    real maxlength;
    bool inferlabels = true;
    bool addsubsets = true;
    bool correct = true;
    bool clip = false;
    bool unit = false;
    bool setcenter = true;
}
``` <config-smooth> #vs
A structure to hold all smooth object-related variables, whose meanings are as follows:
- `interholenumber` --- the default value for the `scnumber` field in the `hole` @smooth-ho-su-el structure;
- `interholeangle` --- this value gets passed to the `range` @path-range function as `ang`, when drawing sections between holes;
- `maxsectionlength` --- the maximum length of a section. A value of `-1` means no restriction. Setting this value may help get rid of some annoying sections that look bad because they are too big;
- `rejectcurve` --- this value is passed to `curvedpath` @path-curvedpath when constructing curves to determine which inter-hole sections to draw and which not to. This is done by checking if the curves intersect with any holes or subsets;
- `edgemargin` --- no point in explaining, let this one remain a mystery. If you REALLY need to know what this does, go see the source code...
- `stepdistance` --- same;
- `nodesize` --- the default value of the `size` parameter in the `node` @smooth-node function;
- `maxlength` --- a parameter dependent on `maxsectionlength`, should not be set manually;
- `inferlabels` --- the default value of the `inferlabels` parameter passed to `addsubset` @smooth-addsubset and its derivatives;
- `addsubsets` --- the default value to pass to the `intersection` @smooth-intersection function and its derivatives;
- `correct` --- whether non-clockwise paths should be reversed to clockwise. This value is passed as default in set operations with paths (see @sc-path-set);
- `clip` --- the default value passed to the `addsubset` @smooth-addsubset, `addhole` @smooth-addhole, `movesubset` @smooth-movesubset and their derivatives, as the `clip` parameter;
- `unit` --- whether to use unit coordinates (see @sc-smooth-unit). This is the default value of the `unit` parameter in all methods that accept it;
- `setcenter` --- whether to automatically set the centers of various objects in various situations by calling `center` @path-center on their `contour`.

== Drawing-related variables <sc-config-drawing>

```
struct drawingconfig {
    pair viewdir = (0,0);
    real viewscale = 0.12;
    real gaplength = .05;
    pen smoothfill = lightgrey;
    pen[] subsetfill = {};
    real sectpenscale = .6;
    real elpenwidth = 3.0;
    real shadescale = .85;
    real dashpenscale = .4;
    real dashopacity = .4;
    real attachedopacity = .8;
    real subpenfactor = .5;
    real subpenbrighten = .5;
    pen sectionpen = nullpen;
    real lineshadeangle = 45;
    real lineshadedensity = 0.15;
    real lineshademargin = 0.1;
    pen lineshadepen = lightgrey;
    int mode = 0;
    bool useopacity = false;
    bool dash = true;
    bool underdashes = false;
    bool shade = false;
    bool drawlabels = true;
    bool fill = true;
    bool fillsubsets = true;
    bool drawcontour = true;
    bool drawsubsetcontour = true;
    int subsetcovermode = 0;
    bool pathrandom = false;
    bool overlap = false;
    bool drawnow = false;
    bool drawextraover = false;
    bool subsetoverlap = false;
    real elementcirclerad = -1;
}
``` <config-drawing> #vs
A structure to hold drawing-related configuration, encoded in the following variables:
- `viewdir`, `smoothfill`, `subsetfill`, `sectionpen`, `mode`, `dash`, `shade`, `drawlabels`, `fill`, `fillsubsets`, `drawcontour`, `drawsubsetcontour`, `subsetcovermode`, `overlap`, `drawnow`, `drawextraover` --- default values of the corresponding `dpar` @smooth-dpar fields;
- `viewscale` --- a value by which the `viewdir` vector is scale on call of the `draw` @smooth-draw function;
- `gaplength` --- the default length of the gaps left in `deferredPath` @def-deferredPath objects when the `fitpath` @def-fitpath function is called;
- `sectpenscale` --- determines how thinner the section pen is compared to `contourpen`;
- `elpenwidth` --- the width of the `dot`'s representing a smooth object's elements, used when calling `draw` @smooth-draw. The relevant pen creation utility is #vs
  ```
  pen elementpen (pen p) { return p + linewidth(config.drawing.elpenwidth); }
  ``` <pen-elements>
- `shadescale` --- how darker shaded section ellipses are compared to object filling color. This is relevant if the `shade` flag is set to `true`;
- `dashpenscale` --- how lighter dashed lines (in cross section drawing) are compared to regular lines;
- `dashopacity` --- default opacity of dashed pens;
- `attachedopacity` --- the opacity used to draw smooth objects `attached` @smooth-smooth to the one currently being drawn;
- `subpenfactor` --- how darker the fill color for subsets get with each layer. See @sc-smooth-dpar and @subsetfill-showcase;
- `subpenbrighen` --- how brighter to make the fill color of a subset than its contour color. The relevant pen creation routines are #vs
  ```
  pen brighten (pen p, real coeff) { return inverse(coeff * inverse(p)); }
  pen nextsubsetpen (pen p, real scale) { return scale * p; }
  ``` <pen-subsets>
- `lineshadeangle`, `lineshadedensity`, `lineshademargin`, `lineshadepen` --- default values passed to the `shaderegion` @misc-shaderegion function;
- `useopacity` --- whether to use Asymptote's `opacity` function for generating pens (primarily dashed section pens). Since some image formats do not support opacity, this is disabled by default, and so the `dashpenscale` field is used for dashed pen creation. Otherwise, the `dashopacity` field is used. The relevant pen creation routines are #vs
  ```
  pen sectionpen (pen p)
  pen dashpenscale (pen p)
      { return inverse(config.drawing.dashpenscale*inverse(p))+dashed; }
  pen dashopacity (pen p) { return p+dashed+opacity(config.drawing.dashopacity); }
  pen dashpen (pen p)
  pen shadepen (pen p) { return config.drawing.shadescale*p; }
  pen underpen (pen p) { return dashpen(p); }
  ``` <pen-sections>
- `underdashes` --- whether to draw the "demoted" parts of a `deferredPath` @def-deferredPath in a dashed line, instead of erasing them;
- `pathrandom` --- the default value passed to the `drawpath` @smooth-drawpath function as `random`;
- `elementcirclerad` --- the radius to use when drawing elements as `circle`'s instead of `dot`'s. This exists because sometimes dots are not showing up in SVG output, in which case the simplest thing to do is say screw it and fill a circle instead of calling the `dot` function.

== Help-related variables <sc-config-help>

```
struct helpconfig {
    bool enable = false;
    real arcratio = 0.2;
    real arrowlength = .2;
    pen linewidth = linewidth(.3);
}
``` <config-help> #vs
A structure to hold the few help-related variables, namely
- `enable` --- whether to enable auxiliary drawing by default;
- `arcratio` --- the relative radius of the blue arcs seen near the center of the hole on @section-showcase, it may be useful to tweak if the arc covers the number in the center of the hole;
- `arrowlength` --- the length of auxiliary arrows drawn by the sides of cross sections when `help = true`. A value of `-1` will disable these arrows (like on @section-showcase);
- `linewidth` -- the pen containing the line width to draw help lines with.

== Arrow variables <sc-config-arrow>

```
struct arrowconfig {
    real mar = 0.03;
    tarrow currentarrow = null;
    tbar currentbar = null;
    bool absmargins = true;
}
``` <config-arrow>
A structure to hold variables related to arrows, namely the following:
- `mar` --- the default arrow margin that is passed as the default value to the `beginmargin` and `endmargin` parameters of the `drawarrow` @smooth-drawarrow function;
- `currentarrow`, `currentbar` --- the default values of the `arrow` and `bar` parameters of `drawarrow` @smooth-drawarrow; The `currentarrow` value is updated after the definition of `DeferredArrow` @def-tarrow-func:
  ```
  config.arrow.currentarrow = DeferredArrow(SimpleHead);
  ```
- `absmargins` --- whether arrow margins should be absolute, as opposed to being relative to the length of the arrow.

= Debugging capabilities <sc-debug>

In case an algorithm runs into an incorrect situation or is given incorrect input, mechanisms are put in place in module `smoothmanifold` to trigger an _error_ (subsequently stopping execution) or a _warning_ (while continuing execution). For errors, the relevant routine is #vs

```
void halt (string msg) {
    write();
    write("> ! " + msg);
    abort("");
}
``` <debug-halt>

Warnings are simply written with a direct call to `write`.

= Miscellaneous auxiliary routines <sc-misc>

== `smooth`-related functions

```
smooth[] concat (smooth[][] smss)
``` <smooth-concat> #vs
Concatenate an array of `smooth` objects. In Asymptote, it is difficult to write a polymorphic `concat` function.

```
void print (smooth sm)
``` <smooth-print> #vs
Print various information about the smooth object `sm` in the console.

```
void printall ()
``` <smooth-printall> #vs
Print all `smooth` objects in the global `smooth.cache` array. #ind[smooth]

```
void smooth.checksubsetindex (int index, string fname)
``` <smooth-checksubsetindex> #vs
Check if `this` has a subset at index `index`. The `fname` parameter is used for debugging purposes -- it contains the name of the function that is calling `checksubsetindex`.

```
void smooth.checkelementindex (int index, string fname)
``` <smooth-checkelementindex> #vs
Check if `this` has a element at index `index`. The `fname` parameter is used for debugging purposes -- it contains the name of the function that is calling `checkelementindex`.

```
smooth[] drawintersect (
    picture pic = currentpicture,
    smooth sm1,
    smooth sm2,
    string label = config.system.dummystring,
    pair labeldir = config.system.dummypair,
    pair labelalign = config.system.dummypair,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    pair shift = (0,0),
    dpar dspec = null
)
``` <smooth-drawintersect> #vs
Draw the `intersection` @smooth-intersection of `sm1` and `sm2` and return it, while also drawing the faint silhouettes of `sm1` and `sm2` themselves. Remaining arguments:
- `label`, `labeldir` and `labelalign` --- these are passed as fields to the intersection object(s);
- `round` and `roundcoeff` --- passed to `intersection` @path-intersection
- `shift` --- allows to additionally shift the involved objects.

The `drawintersect` <smooth-drawintersect-spec> function has overloaded versions that accept `smooth[]` and `... smooth[]` arguments.

```
smooth node (
    string label,
    pair pos = (0,0),
    real size = config.smooth.nodesize
)
``` <smooth-node> #vs
Produce a `smooth` object with label `label` that can be used as a node in a commutative diagram @smooth-drawcommuting. The object will be positioned as `pos` and have the size `size`. Moreover, there is a special `dpar` instance for drawing nodes: #vs
```
dpar nodepar (pen labelpen = currentpen)
``` <smooth-nodepar>

```
void drawcommuting (
    picture pic = currentpicture,
    smooth[] sms,
    real size = config.smooth.nodesize*.5,
    pen p = currentpen,
    bool direction = CW
)
``` <smooth-drawcommuting> #vs
Draw all objects in the `sms` array (all presumably generated by `node` @smooth-node) and draw a "commutative diagram symbol" in the center of the diagram, like so:
#example(
  image("resources/drawcommuting-showcase.svg"),
  ```
  config.system.insertdollars = true;
  smooth a = node("A", pos = (0,0));
  smooth fa = node("F(A)", (5,2));
  smooth g = node("\forall G", (4,-3));

  draw(a, fa, g, dspec = nodepar());
  drawarrow(a, fa, L = Label("\varphi", align = Relative(W)));
  drawarrow(g, a, L = Label("\forall f", align = Relative(W)));
  drawarrow(g, fa, p = dashed, L = Label("\exists!", align = Relative(E)));
  drawcommuting(g, a, fa, size = .7);
  ```,
  [A showcase of the `drawcommuting` function]
)

```
element[] elementcopy (element[] elements)
``` <smooth-elementcopy> #vs
Deeply copy an array of `element` structures.

```
hole[] holecopy (hole[] holes)
``` <smooth-holecopy> #vs
Deeply copy an array of `hole` structures.

```
subset[] subsetcopy (subset[] subsets)
``` <smooth-subsetcopy> #vs
Deeply copy an array of `subset` structures.

```
subset[] subsetintersection (
    subset sb1,
    subset sb2,
    bool inferlabels = config.smooth.inferlabels
)
``` <smooth-subsetintersection> #vs
Calculate the intersection of two subsets by applying `intersection` @path-set-intersection and automatically setting other `subset` @smooth-ho-su-el fields.

```
void subsetdelete (subset[] subsets, int index, bool recursive)
``` <smooth-subsetdelete> #vs
Properly delete entry under `index` from the `subsets` array.

```
int[] subsetgetlayer (subset[] subsets, int[] range, int layer)
``` <smooth-subsetgetlayer> #vs
Fetch those elements of `subsets`, which have layer `layer`, and return their indices. Moreover, these indices are restricted to the elements of `range`.

```
int[] subsetgetall (subset[] subsets, subset s)
int[] subsetgetall (subset[] subsets, int index)
{ return subsetgetall(subsets, subsets[index]); }
``` <smooth-subsetgetall> #vs
Get all descendants (subsets) of subset `s` (or subset `subsets[index]`) in the array `subsets`.

```
int[] subsetgetallnot (subset[] subsets, subset s)
{ return difference(sequence(subsets.length), subsetgetall(subsets, s)); }
int[] subsetgetallnot (subset[] subsets, int index)
{ return difference(sequence(subsets.length), subsetgetall(subsets, index)); }
``` <smooth-subsetgetallnot> #vs
Return the indices of all subsets in `subsets`, which are _not_ subsets of `s`.

```
void subsetdeepen (subset[] subsets, subset s)
``` <smooth-subsetdeepen> #vs
Descend `s` one layer deeper, and patch `subsets` accordingly, so that the subset hierarchy is properly kept.

```
int subsetinsertindex (subset[] subsets, int layer)
``` <smooth-subsetinsertindex> #vs
Calculate the index at which a new subset on layer `layer` should be inserted.

```
int subsetmaxlayer (subset[] subsets, int[] range)
``` <smooth-subsetmaxlayer> #vs
Calculate the maximum layer that subsets in `subsets` with indices in `range` occupy.

```
void subsetcleanreferences (subset[] subsets)
``` <smooth-subsetcleanreferences> #vs
Clean up the `subsets` @smooth-ho-su-el fields of all subsets in `subsets`.

```
int[] findbylabel (string label)
``` <smooth-findbylabel> #vs
A fully general label identification function that returns an index path to either a smooth object or its subset/element with a label matching `label`.

```
path[] holecontours (hole[] h)
{ return sequence(new path (int i){return h[i].contour;}, h.length); }
``` <smooth-holecontours> #vs
Return the contours of an array of `hole` objects.

```
void phantom (picture pic = currentpicture, smooth sm)
``` <smooth-phantom> #vs
Inspired by T#sub[E]X's `\phantom` commands, this takes the space on the plane that `sm` would take, without actually drawing it.

```
smooth rn (
    int n,
    pair labeldir = (.5,1),
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    bool drawnow = false
)
``` <smooth-rn> #vs
Construct an $RR^n$ representation as a `smooth` object. This mainly utilizes the `drawextra` @smooth-smooth field to draw the axes. The `n` parameter controls the $n$ in $RR^n$, all the rest are passed to `smooth`, except for `drawnow` which is passed to `fitpath` @def-fitpath

```
dpar rnpar ()
``` <smooth-rnpar> #vs
The `dpar` instance to draw `rn` @smooth-rn smooth objects.

```
smooth samplesmooth (int type, int num = 0, string label = "")
smooth sm (int type, int num = 0, string label = "") = samplesmooth;
``` <smooth-samplesmooth> #vs
Produce a predefined smooth object. The `type` parameter determines the number of holes, and `num` --- the index of the object inside its type. `label` will be attached to the resulting object. The `sm` function is a convenience shorthand.

```
smooth tangentspace (
    smooth sm,
    int hlindex = -1,
    pair center = config.system.dummypair,
    real angle,
    real ratio,
    real size = 1,
    real rotate = 45,
    string eltlabel = "x",
    pair eltlabelalign = 1.5*S
)
``` <smooth-tangentspace> #vs
Construct a tangent space at a point on `sm`, and attach it to `sm`.
- The point is determined by `hlindex` (an index of `sm`'s hole, a value of `-1` means no hole), `angle`, `center` (determined automatically by default), and `ratio`.
- The `rotate` parameter can be used to rotate the tangent space.
- The `eltlabel` and `eltlabelalign` parameters are passed to the `element` generated at the point where the tangent space is constructed. For a showcase of the `tangentspace` function, see @tangent.

== Array utilities

```
path[] c (... path[] source) { return source; }
path[][] dc (... path[][] source) { return source; }
path[][] cc (... path[] source) { return new path[][]{source}; }
``` <misc-c> #vs
R-style convenience functions for paths, for those who are tired of writing `new path[]`.

```
real[] r (... real[] source) { return source; }
real[][] dr (... real[][] source) { return source; }
real[][] rr (... real[] source) { return new real[][]{source}; }
``` <misc-r> #vs
R-style convenience functions for reals, for those who are tired of writing `new real[]`.

```
pair[] p (... pair[] source) { return source; }
pair[][] dp (... pair[][] source) { return source; }
pair[][] pp (... pair[] source) { return new pair[][]{source}; }
``` <misc-p> #vs
R-style convenience functions for pairs, for those who are tired of writing `new pair[]`.

```
int[] i (... int[] source) { return source; }
int[][] di (... int[][] source) { return source; }
int[][] ii (... int[] source) { return new int[][]{source}; }
``` <misc-i> #vs
R-style convenience functions for integers, for those who are tired of writing `new int[]`.

```
string[] s (... string[] source) { return source; }
string[][] ds (... string[][] source) { return source; }
string[][] ss (... string[] source) { return new string[][]{source}; }
``` <misc-s> #vs
R-style convenience functions for strings, for those who are tired of writing `new string[]`.

```
pair[] concat (pair[][] a)
``` <misc-concat-pair> #vs
Concatenate an array of `pair`.

```
path[] concat (path[][] a)
``` <misc-concat-path> #vs
Concatenate an array of `path`.

```
bool contains (int[] source, int a)
``` <misc-contains> #vs
Check if `source` contains `a`.

```
int[] difference (int[] a, int[] b)
``` <misc-difference> #vs
Calculate the set difference of two arrays of integers.

== Other routines

```
pair comb (pair a, pair b, real t) { return t*b + (1-t)*a;}
``` <misc-comb> #vs
A convex combination between `a` and `b` with time `t`.

```
transform dscale (real scale, pair dir, pair center = (0,0))
``` <misc-dscale> #vs
Return a transform that scales by `scale` in direction `dir`, with center in `center`.

```
bool inside (real a, real b, real c)
{ return (a <= c && c <= b); }
``` <misc-inside> #vs
Determine if `c` lies in the segment `[a,b]`.

```
path[] intersection (
    path p,
    path q,
    path[] holes,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
``` <misc-intersection-holes> #vs
A version of `intersection` @path-set-intersection, but it subtracts all members of `holes` from the intersection of `p` and `q`, using `difference` @path-set-difference.

```
pen inverse (pen p)
``` <misc-inverse> #vs
Derive the "inverse" or "negative" pen from `p`.

```
real mod (real a, real b)
``` <misc-mod> #vs
Calculate `a` modulo `b` by subtracting `b` until the result falls between `0` and `b`.

```
string mode (int md)
``` <misc-mode> #vs
Convert an integer `mode` (see @sc-smooth-modes) value into its string representation. E.g., `mode(0) = "plain"`. Historic side note: in early versions of `smoothmanifold`, the `mode` parameter _was_ a string, but I have later found it excessive and inconvenient.

```
path pop (path[] source)
``` <misc-pop> #vs
Remove the 0-th element of `source` and return it.

```
real round (real a, int places) { return floor(10^places*a)*.1^places; }
pair round (pair a, int places) { return (round(a.x, places), round(a.y, places)); }
``` <misc-round> #vs
Round `a` to the `places` number of decimal places.

```
string repeatstring (string str, int n)
``` <misc-repeatstring> #vs
Produce a string that repeats `str` `n` times.

```
transform srap (real scale, real rotate, pair point)
{ return shift(point)*scale(scale)*rotate(rotate)*shift(-point); }
``` <misc-srap> #vs
[S]cale [R]otate [A]round [P]oint.

```
void shaderegion (
    picture pic = currentpicture,
    path g,
    real angle = config.drawing.lineshadeangle,
    real density = config.drawing.lineshadedensity,
    real mar = config.drawing.lineshademargin,
    pen p = config.drawing.lineshadepen
)
``` <misc-shaderegion> #vs
Shade the region bounded by `g` with straight lines, like so: #vs
#example(
  image("resources/shaderegion-showcase.svg"),
  ```
  path g = wavypath(r(2,4,3,1,2,3,2));
  draw(g);

  shaderegion(
      g,
      angle = -20,
      density = .2,
      mar = .4,
      p = red
  );
  ```,
  [A showcase of the `shaderegion` function]
)

```
real[] unitseq (real step)
``` <misc-unitseq> #vs
Calculate a uniform partition of the unit segment with step `step`.

```
real xsize (picture p) { return xpart(max(p)) - xpart(min(p)); }
real ysize (picture p) { return ypart(max(p)) - ypart(min(p)); }
``` <misc-size> #vs
Calculate the vertical and horizontal size of a given picture `p`.

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  struct gauss
  {
      int x;
      int y;
  }
  ``` <misc-gauss>
  #colbreak()
  ```
  bool operator == (gauss a, gauss b)

  gauss operator cast (pair p)

  pair operator cast (gauss g)
  ``` <misc-gauss-func>
] #vs
A Gaussian integer structure, mainly used by the `combination` @path-combination function.

= Index <sc-index>

#let section(letter, cnt) = {
  // text(size: 13pt, strong(letter))
  v(7pt)
  set list(marker: ([(#letter)]))
  cnt
}
#let e = { h(.5em); math.arrow.long; h(.5em) }
#set raw(lang: none)

#section("*")[
  - `gauss operator cast (pair)` #e @misc-gauss-func
  - `pair operator cast (gauss)` #e @misc-gauss-func
  - `bool operator == (gauss, gauss)` #e @misc-gauss-func
  - `path[] operator - (path, path)` #e @path-set-difference-operator
  - `path[] operator - (path[], path)` #e @path-set-difference-operator
  - `path[] operator :: (path[], path)` #e @path-set-symmetric-operator
  - `path[] operator ^ (path[], path)` #e @path-set-intersection-operator
  - `smooth operator ^ (smooth, smooth)` #e @smooth-intersect-operator
  - `smooth[] operator ^^ (smooth, smooth)` #e @smooth-intersection-operator
  - `path[] operator | (path[], path)` #e @path-set-union-operator
  - `smooth operator + (smooth, smooth)` #e @smooth-unite-operator
  - `smooth[] operator ++ (smooth, smooth)` #e @smooth-union-operator
  - `picture operator * (transform, picture)` #e @def-shipout
]

#section("A")[
  - `struct arrowconfig` #e @config-arrow
  - `struct arrowconfig` #e @config-arrow
  - `real arclength (path, real, real)` #e @path-arclength
  - `path arcsubpath (path, real, real)` #e @path-arcsubpath
  - `transform smooth.adjust (int)` #e @smooth-adjust
  - `smooth smooth.addelement (element, int, bool)` #e @smooth-addelement
  - `smooth smooth.addelement (pair, string, pair, int, bool)` #e @smooth-addelement-spec
  - `smooth smooth.addhole (hole, int, bool, bool)` #e @smooth-addhole
  - `smooth smooth.addhole (path, pair, real[][], pair, real, real, pair, bool, bool)` #e @smooth-addhole-spec
  - `smooth smooth.addholes (hole[], bool, bool)` #e @smooth-addholes
  - `smooth smooth.addholes (bool, bool ... hole[])` #e @smooth-addholes
  - `smooth smooth.addholes (path[], bool, bool)` #e @smooth-addholes-spec
  - `smooth smooth.addholes (bool, bool ... path[])` #e @smooth-addholes-spec
  - `smooth smooth.addsection (int, real[])` #e @smooth-addsection
  - `smooth smooth.addsubset (subset, int, bool, bool, bool, bool)` #e @smooth-addsubset
  - `smooth smooth.addsubset (int, path, pair, pair, real, real, pair, string, pair, pair, bool, bool, bool)` #e @smooth-addsubset-spec
  - `smooth smooth.addsubset (string, subset, bool, bool, bool)` #e @smooth-addsubset-label
  - `smooth smooth.addsubset (string, path, pair, real, real, pair, string, pair, pair, bool, bool, bool)` #e @smooth-addsubset-label
  - `smooth smooth.addsubsets (subset[], int, bool, bool, bool)` #e @smooth-addsubsets
  - `smooth smooth.addsubsets (int, bool, bool, bool ... subset[])` #e @smooth-addsubsets
  - `smooth smooth.addsubsets (path[], int, bool, bool, bool)` #e @smooth-addsubsets-spec
  - `smooth smooth.addsubsets (int, bool, bool, bool ... path[])` #e @smooth-addsubsets-spec
  - `smooth smooth.addsubsets (string, subset[], bool, bool, bool)` #e @smooth-addsubsets
  - `smooth smooth.addsubsets (string, bool, bool, bool ... subset[])` #e @smooth-addsubsets
  - `smooth smooth.addsubsets (string, bool, bool, bool ... path[])` #e @smooth-addsubsets-spec
  - `smooth smooth.attach (smooth)` #e @smooth-attach
]

#section("B")[
  - `pen brighen (pen, real)` #e @pen-subsets
]

#section("C")[
  - `path[] convexpaths` #e @path-defaultpaths
  - `path[] concavepaths` #e @path-defaultpaths
  - `int cartesian` #e @mode-values
  - `int combined` #e @mode-values
  - `globalconfig config` #e @config
  - `pair center (path, int, bool, bool)` #e @path-center
  - `pair comb (pair, pair, real)` #e @misc-comb
  - `path[] c (... path[])` #e @misc-c
  - `path[][] cc (... path[])` #e @misc-c
  - `pair[] concat (pair[][])` #e @misc-concat-pair
  - `path[] concat (path[][])` #e @misc-concat-path
  - `bool contains (int[], int)` #e @misc-contains
  - `bool clockwise (path)` #e @path-clockwise
  - `path curvedpath (pair, pair, real, bool)` #e @path-curvedpath
  - `path cyclepath (pair, real, real)` #e @path-curvedpath
  - `path connect (pair[])` #e @path-connect
  - `path connect (... pair[])` #e @path-connect
  - `path connect (path, path)` #e @path-connect-pq
  - `path[] combination (path, path, int, bool, real)` #e @path-combination
  - `bool checksection (real[])` #e @smooth-checksection
  - `pair[][] cartsectionpoints (path[], real, bool)` #e @smooth-cartsectionpoints
  - `pair[][] cartsections (path[], path[], real, bool)` #e @smooth-cartsections
  - `element element.copy ()` #e @element-copy
  - `hole hole.copy ()` #e @hole-copy
  - `subset subset.copy ()` #e @subset-copy
  - `smooth smooth.copy ()` #e @smooth-copy
  - `void smooth.checksubsetindex (int, string)` #e @smooth-checksubsetindex
  - `void smooth.checkelementindex (int, string)` #e @smooth-checkelementindex
  - `smooth[] concat (smooth[][])` #e @smooth-concat
]

#section("D")[
  - `struct drawingconfig` #e @config-drawing
  - `struct dpar` #e @smooth-dpar
  - `struct deferredPath` #e @def-deferredPath
  - `int dn` #e @dummynumber
  - `private globalconfig defaultconfig` #e @config
  - `transform dscale (real, pair, pair)` #e @misc-dscale
  - `real[][] dr (... real[][])` #e @misc-r
  - `pair[][] dp (... pair[][])` #e @misc-p
  - `int[][] di (... int[][])` #e @misc-i
  - `path[][] dc (... path[][])` #e @misc-c
  - `string[][] ds (... string[][])` #e @misc-s
  - `int[] difference (int[], int[])` #e @misc-difference
  - `path[] difference (path, path, bool, bool, real)` #e @path-set-difference
  - `path[] difference (path[], path, bool, bool, real)` #e @path-set-difference
  - `bool dummy (int)` #e @config-dummy-int
  - `bool dummy (real)` #e @config-dummy-real
  - `bool dummy (pair)` #e @config-dummy-pair
  - `bool dummy (string)` #e @config-dummy-string
  - `pen dashpenscale (pen)` #e @pen-sections
  - `pen dashopacity (pen)` #e @pen-sections
  - `pen dashpen (pen)` #e @pen-sections
  - `void defaults ()` #e @config-defaults
  - `void smooth.drawextra (dpar, smooth)` #e @smooth-smooth
  - `smooth smooth.dirscale (pair, real)` #e @smooth-dirscale
  - `void drawsections (picture, pair[][], pair, bool, bool, bool, real, pen, pen, pen)` #e @smooth-drawsections
  - `void drawcartsections (picture, path[], path[], real, bool, pair, bool, bool, bool, real, pen, pen, pen)` #e @smooth-drawcartsections
  - `void draw (picture, smooth, dpar)` #e @smooth-draw
  - `void draw (picture, smooth[], dpar)` #e @smooth-draw-spec
  - `void draw (picture, dpar ... smooth[])` #e @smooth-draw-spec-dots
  - `smooth[] drawintersect (picture, smooth, smooth, string, pair, pair, bool, bool, real, pair, dpar)` #e @smooth-drawintersect
  - `smooth[] drawintersect (picture, smooth[], string, pair, pair, bool, bool, real, pair, dpar)` #e @smooth-drawintersect-spec
  - `smooth[] drawintersect (picture, string, pair, pair, bool, bool, real, pair, dpar ... smooth[])` #e @smooth-drawintersect-spec
  - `void drawcommuting (picture, smooth[], real, pen, bool)` #e @smooth-drawcommuting
  - `void drawcommuting (picture, real, pen, bool ... smooth[])` #e @smooth-drawcommuting
  - `void drawarrow (picture, smooth, int, pair, smooth, int, pair, bool, real, real, real, bool, pair[], Label, pen, tarrow, tbar, bool, bool, bool, real, real)` #e @smooth-drawarrow
  - `void drawarrow (picture, string, string, real, real, real, bool, pair[], Label, pen, tarrow, tbar, bool, bool, bool, real, real)` #e @smooth-drawarrow-label
  - `void drawpath (picture, smooth, int, smooth, int, real, real, real, bool, pair[], Label, pen, bool, bool, bool, bool)` #e @smooth-drawpath
  - `void drawpath (picture, string, string, real, real, real, bool, pair[], Label, pen, bool, bool, bool, bool)` #e @smooth-drawpath-label
  - `void drawdeferred (picture, bool)` #e @def-drawdeferred
]

#section("E")[
  - `struct element` #e @smooth-ho-su-el
  - `path ellipsepath (pair, pair, real, bool)` #e @path-ellipsepath
  - `pen elementpen (pen)` #e @pen-elements
  - `element[] elementcopy (element[])` #e @smooth-elementcopy
  - `dpar emptypar ()` #e @dpar-emptypar
  - `int extractdeferredindex (picture)` #e @def-extractdeferredindex
  - `deferredPath[] extractdeferredpaths (picture, bool)` #e @def-extractdeferredpaths
]

#section("F")[
  - `int free` #e @mode-values
  - `int smooth.findlocalsubsetindex (string)` #e @smooth-findlocalsubsetindex
  - `int smooth.findlocalelementindex (string)` #e @smooth-findlocalelementindex
  - `smooth fit (int, picture, picture, pair)` #e @smooth-fit
  - `int findsmoothindex (string)` #e @smooth-findindex
  - `smooth findsm (string)` #e @smooth-find
  - `int findsubsetindex (string)` #e @smooth-findindex
  - `subset findsb (string)` #e @subset-find
  - `int findelementindex (string)` #e @smooth-findindex
  - `subset findelt (string)` #e @element-find
  - `int[] findbylabel (string)` #e @smooth-findbylabel
  - `void fitpath (picture, path, bool, int, bool, Label, pen, tarrow, tbar)` #e @def-fitpath
  - `void fitpath (picture, path, bool, int, Label, pen, bool, tarrow, tbar)` #e @def-fitpath-spec
  - `void fitpath (picture, guide, bool, int, Label, pen, bool, tarrow, tbar)` #e @def-fitpath-spec
  - `void fitpath (picture, path[], bool, int, Label, pen, bool)` #e @def-fitpath-spec
  - `void fillfitpath (picture, path, bool, int, Label, pen, pen, bool)` #e @def-fillfitpath
  - `void fillfitpath (picture, path[], bool, int, Label, pen, pen, bool)` #e @def-fillfitpath
  - `void flushdeferred (picture)` #e @def-flushdeferred
]

#section("G")[
  - `struct globalconfig` #e @config
  - `struct gauss` #e @misc-gauss
  - `dpar ghostpar (pen)` #e @dpar-ghostpar
  - `real smooth.getyratio (real)` #e @smooth-get-ratio-point
  - `real smooth.getxratio (real)` #e @smooth-get-ratio-point
  - `real smooth.getypoint (real)` #e @smooth-get-ratio-point
  - `real smooth.getxpoint (real)` #e @smooth-get-ratio-point
  - `path[] getdeferredpaths (picture)` #e @def-getdeferredpaths
]

#section("H")[
  - `struct helpconfig` #e @config-help
  - `struct hole` #e @smooth-ho-su-el
  - `void halt (string)` #e @debug-halt
  - `hole[] holecopy (hole[])` #e @smooth-holecopy
  - `path[] holecontours (hole[])` #e @smooth-holecontours
]

#section("I")[
  - `bool inside (real, real, real)` #e @misc-inside
  - `bool insidepath (path, path)` #e @path-insidepath
  - `int[] i (... int[])` #e @misc-i
  - `int[][] ii (... int[])` #e @misc-i
  - `real intersectiontime (path, pair, pair)` #e @path-intersectiontime
  - `pair intersection (path, pair, pair)` #e @path-intersection
  - `path[] intersection (path, path, bool, bool, real)` #e @path-set-intersection
  - `path[] intersection (path[], bool, bool, real)` #e @path-set-intersection-array
  - `path[] intersection (bool, bool, real ... path[])` #e @path-set-intersection-array-dots
  - `path[] intersection (path, path, path[], bool, bool, real)` #e @misc-intersection-holes
  - `pen inverse (p)` #e @misc-inverse
  - `bool smooth.inside (pair)` #e @smooth-inside
  - `smooth[] intersection (smooth, smooth, bool, bool, real, bool)` #e @smooth-intersection
  - `smooth[] intersection (smooth[], bool, bool, real, bool)` #e @smooth-intersection
  - `smooth[] intersection (bool, bool, real, bool ... smooth[])` #e @smooth-intersection
  - `smooth intersect (smooth[], bool, bool, real, bool)` #e @smooth-intersect
  - `smooth intersect (bool, bool, real, bool ... smooth[])` #e @smooth-intersect
]

#section("J")[ - --- ]

#section("K")[ - --- ]

#section("L")[ - --- ]

#section("M")[
  - `real mod (real, real)` #e @misc-mod
  - `bool meet (path, path)` #e @path-meet
  - `bool meet (path, path[])` #e @path-meet
  - `bool meet (path[], path[])` #e @path-meet
  - `path midpath (path, path, n)` #e @path-midpath
  - `string mode (int)` #e @misc-mode
  - `element element.move (transform)` #e @element-move
  - `element element.move (pair, real, real, pair, bool)` #e @element-move-spec
  - `hole hole.move (transform)` #e @hole-move
  - `hole hole.move (pair, real, real, pair, bool)` #e @hole-move-spec
  - `subset subset.move (transform)` #e @subset-move
  - `subset subset.move (pair, real, real, pair, bool)` #e @subset-move-spec
  - `smooth smooth.move (pair, real, real, pair, bool, bool)` #e @smooth-move
  - `smooth smooth.moveelement (int, pair)` #e @smooth-movelement
  - `smooth smooth.moveelement (string, pair)` #e @smooth-movelement-label
  - `smooth smooth.movehole (int, pair, real, real, pair, bool)` #e @smooth-movehole
  - `smooth smooth.movesubset (int, pair, real, real, pair, bool, bool, bool, bool, bool, bool)` #e @smooth-movesubset
  - `smooth smooth.movesubset (string, pair, real, real, pair, bool, bool, bool, bool, bool, bool)` #e @smooth-movesubset-label
]

#section("N")[
  - `path neigharc (real, real, int, real)` #e @path-neigharc
  - `pen nextsubsetpen (pen, real)` #e @pen-subsets
  - `smooth node (string, pair, real)` #e @smooth-node
  - `dpar nodepar (pen)` #e @smooth-nodepar
]

#section("O")[
  - `bool outsidepath (path, path)` #e @path-outsidepath
  - `bool smooth.onlyprimary (int)` #e @smooth-onlyprimary
  - `bool smooth.onlysecondary (int)` #e @smooth-onlysecondary
]

#section("P")[
  - `struct pathconfig` #e @config-path
  - `int plain` #e @mode-values
  - `pair[] p (... pair[])` #e @misc-p
  - `pair[][] pp (... pair[])` #e @misc-p
  - `path pop (path[])` #e @misc-pop
  - `void print (smooth)` #e @smooth-print
  - `void printall ()` #e @smooth-printall
  - `void purgedeferredunder (deferredPath[])` #e @def-purgedeferredunder
  - `void phantom (picture, smooth)` #e @smooth-phantom
  - `void plainshipout (string, picture, orientation, string, bool, bool, string, string, light, projection)` #e @def-shipout
  - `void plainerase (picture)` #e @def-shipout
  - `void plainapply (transform, picture)` #e @def-shipout
  - `void plainsave ()` #e @def-shipout
  - `void plainrestore ()` #e @def-shipout
]

#section("Q")[ - --- ]

#section("R")[
  - `path randomconvex ()` #e @path-randomdefault
  - `path randomconcave ()` #e @path-randomdefault
  - `real round (real, int)` #e @misc-round
  - `pair round (pair, int)` #e @misc-round
  - `real[] r (... real[] source)` #e @misc-r
  - `real[][] rr (... real[] source)` #e @misc-r
  - `repeatstring (string, int)` #e @misc-repeatstring
  - `real radius (path)` #e @path-radius
  - `real relarctime (path, real, real)` #e @path-relarctime
  - `path reorient (path, real)` #e @path-reorient
  - `pair range (path, pair, pair, real, real)` #e @path-range
  - `pair randomdir (pair, real)` #e @path-randomdirpath
  - `pair randompath (pair[], real)` #e @path-randomdirpath
  - `element element.replicate (element)` #e @element-replicate
  - `hole hole.replicate (hole)` #e @hole-replicate
  - `subset subset.replicate (subset)` #e @subset-replicate
  - `pair smooth.relative (pair)` #e @smooth-relative
  - `smooth smooth.rmelement (int)` #e @smooth-rmelement
  - `smooth smooth.rmelement (string)` #e @smooth-rmelement-label
  - `smooth smooth.rmhole (int)` #e @smooth-rmhole
  - `smooth smooth.rmholes (int[])` #e @smooth-rmholes
  - `smooth smooth.rmholes (... int[])` #e @smooth-rmholes
  - `smooth smooth.rmsection (int, int)` #e @smooth-rmsection
  - `smooth smooth.rmsubset (int, bool)` #e @smooth-rmsubset
  - `smooth smooth.rmsubset (string, bool)` #e @smooth-rmsubset-label
  - `smooth smooth.rmsubsets (int[], bool)` #e @smooth-rmsubsets
  - `smooth smooth.rmsubsets (bool ... int[])` #e @smooth-rmsubsets
  - `smooth smooth.rmsubsets (string[], bool)` #e @smooth-rmsubsets-label
  - `smooth smooth.rmsubsets (bool ... string[])` #e @smooth-rmsubsets-label
  - `smooth smooth.replicate (smooth)` #e @smooth-replicate
  - `smooth rotate (real)` #e @smooth-move-sssr
  - `smooth rn (int, pair, pair, real, real, bool)` #e @smooth-rn
  - `dpar rnpar ()` #e @smooth-rnpar
  - `void restore ()` #e @def-shipout
]

#section("S")[
  - `struct systemconfig` #e @config-system
  - `struct sectionconfig` #e @config-section
  - `struct smoothconfig` #e @config-smooth
  - `struct subset` #e @smooth-ho-su-el
  - `struct smooth` #e @smooth-smooth
  - `transform srap (real, real, pair)` #e @misc-srap
  - `string[] s (... string[])` #e @misc-s
  - `string[][] ss (... string[])` #e @misc-s
  - `path subcyclic (path, pair)` #e @path-subcyclic
  - `path[] symmetric (path, path, bool, bool, real)` #e @path-set-symmetric
  - `real sectionsymmetryrating (pair, pair, pair)` #e @section-quality
  - `real sectiontoobroad (pair, pair, pair, pair)` #e @section-quality
  - `pen sectionpen (pen)` #e @pen-sections
  - `pen shadepen (pen)` #e @pen-sections
  - `path[] sectionellipse (pair, pair, pair, pair, pair)` #e @smooth-sectionellipse
  - `pair[][] sectionparams (path, path, int, real, int)` #e @smooth-sectionparams
  - `subset[] subsetcopy (subset[])` #e @smooth-subsetcopy
  - `subset[] subsetintersection (subset, subset, bool)` #e @smooth-subsetintersection
  - `void subsetdelete (subset[], int, bool)` #e @smooth-subsetdelete
  - `int[] subsetgetlayer (subset[], int[], int)` #e @smooth-subsetgetlayer
  - `int[] subsetgetall (subset[], subset)` #e @smooth-subsetgetall
  - `int[] subsetgetall (subset[], int)` #e @smooth-subsetgetall
  - `int[] subsetgetallnot (subset[], subset)` #e @smooth-subsetgetallnot
  - `int[] subsetgetallnot (subset[], int)` #e @smooth-subsetgetallnot
  - `void subsetdeepen (subset[], subset)` #e @smooth-subsetdeepen
  - `int subsetinsertindex (subset[], int)` #e @smooth-subsetinsertindex
  - `int subsetmaxlayer (subset[], int[])` #e @smooth-subsetmaxlayer
  - `void subsetcleanreferences (subset[])` #e @smooth-subsetcleanreferences
  - `dpar dpar.subs (<...>)` #e @dpar-subs
  - `transform smooth.selfadjust ()` #e @smooth-selfadjust
  - `smooth smooth.setratios (real[], bool)` #e @smooth-setratios
  - `smooth smooth.setcenter (int, pair, bool)` #e @smooth-setcenter
  - `smooth smooth.setcenter (string, pair, bool)` #e @smooth-setcenter-label
  - `smooth smooth.setlabel (int, string, pair, pair)` #e @smooth-setlabel
  - `smooth smooth.setlabel (string, string, pair, pair)` #e @smooth-setlabel-label
  - `smooth smooth.setelement (int, element, int, bool)` #e @smooth-setelement
  - `smooth smooth.setelement (int, pair, string, pair, int, bool)` #e @smooth-setelement
  - `smooth smooth.setelement (string, element, bool)` #e @smooth-setelement-label
  - `smooth smooth.setelement (string, pair, string, pair, bool)` #e @smooth-setelement-label
  - `smooth smooth.setsection (int, int, real[])` #e @smooth-setsection
  - `smooth smooth.shift (explicit pair)` #e @smooth-move-sssr
  - `smooth smooth.shift (real, real)` #e @smooth-move-sssr
  - `smooth smooth.scale (real)` #e @smooth-move-sssr
  - `smooth samplesmooth (int, int, string)` #e @smooth-samplesmooth
  - `smooth sm (int, int, string)` #e @smooth-samplesmooth
  - `void shaderegion (picture, path, real, real, pen)` #e @misc-shaderegion
  - `void save ()` #e @def-shipout
]

#section("T")[
  - `struct tarrow` #e @def-tarrow
  - `struct tbar` #e @def-tbar
  - `path turn (path, pair, pair)` #e @path-turn
  - `smooth tangentspace (smooth, int, pair, real, real, real, real, string, pair)` #e @smooth-tangentspace
]

#section("U")[
  - `path ucircle` #e @path-upaths
  - `path usquare` #e @path-upaths
  - `real[] unitseq (real)` #e @misc-unitseq
  - `path[] union (path, path, bool, bool, real)` #e @path-set-union
  - `path[] union (path[], bool, bool, real)` #e @path-set-union-array
  - `path[] union (bool, bool, real ... path[])` #e @path-set-union-array-dots
  - `pen underpen (pen)` #e @pen-sections
  - `smooth[] union (smooth, smooth, bool, bool, real)` #e @smooth-union
  - `smooth[] union (smooth[], bool, bool, real)` #e @smooth-union
  - `smooth[] union (bool, bool, real ... smooth[])` #e @smooth-union
  - `smooth unite (smooth[], bool, bool, real)` #e @smooth-unite
  - `smooth unite (bool, bool, real ... smooth[])` #e @smooth-unite
]

#section("V")[ - --- ]

#section("W")[
  - `path wavypath (real[], bool, bool)` #e @path-wavypath
  - `path wavypath (... real[])` #e @path-wavypath
]

#section("X")[
  - `real xsize (path)` #e @path-size
  - `real xsize (picture)` #e @misc-size
  - `real subset.xsize ()` #e @subset-size
  - `real smooth.xsize ()` #e @smooth-size
  - `void smooth.xscale (real)` #e @smooth-xscale
]

#section("Y")[
  - `real ysize (path)` #e @path-size
  - `real ysize (picture)` #e @misc-size
  - `real subset.ysize ()` #e @subset-size
  - `real smooth.ysize ()` #e @smooth-size
]

#section("Z")[ - --- ]
