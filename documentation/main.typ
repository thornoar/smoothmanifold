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

In the `picture` structure, the paths drawn on a picture are not stored in an array, but rather indirectly stored in a `void` callback. That is, when the `draw` function is called, the _instruction to draw_ the path is added to the picture, not the path itself. This makes it quite impossible to "modify the path after it is drawn". To go around this limitation, `smoothmanifold` introduces an auxiliary struct:
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
+ Exploit the `nodes` field of the `picture` struct to store an integer. Retrieve this integer, say `n`, from `pic` (or create one if the `nodes` field doesn't contain it).
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

These structs store information about the arrow/bar, and are converted to regular arrowbars when the corresponding path is drawn to the picture. For creating new `tarrow`/`tbar` instances and converting them to arrowbars, the following functions are available:

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

Here, `config` is the global configuration structure, see @sc-config. Furthermore, there are corresponding `fillfitpath` <fillfitpath> functions that serve the same purpose as `filldraw`.

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

The functions `erase`, `add`, `save`, and `restore` are redefined to automatically handle deferred paths.

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
Calculate the time at which arclength `a` will be traveled along the path `g`, starting from time `t0`.

```
path arcsubpath (path g, real arc1, real arc2)
``` <path-arcsubpath> #vs
Calculate the subpath of `g`, starting from arclength `arc1`, and ending with arclength `arc2`.

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
Constuct a curved path between two points. Curvature may be relative (from $0$ to $1$) or absolute.

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
in the hole under `index`.

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
- `clip` --- if set to `false`, this leads to an error whenever `sb`'s contour is out of bounds with `this` objects's contour. If `clip` is set to true, then `sb`'s contour is clipped instead, and its `isonboundary` field is set to `true`;
- `unit` --- as usual, setting this to `true` leads to `sb` being interpreted in `this` objects's unit coordinates, see @sc-smooth-unit;
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
  // (... indices)
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
  ``` <subset-copy>
  #colbreak()
  ```
  hole replicate (hole h)
  ``` <subset-replicate>
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
  ``` <subset-copy>
  #colbreak()
  ```
  element replicate (element elt)
  ``` <subset-replicate>
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
``` <smooth-setcenter-label> #vs
An alternative to `setlabel` @smooth-setlabel, but finds the subset by label.

```
smooth setelement (
    string destlabel,
    pair pos = config.system.dummypair,
    string label = config.system.dummystring,
    pair labelalign = config.system.dummypair,
    bool unit = config.smooth.unit
) { return this.setelement(findlocalelementindex(destlabel), pos, label, labelalign, unit); }
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
  // (... destlabels)
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
```
int findlocalsubsetindex (string label)
``` <smooth-findlocalsubsetindex> #vs
Locate a subset of `this` by its label and return its index.

As a final step, module `smoothmanifold` defines a number of `operator cast` functions for full label integration:

```
smooth operator cast (string label)
smooth[] operator cast (string[] labels)
``` <smooth-cast> #vs
Cast a `string` to a `smooth` object.

```
subset operator cast (string label)
subset[] operator cast (string[] labels)
``` <subset-cast> #vs
Cast a `string` to a `subset` object.

```
element operator cast (string label)
element[] operator cast (string[] labels)
``` <element-cast> #vs
Cast a `string` to a `element` object.

These casts rely on the following auxiliary internal functions: #vs

#bl[
  #show: columns.with(2, gutter: 0pt)
  ```
  int findsmoothindex (string label)
  int[] findsubsetindex (string label)
  int[] findelementindex (string label)
  ``` <smooth-findindex>
  #colbreak()
  ```
  smooth findsm (string label)
  subset findsb (string label)
  element findelt (string label)
  ``` <smooth-find>
]

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

The `free` mode is usually the preferred mode for three-dimensional drawing, it can be enabled via #box[`mode = free`] in the `dpar` @smooth-dpar structure.

The implementation of the `free` mode relies heavily on the following technical routines:

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
  []
)
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
smooth smooth.setratios (real[] ratios, bool horiz)
``` <smooth-setratios> #vs
Set the horizontal/vertical cartesian ratios of `this` smooth object.

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
  )
- `pen sectionpen` --- the pen used to draw cross sections (their visible parts);
- `pen dashpen` --- the pen used to draw the "invisible" (dashed) parts of cross sections;
- `pen shadepen` --- the pen used to fill the section ellipses;
- `pen elementpen` --- the pen used to `dot` the elements of the smooth object;
- `pen labelpen` --- the pen used to `label` the label of the smooth object;
- `pen[] elementlabelpens` --- pens used to `label` the labels of the smooth object's elements. If the array is empty, then `labelpen` is used for all elements. If there are more elements than the length of `elementlabelpens`, then the last member of the array is used for all elements not covered;
- `pen[] subsetlabelpens` --- pens used to `label` the labels of the smooth object's subsets. `labelpen` is used in case `subsetlabelpens` is empty. All subsets not covered by the array use the last member thereof;
- `int mode` --- the drawing mode. Can be one of the four: `plain`, `free`, `cartesian`, `combined` (which have values of `0`, `1`, `2`, `3` respectively). Any other integer value would be accepted, but the consequences may be unpredictable;
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

== The `draw` function <sc-smooth-draw>

= Global configuration <sc-config>

== System variables <sc-config-system>

== Path variables <sc-config-path>

== Cross section variables <sc-config-section>

== Smooth object variables <sc-config-smooth>

== Drawing-related variables <sc-config-drawing>

== Help-related variables <sc-config-help>

== Arrow variables <sc-config-arrow>

= Debugging capabilities <sc-debug>

== Errors <sc-debug-errors>

Should you perform an erroneous calculation step (like adding an out-of-bounds subset to a smooth object, or referring to a non-existent label), `smoothmanifold` will crash with an error message.

== Warnings <sc-debug-warnings>

= Miscellaneous auxiliary routines <sc-misc>

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
Print all `smooth` objects in the global `smooth.cache` array.

= The `export.asy` auxiliary module <sc-export>

== The `export` routine <sc-export-function>

== Animations <sc-export-animations>

== Configuration <sc-export-config>

= Index <sc-index>
