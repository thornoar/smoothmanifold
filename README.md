# Module smoothmanifold

## Description

`smoothmanifold` is an Asymptote module that allows one to quickly and easily create and render high-quality `smooth` objects of topological and diff. geometric nature, similarly to how they would be drawn in a textbook or in lecture notes. These objects strongly resemble smooth two-dimensional manifolds in $\mathbb{R}^3$: spheres, tori, planes and other surfaces. However, most importantly, the module does __not__ depend on the package `three` to render three-dimensional objects. They all are, in fact, completely flat, but made __look__ three-dimensional by imitating perspective and projections. This means that `smoothmanifold` objects enjoy all the benefits of vector graphics, which is one of Asymptote's selling points and which works (almost) only in 2D.

## Features

- A wide collection of convenient functions. Examples include:
    * `void produce` (an advanced version of `shipout`);
    * `path reorient(path p, real time)` (makes `p` start at time `time`);
    * `path[] combination(path p, path q, ...)` (allows one to take unions, intersections, differences (i.e. set operations) on regions enclosed by `p` and `q`, and return the boundaries of the resulting regions);
    * `path randompath(pair[] controlpoints, ...)` (draws an 'arbitrary' smooth path connecting `controlpoints`);
    ...and many more. Many convenient operators are also provided, such as `p - q` for difference, `p & q` for intersection, and `p | q` for union.

- Three most important custom structures:
    * `smooth` --- the main class of the module. It has a `contour`, a `label`, and potentially multiple `holes` and `subsets`. It also stores a parameter `viewdir`, which is responsible for the illusion of three-dimensional rotation.
    * `hole` --- an area cut out of a `smooth` object. Has a `contour` and different `section` parameters, which define the circular cross sections rendered on call of the `draw` function.
    * `subset` --- an area placed inside a `smooth` object.  Has a `contour` and a `label`.

All paths that constitute these custom objects are meant to go __clockwise__, because that is the way they are usually drawn on paper and the way most people usually imagine a cyclic path. But don't worry -- even if you lose track of the orientation of your cyclic path, the constructor will correct it for you.

- Sophisticated object creation. Each of the custom structures is equipped with a smart `operator init`, which requires minimal information from the user to construct a valid object. Changing an existing object is made very easy as well: each `smooth` object has its own 'unit coordinate system', which helps visually locate the preferred place to add a hole or subset. A collection of convenient building functions is also given, e.g. `copy`, `view`, `move`, etc. Finally, there are pre-built arrays of paths and `smooth` objects.

- Wide drawing functionality. The main drawing function is

    ```asymptote
    void draw (picture pic = currentpicture, smooth sm, pen outlinepen = defaultSmCP, pen smoothpen = defaultSmP, pen subsetoutlinepen = outlinepen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+dashed+grey, pen shadepen = defaultSmSSP, string mode = defaultSmMode, bool explain = defaultSmE, bool shade = defaultSmSh, bool drawdashes = defaultSmDD, real margin = defaultSmM)
    ```

    With this function one can render a `smooth` object with different `pens`. The illusion of volume is created by multiple "cross sections" inside the figure. There are four cross section modes: `plain` (no sections, a plain 2D picture), `free` (searches for cross sections in most suitable locations, but provides little control of their positioning), `cart` (renders only vertical and horizontal ("cartesian") cross sections), and `strict` (similar to `free`, but uses a different searching algorithm, giving total control over technical aspects). Each mode has its use cases (see *examples/pictures/three.holes*). The `explain` parameter can be tweaked to hide or show auxillary information about the object on the picture. Useful for debugging.

    Furthermore, an `arrow` can be drawn between two `smooth` objects of their subsets (see *examples/pictures/arrows*). The `drawintersect` function intersects two given `smooth` objects and draws this intersection with dim outlines of the original objects (see *examples/pictures/intersection*).

- Animations. One can animate a `smooth` object `move` (shift, scale and rotate), or `revolve` (change its `viewdir` parameter, creating the illusion of three-dimensional rotation). The animation can be then converted to a video in any format supported by ffmpeg. See *examples/animations/*.

- Independence. `smoothmanifold` does not depend on any other Asymptote module.

## Installation

Just download the `smoothmanifold.asy` file and insert this line in your code:

```asymptote
import "/path/to/smoothmanifold.asy" as smooth;
```

You can clone this git repository to receive regular updates.

## Basic usage

First, you create a `smooth` object with

```asymptote
void operator init (path contour, pair center = center(contour), string label = "", pair labeldir = N, pair labelalign = dummypair, hole[] holes = {}, subset[] subsets = {}, real[] hratios = {}, real[] vratios = {}, pair shift = (0,0), real scale = 1, real rotate = 0, pair viewdir = (0,0), bool unit = true, bool copy = false, bool shiftsubsets = currentSmSS)
```

The only required argument is `contour`, everything else is optional. To see examples of pre-built `smooth` objects, search for 'samplesmooth' in `smoothmanifold.asy`. Then, you may alter your object with functions s.a. `move`, `setlabel`, `addhole`, `union`, `intersection`, `view`, etc. Finally, `draw` your object, or draw an `arrow` connecting two objects. For finer detail, wait for official documentation, explore the code examples, or read the comments in the module file.

## Contact

Any suggestions, bug reports, questions and contributions are most welcome. You can contact me via email: `r.a.maksimovich@gmail.com`, Telegram: `https://t.me/thornoar`, or open an issue on this GitHub repository. I will, however, kindly ask that any question or bug report be written in a readable manner and that it comply with the following scheme:

- Minimal reproducible example;
- Expected behavior;
- Actual behavior;
- Attempted steps to resolve the issue and ideas.

## License

The module is released under version 3 of the GNU General Public License (see the LICENSE file in source).
