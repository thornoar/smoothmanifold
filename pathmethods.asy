/*

This is module pathmethods. It is an auxiliary collection of low-level path-related
functions primarily aimed at supporting the main module, smoothmanifold. It can be
useful on its own, though.

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

private path defaultPaUC = reverse(unitcircle); // [U]nit [C]ircle
private path defaultPaUS = (1,1) -- (1,-1) -- (-1,-1) -- (-1,1) -- cycle; // [U]nit [S]quare
path ucircle = defaultPaUC;
path usquare = defaultPaUS;
real defaultSyRPC = .03; // [R]ounded [P]ath [C]oefficient (how rounded to make the path)
real currentSyRPC = defaultSyRPC;
real defaultSyRPR = 30; // [R]andom [P]ath [R]ange (how random to make the path)
real currentSyRPR = defaultSyRPR;

void pathpar (
    real roundcoeff = currentSyRPC,
    real range = currentSyRPR
) // The configuration function.
{
    if (roundcoeff > .5)
    { write("> ? Number provided for the rounding coefficient ("+(string)roundcoeff+") seems too big. Values below 0.1 are ideal. Just saying."); }
    currentSyRPC = roundcoeff;
    currentSyRPR = range;
}

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

// Array functions

pair[] concat (pair[][] a)
// Same as the standard Asymptote `concat` function, but with more than two arguments.
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
// An improved `subpath` made for cyclic paths.
{
    if (t.x <= t.y) return subpath(p, t.x, t.y);
    return (subpath(p, t.x, length(p)) & subpath(p, 0, t.y));
}

bool clockwise (path p)
// Check if the path is clockwise.
{ return (windingnumber(p, inside(p)) == -1); }

bool meet (path p, path q)
// A shorthand to check if paths intersect.
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

path midpath (path g, path h, int n = 20)
// Construct the "mean" path between two given paths.
{
    path res;
    for (int i = 0; i < n; ++i)
    {
        res = res .. {(dir(g, reltime(g, i/n)) + dir(h, reltime(h, i/n)))*.5}((point(g, reltime(g, i/n)) + point(h, reltime(h, i/n)))*.5);
    }
    return res .. {(dir(g, reltime(g, 1)) + dir(h, reltime(h, 1)))*.5}((point(g, reltime(g, 1)) + point(h, reltime(h, 1)))*.5);
}

path pop (path[] source)
// Delete the first element and return it.
{
    path p = source[0];
    source.delete(0);
    return p;
}

path connect (pair[] points)
// Connect an array of points into a path
{
    guide acc;
    for (int i = 0; i < points.length; ++i)
    { acc = acc .. points[i]; }
    return (path) acc;
}

path wavypath (real[] nums, bool normaldir = true, bool adjust = false)
// Connect points around the origin with a path.
{
    if (nums.length == 0) return nullpath;
    if (nums.length == 1) return scale(nums[0])*defaultPaUC;
    
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

path[] combination (path p, path q, int mode, bool round, real roundcoeff)
// A general way to "combine" two paths based on their intersection points.
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

path[] difference (
    path p,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
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
    path[] paths,
    path q,
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
        if (!clockwise(q)) q = reverse(q);
    }

    return concat(sequence(new path[] (int i){return difference(paths[i], q, correct = false, round = round, roundcoeff = roundcoeff);}, paths.length));
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
    real roundcoeff = defaultSyRPC
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
    real roundcoeff = defaultSyRPC
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
    path[] paths,
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
    }
    if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return intersection(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);
    
    paths = sequence(new path (int i){return paths[i];}, paths.length);
    
    path p = paths.pop();
    path[] prev = intersection(paths, correct = false, round = round, roundcoeff = roundcoeff);
    
    return concat(sequence(new path[] (int i){return intersection(prev[i], p, correct);}, prev.length));
}

path[] intersection (
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
    ... path[] paths
) {return intersection(paths, correct, round, roundcoeff);}

path[] intersection (
    path p,
    path q,
    path[] holes,
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
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
    real roundcoeff = defaultSyRPC
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
    path[] paths,
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
    }
    
    if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return union(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);
    
    for (int i = 0; i < paths.length; ++i)
    {
        for (int j = i+1; j < paths.length; ++j)
        {
            if (meet(paths[i], paths[j]))
            {
                paths[i] = union(paths[i], paths[j], correct = false, round = round, roundcoeff = roundcoeff)[0];
                paths.delete(j);
                j = i;
            }
        }
    }
    
    return paths;
}

path[] union (
    bool correct = true,
    bool round = false,
    real roundcoeff = defaultSyRPC
    ... path[] paths
) { return union(paths, correct, round, roundcoeff); }

path[] operator | (path p, path q)
{ return union(p, q); }

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
