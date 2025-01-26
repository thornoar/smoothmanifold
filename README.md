# Module smoothmanifold

## Description

An [Asymptote](https://asymptote.sourceforge.io/) programming language library (module) that allows one to quickly and easily create and render high-quality diagrams in higher mathematics, that is, set theory, category theory, topology, differential geometry, and many more. The module is useful for any case that involves placing meaningful objects on the plane and connecting them with arrows, or drawing paths on them.

Specifically the functionality focuses on set theory diagrams (sets, subsets, maps, elements) and differential geometry diagrams (smooth manifolds, tangent spaces, $\mathbb{R}^n$). The style of the figures is based on how they would be drawn in a textbook or in lecture notes. The module provides a rich set of instruments to position and manipulate blobs ("sets") on a plane, intersect and unite them, draw arrows between them, etc. Three-dimensional objects can also be drawn, that resemble smooth manifolds in $\mathbb{R}^3$: spheres, tori, planes and other common surfaces. However, most importantly, `smoothmanifold` does __not__ depend on the module `three` to render three-dimensional objects. They all are, in fact, completely flat, but made _look_ three-dimensional by imitating perspective and drawing cross sections. This means that smooth objects enjoy all the benefits of vector graphics, which is one of Asymptote's selling points and which works (almost) only in 2D. Plus, 3D is sometimes broken in Asymptote anyway, so it can be really nice to have a 2D solution.

The module is extremely functional and flexible, while maintaining a simple and convenient user interface.

## Features

- `smoothmanifold` includes a dependency sub-module `pathmethods.asy` --- a collection of useful path functions essential for the main module, such as `path[] union (...)`, `path[] intersection (...)`, `pair center (...)` and more. In summary, cyclic paths in this sub-module are viewed as boundaries of areas on the plane, and its functions have to do with manipulating those areas (intersecting, finding the center, etc.). `pathmethods` can be very useful outside of `smoothmanifold` as well.

- The module itself features four main custom structures --- object blueprints that possess particular attributes and represent particular sets of data:
    * `smooth` --- the main structure of the module. It has a bounding cyclical `contour`, a string `label`, and potentially multiple `holes` and `subsets`. The structure does not store information about how it will be drawn --- it is only an abstract object. The drawing is done with the `draw` function. The `smooth` objects can be copied, moved, intersected with each other, and more. See *examples/pictures* for examples.
    * `hole` --- an area 'cut out of' a smooth object. Has a cyclical `contour` and different `section` parameters which define the elliptical cross sections rendered when drawing the smooth object.
    * `subset` --- an area placed inside a smooth object.  Has a `contour`, a `label`, and may have its own `subset`s. If you add two intersecting subsets to a smooth object, they will automatically intersect and produce a third subset. This way, `smoothmanifold` creates a tree of subsets where the user can easily navigate to any sub-subset. See *examples/pictures/subset.intersection/* for examples.
    * `element` --- a point residing inside a smooth object or its subset, representing an 'element of the set'. Has a `pos`ition and a `label`. Elements can be connected with on-surface paths, see *examples/pictures/surface.paths/*.

All paths that constitute these custom objects are meant to go __clockwise__, because that is the way they are usually drawn on paper and the way most people usually imagine a cyclic path. But don't worry --- even if you lose track of the orientation of your cyclic path, the constructor will correct it for you (unless you disable the correction --- all such features are customizable).

- Sophisticated user interface. Each of the custom structures is equipped with a smart `operator init` constructor, which requires minimal information from the user to construct a valid object. Changing an existing object is made very easy as well: each smooth object has its own 'unit coordinate system', which helps visually locate the preferred place to add a hole, subset, or element. This feature is disabled by default to avoid confusion, but can be enabled with the `unit = true` option in the constructor (or in the `smpar(...)` configuration function for global effect). For smooth objects, a collection of convenient building functions is given, e.g. `copy`, `move`, `movesubset`, `addholesection`, `sethole`, etc. All functions are given in multiple versions corresponding to different input data. Case in point, you can add a hole by providing the hole itself, or by specifying its contour, center, and other information. There are also pre-built arrays of paths and `smooth` objects for quick access.
    
- High configurability: default values can be set for the colors of drawing pens, the positions for cross sections, the precision of algorithms and many more. All configuration is done in the `smpar(...)` function which has 50 parameters.

- Easy access by label. For example, if there are two `smooth` objects with labels `"M"` and `"N"`, an arrow can be drawn between them with `drawarrow("M", "N")`. The smooth objects themselves can be drawn with `draw("M")` and `draw("N")`. Label access also works for `subset`s and `element`s in most cases. An arrow connecting an element `"x"` to a subset `"U"` (in the same or different smooth objects alike) can be drawn with `drawarrow("x", "U", ...)`. See __examples/pictures/arrows.2__ for more examples. The labels themselves can be disabled in the final picture, such that they serve only an in-code reference function.

- Wide drawing functionality. The main drawing function is
    ```asymptote
    void draw (
        picture pic = currentpicture,
        smooth sm,
        dpar dspec = null
    )
    ```
    Here `dpar` is an auxiliary structure that contains all the drawing parameters for the smooth object, such as the contour pen, the filling pen, multiple boolean flags, and many more. Virtually every aspect of the drawing can be controlled. Should one like to render a 3D-looking object, the illusion of volume can be created by multiple "cross sections" inside the blob. There are three cross section modes: `plain` (no sections, a plain 2D picture), `free` (searches for cross section positions that are most symmetric, the level of position freedom can be adjusted), and `cartesian` (renders only vertical and horizontal ("Cartesian") cross sections). Each mode has its use cases (see *examples/pictures/two.holes/*). All the cross sections will be 'aligned' as if the smooth object were a three-dimensional surface that is turned along a certain direction. This direction (and magnitude) can be controlled with the `viewdir` attribute of the drawing structure `dpar` (or globally as an argument to `smpar (...)`). The `help` attribute can be toggled (locally or globally) to hide or show auxiliary information about the object on the picture.
    Further, an arrow can be drawn between two `smooth` objects or their subsets or their elements (see *examples/pictures/logo*) with the routine `void drawarrow (...)`. The `drawpath` function draws a smooth path between two elements, with adjustable control points. The `drawintersect` function intersects two given `smooth` objects and draws this intersection with dim outlines of the original objects (see *examples/pictures/intersection.1*).
    `smoothmanifold` uses a system of deferred drawing. All paths that constitute the contours of smooth objects, holes and subsets, as well as arrows and paths, are not immediately rendered, but rather remembered to be drawn at shipout time. This allows these paths to be changed "after being drawn". For example, an arrow drawn across a smooth object leaves gaps in the object's contour where it passes, and this is achieved by redefining the "already drawn" contour paths. Or, when a smooth object covers another object, the contour of the latter will be 'redrawn' with a dashed pen, indicating that it is not visible. The `shipout` function is redefined in the module to automatically draw all cached paths, so there is no user input needed. As far as I know, this feature of deferred drawing is unique across Asymptote modules.

- Independence. `smoothmanifold` does not depend on any other Asymptote module, apart from its sub-module `pathmethods`.

## Installation

Download the `smoothmanifold.asy`, `pathmethods.asy`, and (optionally) `export.asy` files and insert this line in your code:

```asymptote
import smoothmanifold;
```

Make sure that the files are visible for Asymptote to import. You can specify the import directory by assigning the `settings.dir` variable in your `config.asy` file, or simply put the downloaded library right into your project root directory. For details of search paths refer to the official [documentation](https://asymptote.sourceforge.io/doc/Search-paths.html).

You can clone this git repository to receive regular updates.

## Basic usage

First, create a `smooth` object with

```asymptote
void operator init (
    path contour,
    pair center = center(contour),
    string label = "",
    pair labeldir = N,
    pair labelalign = defaultSyDP,
    hole[] holes = {},
    subset[] subsets = {},
    element[] elements = {},
    real[] hratios = r(defaultSyDN),
    real[] vratios = r(defaultSyDN),
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    pair viewdir = currentSmVD,
    bool distort = true,
    smooth[] attached = {},
    bool copy = false,
    bool shiftsubsets = currentSmSS,
    bool isderivative = false,
    void postdraw (dpar ds) = new void (dpar) {} 
)
```

The only required argument is `contour`, everything else is optional. To see examples of pre-built smooth objects, search for the 'samplesmooth' function in `smoothmanifold.asy`. Then, you may alter your object with functions s.a. `move`, `setlabel`, `addhole`, etc. You can derive new smooth objects with `union`, `intersection` and `copy()`. Finally, `draw` your object, or draw an arrow connecting two objects with `drawarrow`. You can `print()` your smooth objects to get parameter values in the console. For finer detail, wait for official documentation, explore the code examples, or read the comments in the module file.

## Optional extensions

`export.asy` --- a collection of routines that make it much easier to produce an output file from an Asymptote picture. Provides a function `void export (...)`, a sophisticated alternative to `shipout`. It allows for a faster production of rasterized images, it fixes this [issue](https://github.com/vectorgraphics/asymptote/issues/396), it avoids issues [this](https://github.com/PreTeXtBook/pretext/issues/1065) and [this](https://github.com/vectorgraphics/asymptote/issues/33) with SVG output, it allows for setting the picture background and margin, and it can default to plain `shipout` on demand. All that at the cost of using third-party conversion utilities such as ImageMagick and pdf2svg. The extension also has cool grid functionality. If enabled by calling `expar(drawgrid = true)`, it will draw a numbered grid on the final picture, which is very helpful to understand which points have which coordinates, and have an idea which coordinates to use next.

But this is not the end. `export.asy` provides a simple general animation interface. Given an update function, the module will compile you an animation in given quality and in any format supported by FFmpeg or ImageMagick. A nice terminal progress bar is included. Unlike the `animation` base module, the algorithm provided by `export` does not create a massive array of pictures, it only stores one at a time, which can be crucial for machines with little RAM.

The extension `export.asy` is dependent on and integrated with `smoothmanifold`, which makes the usage of the latter much more intuitive and simple. Much like the `smpar(...)` function of the main module, `export.asy` provides a configuration function `expar(...)` with 19 parameters, including default file extensions, background color and many more.

## Optional dependencies

As mentioned before, there is some third-party software needed for the correct work of the `export` extension. This includes ImageMagick's `mogrify` utility and `pdf2svg` for image format conversion, as well as FFmpeg for compiling animations. They do not, however, impact the functionality of the main module in any way.

## Contact

Any suggestions, bug reports, questions and contributions are most welcome. You can contact me via email: `r.a.maksimovich@gmail.com`, Telegram: `https://t.me/thornoar`, or open an issue on this GitHub repository. I will, however, kindly ask that any question or bug report be written in a readable manner and that it comply with the following scheme:

- Minimal reproducible example;
- Expected behavior;
- Actual behavior;
- Attempted steps to resolve the issue and ideas.

## License

The module is released under version 3 of the GNU Lesser General Public License (see the LICENSE and LICENSE.LESSER files attached).
