private path defaultPaUC = reverse(unitcircle); // [U]nit [C]ircle
private path defaultPaUS = (1,1) -- (1,-1) -- (-1,-1) -- (-1,1) -- cycle; // [U]nit [S]quare
path ucircle = defaultPaUC;
path usquare = defaultPaUS;

private real defaultSyRR = .03; // [R]ounded [P]ath [R]atio
real currentSyRR = defaultSyRR;

void roundcoeff (real val = defaultSyRR)
{
	if (val > .5)
	{ abort("Number provided for the rounding coefficient is too big. Values below 0.1 are ideal."); }
	currentSyRR = val;
}

pair center (path p, int n = 10, bool arc = true)
{
    pair sum = (0,0);
    for (int i = 0; i < n; ++i)
    { sum += point(p, arc ? arctime(p, arclength(p)*i/n) : length(p) * i/n); }
	if (inside(p, sum/n)) return sum/n;
	real[] times = times(p, (0, ypart(sum/n)));
	return (point(p, times[0]) + point(p, times[1])) * .5;
}

transform srap (real scale, real rotate, pair point)
{ return shift(point)*scale(scale)*rotate(rotate)*shift(-point); }
// [S]cale [R]otate [A]round [P]oint

bool inside (real a, real b, real c)
{ return (a <= c && c <= b); }

bool isinside (path p, pair x)
{ return windingnumber(p, x) == windingnumber(p, inside(p)); }

bool insidepath (path p, path q)
// Checks if q is completely inside p (the direction of p does not matter). Shorthand for inside(p, q) == 1
{ return (inside(p, srap(scale = .99, rotate = 0, point = center(p))*q) == 1); }

transform dscale (real scale, pair center = (0,0), pair dir) 
{
	if (length(dir) == 0) return identity;
	return rotate(degrees(dir), center) * xscale(scale) * rotate(-degrees(dir), center);
}

pair comb (pair a, pair b, real t)
{ return t*b + (1-t)*a;}

real round (real a, int places)
{ return floor(10^places*a)*.1^places; }
pair round (pair a, int places)
{ return (round(a.x, places), round(a.y, places)); }

real[] a (... real[] source)
{ return source; }
real[][] da (... real[][] source)
{ return source; }
real[][] aa (... real[] source)
{ return new real[][]{source}; }

int[] i (... int[] source)
{ return source; }
int[][] di (... int[][] source)
{ return source; }
int[][] ii (... int[] source)
{ return new int[][]{source}; }

pair[] concat (pair[][] a)
{
	if (a.length == 1) return a[0];
	pair[] b = a.pop();
	return concat(concat(a), b);
}
path[] concat (path[][] a)
// Same as the standard Asymptote `concat` function, but with more than two arguments.
{
    if (a.length == 1) return a[0];
    path[] b = a.pop();
    return concat(concat(a), b);
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
{
	int[] res = {};
	for (int i = 0; i < a.length; ++i)
	{ if (!contains(b, a[i])) res.push(a[i]); }
	return res;
}

real arclength (path g, real a, real b)
{ return arclength(subpath(g, a, b)); }

real relarctime (path g, real t0, real a)
{
    real t0arc = arclength(g, 0, t0);
    if (t0arc + a < 0) return -1;
    if (t0arc + a > arclength(g)) return -2;
    return arctime(g, t0arc+a);
}

real intersectiontime (path g, pair point, pair dir)
// Returns the time of the intersection of `g` with a beam going from `point` in direction `dir`
{
    int dist = 2;
    while (dist < 1024)
    {
        path line = point -- (point + unit(dir)*dist);
        real[] isect = intersect(g, line);
        if (isect.length > 0) return isect[0];
        else dist *= 2;
    }
    return -1;
}

path connect (pair[] points)
{
	path res = nullpath;
	for (int i = 0; i < points.length; ++i)
	{ res = res..points[i]; }
	return res;
}

pair intersection (path g, pair point, pair dir)
{ return point(g, intersectiontime(g, point, dir)); }

path reorient (path g, real time)
{ return subpath(g, time, length(g)) & subpath(g, 0, time) & cycle; }

path turn (path g, pair point, pair dir)
{ return reorient(g, intersectiontime(g, point, dir)); }

path subcyclic (path p, pair t)
{
    if (t.x <= t.y) return subpath(p, t.x, t.y);
    return (subpath(p, t.x, length(p)) & subpath(p, 0, t.y));
}

bool clockwise (path p)
{ return (windingnumber(p, inside(p)) == -1); }

bool meet (path p, path q)
{ return (intersect(p, q).length > 0); }

bool meet (path p, path[] q)
{
    for (int i = 0; i < q.length; ++i)
    { if (meet(p, q[i])) return true; }
    return false;
}

path ellipsepath (pair a, pair b, real curve = 0, bool abs = false)
// Returns half of an ellipse connecting points `a` and `b`. Curvature may be relative or absolute.
{
    if (!abs) curve = curve*length(b-a);
    pair mid = (a+b)*.5;
    path e = rotate(degrees(a-b), z = mid)*ellipse(mid, length(b-a)*.5, curve);
    return subpath(e, 0, reltime(e, .5));
}

path curvedpath (pair a, pair b, real curve = 0, bool abs = false)
// Constucts a curved path between two points.
{
    if (abs) curve = curve/length(b-a);
    pair mid = (a+b)*.5;
    return a .. (mid + curve * (rotate(-90) * (b-a))) .. b;
}

path cyclepath (pair a, real angle, real radius)
{ return shift(a)*rotate(angle)*scale(radius)*shift(1,0)*rotate(180)*reverse(unitcircle); }

pair range (path g, pair center, pair dir, real ang, real orientation = 1)
{
    return (intersectiontime(g, center, rotate(orientation*ang*.5)*dir), intersectiontime(g, center, rotate(-orientation*ang*.5)*dir));
}

bool outsidepath (path p, path q)
{ return !meet(p,q) && !insidepath(p,q); }

path midpath (path g, path h, int n = 20)
// Constructs the "mean" path between two given paths.
{
    path res;
    for (int i = 0; i < n; ++i)
    {
        res = res .. {(dir(g, reltime(g, i/n)) + dir(h, reltime(h, i/n)))*.5}((point(g, reltime(g, i/n)) + point(h, reltime(h, i/n)))*.5);
    }
    return res .. {(dir(g, reltime(g, 1)) + dir(h, reltime(h, 1)))*.5}((point(g, reltime(g, 1)) + point(h, reltime(h, 1)))*.5);
}

path pop (path[] source)
{
	path i = source[0];
	source.delete(0);
	return i;
}

real xsize (path p){return xpart(max(p)) - xpart(min(p));}
real ysize (path p){return ypart(max(p)) - ypart(min(p));}

real xsize (picture p){return xpart(max(p)) - xpart(min(p));}
real ysize (picture p){return ypart(max(p)) - ypart(min(p));}

path wavypath (real[] nums)
{
    if (nums.length == 1) return scale(nums[0])*defaultPaUC;
    
	pair[] points = sequence(new pair (int i){return nums[i]*dir(-360*(i/nums.length));}, nums.length);
    path getpath (pair[] arr)
    {
        if (arr.length == 2) return arr[0]{rotate(-90)*arr[0]}..{rotate(-90)*arr[1]}arr[1];
        pair a = arr.pop();
        return getpath(arr) .. {rotate(-90)*a}a;
    }
    
	return getpath(points)..cycle;
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
// Connects `p` and `q` smoothly.
// { return p -- (point(p, length(p)){dir(p, length(p))} .. {dir(q, 0)}point(q, 0)) -- q; }
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
        if(cross(pdir, qdir)*mode < 0) pway = true;
        else pway = false;
		real curarc = min(pway ? qroundlength : proundlength, arclength(curpath)*.5);
        if(pway)
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
                // finpath = subpath(curpath, begin, end)--(point(curpath, end){dir(curpath, end)}..{dir(curpath, begin)}point(curpath, begin))--cycle;
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

	res = sort(res, new bool (path i, path j){
		if (clockwise(i)) return true;
		else if (!clockwise(j)) return true;
		else return false;
	});

    return res;
}

path[] difference (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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
path[] difference (path[] paths, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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

path[] intersection (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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
path[] intersection (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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
path[] intersection (bool correct = true, bool round = false, real roundcoeff = defaultSyRR ... path[] paths)
{return intersection(paths, correct, round, roundcoeff);}
path[] intersection (path p, path q, path[] holes, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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

path[] union (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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
path[] union (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
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
path[] union (bool correct = true, bool round = false, real roundcoeff = defaultSyRR ... path[] paths)
{return union(paths, correct, round, roundcoeff);}
path[] operator | (path p, path q)
{ return union(p, q); }

pair randomdir (pair dir, real angle)
{ return dir(degrees(dir) + (unitrand()-.5)*angle); }

path randompath (pair[] controlpoints, real angle)
{
	if (controlpoints.length < 2) return nullpath;

	pair outdir = randomdir(controlpoints[1]-controlpoints[0], angle);
	path res = controlpoints[0];
	for (int i = 1; i < controlpoints.length; ++i)
	{
		pair indir = randomdir(controlpoints[i]-controlpoints[i-1], angle);
		res = res{outdir} .. {indir}controlpoints[i];
		outdir = indir;
	}

	return res;
}
