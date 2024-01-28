# Module smoothmanifold

## Description

An [Asymptote](https://asymptote.sourceforge.io/) programming language library (module) that allows one to quickly and easily create and render high-quality diagrams in set-theoretical mathematics, that is, set theory, topology, differential geometry, etc.

Specifically the functionality focuses on set theory diagrams (sets, subsets, maps, elements) and differential geometry diagrams (smooth manifolds, tangent spaces, $\mathbb{R}^n$). The style of the figures is based on how they would be drawn in a textbook or in lecture notes. Three-dimensional objects (referred to as 'smooth objects') can be drawn, that resemble smooth manifolds in $\mathbb{R}^3$: spheres, tori, planes and other surfaces. However, most importantly, `smoothmanifold` does __not__ depend on the module `three` to render three-dimensional objects. They all are, in fact, completely flat, but made __look__ three-dimensional by imitating perspective and cross sections. This means that smooth objects enjoy all the benefits of vector graphics, which is one of Asymptote's selling points and which works (almost) only in 2D.

The module is extremely functional and flexible, while maintaining a simple and convenient user interface.

## Features

- `smoothmanifold` includes a dependency sub-module `pathmethods.asy` --- a collection of useful path functions essential for the main module, such as `path[] union (...)`, `path[] intersection (...)`, `pair center (...)` and more. In summary, cyclic paths in this sub-module are viewed as boundaries of areas on the plane, and its functions have to do with manipulating those areas. `pathmethods` can be very useful outside of `smoothmanifold` as well.

- The module itself features four most important custom structures -- object blueprints that possess particular attributes and represent particular sets of data:
    * `smooth` --- the main structure of the module. It has a `contour`, a `label`, and potentially multiple `holes` and `subsets`. It also stores a parameter `viewdir`, which is responsible for the illusion of three-dimensional rotation. It does not, however, need to be three-dimensional --- a `viewdir` of (0,0) will make it a regular flat area on the plane.
    * `hole` --- an area 'cut out of' a smooth object. Has a `contour` and different `section` parameters, which define the circular cross sections rendered on call of the `draw` function.
    * `subset` --- an area placed inside a smooth object.  Has its own `subset`s, a `contour` and a `label`. If you add two intersecting subsets to a smooth object, they will automatically intersect and produce a third subset. This way, `smoothmanifold` creates a tree of subsets where the user can easily navigate to any sub-subset by specifying an index sequence. See *examples/pictures/subset.intersection/* for detail.
    * `element` --- a point residing inside a smooth object or its subsets, representing an 'element of the set'. Has a `label`.

All paths that constitute these custom objects are meant to go __clockwise__, because that is the way they are usually drawn on paper and the way most people usually imagine a cyclic path. But don't worry --- even if you lose track of the orientation of your cyclic path, the constructor will correct it for you.

- Sophisticated user interface. Each of the custom structures is equipped with a smart `operator init` constructor, which requires minimal information from the user to construct a valid object. Changing an existing object is made very easy as well: each smooth object has its own 'unit coordinate system', which helps visually locate the preferred place to add a hole or subset. A collection of convenient building functions is also given, e.g. `copy`, `view`, `move`, `movesubset`, `addholesection`, `sethole`, etc. All functions are given in multiple versions corresponding to different input data. Case in point, you can access a subsets by its index, an index sequence, or its label. There are also pre-built arrays of paths and `smooth` objects for convenience. Finally, there is a collection of user methods (`drawparams`, `sectionparams`, etc.) for setting global parameters such as the default colors of smooth objects and their subsets, or the cross section mode.
    
    The module is highly configurable: default values can be set for the colors of drawing pens, the positions for cross sections, the precision of algorithms and many more. All configuration is done in the `smpar(...)` function which has 31 parameter.

- Wide drawing functionality. The main drawing function is

    ```asymptote
    void draw (picture pic = currentpicture,
               smooth sm,
               pen contourpen = currentpen,
               pen smoothfill = smoothcolor,
               pen subsetcontourpen = contourpen,
               pen subsetfill = subsetcolor,
               pen sectionpen = sectionpen(contourpen),
               pen dashpen = dashpen(sectionpen),
               pen shadepen = shadepen(smoothfill),
               pen elementpen = elementpen(contourpen),
               int mode = currentDrM,
               bool fill = currentDrF,
               bool fillsubsets = currentDrFS,
               bool drawcontour = currentDrDC,
               bool explain = currentDrE,
               bool dash = currentDrDD,
               bool shade = currentDrDS,
               bool avoidsubsets = currentSeAS,
               bool drag = true,
               bool overlap = currentDrO,
               bool drawnow = currentDrDN)
    ```

    With this function one can render a `smooth` object with different `pens` and other parameters. The illusion of volume can be created by multiple "cross sections" inside the figure. There are three cross section modes: `plain` (no sections, a plain 2D picture), `free` (searches for cross section positions that are most symmetric, the level of position freedom can be adjusted), and `cartesian` (renders only vertical and horizontal ("Cartesian") cross sections). Each mode has its use cases (see *examples/pictures/two.holes/*). The `explain` parameter can be used to hide or show auxiliary information about the object on the picture. It is beneficial for debugging. It can be controlled whether the interior or the contour of the smooth object are drawn.

    Further, an arrow can be drawn between two `smooth` objects or their subsets or their elements (see *examples/pictures/arrows.1*) with the routine `void drawarrow (...)`. The `drawintersect` function intersects two given `smooth` objects and draws this intersection with dim outlines of the original objects (see *examples/pictures/intersection.1*).

    `smoothmanifold` uses a system of deferred drawing. All paths that constitute the contours of smooth objects, holes and subsets, as well as arrows, are not immediately rendered, but rather remembered to be drawn at shipout time. This allows these paths to be changes 'after being drawn'. For example, an arrow drawn across a smooth object leaves gaps in the object's contour where it passes, and this is achieved by redefining the 'already drawn' contour paths. Or, when a smooth object covers another object, the contour of the latter will be 'redrawn' with a dashed pen, indicating that it is not visible. The `shipout` function is redefined in the module to automatically draw all cached paths, so there is no user input needed. As far as I know, this feature of deferred drawing is unique across Asymptote modules.

- Independence. `smoothmanifold` does not depend on any other Asymptote module, apart from its sub-module `pathmethods`.

## Installation

Download the `smoothmanifold.asy`, `pathmethods.asy`, and (optionally) `export.asy` files and insert this line in your code:

```asymptote
import smoothmanifold;
```

Make sure that the files are visible for Asymptote to import. You can specify the import directory by assigning the `settings.dir` variable in your `config.asy` file. For details of search paths refer to the official [documentation](https://asymptote.sourceforge.io/doc/Search-paths.html).

You can clone this git repository to receive regular updates.

## Basic usage

First, create a smooth object with

```asymptote
void operator init (path contour,
                    pair center = center(contour),
                    string label = "",
                    pair labeldir = N,
                    pair labelalign = defaultSyDP,
                    hole[] holes = {},
                    subset[] subsets = {},
                    real[] hratios = a(defaultSyDN),
                    real[] vratios = a(defaultSyDN),
                    pair shift = (0,0),
                    real scale = 1,
                    real rotate = 0,
                    pair viewdir = (0,0),
                    smooth[] attached = {},
                    bool unit = true,
                    bool copy = false,
                    bool shiftsubsets = currentSmSS,
                    bool isderivative = false)
```

The only required argument is `contour`, everything else is optional. To see examples of pre-built smooth objects, search for 'samplesmooth' in `smoothmanifold.asy`. Then, you may alter your object with functions s.a. `move`, `setlabel`, `addhole`, `view`, etc. You can derive new smooth objects with `union`, `intersection` and `copy()`. Finally, `draw` your object, or draw an arrow connecting two objects. You can `print()` your smooth objects to get parameter values in the console. For finer detail, wait for official documentation, explore the code examples, or read the comments in the module file.

## Optional extensions

`export.asy` --- a collection of routines that make it much easier to produce an output file from an Asymptote picture. Provides a function `void export (...)`, a sophisticated alternative to `shipout`. It allows for a faster production of rasterized images, it fixes this [issue](https://github.com/vectorgraphics/asymptote/issues/396), it avoids issues [this](https://github.com/PreTeXtBook/pretext/issues/1065) and [this](https://github.com/vectorgraphics/asymptote/issues/33) with SVG output, it allows for setting the picture background and margin, and it can default to plain `shipout` on demand. All that at the cost of using third-party conversion utilities such as ImageMagick and pdf2svg.

But this is not the end. `export.asy` provides a simple general animation interface. Given an update function, the module will compile you an animation in given quality and in any format supported by FFmpeg or ImageMagick. A nice terminal progress bar is included. Unlike the `animation` base module, the algorithm provided by `export` does not create a massive array of pictures, it only stores one at a time, which can be crucial for machines with little RAM.

The extension `export.asy` is dependent on and integrated with `smoothmanifold`, which makes the usage of the latter much more intuitive and simple. Much like the `smpar(...)` function of the main module, `export.asy` provides a configuration function `expar(...)` with 18 parameters, including default file extensions, background color and many more.

## Optional dependencies

As mentioned before, there is some third-party software needed for the correct work of the `export` extension. This includes ImageMagick's `mogrify` utility and `pdf2svg` for image format conversion, as well as FFmpeg for compiling animations. They do not, however, impact the functionality of the main module in any way.

## Contact

Any suggestions, bug reports, questions and contributions are most welcome. You can contact me via email: `r.a.maksimovich@gmail.com`, Telegram: `https://t.me/thornoar`, or open an issue on this GitHub repository. I will, however, kindly ask that any question or bug report be written in a readable manner and that it comply with the following scheme:

- Minimal reproducible example;
- Expected behavior;
- Actual behavior;
- Attempted steps to resolve the issue and ideas.

## License

The module is released under version 3 of the GNU General Public License (see the LICENSE file in source).
