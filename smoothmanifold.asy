/*

This is module smoothmanifold. It is designed to construct and render
high-quality Asymptote figures that display sets as 2D or 3D surfaces on the plane.

Copyright (C) 2024 Maksimovich Roman Alekseevich. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

*/

// >keywords
/*  config, tarrow, tbar, values, support,
    generic, system, pens, technical, structs,
    hole, subset, dpar, smooth, finding,
    deferredPath, operations, intersections,
    unions, drawing, redefining
*/

// >config | Configuration structures

struct systemconfig {
    string version = "v6.3.0-alpha";
    int dummynumber = -10000;
    string dummystring = (string) dummynumber;
    pair dummypair = (dummynumber, dummynumber);
    bool repeatlabels = false; // whether to allow two entities to have one label.
    bool insertdollars = true; // whether to automatically insert dollars in labels.
}

struct pathconfig {
    real roundcoeff = .03; // how much to round the corners when combining paths
    real range = 30; // angle range for random paths. the more -- the more random
    real neighheight = .05; // see `path neigharc()`
    real neighwidth = .01; // see `path neigharc()`
}

struct sectionconfig {
    real maxbreadth = .65; // how wide the section can be.
    real freedom = .3; // how freely sections can deviate from their target positions.
    int precision = 20; // how many points to sample in search for good section position.
    real elprecision = -1; // precision used in bin. search to construct tangent ellipses for cross sections. A value of -1 uses exact formula instead of binary search.
    bool avoidsubsets = false; // [A]void [S]ubsets
    real[] default = new real[] {-10000,235,5}; // default expressed in section notation.
}

struct smoothconfig {
    int interholenumber = 1; // default # of sections between holes.
    real interholeangle = 25; // range to be used for interhole sections.
    real maxsectionlength = -1; // how long (in diameter) a section can be, compared to the size of parent object. A value of -1 means no restriction.
    real rejectcurve = .15; // defines the condition for drawing sections between two holes (or in cartesian mode).
    real edgemargin = .07; // no point in explaining, see the use cases.
    real stepdistance = .15; //||--
    real nodesize = 1; // the size of nodes.
    real maxlength; // [M]aximum [L]ength
    bool inferlabels = true; // whether to create labels like "A \cap B" on intersection.
    bool shiftsubsets = false; // whether to shift subsets on view.
    bool addsubsets = true; // whether to intersect subsets in smooth object intersections.
    bool correct = true; // [C]orrect [C]ontour
    bool clip = false; // [C]lip
    bool unit = false; // [U]nit
    bool setcenter = true; // [S]et [C]enter
}

struct drawingconfig {
    pair viewdir = (0,0); // the default direction of the view.
    real viewscale = 0.12; // how much the `viewdir` parameter is scaled down.
    real gaplength = .05; // the length of the gap made on path overlaps.
    pen smoothfill = lightgrey; // the filling color of smooth objects.
    pen[] subsetfill = {}; // the filling color of layer 0 subsets.
    real sectpenscale = .6; // how thinner the section pen is compared to the contour pen.
    real elpenwidth = 3.0; // pen width to draw element dots.
    real shadescale = .85; // how darker shaded areas are compared to object filling color.
    real dashpenscale = .4; // how lighter dashed lines are compared to regular ones.
    real dashopacity = .4; // opacity of dashed pens.
    real attachedopacity = .8; // opacity of smooth objects attached to main object.
    real subpenfactor = .5; // how darker subsets get with each new layer.
    real subpenbrighten = .5; // How brighter to make the fill color of a subset than its contour color.
    pen sectionpen = nullpen;
    real lineshadeangle = 45;
    real lineshadedensity = 0.15;
    real lineshademargin = 0.1;
    pen lineshadepen = lightgrey;
    int mode = 0; // [M]ode
    bool useopacity = false; // [U]se [O]pacity
    bool dashes = true; // [D]raw [D]ashes
    bool underdashes = false; // [D]raw [U]nder [D]ashes
    bool shade = false; // [D]raw [S]hade
    bool labels = true; // [D]raw [L]abels
    bool fill = true; // [F]ill
    bool fillsubsets = true; // [F]ill [S]ubsets
    bool drawcontour = true; // [D]raw [C]ontour
    bool drawsubsetcontour = true; // [D]raw [S]ubset [C]ontour
    bool pathrandom = false; // [P]ath [R]andom
    bool overlap = false; // [O]verlap
    bool drawnow = false; // [D]raw [N]ow
    bool postdrawover = false; // [P]ost [D]raw [O]ver
    bool subsetoverlap = false; // [S]ubset [C]outour [O]verlap
}

struct helpconfig {
    bool enable = false;
    real arcratio = 0.2; // the radius of the arc around the center of a hole
    real arrowlength = .2; // the length of help arrows
    pen linewidth = linewidth(.3); // the width of help lines
}

// >tarrow | A more descriptive analog of `arrowbar` for arrows
struct tarrow
{
    arrowhead head;
    real size;
    real angle;
    filltype ftype;
    bool begin;
    bool end;
    bool arc;
}

// >tbar | A more descriptive analog of `arrowbar` for bars
struct tbar
{
    real size;
    bool begin;
    bool end;
}

struct arrowconfig {
    real mar = 0.03; // the margin of arrows from the edge of the object.
    tarrow currentarrow = null;
    tbar currentbar = null;
    bool absmargins = true; // whether arrow margins should be absolute.
}

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

// >values | A collection of pre-defined convenience values

restricted path[] convexpaths = new path[] { // [C]on[V]ex
    (-1.00195,0)..controls (-0.990469,1.33363) and (1.00998,1.31642)..(0.998502,-0.0172156)..controls (0.987026,-1.35085) and (-1.01342,-1.33363)..cycle,
    (-1.26284,0.599848)..controls (-0.829364,1.45475) and (1.64169,0.399899)..(1.07867,-0.86294)..controls (0.74517,-1.61099) and (-1.83112,-0.520921)..cycle,
    (-0.841836,0.446343)..controls (-0.227446,1.55993) and (1.50685,0.5614)..(0.858786,-0.590415)..controls (0.161022,-1.83057) and (-1.33903,-0.454818)..cycle,
    (-1.0522,0.0600251)..controls (-0.572004,1.31702) and (1.08045,1.07692)..(1.0522,-0.176544)..controls (1.0259,-1.34403) and (-1.457,-0.999597)..cycle,
    (-1.3015,0.292664)..controls (-1.16377,1.02949) and (1.58727,0.964071)..(1.08802,-0.447604)..controls (0.699265,-1.54686) and (-1.45274,-0.516484)..cycle,
    (-0.7747,-0.578443)..controls (-1.27059,0.149293) and (-1.30873,0.619498)..(-0.623203,0.977844)..controls (-0.168712,1.21542) and (0.994515,0.849099)..(0.943412,-0.00688622)..controls (0.860778,-1.39102) and (-0.244461,-1.35659)..cycle,
    (0.890573,-0.36047)..controls (-0.148296,-1.45705) and (-1.29345,-1.23691) .. (-0.996593,0.106021) .. controls (-0.669702,1.58481) and (2.03559,0.848164)..cycle,
    (-0.723053,0.87455)..controls (-0.120509,1.45988) and (1.49431,0.148054)..(0.864221,-0.795359)..controls (0.400434,-1.48977) and (-1.84643,-0.216729)..cycle,
    (0.28979,-0.834028)..controls (0.093337,-0.908653) and (-1.20138,-1.95019)..(-1.15209,0.0777484)..controls (-1.10261,2.11334) and (3.02512,0.204973)..cycle,
    (1.01073,-0.409946)..controls (0.812824,-1.99319) and (-2.2123,-0.523035)..(-0.897641,0.36047)..controls (0.779873,1.48783) and (1.20823,1.17008)..cycle,
    (0.636123,-0.975389)..controls (-0.853465,-1.50787) and (-1.37827,0.219109)..(-0.770416,0.961253)..controls (-0.154452,1.7133) and (2.19816,-0.417014)..cycle,
    (0.805756,0.918845)..controls (1.7034,-0.664395) and (-0.374882,-1.93278)..(-0.890573,-0.742144)..controls (-1.3712,0.367538) and (0.34086,1.73882)..cycle,
    (0.572511,-0.925913)..controls (-1.47015,-1.5479) and (-1.32586,0.925729)..(-0.28979,1.00366)..controls (1.30759,1.12382) and (1.65924,-0.595004)..cycle,
    (-1.08848,-0.169633)..controls (-1.65294,0.930585) and (1.00971,1.66132)..(1.0178,0.0282721)..controls (1.02487,-1.39947) and (-0.671464,-0.982457)..cycle
};
restricted path[] concavepaths = new path[] { // [C]on[C]ave
    (
        (-0.9,0).. controls
        (-1.07649842837266,0.638748977821067) and
        (-0.964116819714307,1.31556675048848) 
        ..(-0.46,1.3).. controls
        (0.0281888161644762,1.28492509435253) and
        (0.0424415730404705,0.611597145023648) 
        ..(0.4,0.36).. controls
        (0.623716050683286,0.202581476469435) and
        (0.955392557398132,0.2268850080704) 
        ..(1.12,0).. controls
        (1.39778902724123,-0.382887703564746) and
        (1.00985460296201,-0.913845673503591) 
        ..(0.4,-1).. controls
        (0.0314808795565626,-1.05206079689921) and
        (-0.356264634361184,-0.976905732695238) 
        ..(-0.6,-0.7).. controls
        (-0.770480811250471,-0.506318160575248) and
        (-0.831474513408123,-0.247994188496873) 
        ..cycle
    ),
    (
        (0.523035,-1.10261)..controls
        (-2.62474,-1.37362) and
        (0.932069,3.11139)..(0.558375,0.388742)..controls
        (0.508899,0.0282721) and
        (1.59031,-1.01073)..cycle
    ),
    (
        (-1.4,0).. controls
        (-1.4330976353941,0.309902105154151) and
        (-1.14752451684655,0.558611632511754) 
        ..(-0.84,0.49).. controls
        (-0.66443424676999,0.450829617534925) and
        (-0.529507080118944,0.301231459889368) 
        ..(-0.35,0.28).. controls
        (0.10216096608008,0.226520006851507) and
        (0.27539586949137,0.862356630570909) 
        ..(0.7,0.91).. controls
        (1.05908418967551,0.950291602166852) and
        (1.33041677912753,0.603698618857815) 
        ..(1.33,0.21).. controls
        (1.32951602626534,-0.247172104636948) and
        (1.00821765736334,-0.645111266508212) 
        ..(0.56,-0.7).. controls
        (0.274611440338081,-0.734948682488405) and
        (0.00179568356868698,-0.609311459905892) 
        ..(-0.28,-0.56).. controls
        (-0.46548899922109,-0.527541258147606) and
        (-0.65562744488586,-0.528541447729153) 
        ..(-0.84,-0.49).. controls
        (-1.11441028298393,-0.432636963666203) and
        (-1.37134558383179,-0.268299042718725) 
        ..cycle
    ),
    (
        (-0.74,1.11).. controls
        (-0.45217186192491,1.16995417728509) and
        (-0.244186500029556,0.896228533675695) 
        ..(-1.11022302462516e-16,0.74).. controls
        (0.394876451006404,0.487361263147939) and
        (1.0095388806718,0.479180198886787)
        ..(1.11,1.1327982892113e-16).. controls
        (1.33690476375748,-1.08229204047052) and
        (-0.898239052326633,-1.59366714480983)
        ..(-1.11,0.37).. controls
        (-1.14560254698906,0.700143742564816) and
        (-1.03848931729363,1.04782511478409) ..cycle
    ),
    (
        (-1.35,0).. controls
        (-1.18010190019904,0.416395394711846) and
        (-0.593260371382216,0.281172231186116) 
        ..(-0.27,0.54).. controls
        (0.0113914268982608,0.76530418707376) and
        (0.0415625335934956,1.24549540856936) 
        ..(0.405,1.35).. controls
        (1.23327036593247,1.5881649229556) and
        (1.85490272745839,-0.0949264215164867) 
        ..(0.27,-0.675).. controls
        (0.0952777069905893,-0.738948268869059) and
        (-0.0857655726904087,-0.78403391700961) 
        ..(-0.27,-0.81).. controls
        (-0.962087418222204,-0.907543111787485) and
        (-1.54255992615578,-0.471936216774976) 
        ..cycle
    ),
    (
        (-0.69,0.23).. controls
        (-0.56530943588509,0.830213108154057) and
        (-0.490658723837313,1.55646651437028) 
        ..(0,1.38).. controls
        (0.325235552510512,1.26302830152094) and
        (0.237200927517758,0.801860482003199) 
        ..(0.46,0.575).. controls
        (0.619891745450561,0.41219358416926) and
        (0.894509662874465,0.412735950982866) 
        ..(1.035,0.23).. controls
        (1.25559773374585,-0.0569317384062731) and
        (1.01749624107123,-0.438647936878262) 
        ..(0.69,-0.69).. controls
        (0.106935122935565,-1.13749997528092) and
        (-0.664799927016652,-1.18767474273486) 
        ..(-0.851,-0.644).. controls
        (-0.950985536038634,-0.352058059741617) and
        (-0.751751264242251,-0.0672471774939401) ..cycle
    ),
    (
        (-0.84,-0.24).. controls
        (-1.18825254216645,0.432752580408028) and
        (-0.749760426462422,1.11594975136258) 
        ..(-0.24,0.96).. controls
        (0.0302529853898903,0.877322170006355) and
        (0.10736936611544,0.557158491533225) 
        ..(0.3,0.36).. controls
        (0.513175121412852,0.141814114802958) and
        (0.878268025246844,0.063643117790086) 
        ..(0.96,-0.24).. controls
        (1.09910636339287,-0.756795171199751) and
        (0.418309528013558,-1.17658493090488) 
        ..(-0.24,-0.84).. controls
        (-0.497994898468632,-0.708090630046164) and
        (-0.706794583247006,-0.497325581279094) 
        ..cycle
    )
};

restricted path randomconvex ()
{ return convexpaths[rand()%convexpaths.length]; }

restricted path randomconcave ()
{ return concavepaths[rand()%concavepaths.length]; }

private path[] debugpaths; // [D]ebug [P]aths

restricted int plain = 0;
restricted int free = 1;
restricted int cartesian = 2;
restricted int combined = 3;
restricted int dn = config.system.dummynumber;
restricted arrowbar simple = Arrow(SimpleHead);
restricted arrowbar simples = Arrows(SimpleHead);
restricted path ucircle = reverse(unitcircle); // [U]nit [C]ircle
restricted path usquare = (1,1) -- (1,-1) -- (-1,-1) -- (-1,1) -- cycle; // [U]nit [S]quare

// >support | Supportiong utility functions

real mod (real a, real b)
// Calculate a % b.
{
    if (b < 0) return -1;
    while (a < 0) a += b;
    while (a > b) a -= b;
    return a;
}

pair center (
    path p,
    int n = 10,
    bool arc = true
) /*
    Calculate the center of mass of the area enclosed by the path `p`.
    The `arc` parameter determines whether arclength should be used
    instead of path time. If the resulting point is outside of the
    area, a point inside the area with the same y-coordinate is
    chosen.
*/
{
    pair sum = (0,0);
    for (int i = 0; i < n; ++i)
    { sum += point(p, arc ? arctime(p, arclength(p)*i/n) : (length(p) * i/n)); }
    if (inside(p, sum/n)) return sum/n;
    real[] times = times(p, (0, ypart(sum/n)));
    return (point(p, times[0]) + point(p, times[1])) * .5;
}

transform srap (real scale, real rotate, pair point)
// [S]cale [R]otate [A]round [P]oint
{ return shift(point)*scale(scale)*rotate(rotate)*shift(-point); }

bool inside (real a, real b, real c)
// Check if a <= c <= b.
{ return (a <= c && c <= b); }

bool insidepath (path p, path q)
// Check if q is completely inside p (the directions of p and q do not matter). Shorthand for inside(p, q) == 1
{ return (inside(p, q, evenodd) == 1); }

transform dscale (
    real scale,
    pair dir,
    pair center = (0,0)
) // Scale in given direction
{
    if (length(dir) == 0) return identity;
    return rotate(degrees(dir), center) * xscale(scale) * rotate(-degrees(dir), center);
}

pair comb (pair a, pair b, real t)
// A linear combination.
{ return t*b + (1-t)*a;}

real round (real a, int places)
// Leave the given number of decimal places.
{ return floor(10^places*a)*.1^places; }

pair round (pair a, int places)
// Leave the given number of decimal places, in each coordinate.
{ return (round(a.x, places), round(a.y, places)); }

// The following functions make array creation less of a boilerplate, much like in the R language.

real[] r (... real[] source)
{ return source; }
real[][] dr (... real[][] source)
{ return source; }
real[][] rr (... real[] source)
{ return new real[][]{source}; }

pair[] p (... pair[] source)
{ return source; }
pair[][] dp (... pair[][] source)
{ return source; }
pair[][] pp (... pair[] source)
{ return new pair[][]{source}; }

int[] i (... int[] source)
{ return source; }
int[][] di (... int[][] source)
{ return source; }
int[][] ii (... int[] source)
{ return new int[][]{source}; }

path[] c (... path[] source)
{ return source; }
path[][] dc (... path[][] source)
{ return source; }
path[][] cc (... path[] source)
{ return new path[][]{source}; }

string[] s (... string[] source)
{ return source; }
string[][] ds (... string[][] source)
{ return source; }
string[][] ss (... string[] source)
{ return new string[][]{source}; }

string repeatstring (string str, int n)
{
    if (n == 0) return "";
    return repeatstring(str, n-1) + str;
}

// Array functions

pair[] concat (pair[][] a)
// Same as the standard Asymptote `concat` functions, but with more than two arguments.
{
    if (a.length == 1) return a[0];
    pair[] b = a.pop();
    return concat(concat(a), b);
}
path[] concat (path[][] a)
{
    if (a.length == 0) return new path[];
    if (a.length == 1) return a[0];
    path[] b = a.pop();
    return concat(concat(a), b);
}

real[] unitseq (real step)
{
    real[] res;
    real cur = step;
    while (cur < 1)
    {
        res.push(cur);
        cur += step;
    }
    return res;
}

bool contains (int[] source, int a)
{
    bool res = false;
    for (int i = 0; i < source.length; ++i)
    {
        if (source[i] == a)
        {
            res = true;
            break;
        }
    }
    return res;
}

int[] difference (int[] a, int[] b)
// Calculate the set difference of two arrays.
{
    int[] res = {};
    for (int i = 0; i < a.length; ++i)
    { if (!contains(b, a[i])) res.push(a[i]); }
    return res;
}

real xsize (path p) { return xpart(max(p)) - xpart(min(p)); }
real ysize (path p) { return ypart(max(p)) - ypart(min(p)); }

real radius (path p)
// Calculate the approximate "radius" of a path-enclosed area.
{ return (xsize(p) + ysize(p))*.25; }

real xsize (picture p) { return xpart(max(p)) - xpart(min(p)); }
real ysize (picture p) { return ypart(max(p)) - ypart(min(p)); }

real arclength (path g, real a, real b)
// A more functional version of `arclength`.
{ return arclength(subpath(g, a, b)); }

real relarctime (path g, real t0, real a)
// Calculate the time at which arclength `a` will be traveled, starting from time t0.
{
    real t0arc = arclength(g, 0, t0);
    if (t0arc + a < 0 || t0arc + a > arclength(g)) { return -arctime(g, mod(t0arc + a, arclength(g))); }
    return arctime(g, t0arc+a);
}

path arcsubpath (path g, real arc1, real arc2) {
    if (arc2 <= 0) arc2 = arclength(g) + arc2;
    return subpath(g, arctime(g, arc1), arctime(g, arc2));
}

real intersectiontime (path g, pair point, pair dir)
// Returns the time of the intersection of `g` with a beam going from `point` in direction `dir`
{
    real[] isect = intersect(g, point -- (point + unit(dir)*(8*radius(g))));
    if (isect.length > 0) return isect[0];
    return -1;
}

pair intersection (path g, pair point, pair dir)
// Same as `intersectiontime`, but returns the point.
{ return point(g, intersectiontime(g, point, dir)); }

path reorient (path g, real time)
// Shift the starting point of a path along the path.
{ return subpath(g, time, length(g)) & subpath(g, 0, time) & cycle; }

path turn (path g, pair point, pair dir)
// Reorient in the direction of `dir` from point `point`.
{ return reorient(g, intersectiontime(g, point, dir)); }

path subcyclic (path p, pair t)
// An improved `subpath` made for cyclic ps.
{
    if (t.x <= t.y) return subpath(p, t.x, t.y);
    return (subpath(p, t.x, length(p)) & subpath(p, 0, t.y));
}

bool clockwise (path p)
// Check if the path is clockwise.
{ return (windingnumber(p, inside(p)) == -1); }

bool meet (path p, path q)
// A shorthand to check if ps intersect.
{ return (intersect(p, q).length > 0); }

bool meet (path p, path[] q)
{
    for (int i = 0; i < q.length; ++i)
    { if (meet(p, q[i])) return true; }
    return false;
}

bool meet (path[] p, path[] q)
{
    for (int i = 0; i < p.length; ++i)
    {
        for (int j = 0; j < q.length; ++j)
        { if (meet(p[i], q[j])) return true; }
    }
    return false;
}

pair range (path g, pair center, pair dir, real ang, real orient = 1)
// Calculate the subpath times based on `center`, `dir`, and `ang`.
{
    return (
        intersectiontime(g, center, rotate(orient*ang*.5)*dir),
        intersectiontime(g, center, rotate(-orient*ang*.5)*dir)
    );
}

bool outsidepath (path p, path q)
// Check if `q` is outside of the area enclosed by `p`.
{ return !meet(p,q) && !insidepath(p,q); }

path pop (path[] source)
// Delete the first element and return it.
{
    path p = source[0];
    source.delete(0);
    return p;
}

// >generic | Overall useful path utilities

path neigharc (
    real x = 0,
    real h = config.paths.neighheight,
    int dir = 1,
    real w = config.paths.neighwidth
) // Draw an arc delimiting a neighborhood
{
    return ((x+dir*w, h) .. {(0,-1)}(x, 0) .. (x+dir*w, -h));
}

path ellipsepath (
    pair a,
    pair b,
    real curve = 0,
    bool abs = false
) // Produce half of an ellipse connecting points `a` and `b`. Curvature may be relative or absolute.
{
    if (!abs) curve = curve*length(b-a);
    pair mid = (a+b)*.5;
    path e = rotate(degrees(a-b), z = mid)*ellipse(mid, length(b-a)*.5, curve);
    return subpath(e, 0, reltime(e, .5));
}

path curvedpath (
    pair a,
    pair b,
    real curve = 0,
    bool abs = false
) // Constuct a curved path between two points.
{
    if (abs) curve = curve/length(b-a);
    pair mid = (a+b)*.5;
    return a .. (mid + curve * (rotate(-90) * (b-a))) .. b;
}

path cyclepath (pair a, real angle, real radius)
// A circular path starting from `a` and 
{ return shift(a)*rotate(-180 + angle)*scale(radius)*shift(-1,0)*reverse(unitcircle); }

path midpath (path g, path h, int n = 20)
// Construct the "mean" path between two given ps.
{
    path res;
    for (int i = 0; i < n; ++i)
    {
        res = res .. {(dir(g, reltime(g, i/n)) + dir(h, reltime(h, i/n)))*.5}((point(g, reltime(g, i/n)) + point(h, reltime(h, i/n)))*.5);
    }
    return res .. {(dir(g, reltime(g, 1)) + dir(h, reltime(h, 1)))*.5}((point(g, reltime(g, 1)) + point(h, reltime(h, 1)))*.5);
}

path connect (pair[] points)
// Connect an array of points into a path
{
    guide acc;
    for (int i = 0; i < points.length; ++i)
    { acc = acc .. points[i]; }
    return (path) acc;
}

path connect (... pair[] points)
{ return connect(points); }

path wavypath (real[] nums, bool normaldir = true, bool adjust = false)
// Connect points around the origin with a path.
{
    if (nums.length == 0) return nullpath;
    if (nums.length == 1) return scale(nums[0])*ucircle;
    
    pair[] points = sequence(new pair (int i) { return nums[i]*dir(-360*(i/nums.length)); }, nums.length);

    path res;

    if (normaldir)
    {
        guide getpath (pair[] arr)
        {
            if (arr.length == 2)
            {
                return arr[0]{rotate(-90)*arr[0]} .. 
                             {rotate(-90)*arr[1]}arr[1];
            }
            pair a = arr.pop();
            return getpath(arr) .. {rotate(-90)*a}a;
        }
        res = (path) (getpath(points)..cycle);
    }
    else
    { res = connect(points)..cycle; }

    return adjust ? scale(1/radius(res))*shift(-center(res))*res : res;
}

path wavypath (... real[] nums)
{ return wavypath(nums = nums); }

struct gauss
// A Gaussian integer.
{
    int x;
    int y;

    void operator init (int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}

bool operator == (gauss a, gauss b)
{ return a.x == b.x && a.y == b.y; }

gauss operator cast (pair p)
{ return gauss(floor(p.x), floor(p.y)); }

pair operator cast (gauss g)
{ return (g.x, g.y); }

path connect (path p, path q)
// Connect `p` and `q` smoothly.
{ return p{dir(p, length(p))}..{dir(q,0)}q; }

pair randomdir (pair dir, real angle)
{ return dir(degrees(dir) + (unitrand()-.5)*angle); }

path randompath (pair[] controlpoints, real angle)
// Like `connect`, but the path has some randomness to it.
{
    if (controlpoints.length < 2) return nullpath;

    pair outdir = randomdir(controlpoints[1]-controlpoints[0], angle);
    path res = controlpoints[0];

    for (int i = 1; i < controlpoints.length-1; ++i)
    {
        pair indir = randomdir(controlpoints[(i+1)]-controlpoints[i-1], angle);
        res = res{outdir} .. {indir}controlpoints[i];
        outdir = indir;
    }
    
    pair indir = randomdir(controlpoints[(controlpoints.length-1)]-controlpoints[controlpoints.length-2], angle);
    
    return res{outdir}..{indir}controlpoints[controlpoints.length-1];
}

// >generic

path[] combination (path p, path q, int mode, bool round, real roundcoeff)
// A general way to "combine" two ps based on their intersection points.
{
    if (!meet(p, q)) return new path[];

    real proundlength = roundcoeff*arclength(p);
    real qroundlength = roundcoeff*arclength(q);
    
    real[][] times = intersections(p, q);

    for (int i = 0; i < times.length; ++i)
    {
        pair pdi = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = -1) : dir(p, times[i][0]);
        pair pdo = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = 1) : dir(p, times[i][0]);
        pair qdi = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = -1) : dir(q, times[i][1]);
        pair qdo = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = 1) : dir(q, times[i][1]);

        if (sgn(cross(pdi, qdi))*sgn(cross(pdo, qdo)) <= 0)
        {
            times.delete(i);
            --i;
        }
    }
    
    int n = times.length;

    int[] pinds = sort(sequence(n), new bool (int a, int b){return (times[a][1] <= times[b][1]);});
    int[] qinds = sort(sequence(n), new bool (int a, int b){return (times[pinds[a]][0] <= times[pinds[b]][0]);});
    
    path[] res;
    
    gauss start = (0, qinds[0]);
    gauss[] nextstarts;

    int visited = 0;
    gauss curind = start;
    path curpath;
    
    while (visited < n)
    {
        visited += 1;

        bool pway;
        gauss newind;
        pair pdir = (times[curind.x][0] == floor(times[curind.x][0])) ? dir(p, floor(times[curind.x][0]), sign = 1) : dir(p, times[curind.x][0]);
        pair qdir = (times[curind.x][1] == floor(times[curind.x][1])) ? dir(q, floor(times[curind.x][1]), sign = 1) : dir(q, times[curind.x][1]);

        if (cross(pdir, qdir)*mode < 0) pway = true;
        else pway = false;

        real curarc = min(pway ? qroundlength : proundlength, arclength(curpath)*.5);

        if (pway)
        {
            newind = ((curind.x+1)%n, qinds[(curind.x+1)%n]);

            if ((-(newind.y - curind.y)*windingnumber(q, inside(q)))%n > 1)
            { nextstarts.insert(i = 0, (pinds[(curind.y+1)%n], (curind.y+1)%n)); }
        }
        else
        {
            newind = (pinds[(curind.y+1)%n], (curind.y+1)%n);

            if ((-(newind.x - curind.x)*windingnumber(p, inside(p)))%n > 1)
            { nextstarts.insert(i = 0, ((curind.x+1)%n, qinds[(curind.x+1)%n])); }
        }

        path addpath = subcyclic(pway ? p : q, (times[curind.x][pway ? 0 : 1], times[newind.x][pway ? 0 : 1]));

        if (!round || curpath == nullpath) curpath = curpath & addpath;
        else
        {
            path subcurpath = subpath(curpath, 0, arctime(curpath, arclength(curpath) - curarc));
            path subaddpath = subpath(addpath, arctime(addpath, min(pway ? qroundlength : proundlength, arclength(addpath)*.5)), length(addpath));

            curpath = connect(subcurpath, subaddpath);
        }

        if (newind == start)
        {
            path finpath;
            if (!round) finpath = curpath&cycle;
            else
            {
                real begin = arctime(curpath, curarc);
                real end = arctime(curpath, arclength(curpath)-curarc);
                finpath = subpath(curpath, begin, end){dir(curpath, end)}..{dir(curpath, begin)}cycle;
            }
            res.push(finpath);
            curpath = nullpath;
            if (nextstarts.length == 0) break;
            start = nextstarts.pop();
            curind = start;
        }
        else curind = newind;
    }

    res = sort(res, new bool (path i, path j) {
        if (clockwise(i)) return true;
        else if (!clockwise(j)) return true;
        else return false;
    });

    return res;
}

// >operations | Set operations on paths

path[] difference (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // Construct the set difference between two path-enclosed areas.
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (windingnumber(p, point(q,0)) == -1) return new path[]{p, reverse(q)};
        if (windingnumber(q, point(p,0)) == -1) return new path[]{};
        return new path[]{p};
    }

    return combination(p, reverse(q), mode = -1, round = round, roundcoeff = roundcoeff);
}

path[] difference (
    path[] ps,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
{
    if (correct)
    {
        for (int i = 0; i < ps.length; ++i)
        { if (!clockwise(ps[i])) ps[i] = reverse(ps[i]); }
        if (!clockwise(q)) q = reverse(q);
    }

    return concat(sequence(new path[] (int i){return difference(ps[i], q, correct = false, round = round, roundcoeff = roundcoeff);}, ps.length));
}

path[] operator - (path p, path q)
{ return difference(p, q); }

path[] operator - (path[] p, path q)
{ return difference(p, q); }

path[] symmetric (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // Construct the set symmetric difference between two path-enclosed areas.
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (windingnumber(p, point(q,0)) == -1)
            return new path[] {p, reverse(q)};
        if (windingnumber(q, point(p,0)) == -1)
            return new path[] {q, reverse(p)};
        return new path[] {p,q};
    }

    return concat(difference(p,q,false,round,roundcoeff), difference(q,p,false,round,roundcoeff));
}

path[] operator :: (path p, path q)
{ return symmetric(p, q); }

path[] intersection (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // Construct the intersection of two path-enclosed areas.
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (insidepath(p,q)) return new path[]{q};
        if (insidepath(q,p)) return new path[]{p};
        return new path[];
    }

    return combination(p, q, mode = -1, round = round, roundcoeff = roundcoeff);
}

path[] intersection (
    path[] ps,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
{
    if (correct)
    {
        for (int i = 0; i < ps.length; ++i)
        { if (!clockwise(ps[i])) ps[i] = reverse(ps[i]); }
    }
    if (ps.length == 0) return new path[];
    if (ps.length == 1) return ps;
    if (ps.length == 2) return intersection(ps[0], ps[1], correct = false, round = round, roundcoeff = roundcoeff);
    
    ps = sequence(new path (int i){return ps[i];}, ps.length);
    
    path p = ps.pop();
    path[] prev = intersection(ps, correct = false, round = round, roundcoeff = roundcoeff);
    
    return concat(sequence(new path[] (int i){return intersection(prev[i], p, correct);}, prev.length));
}

path[] intersection (
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... path[] ps
) {return intersection(ps, correct, round, roundcoeff);}

path[] intersection (
    path p,
    path q,
    path[] holes,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
        for (int i = 0; i < holes.length; ++i)
        { if (!clockwise(holes[i])) holes[i] = reverse(holes[i]); }
    }
    
    path[] res = intersection(p, q, correct = false, round = round, roundcoeff = roundcoeff);
    for (int i = 0; i < holes.length; ++i)
    { res = difference(res, holes[i], correct = false, round = round, roundcoeff = roundcoeff); }
    
    return res;
}

path[] operator ^ (path p, path q)
{ return intersection(p, q); }

path[] union (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // Construct the union of two path-enclosed areas.
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (insidepath(p,q)) return new path[]{p};
        if (insidepath(q,p)) return new path[]{q};
        return new path[]{p,q};
    }
    
    return combination(p, q, mode = 1, round = round, roundcoeff = roundcoeff);
}

path[] union (
    path[] ps,
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
{
    if (correct)
    {
        for (int i = 0; i < ps.length; ++i)
        { if (!clockwise(ps[i])) ps[i] = reverse(ps[i]); }
    }
    
    if (ps.length == 0) return new path[];
    if (ps.length == 1) return ps;
    if (ps.length == 2) return union(ps[0], ps[1], correct = false, round = round, roundcoeff = roundcoeff);
    
    for (int i = 0; i < ps.length; ++i)
    {
        for (int j = i+1; j < ps.length; ++j)
        {
            if (meet(ps[i], ps[j]))
            {
                ps[i] = union(ps[i], ps[j], correct = false, round = round, roundcoeff = roundcoeff)[0];
                ps.delete(j);
                j = i;
            }
        }
    }
    
    return ps;
}

path[] union (
    bool correct = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... path[] ps
) { return union(ps, correct, round, roundcoeff); }

path[] operator | (path p, path q)
{ return union(p, q); }

// >system | System functions

usepackage("amssymb"); // LaTeX package for mathematical symbols

restricted void halt (string msg)
// Writes error message and exits compilation.
{
    write();
    write("> ! "+msg);
    abort("");
}

restricted string mode (int md)
// Extracts the name of given draw mode.
{
    if (md == 0) return "plain";
    if (md == 1) return "free";
    if (md == 2) return "cartesian";
    if (md == 3) return "combined";
    return "[undefined]";
}

private bool dummy (int n)
{ return n == config.system.dummynumber; }

private bool dummy (real r)
{ return r == config.system.dummynumber; }

private bool dummy (pair p)
{ return p == config.system.dummypair; }

private bool dummy (string s)
{ return s == config.system.dummystring; }

private bool checksection (real[] section)
// Checks if array has valid section values in it
{
    if (section.length > 0 && !dummy(section[0]) && !inside(0, 360, section[0]))
    { return false; }
    if (section.length > 1 && !dummy(section[1]) && !inside(0, 360, section[1]))
    { return false; }
    if (section.length > 2 && !dummy(section[2]) && section[2] <= 0)
    { return false; }
    if (section.length > 3)
    { return false; }
    return true;
}

private real sectionsymmetryrating (pair p1p2, pair dir1, pair dir2)
// A rating of how symmetric the section is
{ return abs(dot(dir2, p1p2) + dot(p1p2, dir1)); }

private bool sectiontoobroad (pair p1, pair p2, pair dir1, pair dir2)
// Checks if the section is too broad
{
    pair p1p2u = unit(p2-p1);
    return (
        min(dot(dir2, -p1p2u), dot(p1p2u, dir1)) <= -config.section.maxbreadth
        ||
        max(dot(dir2, -p1p2u), dot(p1p2u, dir1)) >= config.section.maxbreadth
    );
}

// >pens | Manipulating pens

private pen inverse (pen p)
// Inverts the colors of `p`.
{
    real[] colors = colors(p);
    if (colors.length == 1) return colorless(p)+gray(1-colors[0]);
    if (colors.length == 3) return colorless(p)+rgb(1-colors[0], 1-colors[1], 1-colors[2]);
    return colorless(p);
}

pen brighten (pen p, real coeff)
// Makes `p` brighter
{
    return inverse(coeff * inverse(p));
}

private pen sectionpen (pen p)
// Derives a pen to draw cross sections
{
    if (config.drawing.sectionpen == nullpen) return p+linewidth(config.drawing.sectpenscale*linewidth(p));
    else return config.drawing.sectionpen;
}

private pen nextsubsetpen (pen p, real scale)
// Derives a pen to fill subsets of increasing layers
{ return scale * p; }

private pen dashpenscale (pen p)
{ return inverse(config.drawing.dashpenscale*inverse(p))+dashed; }

private pen dashopacity (pen p)
{ return p+dashed+opacity(config.drawing.dashopacity); }

private pen dashpen (pen p)
// Derives a pen to draw dashed lines, using either color dimming or opacity.
{
    if (config.drawing.useopacity) return dashopacity(p);
    else return dashpenscale(p);
}

private pen shadepen (pen p)
// Derives a pen to fill shaded regions
{ return config.drawing.shadescale*p; }

private pen elementpen (pen p)
// Derives a pen to render elements
{ return p + linewidth(config.drawing.elpenwidth); }

private pen underpen (pen p)
// Derives a pen to draw paths that go under areas.
{ return dashpen(p); }

restricted void defaults ()
// Revert global settings to the defaults.
{
    // System config
    config.system.version = defaultconfig.system.version;
    config.system.dummynumber = defaultconfig.system.dummynumber;
    config.system.dummystring = defaultconfig.system.dummystring;
    config.system.dummypair = defaultconfig.system.dummypair;
    config.system.repeatlabels = defaultconfig.system.repeatlabels;
    config.system.insertdollars = defaultconfig.system.insertdollars;
    // Path config
    config.paths.roundcoeff = defaultconfig.paths.roundcoeff;
    config.paths.range = defaultconfig.paths.range;
    config.paths.neighheight = defaultconfig.paths.neighheight;
    config.paths.neighwidth = defaultconfig.paths.neighwidth;
    // Section config
    config.section.maxbreadth = defaultconfig.section.maxbreadth;
    config.section.freedom = defaultconfig.section.freedom;
    config.section.precision = defaultconfig.section.precision;
    config.section.elprecision = defaultconfig.section.elprecision;
    config.section.avoidsubsets = defaultconfig.section.avoidsubsets;
    config.section.default = copy(defaultconfig.section.default);
    // Smooth config
    config.smooth.interholenumber = defaultconfig.smooth.interholenumber;
    config.smooth.interholeangle = defaultconfig.smooth.interholeangle;
    config.smooth.maxsectionlength = defaultconfig.smooth.maxsectionlength;
    config.smooth.rejectcurve = defaultconfig.smooth.rejectcurve;
    config.drawing.viewdir = defaultconfig.drawing.viewdir;
    config.drawing.viewscale = defaultconfig.drawing.viewscale;
    config.smooth.edgemargin = defaultconfig.smooth.edgemargin;
    config.smooth.stepdistance = defaultconfig.smooth.stepdistance;
    config.smooth.nodesize = defaultconfig.smooth.nodesize;
    config.smooth.maxlength = defaultconfig.smooth.maxlength;
    config.smooth.inferlabels = defaultconfig.smooth.inferlabels;
    config.smooth.shiftsubsets = defaultconfig.smooth.shiftsubsets;
    config.smooth.addsubsets = defaultconfig.smooth.addsubsets;
    config.smooth.correct = defaultconfig.smooth.correct;
    config.smooth.clip = defaultconfig.smooth.clip;
    config.smooth.unit = defaultconfig.smooth.unit;
    config.smooth.setcenter = defaultconfig.smooth.setcenter;
    // Drawing config
    config.drawing.gaplength = defaultconfig.drawing.gaplength;
    config.drawing.smoothfill = defaultconfig.drawing.smoothfill;
    config.drawing.subsetfill = defaultconfig.drawing.subsetfill;
    config.drawing.sectpenscale = defaultconfig.drawing.sectpenscale;
    config.drawing.elpenwidth = defaultconfig.drawing.elpenwidth;
    config.drawing.shadescale = defaultconfig.drawing.shadescale;
    config.drawing.dashpenscale = defaultconfig.drawing.dashpenscale;
    config.drawing.dashopacity = defaultconfig.drawing.dashopacity;
    config.drawing.attachedopacity = defaultconfig.drawing.attachedopacity;
    config.drawing.subpenfactor = defaultconfig.drawing.subpenfactor;
    config.drawing.subpenbrighten = defaultconfig.drawing.subpenbrighten;
    config.drawing.sectionpen = defaultconfig.drawing.sectionpen;
    config.drawing.lineshadeangle = defaultconfig.drawing.lineshadeangle;
    config.drawing.lineshadedensity = defaultconfig.drawing.lineshadedensity;
    config.drawing.lineshademargin = defaultconfig.drawing.lineshademargin;
    config.drawing.lineshadepen = defaultconfig.drawing.lineshadepen;
    config.drawing.mode = defaultconfig.drawing.mode;
    config.drawing.useopacity = defaultconfig.drawing.useopacity;
    config.drawing.dashes = defaultconfig.drawing.dashes;
    config.drawing.underdashes = defaultconfig.drawing.underdashes;
    config.help.enable = defaultconfig.help.enable;
    config.drawing.shade = defaultconfig.drawing.shade;
    config.drawing.labels = defaultconfig.drawing.labels;
    config.drawing.fill = defaultconfig.drawing.fill;
    config.drawing.fillsubsets = defaultconfig.drawing.fillsubsets;
    config.drawing.drawcontour = defaultconfig.drawing.drawcontour;
    config.drawing.drawsubsetcontour = defaultconfig.drawing.drawsubsetcontour;
    config.drawing.pathrandom = defaultconfig.drawing.pathrandom;
    config.drawing.overlap = defaultconfig.drawing.overlap;
    config.drawing.subsetoverlap = defaultconfig.drawing.subsetoverlap;
    config.drawing.drawnow = defaultconfig.drawing.drawnow;
    config.drawing.postdrawover = defaultconfig.drawing.postdrawover;
    // Help config
    config.help.arcratio = defaultconfig.help.arcratio;
    config.help.arrowlength = defaultconfig.help.arrowlength;
    config.help.linewidth = defaultconfig.help.linewidth;
    // Arrow config
    config.arrow.mar = defaultconfig.arrow.mar;
    config.arrow.absmargins = defaultconfig.arrow.absmargins;
}

// >technical | Low-level path-related functions

private pair[][] cartsectionpoints (path[] g, real r, bool horiz)
{
    real min = horiz ? ypart(min(g)) : xpart(min(g));
    real max = horiz ? ypart(max(g)) : xpart(max(g));
    pair[][] res = new pair[][];
    r = min*(1-r)+max*r;
    
    for (int i = 0; i < g.length; ++i)
    {
        real[] times = horiz ? times(g[i], (0, r)) : times(g[i], r);
        for (int j = 0; j < times.length; ++j)
        { res.push(new pair[] {point(g[i], times[j]), dir(g[i], times[j]), (i,0)}); }
    }
    
    return sort(res, new bool (pair[] i, pair[] j){ return ((horiz ? xpart(i[0]) : ypart(i[0])) < (horiz ? xpart(j[0]) : ypart(j[0]))); });
}

private pair[][] cartsections (path[] g, path[] avoid, real r, bool horiz)
// Marks the places where it is suitable to draw horizontal or vertical sections of `g` at ratio `r`.
{
    pair[][] presections = cartsectionpoints(g, r, horiz);
    if (presections.length % 2 == 1) return new pair[][];
    pair[][] sections;

    for (int i = 0; i < presections.length; i += 2)
    {
        if (sectiontoobroad(presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]))
        { continue; }
        
        if (config.smooth.maxsectionlength > 0 && length(presections[i][0]-presections[i+1][0]) > config.smooth.maxlength)
        { continue; }

        bool exclude = false;
        for (int j = 0; j < avoid.length; ++j)
        {
            if (meet(avoid[j], (path)(presections[i][0]--presections[i+1][0])))
            { exclude = true; }
        }
        if (exclude) continue;
    
        for (int j = 0; j < g.length; ++j)
        {
            if (j == presections[i][2].x || j == presections[i+1][2].x) continue;
            if (meet(g[j], curvedpath(presections[i][0], presections[i+1][0], config.smooth.rejectcurve)) || meet(g[j], curvedpath(presections[i+1][0], presections[i][0], config.smooth.rejectcurve)))
            {
                exclude = true;
                break;
            }
        }
        if (exclude) continue;

        sections.push(new pair[] {presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]});
    }

    return sections;
}

private path[] sectionellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir)
// One of the most important technical functions of the module. Constructs an ellipse that touches `dir1` and `dir2` and whose center lies on the segment [p1, p2].
{
    if (length(viewdir) == 0) return new path[] {p1--p2};

    pair p1p2 = p2-p1;
    real l = length(p1p2);
    real d, x;
    real epsilon = 5.0e-4;

    real h = cross(p1p2, viewdir);
    int sgnh = sgn(h);
    h = abs(h);
    if (h < epsilon*l) return new path[] {p1--p2};
    real lsang1 = cross(p1p2, dir1);
    real lsang2 = cross(dir2, -p1p2);
    if (lsang1 < 0) { dir1 = -dir1; lsang1 = -lsang1; }
    if (lsang2 < 0) { dir2 = -dir2; lsang2 = -lsang2; }
    pair hv = (rotate(90)*p1p2) * h;

    pair dir1p = l*(rotate(-degrees(p1p2, false))*dir1);
    pair dir2p = l*(rotate(-degrees(p1p2, false))*dir2);

    path line1 = (-dir1p) -- (dir1p);
    path line2 = ((l,0) - dir2p) -- ((l,0) + dir2p);

    if (config.section.elprecision <= 0)
    {
        real reciprocal1 = 1/lsang1;
        real reciprocal2 = 1/lsang2;
        d = l * 0.5 * (1.0 + h*h*(reciprocal1 - reciprocal2)*(reciprocal1 + reciprocal2));
        x = sqrt(abs(d*d - h*h*((reciprocal1*l)^2-1)));
    }
    else
    {
        real r1 = 0;
        real l1 = l*.5;
        real r2 = 0;
        real l2 = l*.5;

        path ellipse (real d1, real d2)
        { return ellipse(((d1 + l-d2)*.5, 0), (l-d1-d2)*.5, h); }

        while (l1-r1 >= config.section.elprecision || l2-r2 >= config.section.elprecision)
        {
            real c1 = (r1+l1)*.5;
            real c2 = (r2+l2)*.5;
            if (intersect(line1, ellipse(c1, r2)).length > 0){r1 = c1;}
            else {l1 = c1;}
            if (intersect(line2, ellipse(r1, c2)).length > 0){r2 = c2;}
            else {l2 = c2;}
        }

        d = (r1 + (l-r2))*.5;
        x = (l-r1-r2)*.5;
    }
    
    path pres = (sgnh < 0) ? rotate(180, (d,0))*ellipse((d, 0), x, h) : reverse(rotate(180, (d,0))*ellipse((d, 0), x, h));
    real t1 = 0;
    
    if (lsang1 < l*(1 - epsilon))
    {
        real[] times1 = intersect(pres, line1);
        t1 = (times1.length > 0) ? times1[0] : 0;
    }
    
    pres = reorient(pres, t1);
    real t2 = intersect(pres, (d, 0)--(d+2*x, 0))[0];
    
    if (lsang2 < l*(1 - epsilon))
    {
        real[] times2 = intersect(pres, line2);
        t2 = (times2.length > 0) ? times2[0] : intersect(pres, (d, 0)--(d+2*x, 0))[0];
    }
    
    return map(new path (path p){return shift(p1)*rotate(degrees(p1p2))*p;}, new path[] {subpath(pres, 0, t2), subpath(pres, t2, length(pres))});
}

private pair[][] sectionparams (path g, path h, int n, real r, int p)
// Searches for potential section positions between two given paths using a [clever] algorithm.
{
    pair[] pres;

    if (r < 0)
    {
        if (n == 1)
        { pres = new pair[] {(arctime(g, .5*arclength(g)), arctime(h, .5*arclength(h)))}; }
        else
        {
            real gl = arclength(g)/(n-1);
            real hl = arclength(h)/(n-1);
            pres = sequence(new pair (int i) {
                return (arctime(g, i*gl), arctime(h, i*hl));
            }, n);
        }
    }
    else
    {
        real[] gtimes;
        real[] htimes;

        real rp = r/(1-r);
        real gy = arclength(g)/(n*rp + n - 1);
        real gx = rp*gy;
        real hy = arclength(h)/(n*rp + n - 1);
        real hx = rp*hy;
        for (int i = 0; i < n; ++i)
        {
            gtimes.push(arctime(g, i*(gx+gy)));
            gtimes.push(arctime(g, i*(gx+gy)+gx));
        }
        for (int i = 0; i < n; ++i)
        {
            htimes.push(arctime(h, i*(hx+hy)));
            htimes.push(arctime(h, i*(hx+hy)+hx));
        }

        for (int i = 0; i < 2*n; i += 2)
        {
            real curgtime = gtimes[i];
            real curhtime = htimes[i];
            real optgtime = curgtime;
            real opthtime = curhtime;
            real gtimestep = (gtimes[i+1]-gtimes[i])/p;
            real htimestep = (htimes[i+1]-htimes[i])/p;

            int gi = 0;
            int hi = 0;
            real minval = sectionsymmetryrating(point(g, curgtime)-point(h, curhtime), dir(g, curgtime), dir(h, curhtime));

            while (true)
            {
                bool changed = false;
                real val;

                if (gi < p && (val = sectionsymmetryrating(point(g, curgtime+gtimestep)-point(h, curhtime), dir(g, curgtime+gtimestep), dir(h, curhtime))) < minval)
                {
                    curgtime += gtimestep;
                    minval = val;
                    gi += 1;
                    changed = true;
                    optgtime = curgtime;
                    opthtime = curhtime;
                    continue;
                }
                else if (hi == p) break;

                if (hi < p && (val = sectionsymmetryrating(point(g, curgtime)-point(h, curhtime+htimestep), dir(g, curgtime), dir(h, curhtime+htimestep))) < minval)
                {
                    curhtime += htimestep;
                    minval = val;
                    hi += 1;
                    changed = true;
                    opthtime = curhtime;
                    optgtime = curgtime;
                    continue;
                }
                else if (gi == p) break;

                if (!changed)
                {
                    curgtime += gtimestep;
                    gi += 1;
                    curhtime += htimestep;
                    hi += 1;
                }
            }

            pres.push((optgtime, opthtime));
        }
    }

    return sequence(new pair[] (int i) {
        return new pair[] {point(h, pres[i].y), point(g, pres[i].x), dir(h, pres[i].y), dir(g, pres[i].x)};
    }, pres.length);
}

// >structs | The structures of the module

restricted struct element
// An 'element' of a set, in a set-theoretical sense.
{
    // Attributes

    pair pos;           // The position of the element.
    string label;       // The label of the element.
    pair labelalign;    // The alignment of the label.

    // Methods

    element move (transform move)
    {
        this.pos = move*this.pos;

        return this;
    }
    element move (pair shift, real scale, real rotate, pair point, bool movelabel)
    {
        this.pos = shift(shift)*srap(scale, rotate, point)*this.pos;
        if (movelabel) this.labelalign = rotate(rotate)*this.labelalign;

        return this;
    }

    void operator init (
        pair pos,
        string label = "",
        pair labelalign = S
    )
    {
        this.pos = pos;
        this.label = label;
        this.labelalign = labelalign;
    }

    element copy ()
    { return element(this.pos, this.label, this.labelalign); }

    element replicate (element elt)
    {
        this.pos = elt.pos;
        this.label = elt.label;
        this.labelalign = elt.labelalign;

        return this;
    }
}

private element[] elementcopy (element[] elements)
{ return sequence(new element (int i) { return elements[i].copy(); }, elements.length); }

// >hole
restricted struct hole
// A cyclic area 'cut out' of a smooth object.
{
    // Attributes

    path contour;       // The cyclic boundary of the hole.
    pair center;        // The center of the hole.

    real[][] sections;  // Data related to the positioning of cross sections around the hole.
    int scnumber;       // The preferred number of cross sections between this hole and others.

    // Methods

    hole move (transform move)
    {
        this.contour = move*this.contour;
        if (!dummy(this.center)) this.center = move*this.center;

        return this;
    }
    hole move (pair shift, real scale, real rotate, pair point, bool movesections)
    // Shift, scale, rotate around a point.
    {
        transform move = shift(shift)*srap(scale, rotate, point);

        this.contour = move*this.contour;
        if (!dummy(this.center)) this.center = move*this.center;

        if (!movesections) return this;
        for (int i = 0; i < this.sections.length; ++i)
        { this.sections[i][0] += rotate; }
        return this;
    }

    void operator init (
        path contour,
        pair center = config.system.dummypair,
        real[][] sections = {},
        int scnumber = config.smooth.interholenumber,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center(contour),
        bool correct = config.smooth.correct,
        bool copy = false
    )
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.sections = sections;
            this.scnumber = scnumber;
        }
        else
        {
            if (!clockwise(contour) && correct) contour = reverse(contour);
            this.contour = shift(shift)*srap(scale, rotate, point)*contour;
            this.center = center;
            this.scnumber = scnumber;
            this.sections = new real[][];
            for (int i = 0; i < sections.length; ++i)
            {
                real[] arr = sections[i];
                while (arr.length < config.section.default.length) { arr.push(config.section.default[arr.length]); }
                this.sections.push(arr);
            }
        }
    }

    hole copy ()
    { return hole(this.contour, this.center, copy(this.sections), copy = true); }

    hole replicate (hole h)
    { 
        this.contour = h.contour;
        this.center = h.center;
        this.sections = h.sections;

        return this;
    }
}

// >hole | Utilities for holes

private hole[] holecopy (hole[] holes)
{ return sequence(new hole (int i){return holes[i].copy();}, holes.length); }

private path[] holecontours (hole[] h)
{ return sequence(new path (int i){return h[i].contour;}, h.length); }

// >subset
restricted struct subset
// A structure representing a subset of a given object (see "smooth")
{
    // Attributes

    path contour;       // The boundary of the subset.
    pair center;        // The center of the subset.

    string label;       // The label attached to the subset.
    pair labeldir;      // The direction of the label.
    pair labelalign;    // The alignment of the label.

    int layer;          // The layer in the hierarchy of subsets.
    int[] subsets;      // The list of subsets contained in this subset.

    bool isderivative;  // Whether the subset is an intersection of two other subsets.
    bool isonboundary;  // Whether the subset is on the boundary of the object.

    // Methods

    real xsize ()
    { return xsize(this.contour); }
    real ysize ()
    { return ysize(this.contour); }

    subset move (transform move)
    {
        this.contour = move*this.contour;
        if (!dummy(this.center)) this.center = move*this.center;

        return this;
    }
    subset move (pair shift, real scale, real rotate, pair point, bool movelabel)
    {
        transform move = shift(shift)*srap(scale, rotate, point);
        this.contour = move*this.contour;
        if (!dummy(this.center)) this.center = move*this.center;
        if (movelabel) this.labeldir = rotate(rotate)*this.labeldir;

        return this;
    }

    void operator init (
        path contour,
        pair center = config.system.dummypair,
        string label = "",
        pair labeldir = config.system.dummypair,
        pair labelalign = config.system.dummypair,
        int layer = 0,
        bool isderivative = false,
        bool isonboundary = false,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center(contour),
        bool correct = config.smooth.correct,
        bool copy = false
    )
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
            this.layer = layer;
            this.isderivative = isderivative;
            this.isonboundary = isonboundary;
        }
        else
        {
            contour = (clockwise(contour) && correct) ? contour : reverse(contour);
            this.contour = shift(shift)*srap(scale, rotate, point)*contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
            this.layer = layer;
            this.isderivative = isderivative;
            this.isonboundary = isonboundary;
        }
    }
    
    subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign, this.layer, this.isderivative, this.isonboundary, copy = true);
    }

    subset replicate (subset s)
    { 
        this.contour = s.contour;
        this.center = s.center;
        this.label = s.label;
        this.labeldir = s.labeldir;
        this.labelalign = s.labelalign;
        this.layer = s.layer;
        this.subsets = copy(s.subsets);
        this.isderivative = s.isderivative;
        this.isonboundary = s.isonboundary;
        
        return this;
    }
}

// >subset | Utilities for subsets

private subset[] subsetcopy (subset[] subsets)
{ return sequence(new subset (int i) { return subsets[i].copy(); }, subsets.length); }

private subset[] subsetintersection (subset sb1, subset sb2, bool inferlabels = config.smooth.inferlabels)
{
    path[] contours = intersection(sb1.contour, sb2.contour);
    return sequence(new subset (int i){
        return subset(
            contour = contours[i],
            center = center(contours[i]),
            label = (inferlabels && length(sb1.label) > 0 && length(sb2.label) > 0 && contours.length == 1) ? (sb1.label + " \cap " + sb2.label) : "",
            labeldir = (0,0),
            labelalign = config.system.dummypair,
            layer = max(sb1.layer, sb2.layer)+1,
            isderivative = true,
            isonboundary = false,
            copy = true
        );
    }, contours.length);
}

private void subsetdelete (subset[] subsets, int index, bool recursive)
{
    subset cursb = subsets[index];
    if (recursive)
    {
        for (int i = 0; i < cursb.subsets.length; ++i)
        { subsetdelete(subsets, cursb.subsets[i], recursive); }
    }
    subsets.delete(index);
    for (int i = 0; i < subsets.length; ++i)
    {
        for (int j = 0; j < subsets[i].subsets.length; ++j)
        {
            if (subsets[i].subsets[j] > index) subsets[i].subsets[j] -= 1;
            if (subsets[i].subsets[j] == index) subsets[i].subsets.delete(j);
        }
    }
}

private int[] subsetgetlayer (subset[] subsets, int[] range, int layer)
{
    int[] res;
    for (int i = 0; i < range.length; ++i)
    { if (subsets[range[i]].layer == layer) res.push(range[i]); }
    return res;
}

private int[] subsetgetall (subset[] subsets, subset s)
{
    bool[] wanted = array(subsets.length, false);
    void fill (subset sp)
    {
        for (int i = 0; i < sp.subsets.length; ++i)
        {
            wanted[sp.subsets[i]] = true;
            fill(subsets[sp.subsets[i]]);
        }
    }
    fill(s);
    int[] res;
    for (int i = 0; i < subsets.length; ++i)
    { if (wanted[i]) res.push(i); }
    return res;
}

private int[] subsetgetall (subset[] subsets, int index)
{ return subsetgetall(subsets, subsets[index]); }

private int[] subsetgetallnot (subset[] subsets, subset s)
{ return difference(sequence(subsets.length), subsetgetall(subsets, s)); }

private int[] subsetgetallnot (subset[] subsets, int index)
{ return difference(sequence(subsets.length), subsetgetall(subsets, index)); }

private void subsetdeepen (subset[] subsets, subset s)
{
    s.layer += 1;
    for (int i = 0; i < s.subsets.length; ++i)
    { if (s.layer == subsets[s.subsets[i]].layer) subsetdeepen(subsets, subsets[s.subsets[i]]); }
}

private int subsetinsertindex (subset[] subsets, int layer)
{
    int insertindex = subsets.length;
    for (int i = subsets.length-1; i >= 0; --i)
    {
        if (subsets[i].layer >= layer)
        { insertindex = i; }
    }
    
    return insertindex;
}

private int subsetmaxlayer (subset[] subsets, int[] range)
{
    int res = -1;
    for (int i = 0; i < range.length; ++i)
    { if (subsets[range[i]].layer > res) res = subsets[range[i]].layer; }
    return res;
}

private void subsetcleanreferences (subset[] subsets)
{
    bool[] visited = array(subsets.length, value = false);

    void clean (int i)
    {
        if (visited[i]) return;
        subset cursb = subsets[i];
        visited[i] = true;

        for (int j = 0; j < cursb.subsets.length; ++j)
        {
            if (cursb.subsets[j] >= subsets.length)
            {
                cursb.subsets.delete(j);
                j -= 1;
                continue;
            }
        }
        
        for (int j = 0; j < cursb.subsets.length; ++j)
        {
            clean(cursb.subsets[j]);
            cursb.subsets = difference(cursb.subsets, subsetgetall(subsets, subsets[cursb.subsets[j]]));
        }
    }

    for (int i = 0; i < subsets.length; ++i) { clean(i); }
}

// >dpar
struct dpar
{
    // Attributes

    pen contourpen;         // The pen used to draw the contour of the smooth object.
    pen smoothfill;         // The pen used to fill the smooth object.
    pen[] subsetcontourpens;// An array of pens for subsets of different levels.
    pen[] subsetfill;       // The pen used to fill the subsets.
    pen sectionpen;         // The pen used to draw the cross sections.
    pen dashpen;            // The pen used to draw dashed lines on cross sections.
    pen shadepen;           // The pen used to fill shaded regions.
    pen elementpen;         // The pen used to dot elements.
    pen labelpen;           // The pen used to write labels.
    int mode;               // The drawing mode. Could be either 'plain', 'free', or 'cartesian'.
    pair viewdir;           // The direction of the view.
    bool drawlabels;        // Whether to draw the labels.
    bool fill;              // Whether the smooth object should be filled.
    bool fillsubsets;       // Whether the subsets should be filled.
    bool drawcontour;       // Whether the contour should be drawn.
    bool drawsubsetcontour; // Whether the contour of the subsets should be drawn.
    bool help;              // Whether to draw auxiliary help information.
    bool dash;              // Whether to draw dashed lines on cross sections.
    bool shade;             // Whether to shade the regions between cross sections.
    bool avoidsubsets;      // Whether to refrain from drawing sections that intersect subsets.
    bool overlap;           // Whether to leave gaps where lines intersect.
    bool drawnow;           // Whether to draw the object immediately instead of deferring until shipout.
    bool postdrawover;      // Whether to call `postdraw` after everything else.

    // Methods

    void operator init (
        pen contourpen = currentpen,
        pen smoothfill = config.drawing.smoothfill,
        pen[] subsetcontourpens = {contourpen},
        pen[] subsetfill = config.drawing.subsetfill,
        pen sectionpen = sectionpen(contourpen),
        pen dashpen = dashpen(sectionpen),
        pen shadepen = shadepen(smoothfill),
        pen elementpen = elementpen(contourpen),
        pen labelpen = currentpen,
        int mode = config.drawing.mode,
        pair viewdir = config.drawing.viewdir,
        bool drawlabels = config.drawing.labels,
        bool fill = config.drawing.fill,
        bool fillsubsets = config.drawing.fillsubsets,
        bool drawcontour = config.drawing.drawcontour,
        bool drawsubsetcontour = config.drawing.drawsubsetcontour,
        bool help = config.help.enable,
        bool dash = config.drawing.dashes,
        bool shade = config.drawing.shade,
        bool avoidsubsets = config.section.avoidsubsets,
        bool overlap = config.drawing.overlap,
        bool drawnow = config.drawing.drawnow,
        bool postdrawover = config.drawing.postdrawover
    ) // Constructor
    {
        this.contourpen = contourpen;
        this.smoothfill = smoothfill;
        this.subsetcontourpens = subsetcontourpens;
        this.subsetfill = subsetfill;
        this.sectionpen = sectionpen;
        this.dashpen = dashpen;
        this.shadepen = shadepen;
        this.elementpen = elementpen;
        this.labelpen = labelpen;
        this.mode = mode;
        this.viewdir = viewdir;
        this.drawlabels = drawlabels;
        this.fill = fill;
        this.fillsubsets = fillsubsets;
        this.drawcontour = drawcontour;
        this.drawsubsetcontour = drawsubsetcontour;
        this.help = help;
        this.dash = dash;
        this.shade = shade;
        this.avoidsubsets = avoidsubsets;
        this.overlap = overlap;
        this.drawnow = drawnow;
        this.postdrawover = postdrawover;
    }

    dpar subs (
        pen contourpen = this.contourpen,
        pen smoothfill = this.smoothfill,
        pen[] subsetcontourpens = this.subsetcontourpens,
        pen[] subsetfill = this.subsetfill,
        pen sectionpen = this.sectionpen,
        pen dashpen = this.dashpen,
        pen shadepen = this.shadepen,
        pen elementpen = this.elementpen,
        pen labelpen = this.labelpen,
        int mode = this.mode,
        pair viewdir = this.viewdir,
        bool drawlabels = this.drawlabels,
        bool fill = this.fill,
        bool fillsubsets = this.fillsubsets,
        bool drawcontour = this.drawcontour,
        bool drawsubsetcontour = this.drawsubsetcontour,
        bool help = this.help,
        bool dash = this.dash,
        bool shade = this.shade,
        bool avoidsubsets = this.avoidsubsets,
        bool overlap = this.overlap,
        bool drawnow = this.drawnow,
        bool postdrawover = this.postdrawover
    ) // Create a new dpar with some attributes changed.
    {
        this.contourpen = contourpen;
        this.smoothfill = smoothfill;
        this.subsetcontourpens = subsetcontourpens;
        this.subsetfill = subsetfill;
        this.sectionpen = sectionpen;
        this.dashpen = dashpen;
        this.shadepen = shadepen;
        this.elementpen = elementpen;
        this.labelpen = labelpen;
        this.mode = mode;
        this.viewdir = viewdir;
        this.drawlabels = drawlabels;
        this.fill = fill;
        this.fillsubsets = fillsubsets;
        this.drawcontour = drawcontour;
        this.drawsubsetcontour = drawsubsetcontour;
        this.help = help;
        this.dash = dash;
        this.shade = shade;
        this.avoidsubsets = avoidsubsets;
        this.overlap = overlap;
        this.drawnow = drawnow;
        this.postdrawover = postdrawover;

        return this;
    }
}

// >dpar | Utilities for dpar

dpar ghostpar (pen contourpen = currentpen)
{
    return dpar(
        contourpen = dashpen(contourpen),
        fill = false,
        fillsubsets = false,
        drawsubsetcontour = false,
        mode = plain,
        drawnow = true
    );
}

dpar emptypar ()
{
    return dpar(
        contourpen = nullpen,
        smoothfill = nullpen,
        subsetfill = new pen[]{nullpen}
    );
}

// >smooth
struct smooth
// The main structure in the module. Represents the way a "smooth manifold" would be drawn on a piece of paper.
{
    // Attributes

    path contour;           // The boundary of the smooth object.
    pair center;            // The center of the smooth object.

    string label;           // The label attached to the smooth object.
    pair labeldir;          // The direction of the label.
    pair labelalign;        // The alignment of the label.

    hole[] holes;           // The holes in the smooth object.
    subset[] subsets;       // The subsets of the smooth object.
    element[] elements;     // The elements of the smooth object.

    transform unitadjust;   // The unit coordinates of the object.

    real[] hratios;         // The horizontal insert points for cross sections.
    real[] vratios;         // The vertical insert points for cross sections.

    bool isderivative;      // Whether the smooth object is an intersection of two other smooth objects.

    smooth[] attached;      // The smooth objects linked to this one.

    void postdraw (dpar, smooth);   // What do do after drawing the object.

    static smooth[] cache;  // The store of all smooth objects created.

    // Methods

    private static bool repeats (string label)
    // Whether a label is already used in the cache.
    {
        if (label == "") return false;
        for (int i = 0; i < cache.length; ++i)
        {
            if (cache[i].label == label) return true;
            for (int j = 0; j < cache[i].subsets.length; ++j)
            { if (cache[i].subsets[j].label == label) return true; }
            for (int j = 0; j < cache[i].elements.length; ++j)
            { if (cache[i].elements[j].label == label) return true; }
        }
        return false;
    }

    void checksubsetindex (int index, string fname)
    {
        if (index >= this.subsets.length)
        {
            halt(
                "Subset index out of bounds for smooth object " + 
                (this.label == "" ? "[unlabeled]" : this.label) +
                ". [ " + fname + "() ]"
            );
        }
        if (index < -1)
        {
            write(
                "> ? Unrecognized index value: " +
                (string) index +
                ". Please use -1 for self-reference to the smooth object" +
                ". [ " + fname + "() ]"
            );
        }
    }

    void checkelementindex (int index, string fname)
    {
        if (index >= this.elements.length)
        {
            halt(
                "Element index out of bounds for smooth object " + 
                (this.label == "" ? "[unlabeled]" : this.label) +
                ". [ " + fname + "() ]"
            );
        }
        if (index < -1)
        {
            write(
                "> ? Unrecognized index value: " +
                (string) index +
                ". [ " + fname + "() ]"
            );
        }
    }

    // -- Supporting methods -- //

    real xsize ()
    { return xsize(this.contour); }
    real ysize ()
    { return ysize(this.contour); }

    bool inside (pair x)
    {
        if (!inside(this.contour, x)) return false;
        for (int i = 0; i < this.holes.length; ++i)
        { if (inside(this.holes[i].contour, x)) return false; }
        return true;
    }

    private real getyratio (real y)
    { return (y - ypart(min(this.contour)))/this.ysize(); }

    private real getxratio (real x)
    { return (x - xpart(min(this.contour)))/this.xsize(); }

    private real getypoint (real y)
    { y = y - floor(y); return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y); }

    private real getxpoint (real x)
    { x = x - floor(x); return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x); }

    private transform selfadjust ()
    // Calculates the unit coordinates of the object.
    { return shift(this.center)*scale(radius(this.contour)); }

    transform adjust (int index)
    // Returns the adjustment transform for a subset (calculated) or the object itself (cached).
    {
        this.checksubsetindex(index, "adjust");
        if (index >= 0)
        {
            subset sb = this.subsets[index];
            return shift(sb.center)*scale(radius(sb.contour));
        }
        else
        { return this.unitadjust; }
    }

    pair relative (pair point)
    // Returns the point in unit coordinates.
    { return this.unitadjust * point; }

    private int findlocalsubsetindex (string label)
    // Locate a subset by its label.
    {
        int res = -1;
        bool found = false;
        for (int i = 0; i < this.subsets.length; ++i)
        {
            if (this.subsets[i].label == label)
            {
                if (!config.system.repeatlabels) return i;
                if (found) write("> ? More than one local subset with label \"" + label + "\". Returning the last one. [ findlocalsubsetindex() ]");
                found = true;
                res = i;
            }
        }

        if (!found) halt("Could not identify local subset: no subset with label \"" + label + "\". [ findlocalsubsetindex() ]");
        return res;
    }

    private int findlocalelementindex (string label)
    // Locate an element by its label.
    {
        int res = -1;
        bool found = false;
        for (int i = 0; i < this.elements.length; ++i)
        {
            if (this.elements[i].label == label)
            {
                if (!config.system.repeatlabels) return i;
                if (found) write("> ? More than one local element with label \"" + label + "\". Returning the last one. [ findlocalelementindex() ]");
                found = true;
                res = i;
            }
        }

        if (!found) halt("Could not identify local element: no element with label \"" + label + "\". [ findlocalelementindex() ]");
        return res;
    }

    // -- Methods for moving the smooth object -- //

    smooth move (
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = this.center,
        bool readjust = true,
        bool drag = true
    ) // Transforms the smooth object. Respects the current `viewdir`.
    {
        if (scale <= 0)
        { halt("Could not move: scale value must be positive. [ move() ]"); }

        this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
        this.center = shift(shift)*rotate(rotate, point)*this.center;
        this.labeldir = rotate(rotate)*this.labeldir;
        
        if (readjust) this.unitadjust = this.selfadjust();

        for (int i = 0; i < this.holes.length; ++i)
        { this.holes[i].move(shift, scale, rotate, point, true); }
        for (int i = 0; i < this.subsets.length; ++i)
        { this.subsets[i].move(shift, scale, rotate, point, true); }
        for (int i = 0; i < this.elements.length; ++i)
        { this.elements[i].move(shift, scale, rotate, point, true); }

        if (drag) for (int i = 0; i < this.attached.length; ++i)
        { this.attached[i].move(shift, scale, rotate, point, drag); }
        
        return this;
    }

    private void xscale (real s)
    {
        pair center = this.center;
        this.move(shift = -center, drag = false);
        this.contour = scale(s,1)*this.contour;
        
        for (hole hl : this.holes)
        {
            hl.contour = scale(s,1)*hl.contour;
            hl.center = scale(s,1)*hl.center;

            for (real[] sc : hl.sections)
            { sc[0] = degrees(scale(s,1)*dir(sc[0])); }
        }
        for (subset sb : this.subsets)
        {
            sb.contour = scale(s,1) * sb.contour;
            sb.center = scale(s,1) * sb.center;
            sb.labeldir = scale(1,s) * sb.labeldir;
        }

        this.move(shift = center, drag = false);
    }

    smooth dirscale (pair dir, real s)
    // Scale smooth object along the direction given by `dir`.
    {
        if (length(dir) == 0) return this;
        
        real deg = degrees(dir);
        this.move(rotate = -deg, readjust = false, drag = false);
        this.xscale(s);
        this.move(rotate = deg, readjust = false, drag = false);
        
        this.unitadjust = this.selfadjust();
        
        return this;
    }

    // -- Methods for setting other object parameters -- //

    smooth setratios (real[] ratios, bool horiz)
    // Controls horizontal (vertical) "ratios" that are used in `cartesian` draw mode.
    {
        if (ratios.length > 0 && dummy(ratios[0]))
        {
            int count = 0;
            real[] curratios = horiz ? this.hratios : this.vratios;
            int bound = floor((1 - 2*config.smooth.edgemargin)/config.smooth.stepdistance) + 1;

            real r = config.smooth.edgemargin;
            for (int i = 0; i < bound; ++i)
            {
                curratios.push(r);
                r += config.smooth.stepdistance;
            }

            return this;
        }
        for (int i = 0; i < ratios.length; ++i)
        {
            if (!inside(0,1, ratios[i]))
            { halt("Could not set ratios: all entries must lie between 0 and 1. [ setratios() ]"); }
        }

        if (horiz) this.hratios = ratios;
        else this.vratios = ratios;
        
        return this;
    }

    smooth setcenter (
        int index = -1,
        pair center = config.system.dummypair,
        bool unit = config.smooth.unit
    ) // Sets the center of the object or one of its subsets. The center is used for cross section positioning and arrows.
    {
        this.checksubsetindex(index, "setcenter");
        if (index == -1)
        {
            if (dummy(center)) center = center(this.contour);
            else if (unit) center = this.unitadjust*center;
            
            this.center = center;
            this.unitadjust = this.selfadjust();
            
            if (!this.inside(this.center))
            { write("> ? Center out of bounds: might cause problems later. [ setcenter() ]"); }
        }
        else
        {
            subset sb = this.subsets[index];

            if (dummy(center)) center = center(sb.contour);
            else if (unit) center = this.adjust(index)*center;
            
            sb.center = center;
            
            if (!inside(sb.contour, sb.center))
            { write("> ? Center out of bounds: might cause problems later. [ setcenter() ]"); }
        }

        return this;
    }

    smooth setcenter (
        string destlabel,
        pair center,
        bool unit = config.smooth.unit
    ) { return this.setcenter(findlocalsubsetindex(destlabel), center, unit); }

    smooth setlabel (
        int index = -1,
        string label = config.system.dummystring,
        pair dir = config.system.dummypair,
        pair align = config.system.dummypair
    ) // Controls the label of the object, or one of its subsets under `indexpath`.
    {
        this.checksubsetindex(index, "setlabel");

        if (!config.system.repeatlabels && repeats(label))
        { halt("Could not set label: label \""+label+"\" already assigned. [ setlabel() ]"); }

        if (index == -1)
        {
            if (!dummy(label)) this.label = label;
            if (!dummy(dir)) this.labeldir = dir;
            if (!dummy(align)) this.labelalign = align;
        }
        else
        {
            subset sb = this.subsets[index];
            if (!dummy(label)) sb.label = label;
            if (!dummy(dir)) sb.labeldir = dir;
            if (!dummy(align)) sb.labelalign = align;
        }

        return this;
    }

    smooth setlabel (
        string destlabel,
        string label,
        pair dir = config.system.dummypair,
        pair align = config.system.dummypair
    ) { return this.setlabel(findlocalsubsetindex(destlabel), label, dir, align); }

    // -- Methods for manipulating elements -- //

    smooth addelement (
        element elt,
        int index = -1,
        bool unit = config.smooth.unit
    )
    {
        this.checksubsetindex(index, "addelement");

        if (!config.system.repeatlabels && repeats(elt.label))
        { halt("Could not add element: label \""+elt.label+"\" already assigned. [ addelement() ]"); }
        
        if (unit) { elt.pos = this.adjust(index)*elt.pos; }

        if (!this.inside(elt.pos))
        { halt("Could not add element: position out of bounds. [ addelement() ]"); }

        this.elements.push(elt);
        return this;
    }

    smooth addelement (
        pair pos,
        string label = "",
        pair align = 1.5*S,
        int index = -1,
        bool unit = config.smooth.unit
    )
    { return this.addelement(element(pos, label, align), index, unit); }

    smooth setelement (
        int index,
        element elt,
        int sbindex = -1,
        bool unit = config.smooth.unit
    )
    {
        if (!config.system.repeatlabels && repeats(elt.label))
        { halt("Could not set element: label \""+elt.label+"\" already assigned. [ setelement() ]"); }
        
        if (unit) { elt.pos = this.adjust(sbindex)*elt.pos; }

        this.elements[index] = elt;
        return this;
    }

    smooth setelement (
        int index,
        pair pos = config.system.dummypair,
        string label = config.system.dummystring,
        pair labelalign = config.system.dummypair,
        int sbindex = -1,
        bool unit = config.smooth.unit
    )
    {
        if (!config.system.repeatlabels && repeats(label))
        { halt("Could not set element: label \""+label+"\" already assigned. [ setelement() ]"); }
        
        if (!dummy(pos))
        {
            if (unit) { pos = this.adjust(index)*pos; }
            this.elements[index].pos = pos;
        }
        if (!dummy(label)) this.elements[index].label = label;
        if (!dummy(labelalign)) this.elements[index].labelalign = labelalign;

        return this;
    }

    smooth setelement (
        string destlabel,
        element elt,
        bool unit = config.smooth.unit
    ) { return this.setelement(findlocalelementindex(destlabel), elt, unit); }

    smooth setelement (
        string destlabel,
        pair pos = config.system.dummypair,
        string label = config.system.dummystring,
        pair labelalign = config.system.dummypair,
        bool unit = config.smooth.unit
    ) { return this.setelement(findlocalelementindex(destlabel), pos, label, labelalign, unit); }

    smooth rmelement (int index)
    {
        this.elements.delete(index);
        return this;
    }

    smooth rmelement (string destlabel)
    { this.elements.delete(findlocalelementindex(destlabel)); return this; }

    smooth movelement (int index, pair shift)
    {
        this.elements[index].pos += shift;
        return this;
    }

    smooth movelement (string destlabel, pair shift)
    { return this.movelement(findlocalelementindex(destlabel), shift); }

    // -- Methods for manipulating holes -- //

    smooth addhole (
        hole hl,
        int insertindex = this.holes.length,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    )
    {
        if (unit)
        {
            hl.contour = this.unitadjust * hl.contour;
            if (!dummy(hl.center)) hl.center = this.unitadjust * hl.center;
        }
        
        bool add = true;
        bool mainintersects = false;

        // Checking if the new hole fits inside the object

        if (!insidepath(this.contour, hl.contour))
        {
            if (!meet(this.contour, hl.contour))
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: contour out of bounds. It will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }

            if (clip)
            {
                mainintersects = true;
                add = false;
            }
            else
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: contour out of bounds. It will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }
        }

        for (int i = 0; i < this.holes.length; ++i)
        {
            if (insidepath(this.holes[i].contour, hl.contour))
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: contour inside another hole. It will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }
        }
        bool hlintersects = false;
        int hlindex = -1;
        for (int i = 0; i < this.holes.length; ++i)
        {
            if (meet(this.holes[i].contour, hl.contour))
            {
                if (hlintersects || !clip)
                {
                    debugpaths.push(hl.contour);
                    write("> ? Could not add hole: contour intersecting with more than one hole. It will be drawn in red on the final picture. [ addhole() ]");
                    return this;
                }

                hlintersects = true;
                hlindex = i;
            }
        }
        path[] hlunion;
        if (hlintersects)
        {
            add = false;
            hlunion = union(this.holes[hlindex].contour, hl.contour);
            if (hlunion.length != 1)
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: non-trivial union of holes. The contour will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }
        }
        path[] mdiff;
        if (mainintersects)
        {
            mdiff = difference(this.contour, hl.contour);
            if (mdiff.length != 1)
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: contour disects the object in more than one part. It will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }
        }

        int[] layer0 = subsetgetlayer(this.subsets, sequence(this.subsets.length), 0);

        for (int i = 0; i < layer0.length; ++i)
        {
            if (insidepath(this.subsets[layer0[i]].contour, hl.contour))
            {
                debugpaths.push(hl.contour);
                write("> ? Could not add hole: contour inside subset. It will be drawn in red on the final picture. [ addhole() ]");
                return this;
            }
        }

        path[][] sdiff = new path[this.subsets.length][];
        bool[] intersects = new bool[this.subsets.length];
        bool abort = false;

        void fillintersects (int i)
        {
            intersects[i] = meet(this.subsets[i].contour, hl.contour);
            if (!intersects[i]) { return; }
            else
            {
                if (!clip)
                { abort = true; return; }

                sdiff[i] = difference(this.subsets[i].contour, hl.contour);

                if (sdiff[i].length != 1)
                { abort = true; return; }

                for (int j = 0; j < this.subsets[i].subsets.length; ++j)
                { fillintersects(this.subsets[i].subsets[j]); }
            }
        }

        for (int i = 0; i < layer0.length; ++i)
        {
            fillintersects(layer0[i]);
            if (abort) break;
        }

        if (abort)
        {
            debugpaths.push(hl.contour);
            write("> ? Could not add hole: contour intervening with subsets. It will be drawn in red on the final picture. [ addhole() ]");
            return this;
        }

        // Changing the contours

        if (mainintersects)
        {
            this.contour = mdiff[0];
            if (!hlintersects && config.smooth.setcenter) this.center = center(this.contour);
        }
        if (hlintersects)
        {
            if (mainintersects)
            {
                this.contour = difference(this.contour, this.holes[hlindex].contour)[0];
                if (config.smooth.setcenter) this.center = center(this.contour);
                this.holes.delete(hlindex);
            }
            else
            {
                this.holes[hlindex].contour = hlunion[0];
                if (config.smooth.setcenter) this.holes[hlindex].center = center(this.holes[hlindex].contour);
            }
        }
        for (int i = 0; i < this.subsets.length; ++i)
        {
            if (sdiff[i].length > 0)
            {
                this.subsets[i].contour = sdiff[i][0];
                if (config.smooth.setcenter) this.subsets[i].center = center(this.subsets[i].contour);
                this.subsets[i].isonboundary = true;
            }
        }
        if (!add) return this;

        // Adding the hole if it fits in the object

        if (dummy(hl.center)) hl.center = center(hl.contour);
        pair holedir = (hl.center == this.center) ? (-1,0) : unit(hl.center - this.center);
        for (int i = 0; i < hl.sections.length; ++i)
        {
            if (dummy(hl.sections[i][0]))
            {
                hl.sections[i][0] = degrees(holedir) + 360*i/hl.sections.length;
            }
            if (dummy(hl.sections[i][1]) || hl.sections[i][1] <= 0 || hl.sections[i][1] >= 360) hl.sections[i][1] = config.section.default[1];
            if (dummy(hl.sections[i][2]) || hl.sections[i][2] <= 0 || hl.sections[i][2] != ceil(hl.sections[i][2])) hl.sections[i][2] = config.section.default[2];
        }

        this.holes.insert(i = insertindex, hl);
        return this;
    }

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
    {
        return this.addhole(hole(contour = contour, center = center, sections = sections, shift = shift, scale = scale, rotate = rotate, point = point), clip = clip, unit = unit);
    }

    smooth addholes (
        hole[] holes,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    )
    {
        for (int i = 0; i < holes.length; ++i)
        { this.addhole(holes[i], clip = clip, unit = unit); }
        return this;
    }

    smooth addholes (
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... hole[] holes
    )
    { return this.addholes(holes, clip = clip, unit = unit); }

    smooth addholes (
        path[] contours,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    )
    {
        return this.addholes(holes = sequence(new hole (int i) { return hole(contours[i]); }, contours.length), clip = clip, unit = unit);
    }

    smooth addholes (
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... path[] contours
    )
    { return this.addholes(contours, clip = clip, unit = unit); }

    smooth rmhole (int index = this.holes.length-1)
    { this.holes.delete(index); return this; }

    smooth rmholes (int[] indices)
    {
        indices = sort(indices);
        for (int i = indices.length-1; i >= 0; i -= 1)
        { this.holes.delete(indices[i]); }
        return this;
    }

    smooth rmholes (... int[] indices)
    { return this.rmholes(indices); }

    smooth movehole (
        int index,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = this.holes[index].center,
        bool movesections = false,
        bool keepview = true
    )
    {
        transform move = srap(scale, rotate, point) * shift(shift);
        path newcontour = move * this.holes[index].contour;

        bool outofbounds = false;

        if (!insidepath(this.contour, newcontour)) outofbounds = true;
        if (!outofbounds) for (int i = 0; i < this.holes.length; ++i)
        {
            if (i == index) continue;
            if (meet(newcontour, this.holes[i].contour))
            {
                outofbounds = true;
                break;
            }
        }
        if (!outofbounds) for (int i = 0; i < this.subsets.length; ++i)
        {
            if (meet(newcontour, this.subsets[i].contour))
            {
                outofbounds = true;
                break;
            }
        }

        if (outofbounds)
        {
            debugpaths.push(newcontour);
            write("> ? Could not move hole: new contour out of bounds. It will be drawn in red on the final picture. [ movehole() ]");
            return this;
        }

        hole hl = this.holes[index];
        hl.contour = newcontour;
        hl.center = move * hl.center;
        if (movesections)
        {
            for (int i = 0; i < hl.sections.length; ++i)
            { hl.sections[i][0] += rotate; }
        }

        return this;
    }

    smooth addsection (
        int index,
        real[] section = {}
    )
    {
        if (!checksection(section))
        {
            write("> ? Could not add hole section: invalid entries. [ addsection() ]");
            return this;
        }
        for (int i = 1; i < section.length; ++i)
        { if (dummy(section[i])) section[i] = config.section.default[i]; }
        while (section.length < config.section.default.length)
        { section.push(config.section.default[section.length]); }
        pair holedir = (this.holes[index].center == this.center) ? (-1,0) : unit(this.holes[index].center - this.center);
        if (dummy(section[0]))
        { section[0] = degrees(holedir); }

        this.holes[index].sections.push(section);
        return this;
    }

    smooth setsection (
        int index,
        int scindex = 0,
        real[] section = {}
    )
    {
        if (!checksection(section))
        {
            write("> ? Could not set hole section: invalid entries. [ setsection() ]");
            return this;
        }
        real[] cursection = this.holes[index].sections[scindex];
        int len = min(section.length, cursection.length);
        for (int i = 0; i < len; ++i)
        { if (!dummy(section[i])) cursection[i] = section[i]; }

        return this;
    }

    smooth rmsection (
        int index = this.holes.length-1,
        int ind2 = 0
    ) { this.holes[index].sections.delete(ind2); return this; }

    // -- Methods for manipulating subsets -- //

    smooth addsubset (
        subset sb,
        int index = -1, // the index of parent subset (or the entire smooth object, if index == -1).
        bool inferlabels = config.smooth.inferlabels, // whether to create intersection labels.
        bool clip = config.smooth.clip, // whether to complain if subset is out of bounds, or clip its contour instead.
        bool unit = config.smooth.unit, // whether to fit the subset to the smooth object
        bool checkintersection = true
    ) // Add a subset to the smooth object.
    {
        this.checksubsetindex(index, "addsubset");

        if (!config.system.repeatlabels && repeats(sb.label))
        { halt("Could not add subset: label \""+sb.label+"\" already assigned. [ addsubset() ]"); }

        if (unit)
        {
            transform adjust = this.adjust(index);
            sb.contour = adjust * sb.contour;
            if (!dummy(sb.center)) sb.center = adjust * sb.center;
        }

        if (index == -1)
        {
            int layer = -1;
            int newindex = -1;
            bool found = false;

            void findindex (int i)
            {
                subset cursb = this.subsets[i];
                if (cursb.layer > layer && insidepath(cursb.contour, sb.contour))
                {
                    newindex = i;
                    layer = cursb.layer;
                    for (int j = 0; j < cursb.subsets.length; ++j)
                    {
                        findindex(cursb.subsets[j]);
                        if (found) break;
                    }
                    found = true;
                }
            }

            for (int i = 0; i < this.subsets.length; ++i)
            {
                if (this.subsets[i].layer == 0) findindex(i);
                if (found) return this.addsubset(sb, newindex, inferlabels, clip, false, checkintersection);
            }
        }

        if (sb.subsets.length > 0)
        {
            write("> ? New subset already contains some subset indices. They will be removed. [ addsubset() ]");
            sb.subsets.delete();
        }
        
        path pcontour;
        int[] range;
        subset parent;
        bool sub = index > -1;

        if (sub)
        {
            parent = this.subsets[index];
            sb.layer = parent.layer + 1;
            pcontour = parent.contour;
            range = parent.subsets;
        }
        else
        {
            sb.layer = 0;
            pcontour = this.contour;
            range = subsetgetlayer(this.subsets, sequence(this.subsets.length), 0);
        }

        if (checkintersection && !sub)
        {
            bool meet = false;

            if (!insidepath(pcontour, sb.contour))
            {
                if (clip && meet(pcontour, sb.contour))
                {
                    sb.contour = intersection(pcontour, sb.contour)[0];
                    sb.isonboundary = true;
                    meet = true;
                }
                else
                {
                    debugpaths.push(sb.contour);
                    write("> ? Could not add subset: contour out of bounds. It will be drawn in red on the final picture. [ addsubset() ]");
                    return this;
                }
            }

            for (int i = 0; i < this.holes.length; ++i)
            {
                if (meet(this.holes[i].contour, sb.contour))
                {
                    if (clip)
                    {
                        sb.contour = difference(sb.contour, this.holes[i].contour)[0];
                        sb.isonboundary = true;
                        meet = true;
                    }
                    else
                    {
                        debugpaths.push(sb.contour);
                        write("> ? Could not add subset: contour out of bounds. It will be drawn in red on the final picture. [ addsubset() ]");
                        return this;
                    }
                }
                else if (inside(this.holes[i].contour, inside(sb.contour)))
                {
                    debugpaths.push(sb.contour);
                    write("> ? Could not add subset: contour contained in a hole. It will be drawn in red on the final picture. [ addsubset() ]");
                    return this;
                }
            }
        }

        for (int i = 0; i < range.length; ++i)
        {
            if (insidepath(this.subsets[range[i]].contour, sb.contour))
            {
                debugpaths.push(sb.contour);
                write("> ? Could not add subset: contour is contained in another subset under index "+(string)range[i]+". The contour will be drawn in red on the final picture. [ addsubset() ]");
                return this;
            }
        }

        int insertindex = this.subsets.length;
        int[] intersectionindices = array(this.subsets.length, value = -1);
        if (dummy(sb.center)) sb.center = center(sb.contour);
        this.subsets.push(sb);
        int count = 0;
        bool deepened = false;
        bool terminate = false;

        void intersectwith (int i)
        {
            if (intersectionindices[i] > -1) return;
            if (intersectionindices[i] == -2) return;
            subset cursb = this.subsets[i];

            if (insidepath(sb.contour, cursb.contour))
            {
                deepened = true;
                subsetdeepen(this.subsets, cursb);
                for (int j = 0; j < cursb.subsets.length; ++j)
                { intersectionindices[cursb.subsets[j]] = cursb.subsets[j]; }
                intersectionindices[i] = i;
                return;
            }

            subset[] intersection = subsetintersection(cursb, sb, inferlabels);
            if (intersection.length > 1)
            {
                write("> ? Could not add subset: has disconnected intersection with existing subsets. It will be drawn in red on the final picture. [ addsubset() ]");
                this.subsets.delete(insertindex, this.subsets.length-1);
                subsetcleanreferences(this.subsets);
                terminate = true;
                return;
            }
            if (intersection.length == 0)
            {
                intersectionindices[i] = -2;
                return;
            }
            subset intersectsb = intersection[0];
            for (int j = 0; j < cursb.subsets.length; ++j)
            {
                if (insidepath(this.subsets[cursb.subsets[j]].contour, intersectsb.contour))
                {
                    intersectionindices[i] = -2;
                    return;
                }
            }
            this.subsets.push(intersectsb);
            int intersectindex = this.subsets.length-1;

            bool inside = false;

            for (int j = 0; j < cursb.subsets.length; ++j)
            {
                subset curchild = this.subsets[cursb.subsets[j]];
                if (insidepath(curchild.contour, sb.contour))
                { inside = true; }
                
                intersectwith(cursb.subsets[j]);
                int newindex = intersectionindices[cursb.subsets[j]];
                if (newindex > -1) intersectsb.subsets.push(newindex);
            }

            cursb.subsets.push(intersectindex);
            intersectionindices[i] = intersectindex;
        }

        for (int i = 0; i < range.length; ++i)
        {
            if (terminate) return this;
            
            intersectwith(range[i]);
            int newindex = intersectionindices[range[i]];
            if (newindex > -1) sb.subsets.push(newindex);
        }

        if (sub) parent.subsets.push(insertindex);
        subsetcleanreferences(this.subsets);
        return this;
    }

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
    {
        return this.addsubset(sb = subset(contour = contour, center = center, label = label, labeldir = dir, labelalign = align, shift = shift, scale = scale, rotate = rotate, point = point), index, inferlabels, clip, unit);
    }

    smooth addsubset (
        string destlabel,
        subset sb,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    ) { return this.addsubset(sb, findlocalsubsetindex(destlabel), inferlabels, clip, unit); }

    smooth addsubset (
        string destlabel,
        path contour,
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
    {
        return this.addsubset(destlabel, sb = subset(contour = contour, label = label, labeldir = dir, labelalign = align, shift = shift, scale = scale, rotate = rotate, point = point), inferlabels, clip, unit);
    }

    smooth addsubsets (
        subset[] sbs,
        int index = -1,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    )
    {
        for (int i = 0; i < sbs.length; ++i)
        { this.addsubset(sbs[i], index, inferlabels, clip, unit); }

        return this;
    }

    smooth addsubsets (
        int index = -1,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... subset[] sbs
    ) { return this.addsubsets(sbs, index, inferlabels, clip, unit); }

    smooth addsubsets (
        int index = -1,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... path[] contours
    )
    {
        return this.addsubsets(index = index, sbs = sequence(new subset (int i){ return subset(contours[i]); }, contours.length), inferlabels, clip, unit);
    }

    smooth addsubsets (
        string destlabel,
        subset[] sbs,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
    ) { return this.addsubsets(sbs, findlocalsubsetindex(destlabel), inferlabels, clip, unit); }

    smooth addsubsets (
        string destlabel,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... subset[] sbs
    ) { return this.addsubsets(destlabel, sbs, inferlabels, clip, unit); }

    smooth addsubsets (
        string destlabel,
        bool inferlabels = config.smooth.inferlabels,
        bool clip = config.smooth.clip,
        bool unit = config.smooth.unit
        ... path[] contours
    )
    {
        return this.addsubsets(destlabel, sbs = sequence(new subset (int i){ return subset(contours[i]); }, contours.length), inferlabels, clip, unit);
    }

    smooth rmsubset (
        int index = this.subsets.length-1,
        bool recursive = true
    ) // Remove a subset.
    {
        this.checksubsetindex(index, "rmsubset");

        if (this.subsets[index].isderivative)
        {
            write("> ? Removing an intersection of subsets. [ rmsubset() ]");
        }
        subsetdelete(this.subsets, index, recursive); return this;
    }

    smooth rmsubset (
        string destlabel,
        bool recursive = true
    ) { return this.rmsubset(findlocalsubsetindex(destlabel), recursive); }

    smooth rmsubsets (
        int[] indices,
        bool recursive = true
    )
    {
        for (int i = indices.length-1; i >= 0; i -= 1)
        { this.rmsubset(indices[i], recursive); }
        return this;
    }

    smooth rmsubsets (
        bool recursive = true
        ... int[] indices
    ) { return this.rmsubsets(indices, recursive); }

    smooth rmsubsets (
        string[] destlabels,
        bool recursive = true
    )
    {
        for (int i = 0; i < destlabels.length; ++i)
        { this.rmsubset(destlabels[i], recursive); }
        return this;
    }

    smooth rmsubsets (
        bool recursive = true
        ... string[] destlabels
    ) { return this.rmsubsets(destlabels, recursive); }

    // -- Methods for moving subset globally or within containing subset -- //

    private bool onlyprimary (int index)
    {
        subset s = this.subsets[index];
        
        bool res = true;
        for (int i = 0; i < s.subsets.length; ++i)
        {
            if (this.subsets[s.subsets[i]].isderivative)
            {
                res = false;
                break;
            }
        }

        return res;
    }

    private bool onlysecondary (int index)
    {
        subset s = this.subsets[index];
        
        bool res = true;
        for (int i = 0; i < s.subsets.length; ++i)
        {
            if (!res || !this.subsets[s.subsets[i]].isderivative)
            {
                res = false;
                break;
            }
            res = res && onlysecondary(s.subsets[i]);
        }

        return res;
    }

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
    {
        this.checksubsetindex(index, "movesubset");

        subset cursb = this.subsets[index];
        point = (dummy(point)) ? cursb.center : point;

        if (cursb.isderivative) 
        {
            halt("Could not move subset: subset under index "+(string)index+" is an intersection of subsets. [ movesubset() ]");
        }
        if (cursb.isonboundary)
        {
            halt("Could not move subset: subset under index "+(string)index+" is on the boundary. [ movesubset() ]");
        }

        int parentindex = -1;
        int relindex = -1;
        bool found = false;
        if (bounded) for (int i = 0; i < this.subsets.length; ++i)
        {
            subset curparent = this.subsets[i];
            if (curparent.layer != cursb.layer - 1) continue;

            for (int j = 0; j < curparent.subsets.length; ++j)
            {
                if (curparent.subsets[j] == index)
                {
                    parentindex = i;
                    relindex = j;
                    found = true;
                    break;
                }
            }

            if (found) break;
        }

        bool sub = parentindex > -1;
        int[] allsubsets = subsetgetall(this.subsets, cursb);
        path pcontour;
        int[] range; 

        if (sub)
        {
            subset parent = this.subsets[parentindex];
            pcontour = parent.contour;
            range = parent.subsets;
            range.delete(relindex);
        }
        else
        {
            pcontour = this.contour;
            range = sequence(this.subsets.length);
            range.delete(index);
            range = difference(range, allsubsets);
        }

        path newcontour = shift(shift)*srap(scale, rotate, point)*cursb.contour;

        bool onlysecondary = onlysecondary(index);
        bool onlyprimary = onlyprimary(index);
        if (!onlysecondary && !onlyprimary)
        {
            halt("Could not move subset: situation too complicated: both primary and secondary subsets present. [ movesubset() ]");
            return this;
        }

        if (!clip && onlysecondary)
        {
            bool outofbounds = false;

            if (!insidepath(pcontour, newcontour)) outofbounds = true;
            if (!outofbounds) for (int i = 0; i < this.holes.length; ++i)
            {
                if (meet(this.holes[i].contour, newcontour))
                {
                    outofbounds = true;
                    break;
                }
            }

            if (outofbounds)
            {
                debugpaths.push(newcontour);
                write("> ? Could not move subset: new contour out of bounds. It will be drawn in red on the final picture. [ movesubset() ]");
                return this;
            }
        }

        if (onlysecondary)
        {
            rmsubset(index, recursive = true);
            addsubset(cursb.move(shift, scale, rotate, point, movelabel), inferlabels, clip = clip, unit = false);
            return this;
        }
        if (onlyprimary)
        {
            for (int i = 0; i < range.length; ++i)
            {
                if (range[i] == -1) continue;
                
                if (meet(newcontour, this.subsets[range[i]].contour) || insidepath(newcontour, this.subsets[range[i]].contour) || insidepath(this.subsets[range[i]].contour, newcontour))
                {
                    debugpaths.push(newcontour);
                    write("> ? Could not move subset: new contour intersects with other subsets. It will be drawn in red on the final picture. [ movesubset() ]");
                    return this;
                }
            }
            
            if (recursive)
            {
                for (int i = 0; i < allsubsets.length; ++i)
                { this.subsets[allsubsets[i]].move(shift, scale, rotate, point, movelabel); }

                cursb.move(shift, scale, rotate, point, movelabel);
            }
            else
            {
                for (int i = 0; i < cursb.subsets.length; ++i)
                {
                    if (!insidepath(newcontour, this.subsets[cursb.subsets[i]].contour))
                    {
                        debugpaths.push(newcontour);
                        write("> ? Could not move subset: new contour makes existing subsets out-of-bounds. It will be drawn in red on the final picture. [ movesubset() ]");
                        return this;
                    }
                }

                cursb.move(shift, scale, rotate, point, movelabel);
            }

            return this;
        }

        return this;
    }

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
    {
        return this.movesubset(findlocalsubsetindex(destlabel), shift, scale, rotate, point, movelabel, recursive, bounded, clip, inferlabels, keepview);
    }

    // -- Methods for controlling relationships between smooth objects -- //

    smooth attach (smooth sm)
    // Make the current object remember `sm` and drag it when moving.
    { this.attached.push(sm); return this; }

    smooth fit (
        int index = -1,
        picture pic = currentpicture,
        picture addpic,
        pair shift = (0,0)
    ) // Fit an entire picture inside the object or its subset.
    {
        this.checksubsetindex(index, "fit");

        path contour = (index == -1) ? this.contour : this.subsets[index].contour;
        pair center = (index == -1) ? this.center : this.subsets[index].center;
        addpic = shift(center)*shift(-shift)*addpic;
        clip(addpic, contour);
        pic.add(addpic);

        return this;
    }
    
    // Constructor
    void operator init (
        path contour,
        pair center = center(contour),
        string label = "",
        pair labeldir = N,
        pair labelalign = config.system.dummypair,
        hole[] holes = {},
        subset[] subsets = {},
        element[] elements = {},
        real[] hratios = r(config.system.dummynumber),
        real[] vratios = r(config.system.dummynumber),
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center,
        pair viewdir = config.drawing.viewdir,
        bool distort = true,
        smooth[] attached = {},
        bool correct = config.smooth.correct,
        bool copy = false,
        bool shiftsubsets = config.smooth.shiftsubsets,
        bool isderivative = false,
        bool unit = config.smooth.unit,
        void postdraw (dpar ds, smooth sm) = new void (dpar, smooth) {} 
    )
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
            this.holes = holecopy(holes);
            this.subsets = subsetcopy(subsets);
            this.hratios = hratios;
            this.vratios = vratios;
            this.attached = attached;
            this.isderivative = isderivative;
            this.postdraw = postdraw;
        }
        else
        {
            if (scale <= 0)
            { halt("Could not build: scale value must be positive. [ smooth() ]"); }
            
            this.contour = shift(shift)*srap(scale, rotate, point)*((!clockwise(contour) && correct) ? reverse(contour) : contour);
            this.center = shift(shift)*center;
            if (!config.system.repeatlabels && label != "" && smooth.repeats(label))
            {
                halt("Could not build smooth object: entities with label \""+label+"\" already present. [ smooth() ]");
            }
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;

            this.unitadjust = shift(this.center) * scale(radius(this.contour));

            for (int i = 0; i < holes.length; ++i)
            { addhole(holes[i].move(shift, scale, rotate, point, false), unit = unit); }
            for (int i = 0; i < subsets.length; ++i)
            { addsubset(subsets[i].move(shift, scale, rotate, point, false), unit = unit); }
            for (int i = 0; i < elements.length; ++i)
            { addelement(elements[i].move(shift, scale, rotate, point, false), unit = unit); }

            this.setratios(hratios, true);
            this.setratios(vratios, false);

            this.isderivative = isderivative;
            
            this.attached = attached;

            this.postdraw = postdraw;
        }

        cache.push(this);
    }

    smooth copy ()
    {
        return smooth(
            contour = this.contour,
            center = this.center,
            label = this.label,
            labeldir = this.labeldir,
            labelalign = this.labelalign,
            holes = holecopy(this.holes),
            subsets = subsetcopy(this.subsets),
            elements = elementcopy(this.elements),
            hratios = this.hratios,
            vratios = this.vratios,
            attached = this.attached,
            postdraw = this.postdraw,
            copy = true
        );
    }
    smooth replicate (smooth sm)
    {
        this.contour = sm.contour;
        this.center = sm.center;
        this.label = sm.label;
        this.labeldir = sm.labeldir;
        this.labelalign = sm.labelalign;
        this.holes = holecopy(sm.holes);
        this.subsets = subsetcopy(sm.subsets);
        this.elements = elementcopy(sm.elements);
        this.unitadjust = sm.unitadjust;
        this.hratios = sm.hratios;
        this.vratios = sm.vratios;
        this.attached = sequence(new smooth (int i){return sm.attached[i].copy();}, sm.attached.length);
        this.postdraw = sm.postdraw;

        return this;
    }

    smooth shift (explicit pair shift)
    { return this.move(shift = shift); }

    smooth shift (real xshift, real yshift = 0)
    { return this.move(shift = (xshift, yshift)); }

    smooth scale (real scale)
    { return this.move(scale = scale); }

    smooth rotate (real rotate)
    { return this.move(rotate = rotate); }
}

// >smooth | Utilities for smooth objects

smooth[] concat (smooth[][] smss)
{
    if (smss.length == 0) return new smooth[];
    if (smss.length == 1) return smss[0];
    smooth[] sms = smss.pop();
    return concat(concat(smss), sms);
}

void print (smooth sm)
// Print information about a given smooth object. Could be useful when drawing the object is too resource-consuming.
{
    string[] msg;
    msg.push("> SMOOTH OBJECT: " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label));
    msg.push("> DIRECTION: " + (string)round(sm.labeldir, 2) + " | ALIGN: " + (dummy(sm.labelalign) ? "[normal]" : (string)round(sm.labelalign, 2)));
    msg.push("> CENTER: " + (string)round(sm.center, 2));

    msg.push("");
    msg.push("> HOLES: " + (string)sm.holes.length);
    if (sm.holes.length > 0)
    {
        int holeindexlength = length((string)(sm.holes.length - 1));
        int holecenterlength = max(sequence(
            new int (int i) { return length((string)round(sm.holes[i].center, 2)); },
            sm.holes.length
        ));
        for (int i = 0; i < sm.holes.length; ++i)
        {
            string index = (string)i + repeatstring(" ", holeindexlength - length((string)i));
            string center = (string)round(sm.holes[i].center, 2);
            center = center + repeatstring(" ", holecenterlength - length(center));

            msg.push("| " + index + " | CENTER: " + center + " | SECTIONS: " + (string)sm.holes[i].sections.length);
        }
    }

    msg.push("");
    msg.push("> SUBSETS: " + (string)sm.subsets.length);
    if (sm.subsets.length > 0)
    {
        int subsetindexlength = length((string)(sm.subsets.length - 1));
        int subsetcenterlength = max(sequence(
            new int (int i) { return length((string)round(sm.subsets[i].center, 2)); },
            sm.subsets.length
        ));
        int subsetlabellength = max(sequence(
            new int (int i) {
                if (sm.subsets[i].label == "") return length("[unlabeled]");
                return length(sm.subsets[i].label);
            },
            sm.subsets.length
        ));
        for (int i = 0; i < sm.subsets.length; ++i)
        {
            string index = (string)i + repeatstring(" ", subsetindexlength - length((string)i));
            string center = (string)round(sm.subsets[i].center, 2);
            center = center + repeatstring(" ", subsetcenterlength - length(center));
            string label = sm.subsets[i].label == "" ? "[unlabeled]" : sm.subsets[i].label;
            label = label + repeatstring(" ", subsetlabellength - length(label));
        
            string curmsg = "| " + index + " | CENTER: " + center + " | LABEL: " + label + " | SUBSETS: [";
            for (int j = 0; j < sm.subsets[i].subsets.length; ++j)
            { curmsg += ((string)sm.subsets[i].subsets[j] + (j < sm.subsets[i].subsets.length - 1 ? ", " : "")); }
            curmsg += "]";

            msg.push(curmsg);
        }
    }

    write("");
    string line = repeatstring("-", max(sequence(
        new int (int i) { return length(msg[i]); },
        msg.length
    )));
    write(line);
    for (int i = 0; i < msg.length; ++i)
    { write(msg[i]); }
    write(line);
}

void printall ()
{
    for (int i = 0; i < smooth.cache.length; ++i)
    { print(smooth.cache[i]); }
}

// >finding | Identifying objects by label

private int findsmoothindex (string label)
{
    bool found = false;
    int smres = -1;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        if (smooth.cache[i].label == label)
        {
            if (found) halt("Cannot identify smooth set: ambiguous label \""+label+"\". [ findsetindex() ]");
            found = true;
            if (!config.system.repeatlabels) return i;
            smres = i;
        }
    }

    if (!found) halt("Could not identify set: no object with label \""+label+"\". [ findsetindex() ]");
    return smres;
}

smooth findsm (string label)
{
    // int index = findsmoothindex(label);
    // if (indices[1] != -1) halt("Could not identify smooth object: object with label \""+label+"\" is a subset. Use `findsb()` instead. [ findsm() ]");
    return smooth.cache[findsmoothindex(label)];
}

smooth operator cast (string label)
{ return findsm(label); }

smooth[] operator cast (string[] labels)
{
    return sequence(
        new smooth (int i)
        { return findsm(labels[i]); },
        labels.length
    );
}

private int[] findsubsetindex (string label)
{
    bool found = false;
    int smres = -1;
    int sbres = -1;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        for (int j = 0; j < smooth.cache[i].subsets.length; ++j)
        {
            if (smooth.cache[i].subsets[j].label == label)
            {
                if (found) halt("Cannot identify set: ambiguous label \""+label+"\". [ findsetindex() ]");
                found = true;
                if (!config.system.repeatlabels) return i(i, j);
                smres = i;
                sbres = j;
            }   
        }
    }

    if (!found) halt("Could not identify set: no object with label \""+label+"\". [ findsetindex() ]");
    return i(smres, sbres);
}

subset findsb (string label)
{
    int[] indices = findsubsetindex(label);
    // if (indices[1] == -1) halt("Could not identify subset: object with label \""+label+"\" is not a subset. Use `findsm()` instead. [ findsb() ]");
    return smooth.cache[indices[0]].subsets[indices[1]];
}

subset operator cast (string label)
{ return findsb(label); }

subset[] operator cast (string[] labels)
{
    return sequence(
        new subset (int i)
        { return findsb(labels[i]); },
        labels.length
    );
}

private int[] findelementindex (string label)
{
    bool found = false;
    int smres;
    int eltres;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        for (int j = 0; j < smooth.cache[i].elements.length; ++j)
        {
            if (smooth.cache[i].elements[j].label == label)
            {
                if (found) halt("Cannot identify element: ambiguous label \""+label+"\". [ findelementindex() ]");
                found = true;
                if (!config.system.repeatlabels) return i(i, j);
                smres = i;
                eltres = j;
            }   
        }
    }

    if (!found) halt("Could not identify element: no object with label \""+label+"\". [ findelementindex() ]");
    return i(smres, eltres);
}

element findelt (string label)
// 
{
    int[] indices = findelementindex(label);
    // if (indices[1] == -1) halt("Could not identify element: object with label \""+label+"\" is not a element. Use `findsm()` instead. [ findsb() ]");
    return smooth.cache[indices[0]].elements[indices[1]];
}

element operator cast (string label)
{ return findelt(label); }

element[] operator cast (string[] labels)
{
    return sequence(
        new element (int i)
        { return findelt(labels[i]); },
        labels.length
    );
}

private int[] findbylabel (string label)
{
    bool found = false;
    int smres;
    int type = -2;
    int sbres = -1;
    int eltres;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        if (smooth.cache[i].label == label)
        {
            if (found) halt("Cannot identify smooth set: ambiguous label \""+label+"\". [ findsetindex() ]");
            if (!config.system.repeatlabels) return i(i, -1, -1);
            found = true;
            smres = i;
            type = -1;
        }

        for (int j = 0; j < smooth.cache[i].subsets.length; ++j)
        {
            if (smooth.cache[i].subsets[j].label == label)
            {
                if (found) halt("Cannot identify set: ambiguous label \""+label+"\". [ findsetindex() ]");
                found = true;
                if (!config.system.repeatlabels) return i(i, 0, j);
                smres = i;
                type = 0;
                sbres = j;
            }   
        }

        for (int j = 0; j < smooth.cache[i].elements.length; ++j)
        {
            if (smooth.cache[i].elements[j].label == label)
            {
                if (found) halt("Cannot identify element: ambiguous label \""+label+"\". [ findelementindex() ]");
                found = true;
                if (!config.system.repeatlabels) return i(i, 1, j);
                smres = i;
                type = 1;
                eltres = j;
            }   
        }
    }

    if (!found) halt("Could not identify set: no object with label \""+label+"\". [ findsetindex() ]");
    return i(smres, type, (type == 1) ? eltres : sbres);
}

// >tarrow | Utilities for `tarrow`

tarrow DeferredArrow(
    arrowhead head = DefaultHead,
    real size = 0,
    real angle = arrowangle,
    bool begin = false,
    bool end = true,
    bool arc = false,
    filltype filltype = null
)
{
    tarrow res;
    res.head = head;
    res.size = size;
    res.angle = angle;
    res.ftype = filltype;
    res.begin = begin;
    res.end = end;
    res.arc = arc;
    return res;
}
config.arrow.currentarrow = DeferredArrow(SimpleHead);

private arrowbar convertarrow(
    tarrow arrow,
    bool overridebegin = false,
    bool overrideend = false
)
{
    if (overridebegin && overrideend) return None;
    if (arrow == null) return None;
    unravel arrow;
    if (!begin && !end) return None;
    if (!begin && overridebegin) return None;
    if (!end && overrideend) return None;
    if (begin && end && !overridebegin && !overrideend)
    {
        return arc ? ArcArrows(head, size, angle, ftype) : Arrows(head, size, angle, ftype);
    }
    if (end && !overridebegin)
    {
        return arc ? EndArcArrow(head, size, angle, ftype, EndPoint) : EndArrow(head, size, angle, ftype, EndPoint);
    }
    else
    {
        return arc ? BeginArcArrow(head, size, angle, ftype, BeginPoint) : BeginArrow(head, size, angle, ftype, BeginPoint);
    }
}

// >tbar | Utilities for `tbar`

tbar DeferredBar(
    real size = 0,
    bool begin = false,
    bool end = false
)
{
    tbar res;
    res.size = size;
    res.begin = begin;
    res.end = end;
    return res;
}

private arrowbar convertbar(
    tbar bar,
    bool overridebegin = false,
    bool overrideend = false
)
{
    if (overridebegin && overrideend) return None;
    if (bar == null) return None;
    unravel bar;
    if (!begin && !end) return None;
    if (!begin && overridebegin) return None;
    if (!end && overrideend) return None;
    if (begin && end && !overridebegin && !overrideend) { return Bars(size); }
    if (begin && !overrideend) { return BeginBar(size); }
    if (end) { return EndBar(size); }
    return None;
}

// >deferredPath | An auxiliary structure for deferred path drawing
private struct deferredPath
{
    path[] g;
    pen p;
    int[] under;
    tarrow arrow;
    tbar bar;
}

// >deferredPath | Utilities for deferred paths

private deferredPath[][] deferredPaths;
private deferredPath[][] savedDeferredPaths;

private int extractdeferredindex (picture pic)
{
    string[] split;
    if (pic.nodes.length > 0 && (split = split(pic.nodes[0].key, "")).length > 1 && dummy(split[0]))
    { return (int)split[1]; }
    return -1;
}

private deferredPath[] extractdeferredpaths (picture pic, bool createlink)
{
    deferredPath[] res;
    int ind = extractdeferredindex(pic);
    if (ind >= 0) res = deferredPaths[ind];
    else if (createlink)
    {
        deferredPaths.push(res);
        pic.nodes.insert(0, node(
            d = new void (frame f, transform t, transform T, pair lb, pair rt) {},
            key = config.system.dummystring+" "+(string)(deferredPaths.length-1)
        ));
    }
    return res;
}

path[] getdeferredpaths (
    picture pic = currentpicture
) {
    deferredPath[] ps = extractdeferredpaths(pic, false);
    return concat(sequence(new path[] (int i) {
        return ps[i].g;
    }, ps.length));
}

private void purgedeferredunder (deferredPath[] curdeferred)
{
    for (int i = 0; i < curdeferred.length; ++i)
    {
        for (int j = 0; j < curdeferred[i].g.length; ++j)
        {
            if (curdeferred[i].under[j] > 0)
            {
                if (j == 0)
                {
                    if (curdeferred[i].arrow != null) curdeferred[i].arrow.begin = false;
                    if (curdeferred[i].bar != null) curdeferred[i].bar.begin = false;
                }
                if (j == curdeferred[i].g.length-1)
                {
                    if (curdeferred[i].arrow != null) curdeferred[i].arrow.end = false;
                    if (curdeferred[i].bar != null) curdeferred[i].bar.end = false;
                }
                curdeferred[i].g.delete(j);
                curdeferred[i].under.delete(j);
                j -= 1;
            }
        }
    }
}

// >values | Default smooth objects

smooth samplesmooth (int type, int num = 0, string label = "")
{
    if (type == 0)
    {
        if (num == 0)
        {
            return smooth(
                contour = ucircle,
                hratios = new real[] {.5},
                vratios = r(),
                distort = false,
                unit = false,
                label = label
            );
        }
        if (num == 1)
        {
            return smooth(
                contour = concavepaths[0],
                unit = false,
                label = label
            ); 
        }
        if (num == 2)
        {
            return smooth(
                contour = rotate(-90)*concavepaths[2],
                subsets = new subset[] {
                    subset(
                        contour = concavepaths[3],
                        scale = .48,
                        shift = (.13, -.55),
                        labeldir = dir(140)
                    )
                },
                unit = false,
                hratios = new real[] {.6, .83},
                vratios = r(),
                label = label
            );
        }
    }
    if (type == 1) 
    {
        if (num == 0)
        {
            return smooth(
                contour = convexpaths[1],
                labeldir = (-2,1),
                holes = new hole[] {
                    hole(
                        contour = convexpaths[2],
                        sections = rr(config.system.dummynumber, 260, config.system.dummynumber),
                        shift = (-.65, .25),
                        scale = .5
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = convexpaths[3],
                        labeldir = S,
                        shift = (.43,-.38),
                        scale = .5,
                        rotate = 10
                    )
                },
                unit = false,
                label = label
            );
        }
        if (num == 1)
        {
            return smooth(
                contour = rotate(50) * reflect((0,0), (0,1))*concavepaths[4],
                holes = new hole[] {
                    hole(
                        contour = rotate(45) * convexpaths[4],
                        shift = (-.73,-.08),
                        scale = .51,
                        rotate = -60,
                        sections = new real[][] {
                            new real[] {190, 280, 10}
                        }
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = convexpaths[6],
                        scale = .45,
                        rotate = 20,
                        shift = (.5,.28)
                    )
                },
                unit = false,
                label = label
            );
        }
        if (num == 2)
        {
            return smooth(
                contour = wavypath(2,2,2,2,2, 3.15, 2,2,2),
                holes = new hole[] {
                    hole(contour = convexpaths[5], scale = .55, shift = (-2,.7), rotate = 10, sections = rr(161,230,8))
                },
                subsets = new subset[] {
                    subset(contour = concavepaths[3], shift = (-.3,-.35), rotate = -50),
                    subset(contour = convexpaths[3], scale = .9, rotate = 10, shift = (.3,.5))
                },
                unit = false,
                label = label,
                scale = .5,
                shift = (.3,-.1)
            );
        }
    }
    if (type == 2)
    {
        if (num == 0)
        {
            return smooth(
                contour = concavepaths[4],
                holes = new hole[] {
                    hole(
                        contour = convexpaths[4],
                        sections = new real[][] {
                            new real[] {140, 60, 3},
                            new real[] {270, 80, 4}
                        },
                        shift = (-.5, -.15),
                        scale = .45,
                        rotate = 15
                    ),
                    hole(
                        contour = convexpaths[3],
                        sections = new real[][] {
                            new real[] {config.system.dummynumber, 230, 10}
                        },
                        shift = (.57,.52),
                        scale = .47,
                        rotate = -113
                    )
                },
                unit = false,
                label = label
            );
        }
    }
    if (type == 3)
    {
        if (num == 0)
        {
            return smooth(
                contour = scale(.35)*wavypath(new real[] {4,2,4,2,3.7,2}),
                holes = new hole[] {
                    hole(
                        contour = scale(.35)*convexpaths[4],
                        sections = rr(),
                        scale = .75,
                        shift = (.9,.02),
                        rotate = 5
                    ),
                    hole(
                        contour = scale(.35)*convexpaths[6],
                        sections = rr(),
                        scale = .75,
                        shift = (-.4,-.75)
                    ),
                    hole(
                        contour = scale(.35)*convexpaths[5],
                        sections = rr(),
                        scale = .80,
                        shift = (-.35,.6),
                        rotate = -20
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = scale(.35)*convexpaths[2],
                        shift = (.05, -.1),
                        scale = .95
                    )
                },
                unit = false,
                label = label
            );
        }
        if (num == 1)
        {
            return smooth(
                contour = concavepaths[5],
                holes = new hole[] {
                    hole(
                        contour = convexpaths[5],
                        sections = new real[][] {
                            new real[] {0, 160, 7}
                        },
                        shift = (.57,-.13),
                        scale = .37,
                        rotate = 90
                    ),
                    hole(
                        contour = reverse(ellipse(c = (0,0), a = 1, b = 2)),
                        sections = new real[][] {
                            new real[] {90,190,6}
                        },
                        scnumber = -1,
                        shift = (-.12,.7),
                        scale = .25
                    ),
                    hole(
                        contour = convexpaths[6],
                        sections = new real[][] {
                            new real[] {220, 190, 6}
                        },
                        shift = (-.35,-.43),
                        scale = .32,
                        rotate = 75
                    )
                },
                unit = false,
                label = label
            );
        }
    }

    if (type == 5)
    {
        if (num == 0)
        {
            return smooth(
                contour = wavypath(1.05,2,1.1,2,1.15,2,1.1,2),
                holes = new hole[] {
                    hole(
                        contour = convexpaths[4],
                        shift = (-.83,-.85),
                        scale = .4,
                        rotate = 60,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpaths[1],
                        shift = (.9,-.8),
                        scale = .38,
                        rotate = -10,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpaths[10],
                        shift = (-.9,.92),
                        scale = .35,
                        rotate = 15,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpaths[3],
                        shift = (.9,.9),
                        scale = .34,
                        rotate = 70,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpaths[2],
                        shift = (-.05,.05),
                        scale = .56
                    )
                },
                unit = false,
                label = label
            );
        }
    }

    halt("Invalid input. [ samplesmooth() ]");
    return null;
}

smooth sm (int type, int num = 0, string label = "") = samplesmooth;

smooth rn (
    int n,
    pair labeldir = (1,1),
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0
) // A method for the common diagram representation of the n-dimensional Eucledian space.
{
    return smooth(
        contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle,
        label = "\mathbb{R}^" + ((n == -1) ? "n" : (string)n),
        labeldir = (.5,1),
        labelalign = (-1.5,-1.5),
        hratios = new real[] {},
        vratios = new real[] {},
        postdraw = new void (dpar dspec, smooth sm)
        {
            transform adj = sm.unitadjust;
            pen p = dspec.contourpen;
            draw(adj*((-1,-.2)--(1,-.2)), p = p, arrow = Arrow(SimpleHead));
            draw(adj*((-.2,-1)--(-.2,1)), p = p, arrow = Arrow(SimpleHead));
        },
        shift = shift,
        scale = scale,
        rotate = rotate
    );
}
dpar rnpar ()
{
    return dpar(
        drawcontour = false,
        drawsubsetcontour = true,
        fill = false,
        fillsubsets = true,
        mode = plain,
        viewdir = (0,0),
        postdrawover = false
    );
}

smooth node (
    string label,
    pair pos = (0,0),
    real size = config.smooth.nodesize
)
{
    frame f;
    path contour = ellipse(f, Label(label));
    real csize = min(xsize(contour), ysize(contour));
    contour = scale(size/csize)*contour;
    return smooth(
        contour = contour,
        label = label,
        labeldir = (0,0),
        labelalign = (0,0),
        shift = pos
    );
}
dpar nodepar ()
{
    return dpar(
        fill = false,
        fillsubsets = false,
        drawcontour = false,
        drawsubsetcontour = false
    );
}

// >operations | Set operations on smooth objects

// >intersections

smooth[] intersection (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
) // Constructs the intersection of two given smooth objects.
{
    path[] contours = intersection(sm1.contour, sm2.contour, round = round, roundcoeff = roundcoeff);
    int initialsize = contours.length;

    if (contours.length == 0)
    {
        write("> ? Smooth objects are not intersecting, so returning an empty array. [ intersection() ]");
        return new smooth[];
    }

    hole[] trueholes = concat(holecopy(sm1.holes), holecopy(sm2.holes));
    path[] holes = holecontours(concat(sm1.holes, sm2.holes));
    bool[] htaken = array(holes.length, false);
    int[] hrefs = sequence(holes.length);

    for (int i = 0; i < holes.length; ++i)
    {
        if (htaken[i]) continue;

        for (int j = 0; j < holes.length; ++j)
        {
            if (i == j) continue;
            if (insidepath(holes[i], holes[j]))
            { htaken[j] = true; }
        }

        for (int j = i+1; j < holes.length; ++j)
        {
            if (meet(holes[i], holes[j]) && !htaken[j])
            {
                path[] holeunion = union(holes[i], holes[j], round = round, roundcoeff = roundcoeff);
                holes[i] = holeunion[0];
                for (int k = 1; k < holeunion.length; ++k)
                { contours.push(holeunion[k]); }
                htaken[j] = true;
                hrefs[i] = -1;
                j = i;
            }
        }
    }

    subset[] subsets1 = addsubsets ? subsetcopy(sm1.subsets) : new subset[] {};
    subset[] subsets2 = addsubsets ? subsetcopy(sm2.subsets) : new subset[] {};
    path[] holecontours1 = holecontours(sm1.holes);
    path[] holecontours2 = holecontours(sm2.holes);

    for (int i = 0; i < subsets1.length; ++i)
    {
        path[] curcontours = intersection(p = subsets1[i].contour, q = sm2.contour, holes = holecontours2, round = round, roundcoeff = roundcoeff);
        if (curcontours.length == 0)
        {
            subsetdelete(subsets1, i, true);
            i -= 1;
            continue;
        }
        if (curcontours.length > 1)
        {
            subsetdelete(subsets1, i, true);
            i -= 1;
            continue;
        }
        subsets1[i].contour = curcontours[0];
        subsets1[i].center = center(curcontours[0]);
        if (meet(subsets1[i].contour, sm2.contour^^holecontours2)) subsets1[i].isonboundary = true;
    }
    for (int i = 0; i < subsets2.length; ++i)
    {
        path[] curcontours = intersection(p = subsets2[i].contour, q = sm1.contour, holes = holecontours1, round = round, roundcoeff = roundcoeff);
        if (curcontours.length == 0)
        {
            subsetdelete(subsets2, i, true);
            i -= 1;
            continue;
        }
        if (curcontours.length > 1)
        {
            subsetdelete(subsets2, i, true);
            i -= 1;
            continue;
        }
        subsets2[i].contour = curcontours[0];
        subsets2[i].center = center(curcontours[0]);
        if (meet(subsets2[i].contour, sm1.contour^^holecontours1)) subsets2[i].isonboundary = true;
    }

    smooth[] res;

    while (contours.length != 0)
    {
        path curcontour = contours.pop();

        smooth cursm = smooth(
            contour = curcontour,
            label = (config.smooth.inferlabels && length(sm1.label) > 0 && length(sm2.label) > 0) ? (sm1.label+" \cap "+sm2.label) : "",
            labeldir = rotate(90)*unit(sm1.center - sm2.center),
            isderivative = true,
            copy = true
        );
    
        for (int j = 0; j < holes.length; ++j)
        {
            if (htaken[j]) continue;
            if (meet(cursm.contour, holes[j]))
            {
                path[] diff = difference(cursm.contour, holes[j], round = round, roundcoeff = roundcoeff);
                cursm.contour = diff.pop();
                contours.append(diff);
                htaken[j] = true;
            }
            else if (insidepath(curcontour, holes[j]))
            {
                cursm.addhole((hrefs[j] == -1 || !keepdata) ? hole(contour = holes[j]) : trueholes[hrefs[j]], unit = false);
            }
        }

        cursm.subsets = subsetcopy(subsets1);
            
        for (int i = 0; i < cursm.subsets.length; ++i)
        {
            if (cursm.subsets[i].layer > 0) break;

            if (!inside(cursm.contour, cursm.subsets[i].center))
            { subsetdelete(cursm.subsets, i, true); }
        }

        bool[] subsetsadded = array(subsets2.length, false);
        bool[] subsets2inside = array(subsets2.length, false);
        void subset2add (int ind, int ind2)
        {
            if (subsetsadded[ind2]) return;

            if (subsets2inside[ind2] || inside(cursm.contour, subsets2[ind2].center))
            {
                cursm.addsubset(subsets2[ind2], ind, unit = false, clip = true, checkintersection = false);
                subsetsadded[ind2] = true;

                for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
                {
                    subsets2inside[subsets2[ind2].subsets[i]] = true;
                    subset2add(cursm.subsets.length-1, subsets2[ind2].subsets[i]);
                }
            }
            else
            {
                subsetsadded[ind2] = true;
                int[] allsubsets = subsetgetall(subsets2, ind2);
                for (int i = 0; i < allsubsets.length; ++i)
                { subsetsadded[allsubsets[i]] = true; }
            }
        }
        for (int i = 0; i < subsets2.length; ++i)
        { subset2add(ind = -1, ind2 = i); }

        cursm.setratios(new real[], true);
        cursm.setratios(new real[], false);

        res.push(cursm);
    }

    return res;
}

smooth[] intersection (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
)
{
    sms = sequence(new smooth (int i){return sms[i];}, sms.length);

    smooth[] getintersection (smooth[] smsp, bool keepdata, bool round, real roundcoeff, bool addsubsets)
    {
        if (smsp.length < 2)
        { return smsp; }
        smooth lastsm = smsp.pop();
        smooth[] preintersection = getintersection(smsp, keepdata, round, roundcoeff, addsubsets);
        
        smooth[] res;
        for (int i = 0; i < preintersection.length; ++i)
        { res.append(intersection(sm1 = preintersection[i], sm2 = lastsm, keepdata, round, roundcoeff, addsubsets)); }
        sms.push(lastsm);

        return res;
    }

    smooth[] res = getintersection(sms, keepdata, round, roundcoeff, addsubsets);
    return res;
}

smooth[] intersection (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
    ... smooth[] sms
) { return intersection(sms, keepdata, round, roundcoeff, addsubsets); }

smooth[] operator ^^ (smooth sm1, smooth sm2)
{ return intersection(sm1, sm2); }

smooth intersect (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
)
{
    smooth[] intersection = intersection(sms, keepdata, round, roundcoeff, addsubsets);
    if (intersection.length == 0)
    { halt("Could not intersect: smooth objects do not intersect. [ intersect() ]"); }
    if (intersection.length > 1)
    { write("> ? Intersection produced more than one object. Returning only the 0-th one. [ intersect() ]"); }
    return intersection[0];
}

smooth intersect (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    bool addsubsets = config.smooth.addsubsets
    ... smooth[] sms
) { return intersect(sms, keepdata, round, roundcoeff, addsubsets); }

smooth operator ^ (smooth sm1, smooth sm2)
{ return intersect(sm1, sm2); }

// >unions

smooth[] union (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // Constructs the union of two given smooth objects.
{
    if (!meet(sm1.contour, sm2.contour) && !insidepath(sm1.contour, sm2.contour) && !insidepath(sm2.contour, sm1.contour))
    { return new smooth[] {sm1, sm2}; }

    path[] union = union(sm1.contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
    path contour; 
    hole[] trueholes = concat(holecopy(sm1.holes), holecopy(sm2.holes));
    path[] holes;
    int[] hrefs;
    bool[] used = array(value = false, sm2.holes.length);
    bool[] diffused = array(value = false, trueholes.length);

    for (int i = 0; i < sm1.holes.length; ++i)
    {
        if (!meet(sm1.holes[i].contour, sm2.contour)) continue;
        path[] diff = difference(sm1.holes[i].contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
        holes.append(diff);
        hrefs.append(array(value = -1, diff.length));
        diffused[i] = true;
    }
    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if (!meet(sm2.holes[i].contour, sm1.contour)) continue;
        path[] diff = difference(sm2.holes[i].contour, sm1.contour, correct = false, round = round, roundcoeff = roundcoeff);
        holes.append(diff);
        hrefs.append(array(value = -1, diff.length));
        diffused[sm1.holes.length + i] = true;
    }

    for (int i = 0; i < sm1.holes.length; ++i)
    {
        bool used1 = false;
        for (int j = 0; j < sm2.holes.length; ++j)
        {
            path[] intersect = intersection(sm1.holes[i].contour, sm2.holes[j].contour, correct = false, round = round, roundcoeff = roundcoeff);

            if (intersect.length > 0 || inside(sm2.holes[j].contour, sm1.holes[i].center))
            {
                used1 = true;
                used[j] = true;
                holes.append(intersect);
                hrefs.append(array(value = -1, intersect.length));
            }
        }

        if (!used1 && !diffused[i])
        {
            if (inside(sm2.contour, sm1.holes[i].center)) continue;
            holes.push(sm1.holes[i].contour);
            hrefs.push(i);            
            for (int j = 0; j < trueholes[i].sections.length; ++j)
            {
                real[] section = trueholes[i].sections[j];
                pair center = trueholes[i].center;
                real dirang = section[0];
                real ang = section[1];
                int num = floor(section[2]);
                real langlim = 1;
                
                if (intersectiontime(sm2.contour, center, dir(dirang)) != -1)
                {
                    trueholes[i].sections.delete(j);
                    j -= 1;
                    continue;
                }

                while (ang > langlim && intersectiontime(sm2.contour, center, dir(dirang+ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang -= ang*.5;
                    num = ceil((real)num*.5);
                }
                while (ang > langlim && intersectiontime(sm2.contour, center, dir(dirang-ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang += ang*.5;
                    num = ceil((real)num*.5);
                }
                trueholes[i].sections[j] = new real[] {dirang, ang, num};
            }
        }
    }

    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if (!used[i] && !diffused[sm1.holes.length + i])
        {
            if (inside(sm1.contour, sm2.holes[i].center)) continue;
            holes.push(sm2.holes[i].contour);
            hrefs.push(i + sm1.holes.length);

            for (int j = 0; j < trueholes[sm1.holes.length + i].sections.length; ++j)
            {
                real[] section = trueholes[sm1.holes.length+i].sections[j];
                pair center = trueholes[sm1.holes.length+i].center;
                real dirang = section[0];
                real ang = section[1];
                int num = floor(section[2]);
                real langlim = 1;
                
                if (intersectiontime(sm1.contour, center, dir(dirang)) != -1)
                {
                    trueholes[sm1.holes.length + i].sections.delete(j);
                    j -= 1;
                    continue;
                }

                while (ang > langlim && intersectiontime(sm1.contour, center, dir(dirang+ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang -= ang*.5;
                    num = ceil((real)num*.5);
                }
                while (ang > langlim && intersectiontime(sm1.contour, center, dir(dirang-ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang += ang*.5;
                    num = ceil((real)num*.5);
                }
                
                trueholes[sm1.holes.length+i].sections[j] = new real[] {dirang, ang, num};
            }
        }
    }

    contour = pop(union);
    holes.append(union);
    hrefs.append(array(union.length, -1));

    smooth res = smooth(
        contour = contour,
        label = (config.smooth.inferlabels && length(sm1.label) > 0 && length(sm2.label) > 0) ? (sm1.label+" \cup "+sm2.label) : "",
        labeldir = unit(sm1.center - sm2.center),
        isderivative = true
    );

    pair cursize = max(res.contour)-min(res.contour);
    real rsize = min(cursize.x, cursize.y);
    pair size1 = max(sm1.contour)-min(sm1.contour);
    real rsize1 = min(size1.x, size1.y);
    pair size2 = max(sm2.contour)-min(sm2.contour);
    real rsize2 = min(size2.x, size2.y);

    for (int i = 0; i < holes.length; ++i)
    {
        res.addhole((hrefs[i] == -1) ? hole(holes[i], copy = true) : trueholes[hrefs[i]], unit = false);
    }

    res.subsets = subsetcopy(sm1.subsets);
    subset[] subsets2 = subsetcopy(sm2.subsets);
    bool[] subsetsadded = array(subsets2.length, false);
    void subset2add (int ind, int ind2)
    {
        if (subsetsadded[ind2]) return;
        res.addsubset(subsets2[ind2], ind, unit = false);
        subsetsadded[ind2] = true;
        for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
        { subset2add(res.subsets.length-1, subsets2[ind2].subsets[i]); }
    }
    for (int i = 0; i < subsets2.length; ++i)
    { subset2add(ind = -1, ind2 = i); }

    return new smooth[] {res};
}

smooth[] union (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
)
{
    sms = sequence(new smooth (int i){return sms[i];}, sms.length);

    smooth[] getunion (smooth[] smsp, bool keepdata, bool round, real roundcoeff)
    {
        if (smsp.length < 2) return smsp;
        smooth lastsm = smsp.pop();
        smooth[] res = getunion(smsp, keepdata, round, roundcoeff);

        for (int i = 0; i < res.length; ++i)
        {
            smooth[] curunion = union(sm1 = res[i], sm2 = lastsm, keepdata, round, roundcoeff);

            if (curunion.length == 1)
            {
                res[i] = curunion[0];
                return getunion(res, keepdata, round, roundcoeff);
            }
        }
        
        res.push(lastsm);
        return res;
    }

    smooth[] res = getunion(sms, keepdata, round, roundcoeff);
    return res;
}

smooth[] union (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... smooth[] sms
) { return union(sms, keepdata, round, roundcoeff); }

smooth[] operator ++ (smooth sm1, smooth sm2)
{ return union(sm1, sm2); }

smooth unite (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
) // An alternative to `union` that only returns one smooth object, if there is only one.
{
    smooth[] union = union(sms, keepdata, round, roundcoeff);
    if (union.length > 1) 
    { write("> ? Union produced more than one object. Returning only the 0-th one. [ intersect() ]"); }
    return union[0];
}

smooth unite (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff
    ... smooth[] sms
) { return union(sms, keepdata, round, roundcoeff)[0]; }

smooth operator + (smooth sm1, smooth sm2)
{ return unite(sm1, sm2); }

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
) // Returns a tangent space to `sm` at point determined by `hlindex`, `dir` and `ratio` //
{
    if (!inside(-1, sm.holes.length-1, hlindex))
    { halt("Could not build tangent space: index out of bounds. [ tangentspace() ]"); }
    if (dummy(center)) center = (hlindex == -1) ? sm.center : sm.holes[hlindex].center;
    if (!sm.inside(center))
    { halt("Could not build tangent space: center out of bouds [ tangentspace() ]"); }
    if (!inside(0, 1, ratio))
    { halt("Could not build tangent space: ratio out of bounds. [ tangentspace() ]"); }

    pair dir = dir(angle);
    path dirpath = center -- (center + (sm.xsize()+sm.ysize()) * dir);
    pair start;
    pair finish;
    pair[] ipoints;

    if (hlindex > -1)
    {
        path[] fullcontour = sm.contour ^^ holecontours(sm.holes);
        ipoints = sort(concat(sequence(new pair[](int i){return intersectionpoints(dirpath, fullcontour[i]);}, fullcontour.length)), new bool (pair i, pair j){return length(i - center) <= length(j - center);});
        start = comb(ipoints[0], ipoints[1], .5);
        finish = (ratio > 0) ? ipoints[1] : ipoints[0];
    }
    else
    {
        ipoints = sort(intersectionpoints(dirpath, sm.contour), new bool (pair i, pair j){return length(i - center) <= length(j - center);});
        start = center;
        finish = ipoints[0];
    }
    pair x = comb(start, finish, abs(ratio));

    real incline = sqrt(1 - ratio * ratio);
    smooth res = smooth(
        contour = shift(x) * dscale(scale = incline, dir = sgn(ratio) * dir) * scale(size) * rotate(rotate) * usquare,
        label = "T_{"+eltlabel+"}" + sm.label,
        labeldir = dscale(scale = incline, dir = sgn(ratio) * dir) * rotate(rotate) * N
    );
    sm.attach(res);
    sm.addelement(element(x, eltlabel, eltlabelalign));

    return res;
}

// >drawing | Generic drawing functionality

private void fitpath (
    picture pic,
    bool overlap,
    int covermode,
    bool drawnow,
    path gs,
    Label L,
    pen p,
    tarrow arrow,
    tbar bar
)
/*
Fit the path on the picture without actually drawing it (unless specified otherwise). The path may then be changed "after it was drawn", and it will finally be rendered to the picture at shipout time.
The `covermode` parameter needs additional explanation. It determines what happens to the paths that find themselves going 'under' the path `gs`. The possible values are:
    -1: The path going under is 'promoted' back to the surface (used by holes in smooth objects)
    0: The path going under is left as it is (used with non-cyclical `gs`, serves as a neutral mode)
    1: The path going under is 'demoted' to the background and either removed or drawn with a dashed line (used by smooth and subset contours)
    2: The path going under is erased.
*/
{
    if (config.system.insertdollars && length(L.s) > 0) L.s = "$"+L.s+"$";
    if (config.drawing.labels && length(L.s) > 0)
    { label(pic = pic, gs, L = L, p = p); }

    deferredPath[] curdp = extractdeferredpaths(pic, true);

    if (!overlap)
    {
        bool gscyclic = cyclic(gs);

        int under (bool inside, int curunder)
        {
            int res = curunder;
            if (inside)
            {
                if (covermode == 1) { res += 1; }
                else if (covermode == -1) { res = max(0,res-1); }
            }
            return res;
        }

        for (int i = 0; i < curdp.length; ++i)
        {
            path[] g = curdp[i].g;
            path[] newg;
            int[] newunder;
            if (!gscyclic) covermode = 0;
            bool gjcyclic = (g.length == 1);

            for (int j = 0; j < g.length; ++j)
            {
                real[] aligntest = intersect(g[j], gs);
                if (aligntest.length == 0)
                {
                    bool inside;
                    if (!gscyclic || !(inside = inside(gs, beginpoint(g[j]))) || covermode < 3)
                    {
                        newg.push(g[j]);
                        newunder.push(under(inside, curdp[i].under[j]));
                    }
                    continue;
                }

                real[][] times = intersections(g[j], gs);

                real[] cuttimes = new real[] {0};
                bool[] skipped = array(2*(times.length+1), value = false);
                real t1;
                real t2;
                real t3 = -1;

                gjcyclic = gjcyclic && cyclic(g[j]);

                for (int k = 0; k < times.length; ++k)
                {
                    pair gjdi = (times[k][0] == floor(times[k][0])) ? dir(g[j], floor(times[k][0]), sign = -1) : dir(g[j], times[k][0]);
                    pair gjdo = (times[k][0] == floor(times[k][0])) ? dir(g[j], floor(times[k][0]), sign = 1) : dir(g[j], times[k][0]);
                    pair gsdi = (times[k][1] == floor(times[k][1])) ? dir(gs, floor(times[k][1]), sign = -1) : dir(gs, times[k][1]);
                    pair gsdo = (times[k][1] == floor(times[k][1])) ? dir(gs, floor(times[k][1]), sign = 1) : dir(gs, times[k][1]);
                    if (sgn(cross(gjdi, gsdi))*sgn(cross(gjdo, gsdo)) < 0) { continue; }

                    pair gjd = unit(gjdi+gjdo);
                    pair gsd = unit(gsdi+gsdo);
                    
                    real cross = cross(gjd, gsd);
                    real sang = max(abs(cross), .3);
                    t1 = relarctime(g[j], times[k][0], -config.drawing.gaplength/sang*.5);
                    t2 = relarctime(g[j], times[k][0], config.drawing.gaplength/sang*.5);
                    if (t1 < cuttimes[cuttimes.length-1])
                    {
                        cuttimes[cuttimes.length-1] = t2;
                        if (cuttimes.length > 2) skipped[cuttimes.length-3] = true;
                        if (gjcyclic && t1 < 0 && t3 < 0) t3 = abs(t1);
                        continue;
                    }
                    cuttimes.push(t1);
                    cuttimes.push(t2);
                }

                if (t2 < 0)
                {
                    if (gjcyclic) cuttimes[0] = abs(t2);
                    cuttimes.pop();
                }
                else if (t3 >= 0)
                {
                    if (t3 <= t2) cuttimes.pop();
                    // else cuttimes.insert(cuttimes.length-1, t3);
                    else cuttimes.push(t3);
                }
                else if (cuttimes.length % 2 == 1)
                {
                    if (gjcyclic)
                    { cuttimes[0] = cuttimes.pop(); }
                    else cuttimes.push(length(g[j]));
                }

                bool inside = gscyclic ? inside(gs, point(g[j], cuttimes[0])) : false;
                for (int k = 0; k < cuttimes.length-1; k += 2)
                {
                    if (!inside || covermode < 2)
                    {
                        newg.push(gjcyclic ? subcyclic(g[j], (cuttimes[k], cuttimes[k+1])) : subpath(g[j], cuttimes[k], cuttimes[k+1]));
                        newunder.push(under(inside, curdp[i].under[j]));
                    }
                    if (!skipped[k]) inside = !inside;
                }
            }

            if (newg.length > 0 || newunder.length > 0)
            {
                if (newg.length > 0 && abs(beginpoint(newg[0]) - beginpoint(g[0])) > config.drawing.gaplength)
                {
                    if (curdp[i].arrow != null) curdp[i].arrow.begin = false;
                    if (curdp[i].bar != null) curdp[i].bar.begin = false;
                }
                if (newg.length > 0 && abs(endpoint(newg[newg.length-1]) - endpoint(g[g.length-1])) > config.drawing.gaplength)
                {
                    if (curdp[i].arrow != null) curdp[i].arrow.end = false;
                    if (curdp[i].bar != null) curdp[i].bar.end = false;
                }
                curdp[i].g = newg;
                curdp[i].under = newunder;
            }
            else
            {
                curdp.delete(i);
                i -= 1;
            }
        }
    }
    if (!drawnow)
    {
        deferredPath newdp;
        newdp.g = new path[] {gs};
        newdp.p = p;
        newdp.under = new int[] {0};
        newdp.arrow = arrow;
        newdp.bar = bar;
        curdp.push(newdp);
    }
    else { draw(pic = pic, gs, p = p, arrow = convertarrow(arrow), bar = convertbar(bar)); }
}

void fitpath (
    picture pic = currentpicture,
    path g,
    bool overlap = false,
    int covermode = 0,
    Label L = "",
    pen p = currentpen,
    bool drawnow = false,
    tarrow arrow = null,
    tbar bar = config.arrow.currentbar
) { fitpath(pic, overlap, covermode, drawnow, g, L, p, arrow, bar); }

void fitpath (
    picture pic = currentpicture,
    guide g,
    bool overlap = false,
    int covermode = 0,
    Label L = "",
    pen p = currentpen,
    bool drawnow = false,
    tarrow arrow = null,
    tbar bar = config.arrow.currentbar
) { fitpath(pic, overlap, covermode, drawnow, (path)g, L, p, arrow, bar); }

void fitpath (
    picture pic = currentpicture,
    path[] g,
    bool overlap = false,
    int covermode = 0,
    Label L = "",
    pen p = currentpen,
    bool drawnow = false
)
{
    for (int i = 0; i < g.length; ++i)
    { fitpath(pic, overlap, covermode, drawnow, g[i], L, p, null, null); }
}

void fillfitpath (
    picture pic = currentpicture,
    path g,
    bool overlap = false,
    int covermode = 1,
    Label L = "",
    pen drawpen = currentpen,
    pen fillpen = currentpen,
    bool drawnow = false
)
{
    fill(pic, g, fillpen);
    fitpath(pic, overlap, covermode, drawnow, g, L, drawpen, null, null);
}

void fillfitpath (
    picture pic = currentpicture,
    path[] g,
    bool overlap = false,
    int covermode = 1,
    Label L = "",
    pen drawpen = currentpen,
    pen fillpen = currentpen,
    bool drawnow = false
)
{
    fill(pic, g, fillpen);
    for (int i = 0; i < g.length; ++i)
    { fitpath(pic, overlap, covermode, drawnow, g[i], L, drawpen, null, null); }
}

void shaderegion (
    picture pic = currentpicture,
    path g,
    real angle = config.drawing.lineshadeangle,
    real density = config.drawing.lineshadedensity,
    real mar = config.drawing.lineshademargin,
    pen p = config.drawing.lineshadepen
) // Draws shade lines inside a cyclic path.
{
    if (!cyclic(g))
    { halt("Could not shade region: path is non-cyclic [ shaderegion() ]"); }
    real vsep = density / Cos(angle);
    pair min = min(g), max = max(g);
    pair diag = max - min;
    g = srap(max((length(diag)-mar)/length(diag), 0.5), 0, center(g)) * g;
    min -= 0.1*diag;
    max += 0.1*diag;
    diag = max - min;
    real h = xpart(diag) * Tan(angle);
    for (real y = ypart(min) - h; y <= ypart(max); y += vsep) {
        real[][] sects = intersections(g, (xpart(min), y) -- (xpart(max), y+h));
        if (sects.length % 2 == 1) continue;
        for (int i = 0; i < sects.length; i += 2) {
            draw(
                pic,
                point(g, sects[i][0]) -- point(g, sects[i+1][0]),
                p = p
            );
        }
    }
}

// >drawing | Drawing high-level structures

private void drawsections (picture pic, pair[][] sections, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
// Renders the circular sections, given an array of control points.
{
    for (int k = 0; k < sections.length; ++k)
    {
        path[] section = sectionellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir);
        if (shade && config.drawing.fill && section.length > 1) { fill(pic = pic, section[0]--section[1]--cycle, shadepen); }
        if (section.length > 1 && dash) { draw(pic, section[1], dashpen); }
        draw(pic, section[0], sectionpen);
        if (help)
        {
            dot(pic, point(section[0], arctime(section[0], arclength(section[0])*.5)), red+1);
            dot(pic, sections[k][0], blue+1.5);
            dot(pic, sections[k][1], blue+1);
            draw(pic, sections[k][0] -- sections[k][1], deepgreen + config.help.linewidth);
            draw(pic, sections[k][0]-.5*config.help.arrowlength*scale*sections[k][2] -- sections[k][0]+.5*config.help.arrowlength*scale*sections[k][2], deepgreen+config.help.linewidth, arrow = Arrow(SimpleHead));
            draw(pic, sections[k][1]-.5*config.help.arrowlength*scale*sections[k][3] -- sections[k][1]+.5*config.help.arrowlength*scale*sections[k][3], deepgreen+config.help.linewidth, arrow = Arrow(SimpleHead));
        }
    }
}

private void drawcartsections (picture pic, path[] g, path[] avoid, real y, bool horiz, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
// Draw vertical and horizontal cross sections.
{
    drawsections(pic, cartsections(g, avoid, y, horiz), viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);
}

void draw (
    picture pic = currentpicture,
    smooth sm,
    dpar dspec = null
) // The main drawing function of the module. It renders a given smooth object with substantial customization: all drawing pens can be altered, there are three section-drawing modes available: `free`, `cartesian` and `plain`. 
{
    // Configuring variables

    if (dspec == null) dspec = dpar();

    pair viewdir = config.drawing.viewscale*dspec.viewdir;
    if (config.smooth.maxsectionlength > 0) config.smooth.maxlength = config.smooth.maxsectionlength*min(xsize(sm.contour), ysize(sm.contour));

    path[] holes = holecontours(sm.holes);
    path[] contour = reverse(sm.contour) ^^ holes;
    real scale = radius(sm.contour);

    // Applying the postdraw function if specified

    if (!dspec.postdrawover) sm.postdraw(dspec, sm);

    // Filling and drawing main contour

    if (dspec.fill) fill(pic = pic, contour, p = dspec.smoothfill);
    if (dspec.drawcontour)
    {
        for (int i = 0; i < contour.length; ++i)
        {
            if (dspec.help && (i == 0 ? clockwise(contour[i]) : !clockwise(contour[i])))
            {
                debugpaths.push(contour[i]);
            }
            fitpath(pic = pic, dspec.overlap = dspec.overlap || sm.isderivative, covermode = 1-2*sgn(i), dspec.drawnow = dspec.drawnow, gs = contour[i], L = "", p = dspec.contourpen, arrow = null, bar = null);
        }
    }

    // Drawing cross sections

    if (dspec.mode % 2 == 1)
    {
        bool[][] holeconnected = new bool[sm.holes.length][sm.holes.length];

        for (int i = 0; i < sm.holes.length; ++i)
        {
            for (int j = 0; j < sm.holes.length; ++j)
            { holeconnected[i][j] = false; }
            holeconnected[i][i] = true;
        }
        for (int i = 0; i < sm.holes.length; ++i)
        {
            hole hl = sm.holes[i];
            for (int j = 0; j < hl.sections.length; ++j)
            {
                pair smrange = range(sm.contour, hl.center, dir(hl.sections[j][0]), hl.sections[j][1]);
                pair hlrange = range(hl.contour, hl.center, dir(hl.sections[j][0]), hl.sections[j][1]);
                path cursmcontour = subcyclic(sm.contour, smrange);
                path curhlcontour = subcyclic(hl.contour, hlrange);

                if (dspec.help)
                {
                    pair hlstart = point(curhlcontour, 0);
                    pair hlfinish = point(curhlcontour, length(curhlcontour));
                    pair hlvec = config.help.arcratio * radius(hl.contour) * unit(hlstart - hl.center);
                    draw(pic = pic, (hl.center + hlvec) -- hlstart, yellow + config.help.linewidth);
                    draw(pic = pic, (hl.center + rotate(-hl.sections[j][1])*hlvec) -- hlfinish, yellow + config.help.linewidth);
                    draw(pic = pic, arc(hl.center, hl.center + hlvec, hlfinish, direction = CW), blue+config.help.linewidth);
                }

                drawsections(pic, sectionparams(curhlcontour, cursmcontour, ceil(hl.sections[j][2]), config.section.freedom, config.section.precision), viewdir, dspec.dash, dspec.help, dspec.shade, scale, dspec.sectionpen, dspec.dashpen, dspec.shadepen);
            }

            // Drawing sections between holes
            if (config.smooth.interholenumber > 0)
            {   
                for (int j = 0; j < sm.holes.length; ++j)
                {
                    if (holeconnected[i][j] || holeconnected[j][i]) continue;                    

                    if (meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = config.smooth.rejectcurve)) || meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = -config.smooth.rejectcurve))) continue;
                    
                    bool near = true;
                    for (int k = 0; k < sm.holes.length; ++k)
                    {
                        if (k == i || k == j) continue;

                        if (intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = config.smooth.rejectcurve)).length > 0 || intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = -config.smooth.rejectcurve)).length > 0)
                        {
                            near = false;
                            break;
                        }
                    }

                    if (!near) continue;

                    hole hl1 = hl;
                    hole hl2 = sm.holes[j];

                    pair hl1times = range(hl1.contour, hl1.center, hl2.center-hl1.center, config.smooth.interholeangle);
                    pair hl2times = range(reverse(hl2.contour), hl2.center, hl1.center-hl2.center, config.smooth.interholeangle, -1);
                    path curhl1contour = subcyclic(hl1.contour, hl1times);
                    path curhl2contour = subcyclic(reverse(hl2.contour), hl2times);

                    if (dspec.help)
                    {
                        pair hl1start = point(curhl1contour, 0);
                        pair hl1finish = point(curhl1contour, length(curhl1contour));
                        pair hl2start = point(curhl2contour, 0);
                        pair hl2finish = point(curhl2contour, length(curhl2contour));
                        pair hl1vec = config.help.arcratio * radius(hl1.contour) * unit(hl1start - hl1.center);
                        pair hl2vec = config.help.arcratio * radius(hl2.contour) * unit(hl2start - hl2.center);
                        draw(pic, (hl1.center + hl1vec)--hl1start, yellow+config.help.linewidth);
                        draw(pic, (hl1.center + rotate(-config.smooth.interholeangle)*hl1vec)--hl1finish, yellow+config.help.linewidth);
                        draw(pic, (hl2.center + hl2vec)--hl2start, yellow+config.help.linewidth);
                        draw(pic, (hl2.center + rotate(config.smooth.interholeangle)*hl2vec)--hl2finish, yellow+config.help.linewidth);
                        draw(pic = pic, arc(hl1.center, hl1.center + hl1vec, hl1finish, direction = CW), blue+config.help.linewidth);
                        draw(pic = pic, arc(hl2.center, hl2.center + hl2vec, hl2finish, direction = CCW), blue+config.help.linewidth);
                    }

                    drawsections(pic, sectionparams(curhl1contour, curhl2contour, abs(min(hl1.scnumber, hl2.scnumber)), config.section.freedom, config.section.precision), viewdir, dspec.dash, dspec.help, dspec.shade, scale, dspec.sectionpen, dspec.dashpen, dspec.shadepen);

                    holeconnected[i][j] = true;
                    holeconnected[j][i] = true;
                }
            }
        }
    }
    if (dspec.mode # 2 == 1)
    {
        for (int i = 0; i < sm.hratios.length; ++i)
        {
            drawcartsections(pic, contour, (dspec.avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[] {}), sm.hratios[i], true, viewdir, dspec.dash, dspec.help, dspec.shade, scale, dspec.sectionpen, dspec.dashpen, dspec.shadepen);
        }
        for (int i = 0; i < sm.vratios.length; ++i)
        {
            drawcartsections(pic, contour, (dspec.avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[] {}), sm.vratios[i], false, viewdir, dspec.dash, dspec.help, dspec.shade, scale, dspec.sectionpen, dspec.dashpen, dspec.shadepen);
        }
    }

    // Filling and drawing subsets

    if (dspec.fillsubsets && (dspec.subsetfill.length > 0 || dspec.subsetcontourpens.length > 0))
    {
        int maxlayer = subsetmaxlayer(sm.subsets, sequence(sm.subsets.length));
        pen[] subsetpens =
            (dspec.subsetfill.length > 0) ?
            copy(dspec.subsetfill) : (
                (dspec.subsetcontourpens.length > 0) ?
                map(new pen (pen p) { return brighten(p, config.drawing.subpenbrighten); }, dspec.subsetcontourpens) :
                new pen[]{}
            );
        real penscale = (maxlayer - subsetpens.length >= 0) ? config.drawing.subpenfactor^(1/(maxlayer - subsetpens.length + 1)) : 1;
        for (int i = subsetpens.length; i <= maxlayer; ++i)
        { subsetpens[i] = nextsubsetpen(subsetpens[i-1], penscale); }
        int[] orderindices = sort(sequence(sm.subsets.length), new bool (int i, int j){return sm.subsets[i].layer < sm.subsets[j].layer;});
        for (int i = 0; i < orderindices.length; ++i)
        {
            subset sb = sm.subsets[orderindices[i]];
            fill(pic = pic, sb.contour, subsetpens[sb.layer]);
        }
    }
    if (dspec.drawsubsetcontour)
    {
        for (int i = 0; i < sm.subsets.length; ++i)
        {
            if (!sm.subsets[i].isderivative)
            {
                if (dspec.help && !clockwise(sm.subsets[i].contour))
                {
                    debugpaths.push(sm.subsets[i].contour);
                }
                fitpath(pic = pic, dspec.overlap = dspec.overlap || config.drawing.subsetoverlap || sm.subsets[i].isonboundary, covermode = 0, dspec.drawnow = dspec.drawnow, gs = sm.subsets[i].contour, L = "", p = dspec.subsetcontourpens[min(sm.subsets[i].layer, dspec.subsetcontourpens.length-1)], arrow = null, bar = null);
            }
        }
    }
    
    // Drawing the attached smooth objects

    for (int i = 0; i < sm.attached.length; ++i)
    { draw(pic = pic, sm = sm.attached[i], dspec = dspec.subs(smoothfill = dspec.smoothfill+opacity(config.drawing.attachedopacity))); }

    // Labels and help drawings

    for (int i = 0; i < sm.elements.length; ++i)
    {
        element elt = sm.elements[i];
        if (dspec.drawlabels && elt.label != "")
        {
            label(pic = pic, position = elt.pos, L = Label((config.system.insertdollars ? ("$"+elt.label+"$") : elt.label), align = elt.labelalign));
        }
        dot(pic = pic, elt.pos, dspec.elementpen);
    }
    if (dspec.drawlabels && sm.label != "") 
    {
        pair pos = (abs(sm.labeldir) == 0) ? sm.center : intersection(sm.contour, sm.center, sm.labeldir);
        pair align = sm.labelalign;
        if (dummy(sm.labelalign))
        {
            if (abs(sm.labeldir) == 0) align = (0,0);
            else align = rotate(90)*dir(sm.contour, intersectiontime(sm.contour, sm.center, sm.labeldir));
        }
        label(pic = pic, position = pos, L = Label((config.system.insertdollars ? ("$"+sm.label+"$") : sm.label), align = align));
        if (dspec.help && abs(sm.labeldir) > 0)
        {
            draw(pic = pic, sm.center -- pos, purple+config.help.linewidth);
            draw(pic = pic, pos -- pos+scale*config.help.arrowlength*align, purple+config.help.linewidth, arrow = Arrow(SimpleHead));
        }
    }

    for (int i = 0; i < sm.subsets.length; ++i)
    {
        subset sb = sm.subsets[i];
        if (dspec.drawlabels && sb.label != "")
        {
            pair pos = (abs(sb.labeldir) == 0) ? sb.center : intersection(sb.contour, sb.center, sb.labeldir);
            pair align = sb.labelalign;
            if (dummy(sb.labelalign))
            {
                if (abs(sb.labeldir) == 0) align = (0,0);
                else align = rotate(90)*dir(sb.contour, intersectiontime(sb.contour, sb.center, sb.labeldir));
            }
            label(pic = pic, position = pos, L = Label((config.system.insertdollars ? ("$"+sb.label+"$") : sb.label), align = align, p = dspec.subsetcontourpens[min(sb.layer, dspec.subsetcontourpens.length-1)]));
            if (dspec.help && abs(sb.labeldir) > 0)
            {
                draw(pic = pic, sb.center -- pos, purple+config.help.linewidth);
                draw(pic = pic, pos -- pos+scale*config.help.arrowlength*align, purple+config.help.linewidth, arrow = Arrow(SimpleHead));
            }
        }

        if (dspec.help && dspec.drawlabels) label(pic = pic, L = Label((string)i, position = sb.center, p = blue));
    }
    if (dspec.help)
    {
        draw(pic = pic, sm.center -- sm.center+unit(viewdir)*config.help.arrowlength, purple+config.help.linewidth, arrow = Arrow(SimpleHead));
        dot(pic = pic, sm.center, red+1);
        if (dspec.drawlabels) for (int i = 0; i < sm.holes.length; ++i)
        { label(pic = pic, L = Label((string)i, position = sm.holes[i].center, p = red, filltype = NoFill)); }
        draw(sm.adjust(-1)*unitcircle, blue+config.help.linewidth);
    }

    // Applying the postdraw function if specified

    if (dspec.postdrawover) sm.postdraw(dspec, sm);
}

void draw (
    picture pic = currentpicture,
    smooth[] sms,
    dpar dspec = null
)
{
    for (int i = 0; i < sms.length; ++i)
    { draw(pic = pic, sm = sms[i], dspec = dspec); }
}

void draw (
    picture pic = currentpicture,
    dpar dspec = null
    ... smooth[] sms
)
{ draw(pic, sms, dspec); }

void phantom (
    picture pic = currentpicture,
    smooth sm
)
{
    dot(pic, max(sm.contour), invisible);
    dot(pic, min(sm.contour), invisible);
}

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
) // Draws the intersection of two smooth objects, as well as their dim contours for comparison
{
    smooth smp1 = sm1.copy().move(shift = shift, drag = false);
    smooth smp2 = sm2.copy().move(shift = shift, drag = false);
    
    smooth[] res = intersection(smp1, smp2, keepdata, round, roundcoeff);

    smp1.subsets.delete();
    smp2.subsets.delete();
    smp1.label = "";
    smp2.label = "";

    draw(pic, ghostpar(), smp1, smp2);

    if (res.length == 1)
    { res[0].setlabel(label, labeldir, labelalign); }

    for (int i = 0; i < res.length; ++i)
    { draw(pic, res[i], dspec); }

    return res;
}

smooth[] drawintersect (
    picture pic = currentpicture,
    smooth[] sms,
    string label = config.system.dummystring,
    pair dir = config.system.dummypair,
    pair align = config.system.dummypair,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    pair shift = (0,0),
    dpar dspec = null
)
{
    smooth[] smsp = sequence(new smooth (int i){return sms[i].copy().move(shift = shift);}, sms.length);
    smooth[] res = intersection(smsp, keepdata, round, roundcoeff);

    for (int i = 0; i < smsp.length; ++i)
    {
        smsp[i].subsets.delete();
        smsp[i].label = "";
        draw(pic, smsp[i], dpar(contourpen = dashpen(dspec.contourpen), smoothfill = invisible, mode = plain));
    }

    if (res.length == 1)
    { res[0].setlabel(label, dir, align); }

    for (int i = 0; i < res.length; ++i)
    { draw(pic, res[i], dspec); }

    return res;
}

smooth[] drawintersect (
    picture pic = currentpicture,
    string label = config.system.dummystring,
    pair dir = config.system.dummypair,
    pair align = config.system.dummypair,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = config.paths.roundcoeff,
    pair shift = (0,0),
    dpar dspec = null
    ... smooth[] sms
)
{ return drawintersect(pic, sms, label, dir, align, keepdata, round, roundcoeff, shift, dspec); }

void drawcommuting (
    picture pic = currentpicture,
    smooth[] sms,
    real size = config.smooth.nodesize*.5,
    pen p = currentpen,
    bool direction = CW
)
{
    if (sms.length < 3)
    { halt("Could not draw commutative diagram symbol: too few objects in diagram"); }

    pair center = (1/sms.length)*sum(sequence(new pair (int i){ return sms[i].center; }, sms.length));
    real angd2 = 40;
    if (direction == CCW) angd2 - angd2;
    real deg = degrees(sms[0].center - center);
    pair vec1 = size*dir(deg - angd2);
    pair vec2 = dir(deg + angd2);

    draw(pic, arc(center, center+vec1, center+vec2, direction), p = p, arrow = ArcArrow(SimpleHead));
}

void drawcommuting (
    picture pic = currentpicture,
    real size = config.smooth.nodesize*.5,
    pen p = currentpen,
    bool direction = CW
    ... smooth[] sms
) { drawcommuting(pic, sms, size, p, direction); }

// >drawing | Arrows and paths

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
) // Draws an arrow between two given smooth objects, or their subsets.
{
    bool onself = false;
    bool hasenclosure1 = false;
    path g1;
    bool hasenclosure2 = false;
    path g2;

    if (endmargin == config.system.dummynumber)
    {
        endmargin = beginmargin;
    }
    
    if (start == config.system.dummypair)
    {
        if (sm1 == null)
        {
            halt("Please provide either `sm1` or a starting point for the arrow. [ drawarrow() ]");
        }

        if (index1 == config.system.dummynumber) index1 = -1;
        if (index1 > -1)
        {
            if (elements)
            {
                sm1.checkelementindex(index1, "drawarrow");
                hasenclosure1 = false;
                start = sm1.elements[index1].pos;
            }
            else
            {
                sm1.checksubsetindex(index1, "drawarrow");
                hasenclosure1 = true;
                subset sb1 = sm1.subsets[index1];
                g1 = sb1.contour;
                start = sb1.center;
            }
        }
        else
        {
            hasenclosure1 = true;
            g1 = sm1.contour;
            start = sm1.center;
        }
    }

    if (finish == config.system.dummypair)
    {
        if (sm2 == null)
        {
            halt("Please provide either `sm2` or a finishing point for the arrow. [ drawarrow() ]");
        }

        // hasenclosure2 = true;
        if (index2 == config.system.dummynumber)
        {
            if (sm1 == sm2) index2 = index1;
            else index2 = -1;
        }

        onself = sm2 == sm1 && index1 == index2;

        if (!onself)
        {
            if (index2 > -1)
            {
                if (elements)
                {
                    sm2.checkelementindex(index2, "drawarrow");
                    hasenclosure2 = false;
                    finish = sm2.elements[index2].pos;
                }
                else
                {
                    sm2.checksubsetindex(index2, "drawarrow");
                    hasenclosure2 = true;
                    subset sb2 = sm2.subsets[index2];
                    g2 = sb2.contour;
                    finish = sb2.center;
                }
            }
            else
            {
                hasenclosure2 = true;
                g2 = sm2.contour;
                finish = sm2.center;
            }
        }
        else
        {
            finish = start;
            hasenclosure2 = hasenclosure1;
        }
    }

    path g;

    if (points.length > 0)
    { g = connect(concat(new pair[] {start}, points, new pair[] {finish})); }
    else if (onself)
    {
        if (dummy(radius)) radius = radius(sm1.contour);
        g = cyclepath(start, angle, radius);
    }
    else
    { g = curvedpath(start, finish, curve = curve); }
    if (reverse) g = reverse(g);

    real[][] intersection1;
    if (hasenclosure1) intersection1 = intersections(g, g1);
    real[][] intersection2;
    if (hasenclosure2) intersection2 = onself ? intersection1 : intersections(g, g2);

    real length = arclength(g);
    if (!config.arrow.absmargins)
    {
        beginmargin *= length;    
        endmargin *= length;    
    }
    real time1;
    real time2; 

    if (intersection1.length > 0)
    { time1 = arctime(g, arclength(g, 0, intersection1[0][0])+beginmargin); }
    else { time1 = arctime(g, beginmargin); }

    if (intersection2.length > (onself ? 1 : 0))
    { time2 = arctime(g, arclength(g, 0, intersection2[intersection2.length-1][0])-endmargin); }
    else { time2 = arctime(g, (length-endmargin)); }

    path gs = subpath(g, time1, time2);

    if (help)
    {
        for (int i = 0; i < points.length; ++i)
        { dot(pic, points[i], elementpen(red)); }
        dot(start, elementpen(blue));
        dot(finish, elementpen(blue));
    }

    fitpath(pic, overlap = overlap, covermode = 0, drawnow = drawnow, gs = gs, L = L, p = p, arrow = arrow, bar = bar);
}

void drawarrow (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
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
{
    if (endmargin == config.system.dummynumber)
    {
        endmargin = beginmargin;
    }

    smooth sm1 = null, sm2 = null;
    int index1 = config.system.dummynumber, index2 = config.system.dummynumber;
    pair start = config.system.dummypair, finish = config.system.dummypair;

    int[] indices1 = findbylabel(destlabel1);
    sm1 = smooth.cache[indices1[0]];
    if (indices1[1] == 0) index1 = indices1[2];
    else if (indices1[1] == 1)
    { start = sm1.elements[indices1[2]].pos; }

    if (destlabel2 == destlabel1)
    {
        sm2 = sm1;
        index2 = index1;
        finish = start;
    }
    else
    {
        int[] indices2 = findbylabel(destlabel2);
        sm2 = smooth.cache[indices2[0]];
        if (indices2[1] == 0) index2 = indices2[2];
        else if (indices2[1] == 1)
        { finish = sm2.elements[indices2[2]].pos; }
    }

    drawarrow(pic, sm1, index1, start, sm2, index2, finish, curve, angle, radius, points, L, p, arrow, bar, help, overlap, drawnow, beginmargin, endmargin);
}

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
) // Draw a surface path on a smooth object
{
    bool onself = sm2 == sm1 && index1 == index2;

    path gs;

    if (help)
    {
        for (int i = 0; i < points.length; ++i)
        { dot(pic, points[i], elementpen(red)); }
    }
    if (points.length < 2 && onself)
    {
        element elt = sm1.elements[index1];

        if (dummy(angle))
        { angle = degrees(-elt.labelalign, warn = false); }
        if (dummy(radius))
        { radius = .05*radius(sm1.contour); }

        pair dir1 = randomdir(dir(angle-range), range);
        pair dir2 = -randomdir(dir(angle+range), range);
        
        gs =
        elt.pos{dir1} ..
        (elt.pos+2*radius*(1+.1*unitrand())*dir(angle)) .. 
        {dir2}elt.pos;
    }
    else
    {
        pair center1 = sm1.elements[index1].pos;
        pair center2 = sm2.elements[index2].pos;

        points.insert(0, center1);
        points.push(center2);

        if (random) gs = randompath(points, range);
        else gs = connect(points);
    }

    if (reverse) gs = reverse(gs);
    
    fitpath(pic, overlap = overlap, covermode = 0, drawnow = drawnow, gs = gs, L = L, p = p, null, null);
}

void drawpath (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
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
{
    int[] indices1 = findelementindex(destlabel1);
    smooth sm1 = smooth.cache[indices1[0]];
    int index1 = indices1[1];
    smooth sm2;
    int index2;
    if (destlabel1 == destlabel2)
    {
        sm2 = sm1;
        index2 = index1;
    }
    else
    {
        int[] indices2 = findelementindex(destlabel2);
        sm2 = smooth.cache[indices2[0]];
        index2 = indices2[1];
    }

    drawpath(pic, sm1, index1, sm2, index2, range, angle, radius, reverse, points, L, p, help, overlap, drawnow);
}

// >drawing | Deferred drawing implementation

void drawdeferred (
    picture pic = currentpicture,
    bool flush = true
)
{
    deferredPath[] curdp = extractdeferredpaths(pic, false);
    if (!config.drawing.underdashes) { purgedeferredunder(curdp); }

    void auxdraw (deferredPath p)
    {
        unravel p;

        int startind = 0;
        int finishind = g.length-1;
        pen underp = underpen(p);

        bool beginarrow = arrow == null || arrow.begin;
        bool endarrow = arrow == null || arrow.end;
        bool beginbar = bar == null || bar.begin;
        bool endbar = bar == null || bar.end;
        arrowbar truearrow = convertarrow(arrow);
        arrowbar truebar = convertbar(bar);

        if (!beginarrow && !endarrow && !beginbar && !endbar)
        {
            for (int j = startind; j <= finishind; ++j)
            { draw(pic = pic, g[j], p = under[j] > 0 ? underp : p); }
            return;
        }

        if (!beginarrow && !beginbar)
        {
            draw(pic = pic, g[g.length-1], p = under[g.length-1] > 0 ? underp : p, arrow = truearrow, bar = truebar);
            finishind -= 1;
        }
        else if (!endarrow && !endbar)
        {
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = truearrow, bar = truebar);
            startind += 1;
        }
        else if (g.length > 1)
        {
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = convertarrow(arrow, overridebegin = true), bar = convertbar(bar, overridebegin = true));
            draw(pic = pic, g[g.length-1], p = under[g.length-1] > 0 ? underp : p, arrow = convertarrow(arrow, overrideend = true), bar = convertbar(bar, overrideend = true));
            startind += 1;
            finishind -= 1;
        }
        else
        {
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = truearrow, bar = truebar);
            return;
        }

        for (int j = startind; j <= finishind; ++j)
        { draw(pic = pic, g[j], p = under[j] > 0 ? underp : p); }
    }

    for (int i = 0; i < curdp.length; ++i)
    { auxdraw(curdp[i]); }

    if (flush) curdp.delete();
}

void flushdeferred (
    picture pic = currentpicture
) { extractdeferredpaths(pic, false).delete(); }

// >redefining | Changing basic Asymptote functions to accomodate for deferred drawing

void plainshipout (
    string prefix=defaultfilename,
    picture pic=currentpicture,
    orientation orntn=orientation,
    string format="",
    bool wait=false,
    bool view=true,
    string options="",
    string script="",
    light lt=currentlight,
    projection P=currentprojection
) = shipout;

shipout = new void (
    string prefix=defaultfilename,
    picture pic=currentpicture,
    orientation orntn=orientation,
    string format="",
    bool wait=false,
    bool view=true,
    string options="",
    string script="",
    light lt=currentlight,
    projection P=currentprojection
)
{
    drawdeferred(pic = pic, flush = false);
    draw(pic = pic, debugpaths, red+1);
    plainshipout(prefix, pic, orntn, format, wait, view, options, script, lt, P);
};

void plainerase (
    picture pic = currentpicture
) = erase;

erase = new void (
    picture pic = currentpicture
)
{
    flushdeferred();
    plainerase(pic);
};

add = new void (
    picture dest,
    picture src,
    bool group=true,
    filltype filltype=NoFill,
    bool above=true
)
{
    drawdeferred(src);
    dest.add(src, group, filltype, above);
};

add = new void (
    picture src,
    bool group=true,
    filltype filltype=NoFill,
    bool above=true
)
{
    drawdeferred(src);
    currentpicture.add(src, group, filltype, above);
};

add = new void (
    picture dest,
    picture src,
    pair position,
    bool group=true,
    filltype filltype=NoFill,
    bool above=true
)
{
    drawdeferred(src);
    add(dest, src.fit(identity()), position, group, filltype, above);
};

picture plainapply (transform t, picture p) { return t*p; }

picture operator * (transform t, picture p)
{
    deferredPath[] curdp = extractdeferredpaths(p, false);
    picture q = plainapply(t,p);
    if (curdp.length > 0)
    {
        for (int i = 0; i < curdp.length; ++i)
        { curdp[i].g = t*curdp[i].g; }
        q.nodes.insert(0, p.nodes[0]);
    }
    return q;
}

void plainsave () { save(); }

void save ()
{
    deferredPath[] curdp = extractdeferredpaths(currentpicture, false);
    savedDeferredPaths.push(copy(curdp));
    plainsave();
};

void plainrestore () { restore(); }

void restore ()
{
    int ind = extractdeferredindex(currentpicture);
    plainrestore();
    if (ind >= 0 && savedDeferredPaths.length > 0)
    {
        deferredPaths[ind] = savedDeferredPaths.pop();
        if (extractdeferredindex(currentpicture) == -1)
        {
            currentpicture.nodes.insert(0, node(
                d = new void (frame f, transform t, transform T, pair lb, pair rt) {},
                key = (string) config.system.dummynumber+" "+(string)ind
            ));
        }
    }
}
