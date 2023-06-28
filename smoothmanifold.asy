// ---------------------------------------------------------------------- //
// This is module smoothmanifold. First goes a list of (generally) useful //
// path functions.                                                        //
// ---------------------------------------------------------------------- //
// navigation keyword: $paths

a (b = c)

real defaultBSP = .0001;
real defaultNaP = .1;
bool defaultUBS = false;
real defaultCLB = .0000001;
real defaultGLB = .01;
real defaultSGUB = .55;
real defaultSpCh = .65;
pen defaultBgC = white;
real defaultRPR = .03;

path defaultUC = reverse(unitcircle);

path[] defaultCVSP = new path[]{
    defaultUC,
    scale(.4)*shift(-.4,.3)*((-3,0)..(-1,2)..(1.5, 1)..(3,-2.5)..(-1,-2)..cycle),
    scale(.5)*shift(-.8,-.4)*((-1,0)..(0,2.1)..(1.8,-1.5)..cycle),
    rotate(-100)*scale(.29)*shift(1,-1)*((-5,0)..(1,3.5)..(2,-1.9)..(-1,-1.8)..cycle),
    scale(.54)*shift(-.9,.4)*((-1.5,0)..(0,1)..(3,-1)..(-1,-1)..cycle),
    scale(.47)*shift(-.4,.2)*((-2,0)..(-.3, 2)..(0, -2.5)..(-1.3, -1.3).. cycle),
    (0.890573,-0.36047)..controls (-0.148296,-1.45705) and (-1.29345,-1.23691) .. (-0.996593,0.106021) .. controls (-0.669702,1.58481) and (2.03559,0.848164)..cycle,
    (-0.614919,1.31465)..controls (-0.614919,1.31465) and (-0.614919,1.31465)..(-0.614919,1.31465)..controls (-0.614919,1.31465) and (-0.614919,1.31465)..cycle,
    (0.989525,-0.664395)..controls (-0.155497,-1.61858) and (-1.40332,0.329701)..(-0.862301,0.79162)..controls (0.346334,1.82355) and (1.39766,-0.324279)..cycle,
    (0.28979,-0.834028)..controls (0.093337,-0.908653) and (-1.20138,-1.95019)..(-1.15209,0.0777484)..controls (-1.10261,2.11334) and (3.02512,0.204973)..cycle,
    (1.01073,-0.409946)..controls (0.812824,-1.99319) and (-2.2123,-0.523035)..(-0.897641,0.36047)..controls (0.779873,1.48783) and (1.20823,1.17008)..cycle,
    (0.636123,-0.975389)..controls (-0.853465,-1.50787) and (-1.37827,0.219109)..(-0.770416,0.961253)..controls (-0.154452,1.7133) and (2.19816,-0.417014)..cycle,
    (0.805756,0.918845)..controls (1.7034,-0.664395) and (-0.374882,-1.93278)..(-0.890573,-0.742144)..controls (-1.3712,0.367538) and (0.34086,1.73882)..cycle,
    (0.572511,-0.925913)..controls (-1.47015,-1.5479) and (-1.32586,0.925729)..(-0.28979,1.00366)..controls (1.30759,1.12382) and (1.65924,-0.595004)..cycle
};

path[] defaultCCSP = new path[]{
    scale(.2)*shift(0, -1)*((-4.5,1)..(-2.3,7.5)..(2,2.8)..(5.6,1)..(2,-4)..(-3,-2.5)..cycle),
    (0.523035,-1.10261)..controls (-2.62474,-1.37362) and (0.932069,3.11139)..(0.558375,0.388742)..controls (0.508899,0.0282721) and (1.59031,-1.01073)..cycle,
    rotate(-90)*scale(.7)*shift(-.5, 0)*((-1.5, 0)..(-.7,.7)..(0, .4)..(1.5, 1.3)..(2.4, .3)..(1.3, -1)..(.1, -.8)..(-.7, -.7)..cycle), rotate(-90)*scale(.37)*shift(-3,-2)*((0,0)..(1,2)..(3,5)..(2,-1)..cycle),
    scale(.27)*((-5,0)..(-1,2)..(1.5, 5)..(1,-2.5)..(-1,-3)..cycle),
    scale(.23)*shift(1,0)*((-4,1)..(-1,6)..(1,2.5)..(3.5,1)..(2,-3)..(-4.7,-2.8)..cycle),
    scale(.3)*shift(-.8,-.8)*((-2,0)..(0,4)..(1.8,2)..(4,0)..(0,-2)..cycle)
};

path wavypath (real[] nums)
{
    if (nums.length == 1) return scale(nums[0])*defaultUC;

    pair[] points = sequence(new pair (int i){return nums[i]*dir(-360*(i/nums.length));}, nums.length);

    path get_path (pair[] arr)
    {
        if (arr.length == 2) return arr[0]{rotate(-90)*arr[0]}..{rotate(-90)*arr[1]}arr[1];

        pair a = arr.pop();

        return get_path(arr) .. {rotate(-90)*a}a;
    }

    return get_path(points)..cycle;
}
path wavypath (... real[] nums)
{
    return wavypath(nums = nums);
}

// int find_index (T[] arr, T a)
// {
//     return find(map(new bool (T x){return (x == a);}, arr));
// }

real dist (pair a, pair b)
{
    return length(b-a);
}

int[] decompose (int n)
{
    int[] res;

    while (n > 0)
    {
        int e = floor(log(n)/log(2));
        res.push(e);
        n -= 2^e;
    }

    return res;
}

bool inside (real a, real b, real c)
{
    return (a <= c && c <= b);
}

transform rotate_around_point (real rotate, pair point = (0,0)) {return shift(point)*rotate(rotate)*shift(-point);}

transform scale_around_point (real scale, pair point) {return shift(point)*scale(scale)*shift(-point);}

transform srap (real scale, real rotate, pair point) {return shift(point)*scale(scale)*rotate(rotate)*shift(-point);}

pair path_middle (path p, int n = 10)
{
    pair sum = (0,0);

    for (int i = 0; i < n; ++i)
    {
        sum += point(p, arctime(p, arclength(p)*i/n));
    }

    return sum/n;
}

real sub_arclength (path g, real a = 0, real b = length(g))
{
    return arclength(subpath(g, a, b));
}

real polar_intersection_time (path g, pair center = path_middle(g), pair dir)
{
    int dist = 2;

    while (dist < 1024)
    {
        path line = center -- (center + unit(dir)*dist);

        real[] isect = intersect(g, line);

        if (isect.length > 0)
        {
            return isect[0];
        }
        else {dist *= 2;}
    }

    return -1;
}

path turn_int (path g, pair a, pair b)
{
    int[] arr = sequence(length(g));

    pair dir = b-a;

    arr = sort(arr, new bool (int i, int j){return (dot(dir, point(g, i)) > dot(dir, point(g, j)));});

    int n = arr[0];

    return subpath(g, n, length(g))--subpath(g, 0, n)--cycle;
}

path reorient (path g, real time)
{
    return subpath(g, time, length(g))--subpath(g, 0, time)--cycle;
}

path turn (path g, pair a, pair b)
{
    return reorient(g, polar_intersection_time(g, a, b));
}

path cyclic_subpath (path p, real t1, real t2)
{
    if (t1 <= t2) return subpath(p, t1, t2);

    return subpath(p, t1,length(p))--subpath(p, 0, t2);
}

bool clockwise (path p)
{
    return (windingnumber(p, inside(p)) == -1);
}

bool do_intersect (path p, path q)
{
    return (intersect(p, q).length > 0);
}

bool do_intersect (path p, path[] q)
{
    for (int i = 0; i < q.length; ++i)
    {
        if (do_intersect(p, q[i])) return true;
    }

    return false;
}

struct gauss
{
    int x;
    int y;

    void operator init (int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}

gauss operator cast (pair p)
{
    return gauss(floor(p.x), floor(p.y));
}
pair operator cast (gauss g)
{
    return (g.x, g.y);
}

path round_connect (path p, path q)
{
    return p -- (point(p, length(p)){dir(p, length(p))} .. {dir(q, 0)}point(q, 0)) -- q;
}

path[] combination (path p, path q, int mode, bool round, real roundcoeff)
{
    if (!do_intersect(p, q)) return new path[];

    real proundlength = roundcoeff*arclength(p);
    real qroundlength = roundcoeff*arclength(q);

    real[][] times = intersections(p, q);

    for (int i = 0; i < times.length; ++i)
    {
        pair pdi = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = -1) : dir(p, times[i][0]);
        pair pdo = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = 1) : dir(p, times[i][0]);
        pair qdi = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = -1) : dir(q, times[i][1]);
        pair qdo = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = 1) : dir(q, times[i][1]);

        if (sgn(cross(qdi, pdi))*sgn(cross(pdo, qdo)) >= 0)
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

        if(pway)
        {
            newind = ((curind.x+1)%n, qinds[(curind.x+1)%n]);

            if ((-(newind.y - curind.y)*windingnumber(q, inside(q)))%n > 1)
            {
                nextstarts.insert(i = 0, (pinds[(curind.y+1)%n], (curind.y+1)%n));
            }
        }
        else
        {
            newind = (pinds[(curind.y+1)%n], (curind.y+1)%n);

            if ((-(newind.x - curind.x)*windingnumber(p, inside(p)))%n > 1)
            {
                nextstarts.insert(i = 0, ((curind.x+1)%n, qinds[(curind.x+1)%n]));
            }
        }

        path addpath = cyclic_subpath(pway ? p : q, times[curind.x][pway ? 0 : 1], times[newind.x][pway ? 0 : 1]);

        if (!round || curpath == nullpath) curpath = curpath -- addpath;
        else
        {
            path subcurpath = subpath(curpath, 0, arctime(curpath, arclength(curpath)- (pway ? qroundlength : proundlength)));

            path subaddpath = subpath(addpath, arctime(addpath, (pway ? proundlength : qroundlength)), length(addpath));

            curpath = round_connect(subcurpath, subaddpath);
        }

        if ((pair)newind == (pair)start)
        {
            path finpath;

            if (!round)
            {
                finpath = curpath--cycle;
            }
            else
            {
                real begin = arctime(curpath, (pway ? qroundlength : proundlength));
                real end = arctime(curpath, arclength(curpath)-(pway ? proundlength : qroundlength));

                finpath = subpath(curpath, begin, end)--(point(curpath, end){dir(curpath, end)}..{dir(curpath, begin)}point(curpath, begin))--cycle;

            }

            res.push(finpath);
            curpath = nullpath;

            if (nextstarts.length == 0) break;

            start = nextstarts.pop();

            curind = start;
        }
        else
        {
            curind = newind;
        }
    }

    return res;
}

path[] concat (path[][] a)
{
    if (a.length == 1) return a[0];

    path[] b = a.pop();

    return concat(concat(a), b);
}

bool inside_path (path p, path q, bool checkintersection = true)
{
    if (checkintersection) if(do_intersect(p, q)) return false;

    return (windingnumber(p, point(q, 0)) == windingnumber(p, inside(p)));
}

path[] difference (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }

    if (!do_intersect(p, q))
    {
        if (windingnumber(p, point(q,0)) == -1) return new path[]{p, reverse(q)};
        if (windingnumber(q, point(p,0)) == -1) return new path[];

        return new path[]{p};
    }

    return combination(p, reverse(q), mode = -1, round = round, roundcoeff = roundcoeff);
}
path[] difference (path[] p, path q, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        for (int i = 0; i < p.length; ++i)
        {
            if (!clockwise(p[i])) p[i] = reverse(p[i]);
        }

        if (!clockwise(q)) q = reverse(q);
    }

    return concat(sequence(new path[] (int i){return difference(p[i], q, correct = false, round = round, roundcoeff = roundcoeff);}, p.length));
}

path[] intersection (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }

    if (!do_intersect(p, q))
    {
        if (inside_path(p,q)) return new path[]{q};
        if (inside_path(q,p)) return new path[]{p};

        return new path[];
    }

    return combination(p, q, mode = -1, round = round, roundcoeff = roundcoeff);
}
path[] intersection (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        {
            if (!clockwise(paths[i])) paths[i] = reverse(paths[i]);
        }
    }

    if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return intersection(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);

    path p = paths.pop();
    path[] prev = intersection(paths, correct = false, round = round, roundcoeff = roundcoeff);

    return concat(sequence(new path[] (int i){return intersection(prev[i], p, correct);}, prev.length));
}
path[] intersection (bool correct = true, bool round = false, real roundcoeff = defaultRPR ... path[] paths) {return intersection(paths, correct, round, roundcoeff);}

path[] intersection (path p, path q, path[] holes, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);

        for (int i = 0; i < holes.length; ++i)
        {
            if (!clockwise(holes[i])) holes[i] = reverse(holes[i]);
        }
    }

    path[] pcapq = intersection(p, q, correct = false, round = round, roundcoeff = roundcoeff);

    path[][] res;

    for (int i = 0; i < holes.length; ++i)
    {
        res.push(difference(pcapq, holes[i], correct = false, round = round, roundcoeff = roundcoeff));
    }

    return concat(res);
}

path[] union (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }

    if (!do_intersect(p, q))
    {
        if (inside_path(p,q)) return new path[]{p};
        if (inside_path(q,p)) return new path[]{q};

        return new path[]{p,q};
    }

    return combination(p, q, mode = 1, round = round, roundcoeff = roundcoeff);
}
path[] union (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultRPR)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        {
            if (!clockwise(paths[i])) paths[i] = reverse(paths[i]);
        }
    }

    if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return union(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);

    for (int i = 0; i < paths.length; ++i)
    {
        for (int j = i+1; j < paths.length; ++j)
        {
            if (do_intersect(paths[i], paths[j]))
            {
                paths[i] = union(paths[i], paths[j], correct = false, round = round, roundcoeff = roundcoeff)[0];
                paths.delete(j);
                j = i;
            }
        }
    }

    return paths;
}
path[] union (bool correct = true, bool round = false, real roundcoeff = defaultRPR ... path[] paths) {return union(paths, correct, round, roundcoeff);}

real grade (pair p1, pair p2, pair dir1, pair dir2)
{
    return abs(dot(unit(dir2), unit(p1-p2))-dot(unit(p2-p1), unit(dir1)));
}

bool spread_check (pair p1, pair p2, pair dir1, pair dir2)
{
    return (min(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) > -defaultSpCh && max(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) < defaultSpCh);
}

pair[][] h_section_points (path[] g, real y, real ignore)
{
    real ymin = ypart(min(g));
    real ymax = ypart(max(g));

    real ri = ignore * (ymax-ymin);

    pair[][] res = new pair[][];

    real ry = ymin*(1-y)+ymax*y;

    for (int i = 0; i < g.length; ++i)
    {
        real[] times = times(g[i], (0, ry));

        real curymin = ypart(min(g[i]));
        real curymax = ypart(max(g[i]));

        for (int j = 0; j < times.length; ++j)
        {
            if(abs(ry - curymin) >= ri && abs(ry - curymax) >= ri)
            {
                res.push(new pair[] {point(g[i], times[j]), dir(g[i], times[j])});
            }
        }
    }

    return sort(res, new bool (pair[] i, pair[] j){
        return (xpart(i[0]) < xpart(j[0]));
    });
}

pair[][] h_cartsections (path[] g, real y, real ignore)
{
    int n = floor(y);
    y = y-n;

    pair[][] presections = h_section_points(g, y, ignore);

    // if(presections.length % 2 == 1) return new pair[][];

    int[] arr = decompose(n);

    pair[][] sections = new pair[][];

    for (int j = 0; j < presections.length; j += 2)
    {
        if (!spread_check(presections[j][0], presections[j+1][0], presections[j+1][1], presections[j][1])) continue;

        sections.push(new pair[] {presections[j][0], presections[j+1][0], presections[j][1], presections[j+1][1]});
    }

    for (int j = 0; j < arr.length; ++j)
    {
        if(sections.length > arr[j]){sections.delete(arr[j]);}
    }

    return sections;
}

pair[][] v_section_points (path[] g, real x, real ignore)
{
    real xmin = xpart(min(g));
    real xmax = xpart(max(g));

    real ri = ignore * (xmax-xmin);

    pair[][] res = new pair[][];

    real rx = xmin*(1-x)+xmax*x;

    for (int i = 0; i < g.length; ++i)
    {
        real[] times = times(g[i], rx);

        real curxmin = xpart(min(g[i]));
        real curxmax = xpart(max(g[i]));

        for (int j = 0; j < times.length; ++j)
        {
            if(abs(rx - curxmin) > ri && abs(rx - curxmax) > ri)
            {
                res.push(new pair[] {point(g[i], times[j]), dir(g[i], times[j])});
            }
        }
    }

    return sort(res, new bool (pair[] i, pair[] j){
        return (ypart(i[0]) < ypart(j[0]));
    });
}

pair[][] v_cartsections (path[] g, real x, real ignore)
{
    int n = floor(x);
    x = x-n;

    pair[][] presections = v_section_points(g, x, ignore);
    
    if(presections.length % 2 == 1) return new pair[][];

    int[] arr = decompose(n);

    pair[][] sections = new pair[][];

    for (int j = 0; j < presections.length; j += 2)
    {
        if (!spread_check(presections[j][0], presections[j+1][0], presections[j][1], presections[j+1][1])) continue;

        sections.push(new pair[] {presections[j][0], presections[j+1][0], presections[j][1], presections[j+1][1]});
    }

    for (int j = 0; j < arr.length; ++j)
    {
        if(sections.length > arr[j]){sections.delete(arr[j]);}
    }

    return sections;
}

path ellipse_path (pair a, pair b, real curve = 0)
{
    pair mid = (a+b)/2;
    pair d = b-a;

    path e = rotate(degrees(-d), z = mid)*ellipse(mid, length(d)/2, curve*length(d));

    return subpath(e, 0, reltime(e, .5));
}

path abs_ellipse_path (pair a, pair b, real curve = 0)
{
    return ellipse_path(a, b, curve/length(b-a));
}

path curved_path (pair a, pair b, real curve = 0)
{
    pair mid = (a+b)/2;

    return a .. (mid + curve*(rotate(-90)*(b-a))) .. b;
}

path abs_curved_path (pair a, pair b, real curve = 0)
{
    return curved_path(a, b, curve/length(b-a));
}

pair locate_ellipse_search (real l, real h, real cang1, real cang2)
{
    real r1 = 0;
    real l1 = l*.5;

    real r2 = 0;
    real l2 = l*.5;

    path get_ellipse (real d1, real d2)
    {
        pair center = ((d1 + l-d2)*.5, 0);

        return ellipse(center, (l-d1-d2)*.5, h);
    }

    real want = defaultBSP;

    path line1 = -(cang1, sqrt(1-cang1^2)) -- (cang1, sqrt(1-cang1^2));
    path line2 = ((l,0) - (-cang2, sqrt(1-cang2^2))) -- ((l,0) + (-cang2, sqrt(1-cang2^2)));

    while (l1-r1 >= want || l2-r2 >= want)
    {
        real c1 = (r1+l1)/2;
        real c2 = (r2+l2)/2;

        if(!do_intersect(line1, get_ellipse(c1, r2))){l1 = c1;}
        else {r1 = c1;}

        if(!do_intersect(line2, get_ellipse(r1, c2))){l2 = c2;}
        else {r2 = c2;}
    }

    return ((l1 + (l-l2))*.5, (l-l1-l2)*.5);
}

pair locate_ellipse_symmetric (real l, real h, real cang)
{
    return (l*.5, sqrt(l*l*.25 - cang^2 * h^2 / (1 - cang^2)));
}

real mod (real a, real b)
{
    while (a < 0) a += b;
    while (a <= b) a -= b;

    return a;
}

path[] tangent_section_ellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir, bool naive)
{
    pair p1p2 = unit(p2-p1);
    real l = length(p2-p1);

    if (cross(viewdir, p1p2) == 0) return new path[] {p1--p2};

    pair hv = (rotate(90)*p1p2) * cross(p2-p1, viewdir);
    real h = length(hv);

    if(cross(p1p2, dir1) < 0) dir1 = rotate(180)*dir1;
    if(cross(dir2, -p1p2) < 0) dir2 = rotate(180)*dir2;

    real cang1 = dot(p1p2, unit(dir1));
    real cang2 = dot(unit(dir2), -p1p2);

    real sign = sgn(cross(p1p2, hv));

    path line1 = (p1 - 10*dir1) -- (p1 + 10*dir1);
    path line2 = (p2 - 10*dir2) -- (p2 + 10*dir2);

    real cang = (cang1+cang2)/2;

    if (l*l*.25 - cang^2 * h^2 / (1 - cang^2) < 0) return new path[]{p1--p2};

    pair pos = ((naive || defaultUBS) && !(grade(p1, p2, dir1, dir2) < defaultGLB)) ? locate_ellipse_search(l, h, cang1, cang2) : locate_ellipse_symmetric(l, h, (cang1+cang2)/2);

    real c = pos.x;
    real x = pos.y;

    path pres = (sign < 0) ? rotate(180, (c,0))*ellipse((c, 0), x, h) : reverse(rotate(180, (c,0))*ellipse((c, 0), x, h));

    real tg1 = (abs(cang1) < defaultCLB) ? 0 : sqrt(1 - cang1^2)/cang1;
    
    real t1 = 0;

    if(tg1 != 0)
    {
        real r1 = abs(h/(tg1 * sqrt(1 + (x/h * tg1)^2)));

        real[] times1 = times(pres, r1);

        t1 = (times1.length == 2) ? times1[1 - floor((sgn(tg1)*sign + 1)*.5)] : 0;
    }

    pres = reorient(pres, t1);

    real t2 = intersect(pres, (c, 0)--(c+2*x, 0))[0];

    real tg2 = (abs(cang2) < defaultCLB) ? 0 : sqrt(1 - cang2^2)/cang2;

    if(tg2 != 0)
    {
        real r2 = l - abs(h/(tg2 * sqrt(1 + ((l-x)/h * tg2)^2)));
    
        real[] times2 = times(pres, r2);

        t2 = (times2.length == 2) ? times2[1 - floor((sgn(tg2)*sign + 1)*.5)] : intersect(pres, (c, 0)--(c+2*x, 0))[0];
    }

    return map(new path (path p){return shift(p1)*rotate(degrees(p1p2))*p;}, new path[] {subpath(pres, 0, t2), subpath(pres, t2, length(pres))});
}

pair polar_intersection (path g, pair center, pair dir)
{
    return point(g, polar_intersection_time(g, center, dir));
}

pair range (path g, pair center, pair dir, real ang, real orientation = 1)
{
    return (polar_intersection_time(g, center, rotate(orientation*ang/2)*dir), polar_intersection_time(g, center, rotate(-orientation*ang/2)*dir));
}

pair[][] free_sect_positions (path g, path h, pair gt = (0, length(g)), pair ht = (0, length(h)), int n, real ratio, int p, bool addtimes = false)
{
    real goddstep = sub_arclength(g, gt.x, gt.y)/(n + (n-1)*(1 - ratio)/ratio);
    real gevenstep = goddstep*(1-ratio)/ratio;

    real hoddstep = sub_arclength(h, ht.x, ht.y)/(n + (n-1)*(1-ratio)/ratio);
    real hevenstep = hoddstep*(1-ratio)/ratio;

    real gbeforearc = sub_arclength(g, 0, gt.x);
    real hbeforearc = sub_arclength(h, 0, ht.x);

    real[] gtimes = new real[];
    for(int i = 0; i < 2*n; ++i)
    {
        if(i % 2 == 0)
        {
            gtimes.push(arctime(g, gbeforearc + i/2*(goddstep + gevenstep)));
        }
        else
        {
            gtimes.push(arctime(g, gbeforearc + goddstep*(i+1)/2 + gevenstep*(i-1)/2));
        }
    }

    real[] htimes = new real[];
    for (int i = 0; i < 2*n; ++i)
    {
        if(i % 2 == 0)
        {
            htimes.push(arctime(h, hbeforearc + i/2*(hoddstep + hevenstep)));
        }
        else
        {
            htimes.push(arctime(h, hbeforearc + hoddstep*(i+1)/2 + hevenstep*(i-1)/2));
        }
    }

    pair[][] res = new pair[][];

    for (int i = 0; i < 2*n-1; i += 2)
    {
        int gi = 0;
        int hi = 0;

        real gtimestep = (gtimes[i+1]-gtimes[i])/p;
        real htimestep = (htimes[i+1]-htimes[i])/p;

        pair p1 = point(g, gtimes[i]);
        pair dir1 = dir(g, gtimes[i]);
        pair p2 = point(h, htimes[i]);
        pair dir2 = dir(h, htimes[i]);

        pair t;

        if(addtimes) t  = (gtimes[i], htimes[i]);

        while(gi < p-1 || hi < p-1)
        {
            pair p1new = point(g, gtimes[i]+(gi+1)*gtimestep);
            pair dir1new = dir(g, gtimes[i]+(gi+1)*gtimestep);

            pair p2new = point(h, htimes[i]+(hi+1)*htimestep);
            pair dir2new = dir(h, htimes[i]+(hi+1)*htimestep);

            if ((grade(p1, p2new, dir1new, dir2new) < grade(p1new, p2, dir1new, dir2) && hi < p-1) || gi == p-1)
            {
                hi += 1;

                if (grade(p1, p2new, dir1, dir2new) < grade(p1, p2, dir1, dir2))
                {
                    p2 = p2new;
                    dir2 = dir2new;
                    if(addtimes) t = (t.x, htimes[i]+(hi+1)*htimestep);
                }
            }
            else
            {
                gi += 1;

                if (grade(p1new, p2, dir1new, dir2) < grade(p1, p2, dir1, dir2))
                {
                    p1 = p1new;
                    dir1 = dir1new;
                    if(addtimes) t = (gtimes[i]+(gi+1)*gtimestep, t.y);
                }
            }
        }

        if(addtimes) res.push(new pair[] {p2, p1, dir2, dir1, t});
        else res.push(new pair[] {p2, p1, dir2, dir1});
    }

    return res;
}

pair[][] naive_sect_positions (path g, path h, pair gt, int p, int step)
{
    pair[][] res = new pair[][];

    real[] gtimes = sequence(new real (int i){return gt.x + (gt.y-gt.x)*i/p;}, p);

    for (int i = 0; i < gtimes.length; ++i)
    {
        real gtime = gtimes[i];

        pair p1 = point(g, gtime);
        pair dir1 = dir(g, gtime);

        real htime = polar_intersection_time(h, p1, rotate(90)*dir1);

        if (htime != -1)
        {
            pair p2 = point(h, htime);
            pair dir2 = dir(h, htime);

            if (grade(p1, dir1, p2, dir2) < defaultNaP)
            {
                res.push(new pair[] {p2, p1, dir2, dir1});

                i += step;
            }
        }
    }

    return res;
}

path mymidpath (path g, path h)
{
    pair[][] mat = free_sect_positions(g = g, h = h, n = 30, ratio = .9, p = 20);

    path res = ((mat[0][0]+mat[0][1])/2){(mat[0][2]+mat[0][3])/2} .. {(mat[1][2]+mat[1][3])/2}((mat[1][0]+mat[1][1])/2);

    for (int i = 2; i < mat.length; ++i)
    {
        res = res .. {(mat[i][2]+mat[i][3])/2}((mat[i][0]+mat[i][1])/2);
    }

    return res;
}

path midpath (path g, path h, int n = 20)
{
    path res = ((point(g, 0)+point(h, 0))/2){(dir(g, 0)+dir(h,0))/2} .. {(dir(g, reltime(g, 1/n)) + dir(h, reltime(h, 1/n)))/2}((point(g, reltime(g, 1/n))+point(h, reltime(h, 1/n)))/2);

    for (int i = 2; i < n; ++i)
    {
        res = res .. {(dir(g, reltime(g, i/n)) + dir(h, reltime(h, i/n)))/2}((point(g, reltime(g, i/n)) + point(h, reltime(h, i/n)))/2);
    }

    return res .. {(dir(g, reltime(g, 1)) + dir(h, reltime(h, 1)))/2}((point(g, reltime(g, 1)) + point(h, reltime(h, 1)))/2);
}

void draw_overlap (picture pic=currentpicture, Label L="", path g, align align = NoAlign, pen p = currentpen, arrowbar arrow = None, arrowbar bar = None, margin margin = NoMargin, Label legend = "", marker marker = nomarker, pen fillpen = defaultBgC+linewidth(8pt))
{
    draw(pic = pic, g = g, align = align, p = fillpen, margin = margin);

    draw(pic = pic, L = L, g = g, align = align, p = p, arrow = arrow, bar = bar, margin = margin, legend = legend, marker = marker);
}


// -------------------------- //
// Here the definitions start //
// -------------------------- //
// keyword: $definitions


int dummynumber = -100;
pair dummypair = (dummynumber, dummynumber);
string dummystring = (string)dummynumber;
int prohibitednumber = -200;
real defaultSAB = 220;
real defaultSAS = 30;
int defaultSN = 7;
real defaultSR = .8;
int defaultSP = 50;
int defaultNN = 2;
real defaultOL = .015;
real defaultOLW = 4;
real defaultATM = .04;
real defaultTAVAN = 25;
real defaultTARN = 15;
pen defaultSmP = lightgrey;
pen defaultSbP = grey;
pen defaultSmSP = currentpen+linewidth(.3);
real defaultSmM = .5;
real defaultSmAR = .1;
real defaultSmVS = .2;
string defaultSmMode = "free";
bool defaultSmE = false;
real defaultSmEDL = .2;
bool defaultSmDD = true;
real defaultSmCI = .05;
real defaultSmCSD = .05;
int defaultSmCSN = 15;
real defaultSmCSTL = .5;

usepackage("amssymb");

struct hole
{
    path contour;
    
    pair center;

    bool drawsections;
    bool drawsections_neigh;
    bool drawsections_smooth;

    real[][] sections;

    int neighnumber;

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), bool drawsections = true, bool drawsections_neigh = true, bool drawsections_smooth = true, real[][] sections = {}, int neighnumber = dummynumber, pair cartsectratios = dummypair, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        transform t = shift(shift)*srap(scale, rotate, center);

        path pseudocontour = t*contour;
        pair pseudocenter = path_middle(pseudocontour);

        this.contour = (!clockwise(pseudocontour)) ? reverse(pseudocontour) : pseudocontour;

        this.center = shift(shift)*center;

        this.drawsections = drawsections;
        this.drawsections_neigh = drawsections_neigh;
        this.drawsections_smooth = drawsections_smooth;

        this.sections = new real[][];
        for (int i = 0; i < sections.length; ++i)
        {
            real[] arr = sections[i];

            while(arr.length < 6) {arr.push(dummynumber);}

            this.sections.push(arr);
        }

        this.neighnumber = neighnumber;
    }

    hole move (pair shift, real scale, real rotate, pair point = this.center, bool movesections = false)
    {
        this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;

        this.center = shift(shift)*srap(scale, rotate, point)*this.center;

        if (!movesections) return this;

        for (int i = 0; i < this.sections.length; ++i)
        {
            pair sectdir = (this.sections[i][0], this.sections[i][1]);

            this.sections[i][0] = xpart(rotate(rotate)*sectdir);
            this.sections[i][1] = ypart(rotate(rotate)*sectdir);
        }
        
        return this;
    }
    hole adjust (pair shift, real scale, real rotate, pair point)
    {
        this.contour = srap(scale, rotate, point)*shift(shift)*this.contour;

        this.center = srap(scale, rotate, point)*shift(shift)*this.center;

        for (int i = 0; i < this.sections.length; ++i)
        {
            pair sectdir = (this.sections[i][0], this.sections[i][1]);

            this.sections[i][0] = xpart(rotate(rotate)*sectdir);
            this.sections[i][1] = ypart(rotate(rotate)*sectdir);
        }
        
        return this;
    }

    hole copy ()
    {
        return hole(this.contour, this.center, this.drawsections, this.drawsections_neigh, this.drawsections_smooth, this.sections, this.neighnumber);
    }
}

path operator cast (hole h)
{
    return h.contour;
}

path[] operator cast (hole[] h)
{
    return sequence(new path (int i){return h[i].contour;}, h.length);
}

struct subset
{
    path contour;

    pair center;

    string label;
    pair labeldir;
    pair labelalign;

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), string label = dummystring, pair labeldir = dummypair, pair labelalign = dummypair, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        transform t = shift(shift)*srap(scale, rotate, center);

        path pseudocontour = t*contour;
        pair pseudocenter = path_middle(pseudocontour);

        this.contour = (!clockwise(pseudocontour)) ? reverse(pseudocontour) : pseudocontour;

        this.center = shift(shift)*center;

        this.label = label == dummystring ? "" : label;
        this.labeldir = labeldir == dummypair ? S : labeldir;
        this.labelalign = labelalign == dummypair ? rotate(90)*dir(this.contour, polar_intersection_time(this.contour, this.center, this.labeldir)) : labelalign;
    }

    subset set_label (string label = dummystring, pair labeldir = dummypair, pair labelalign = dummypair)
    {
        this.label = label == dummystring ? this.label : label;
        this.labeldir = labeldir == dummypair ? this.labeldir : labeldir;
        this.labelalign = labelalign == dummypair ? rotate(90)*dir(this.contour, polar_intersection_time(this.contour, this.center, this.labeldir)) : labelalign;

        return this;
    }
    subset move (pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.center)
    {
        this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;

        this.center = shift(shift)*srap(scale, rotate, point)*this.center;
        
        return this;
    }
    subset adjust (pair shift, real scale, real rotate, pair point)
    {
        this.contour = srap(scale, rotate, point)*shift(shift)*this.contour;

        this.center = srap(scale, rotate, point)*shift(shift)*this.center;

        this.labeldir = rotate(rotate)*this.labeldir;
        
        return this;
    }

    subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign);
    }
}

path operator cast (subset s)
{
    return s.contour;
}

path[] operator cast (subset[] s)
{
    return sequence(new path (int i){return s[i].contour;}, s.length);
}

struct smooth
{
    path contour;

    pair center;

    string label;
    pair labeldir;
    pair labelalign;

    hole[] holes;

    subset[] subsets;

    real[] hsectratios;
    real[] vsectratios;

    pair shift;
    real scale;
    real rotate;

    smooth set_contour (path contour, bool unit = true)
    {
        this.contour = unit ? srap(this.scale, this.rotate, this.center)*shift(this.shift)*contour : contour;
        
        return this;
    }
    smooth set_center (pair center = path_middle(this.contour), bool unit = true)
    {
        this.center = unit ? shift(this.shift)*center : center;
        
        return this;
    }
    smooth set_label (string label = this.label, pair labeldir = this.labeldir, pair labelalign = dummypair)
    {
        this.label = label == dummystring ? this.label : label;
        this.labeldir = labeldir == dummypair ? this.labeldir : labeldir;
        this.labelalign = labelalign == dummypair ? rotate(90)*dir(this.contour, polar_intersection_time(this.contour, this.center, this.labeldir)) : labelalign;

        return this;
    }
    smooth set_subset_label (int ind = 0, string label = this.subsets[ind].label, pair labeldir = this.subsets[ind].labeldir, pair labelalign = dummypair)
    {
        this.subsets[ind].set_label(label, labeldir, labelalign);

        return this;
    }
    real get_ratio_y_point (real y)
    {
        return (y - ypart(min(this.contour)))/(ypart(max(this.contour)) - ypart(min(this.contour)));
    }
    real get_ratio_x_point (real x)
    {
        return (x - xpart(min(this.contour)))/(xpart(max(this.contour)) - xpart(min(this.contour)));
    }
    real get_point_y_ratio (real y)
    {
        y = y - floor(y);
        return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y);
    }
    real get_point_x_ratio (real x)
    {
        x = x - floor(x);
        return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x);
    }
    void revise_hsectratios ()
    {
        real ymin = ypart(min(this.contour));
        real ymax = ypart(max(this.contour));
        real height = ymax-ymin;
        real xmin = xpart(min(this.contour));
        real xmax = xpart(max(this.contour));
        real length = xmax-xmin;
        real yrealCI = defaultSmCI * height;
        real yrealSD = defaultSmCSD * height;

        path[] contour = (this.contour ^^ sequence(new path(int i){
            return this.holes[i].contour;
        }, this.holes.length));

        real[] yres;

        triple[] ycontour = sequence(new triple (int i){return (ypart(min(contour[i])), ypart(max(contour[i])), (i == 0) ? this.center.x : this.holes[i-1].center.x);}, contour.length);

        int count = 1;

        while (count*1.01*defaultSmCSD < 1)
        {
            yres.push(count*1.01*defaultSmCSD);
            count += 1;
        }

        for (int i = 0; i < yres.length; ++i)
        {
            pair[][] sections = h_cartsections(contour, yres[i], defaultSmCI);

            bool foundsection = false;
            real yreal = get_point_y_ratio(yres[i]);

            for (int j = 0; j < sections.length; ++j)
            {
                real x1 = sections[j][0].x;
                real x2 = sections[j][1].x;

                bool exlude = false;

                for (int k = 0; k < ycontour.length; ++k)
                {
                    if (!inside(x1, x2, ycontour[k].z)) continue;

                    if (abs(yreal - ycontour[k].x) < yrealCI || abs(yreal - ycontour[k].y) < yrealCI || x2-x1 > defaultSmCSTL*length)
                    {
                        exlude = true;
                        break;
                    }
                }

                if (exlude) yres[i] += 2^j;
                else foundsection = true; 
            }

            if (!foundsection)
            {
                yres.delete(i);
                i -= 1;
            }
        }

        this.hsectratios = yres;
    }
    void revise_vsectratios ()
    {
        real xmin = xpart(min(this.contour));
        real xmax = xpart(max(this.contour));
        real length = xmax-xmin;
        real ymin = ypart(min(this.contour));
        real ymax = ypart(max(this.contour));
        real height = ymax-ymin;
        real xrealCI = defaultSmCI * length;
        real xrealSD = defaultSmCSD * length;

        real[] xres;

        path[] contour = (this.contour ^^ sequence(new path(int i){
            return this.holes[i].contour;
        }, this.holes.length));

        triple[] xcontour = sequence(new triple (int i){return (xpart(min(contour[i])), xpart(max(contour[i])), (i == 0) ? this.center.y : this.holes[i-1].center.y);}, contour.length);

        int count = 1;

        while (count*1.01*defaultSmCSD < 1)
        {
            xres.push(count*1.01*defaultSmCSD);
            count += 1;
        }

        for (int i = 0; i < xres.length; ++i)
        {
            pair[][] sections = v_cartsections(contour, xres[i], defaultSmCI);

            bool foundsection = false;
            real xreal = get_point_x_ratio(xres[i]);

            for (int j = 0; j < sections.length; ++j)
            {
                real y1 = sections[j][0].y;
                real y2 = sections[j][1].y;

                bool exlude = false;

                for (int k = 0; k < xcontour.length; ++k)
                {
                    if (!inside(y1, y2, xcontour[k].z)) continue;

                    if (abs(xreal - xcontour[k].x) < xrealCI || abs(xreal - xcontour[k].y) < xrealCI || y2-y1 > defaultSmCSTL*height)
                    {
                        exlude = true;
                        break;
                    }
                }

                if (exlude) xres[i] += 2^j;
                else foundsection = true; 
            }

            if (!foundsection)
            {
                xres.delete(i);
                i -= 1;
            }
        }
        
        this.vsectratios = xres;
    }
    void revise_cartsectratios ()
    {
        this.revise_hsectratios();
        this.revise_vsectratios();
    }
    smooth add_hole (hole H, int ind = this.holes.length, bool unit = true, bool revisecart = true)
    {
        hole Hp = unit ? H.copy().adjust(this.shift, this.scale, this.rotate, this.center) : H;

        real[][] data = Hp.sections;
        real[][] newdata = new real[][];

        pair defaultdir = (Hp.center == this.center) ? (-1,0) : unit(Hp.center - this.center);

        for (int i = 0; i < data.length; ++i)
        {
            newdata.push(new real[] {((data[i][0] == dummynumber) ? (rotate(360*i/data.length)*defaultdir).x : data[i][0]), ((data[i][1] == dummynumber) ? (rotate(360*i/data.length)*defaultdir).y : data[i][1]), ((data[i][2] == dummynumber || data[i][2] <= 0) ? defaultSAB : data[i][2]), ((data[i][3] == dummynumber || data[i][3] <= 0 || ceil(data[i][3]) != data[i][3]) ? defaultSN : ceil(data[i][3])), ((data[i][4] == dummynumber || data[i][4] <= 0 || data[i][4] > 1) ? defaultSR : data[i][4]), ((data[i][5] == dummynumber || data[i][5] <= 0 || ceil(data[i][5]) != data[i][5]) ? defaultSP : (int)data[i][5])});
        }

        this.holes.insert(i = ind, hole(
            contour = Hp.contour,
            center = Hp.center,
            drawsections = Hp.drawsections,
            drawsections_neigh = Hp.drawsections_neigh,
            drawsections_smooth = Hp.drawsections_smooth,
            sections = newdata,
            neighnumber = Hp.neighnumber
        ));

        if (revisecart) this.revise_cartsectratios();
        
        return this;
    }
    smooth remove_hole(int ind)
    {
        this.holes.delete(ind);
        
        return this;
    }
    smooth add_hole_section (int ind, real[] section = {}, bool unit = false)
    {
        while(section.length < 6)
        {
            section.push(dummynumber);
        }

        if (unit && this.rotate != 0)
        {
            pair sectdir = (section[0], section[1]);
            section[0] = xpart(rotate(this.rotate)*sectdir);
            section[1] = ypart(rotate(this.rotate)*sectdir);
        }

        this.holes[ind].sections.push(section);
        
        return this;
    }
    smooth set_hole_section (int ind, int ind2 = 0, real[] section = {}, bool unit = false)
    {
        this.holes[ind].sections.delete(ind2);

        while(section.length < 6)
        {
            section.push(dummynumber);
        }

        if (unit && this.rotate != 0)
        {
            pair sectdir = (section[0], section[1]);
            section[0] = xpart(rotate(this.rotate)*sectdir);
            section[1] = ypart(rotate(this.rotate)*sectdir);
        }

        this.holes[ind].sections.insert(i = ind2, section);
        
        return this;
    }
    smooth remove_hole_section (int ind, int ind2 = 0)
    {
        this.holes[ind].sections.delete(ind2);
        
        return this;
    }
    smooth add_subset (subset s, int ind = this.subsets.length, bool unit = true, bool revisecart = true)
    {
        this.subsets.insert(i = ind, unit ? s.copy().adjust(this.shift, this.scale, this.rotate, this.center) : s.copy());
        
        if (revisecart) this.revise_cartsectratios();

        return this;
    }
    smooth remove_subset (int ind)
    {
        this.subsets.delete(ind);
        
        return this;
    }
    smooth set_vsectratios (real[] vsectratios)
    {
        this.vsectratios = vsectratios;
        
        return this;
    }
    smooth set_hsectratios (real[] hsectratios)
    {
        this.hsectratios = hsectratios;
        
        return this;
    }
    smooth move_hole (int ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.holes[ind].center, bool movesections = false)
    {
        this.holes[ind].move(shift, scale, rotate, point, movesections);
        this.revise_cartsectratios();
        
        return this;
    }
    smooth adjust_hole (int ind, pair shift = (0,0), real scale, real rotate)
    {
        this.holes[ind].adjust(shift, scale, rotate, this.center);
        this.revise_cartsectratios();
        
        return this;
    }
    smooth move_subset (int ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.subsets[ind].center)
    {
        this.subsets[ind].move(shift, scale, rotate, point);
        
        return this;
    }
    smooth adjust_subset (int ind, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        this.subsets[ind].adjust(shift, scale, rotate, this.center);
        
        return this;
    }
    smooth move (pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        this.rotate += rotate;
        this.scale *= scale;
        this.shift += shift;

        this.contour = shift(shift)*srap(scale, rotate, this.center)*this.contour;
        this.center = shift(shift)*this.center;
        this.labeldir = rotate(rotate)*this.labeldir;

        for (int i = 0; i < this.holes.length; ++i)
        {
            this.adjust_hole(i, shift, scale, rotate);
        }

        for (int i = 0; i < this.subsets.length; ++i)
        {
            this.adjust_subset(i, shift, scale, rotate);
        }

        if (rotate != 0)
        {
            for (int i = 0; i < this.holes.length; ++i)
            {
                this.revise_cartsectratios();
            }
        }
        
        return this;
    }

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), string label = "", pair labeldir = W+N, pair labelalign = dummypair, hole[] holes = {}, subset[] subsets = {}, real[] hsectratios = {}, real[] vsectratios = {}, pair shift = (0,0), real scale = 1, real rotate = 0, bool unit = true)
    {
        this.shift = shift;
        this.scale = scale;
        this.rotate = rotate;

        pair pseudocenter = path_middle(contour);

        this.contour = shift(shift)*srap(scale, rotate, center)*((!clockwise(contour)) ? reverse(contour) : contour);
        this.center = shift(shift)*center;

        this.label = label;
        this.labeldir = labeldir;
        this.labelalign = labelalign == dummypair ? rotate(90)*dir(this.contour, polar_intersection_time(this.contour, this.center, this.labeldir)) : labelalign;

        this.holes = new hole[];

        for (int i = 0; i < holes.length; ++i)
        {
            this.add_hole(holes[i], unit, revisecart = false);
        }
        
        for (int i = 0; i < subsets.length; ++i)
        {
            this.add_subset(subsets[i], unit, revisecart = false);
        }

        this.hsectratios = hsectratios;

        if (hsectratios.length == 0) this.revise_hsectratios();

        this.vsectratios = vsectratios;

        if (vsectratios.length == 0) this.revise_vsectratios();
    }

    smooth copy ()
    {
        smooth sm = smooth();

        sm.contour = this.contour;
        sm.center = this.center;
        sm.label = this.label;
        sm.labeldir = this.labeldir;
        sm.labelalign = this.labelalign;

        for (int i = 0; i < this.holes.length; ++i)
        {
            sm.holes.push(this.holes[i].copy());
        }

        for (int i = 0; i < this.subsets.length; ++i)
        {
            sm.subsets.push(this.subsets[i].copy());
        }

        sm.hsectratios = this.hsectratios;
        sm.vsectratios = this.vsectratios;

        sm.shift = this.shift;
        sm.scale = this.scale;
        sm.rotate = this.rotate;

        return sm;
    }
}

smooth samplesmooth (int type = 0, int num = 0)
{
    if (type == 0)
    {
        if(num == 0)
        {
            return smooth(
                contour = defaultCVSP[0],
                hsectratios = new real[] {.5}
            );
        }
        if(num == 1)
        {
            return smooth(
                contour = defaultCCSP[0]
            ); 
        }
        if(num == 2)
        {
            return smooth(
                contour = defaultCCSP[2],
                subsets = new subset[]{
                    subset(
                        contour = defaultCCSP[3],
                        scale = .48,
                        shift = (.18, -.65),
                        labeldir = dir(140)
                    )
                },
                hsectratios = new real[]{.6, .83}
            );
        }
    }
    if (type == 1) 
    {
        if (num == 0)
        {
            return smooth(
                contour = defaultCVSP[1],
                labeldir = (-2,1),
                holes = new hole[]{
                    hole(
                        contour = defaultCVSP[2],
                        sections = new real[][]{
                            new real[] {dummynumber, dummynumber, 270, dummynumber, .35, dummynumber}
                        },
                        shift = (-.65, .25),
                        scale = .5
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = defaultCVSP[3],
                        labeldir = S,
                        shift = (.45,-.45),
                        scale = .43,
                        rotate = 110
                    )
                }
            );
        }
    }
    if(type == 2)
    {
        return smooth(
            contour = defaultCCSP[4],
            holes = new hole[]{
                hole(
                    contour = defaultCVSP[4],
                    sections = new real[][]{
                        new real[]{-2,1.5, 60, 3},
                        new real[]{0, -1, 80, 4}
                    },
                    neighnumber = 1,
                    cartsectratios = (dummynumber, prohibitednumber),
                    shift = (-.5, -.15),
                    scale = .45,
                    rotate = 15
                ),
                hole(
                    contour = defaultCVSP[3],
                    sections = new real[][]{
                        new real[]{dummynumber, dummynumber, 230, 10}
                    },
                    cartsectratios = (dummynumber, .7),
                    shift = (.57,.48),
                    scale = .47,
                    rotate = 17
                )
            }
        );
    }
    if(type == 3)
    {
        return smooth(
            contour = defaultCCSP[5],
            holes = new hole[]{
                hole(
                    contour = defaultCVSP[5],
                    sections = new real[][]{
                        new real[]{3,-1, 140, 7}
                    },
                    shift = (.55,-.15),
                    neighnumber = 1,
                    scale = .37,
                    rotate = -90
                ),
                hole(
                    contour = reverse(ellipse(c = (0,0), a = 1, b = 2)),
                    shift = (-.1,.7),
                    scale = .25
                ),
                hole(
                    contour = defaultCCSP[6],
                    neighnumber = 1,
                    sections = new real[][]{
                        new real[]{-3,-1, 150, 6}
                    },
                    shift = (-.27,-.43),
                    scale = .39,
                    rotate = -15
                )
            }
        );
    }

    return smooth();
}

smooth[] intersection (smooth sm1, smooth sm2, bool keepdata = true, bool intersectsubsets = true, bool round = true, real roundcoeff = defaultRPR)
{
    path[] contours = intersection(sm1.contour, sm2.contour, round = round, roundcoeff = roundcoeff);
    
    if (contours.length == 0) return new smooth[];

    path[] contour1 = sm1.contour ^^ (path[])sm1.holes;
    path[] contour2 = sm2.contour ^^ (path[])sm2.holes;

    hole[] trueholes = concat(sm1.holes, sm2.holes);
    path[] holes = concat(sm1.holes, sm2.holes);
    bool[] htaken = array(holes.length, false);
    int[] hrefs = sequence(holes.length);
    int[] hsmrefs = array(holes.length, -1);

    for (int i = 0; i < holes.length; ++i)
    {
        if (htaken[i]) continue;

        for (int j = i+1; j < holes.length; ++j)
        {
            if(do_intersect(holes[i], holes[j]) && !htaken[j])
            {
                holes[i] = union(holes[i], holes[j], round = round, roundcoeff = roundcoeff)[0];//
                htaken[j] = true;
                hrefs[i] = -1;
                j = i;
            }
        }

        if (do_intersect(holes[i], sm1.contour) || do_intersect(holes[i], sm2.contour)) continue;

        for (int j = 0; j < contours.length; ++j)
        {
            if (inside_path(contours[j], holes[i]))
            {
                hsmrefs[i] = j;
                break;
            }
        }
    }

    subset[] subsets = concat(sm1.subsets, sm2.subsets);

    bool[] staken = array(subsets.length, false);

    smooth[] res;

    for (int i = 0; i < contours.length; ++i)
    {
        smooth cursm = smooth(
            contour = contours[i],
            label = (length(sm1.label) > 0 && length(sm2.label) > 0) ? (sm1.label+"$\cap$"+sm2.label) : ""
        );

        for (int j = 0; j < holes.length; ++j)
        {
            if (htaken[j]) continue;
            if (hsmrefs[j] == -1)
            {
                cursm.contour = difference(cursm.contour, holes[j], round = round, roundcoeff = roundcoeff)[0];
            }
            else
            {
                cursm.add_hole((hrefs[j] == -1 || !keepdata) ? hole(contour = holes[j]) : trueholes[hrefs[j]]);
            }
        }

        int curboundindex = -1;

        for (int j = 0; j < subsets.length; ++j)
        {
            if (staken[j]) continue;

            bool contintersect = do_intersect(subsets[j], concat(new path[]{contours[i]}, cursm.holes));
            bool continside = inside_path(contours[i], subsets[j]);

            if (!contintersect && !continside) continue;

            bool firstsm = (j < sm1.subsets.length);

            if (j == sm1.subsets.length) curboundindex = cursm.subsets.length;

            if (!contintersect && continside)
            {
                cursm.subsets.push(subsets[j]);
                staken[j] = true;
            }
            else
            {
                path[] cursbcontours = intersection(subsets[j], contours[i], holes = cursm.holes, round = round, roundcoeff = roundcoeff);

                for (int k = 0; k < cursbcontours.length; ++k)
                {
                    cursm.add_subset(subset(
                        contour = cursbcontours[k],
                        label = (length(subsets[j].label) == 0) ? '' : ((length(firstsm ? sm2.label : sm1.label) == 0) ? subsets[j].label : (subsets[j].label + '$\cap$' + (firstsm ? sm2.label : sm1.label))),
                        labeldir = subsets[j].labeldir
                    ));
                }
            }
        }

        if (intersectsubsets)
        {
            int cursize = cursm.subsets.length;

            for (int j = 0; j < cursize; ++j)
            {
                for (int k = (j < curboundindex ? curboundindex : 0); k < (j < curboundindex ? cursize : curboundindex); ++k)
                {
                    path[] cursbcontours = intersection(cursm.subsets[j], cursm.subsets[k], round = round, roundcoeff = roundcoeff);

                    for (int l = 0; l < cursbcontours.length; ++l)
                    {
                        cursm.add_subset(subset(
                            contour = cursbcontours[l],
                            label = (length(cursm.subsets[j].label) == 0 || length(cursm.subsets[k].label) == 0) ? '' : cursm.subsets[j].label + '$\cap$' + cursm.subsets[k].label,
                            labeldir = unit(rotate(90)*(cursm.subsets[j].center - cursm.subsets[k].center))
                        ));
                    }
                }
            }
        }

        res.push(cursm);
    }

    return res;
}

//smooth[] union (smooth sm1, smooth sm2, bool keepdata = true)
//{
//    if (!do_intersect(sm1.contour, sm2.contour) && !inside_path(sm1.contour, sm2.contour) && !inside_path(sm2.contour, sm1.contour)) return new smooth[]{sm1, sm2};
//
//    path[] union = union(sm1.contour, sm2.contour);
//
//    path contour;
//
//    for (int i = 0; i < union.length; ++i)
//    {
//     if (windingnumber(union[i], inside(union[i])) < 0)
//    }
//
//    smooth res = smooth(contour = contour);
//
//    for (int i = 0; i < sm1.holes.length; ++i)
//    {
//
//    }
//}

smooth rn (int n, pair labeldir = (1,1), pair shift = (0,0), real scale = 1, real rotate = 0)
{
    return smooth(contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle, label = "$\mathbb{R}^" + ((n == -1) ? "n" : (string)n)  + "$", labeldir = (1,1), labelalign = (-1,-1.5), hsectratios = new real[]{.5}, vsectratios = new real[]{.5}, shift = shift, scale = scale, rotate = rotate);
}


// ------------------------------------------------------------ //
// From here the real fun begins. This is the collection of the //
// drawing functions provided by the module.                    //
// ------------------------------------------------------------ //
// keyword: $smooth

import animate;
import animation;
import graph;

void draw_sections (picture pic, pair[][] sections, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen, string mode)
{
    for (int k = 0; k < sections.length; ++k)
    {
        if(explain)
        {
            dot(pic, sections[k][0], blue+2.5*scale);
            dot(pic, sections[k][1], blue+2*scale);
            draw(pic, sections[k][0] -- sections[k][1], green + .4);
            draw(sections[k][0]-defaultSmEDL*scale*sections[k][2] -- sections[k][0]+defaultSmEDL*scale*sections[k][2], deepgreen+.4, arrow = Arrow(SimpleHead));
            draw(sections[k][1]-defaultSmEDL*scale*sections[k][3] -- sections[k][1]+defaultSmEDL*scale*sections[k][3], deepgreen+.4, arrow = Arrow(SimpleHead));
        }

        path[] section = tangent_section_ellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir, (mode == "naive"));

        draw(pic, section[0], sectionpen);

        if (section.length > 1 && drawdashes)
        {
            draw(pic, section[1], dashpen+dashed);
        }

        if(explain) dot(pic, point(section[0], arctime(section[0], arclength(section[0])/2)), red+1.5);
    }
}

void draw_hole_sections (picture pic, hole hl, hole hlp, pair viewdir, bool drawdashes, bool explain, real scale, string mode = "naive", pen sectionpen, pen dashpen)
{
    if (!hl.drawsections_neigh || !hlp.drawsections_neigh) return;

    int n = dummynumber;
    if (hl.neighnumber == dummynumber && hlp.neighnumber == dummynumber) n = defaultNN;
    if (n == dummynumber && (hl.neighnumber == dummynumber || hlp.neighnumber == dummynumber))
    {
        n = max(hl.neighnumber, hlp.neighnumber);
    }
    if (n == dummynumber) n = min(hl.neighnumber, hlp.neighnumber);

    path curhlcontour = turn(hl.contour, hl.center, hl.center-hlp.center);
    path curhlpcontour = turn(reverse(hlp.contour), hlp.center, hlp.center-hl.center);

    pair hltimes = range(curhlcontour, hl.center, hlp.center-hl.center, defaultSAS);
    pair hlptimes = range(curhlpcontour, hlp.center, hl.center-hlp.center, defaultSAS, orientation = -1);

    if (explain)
    {
        draw(subpath(curhlcontour, hltimes.x, hltimes.y), lightred+1);
        draw(subpath(curhlpcontour, hlptimes.x, hlptimes.y), lightred+1);
        draw(pic, hl.center--point(curhlcontour, hltimes.x), yellow+.3);
        draw(pic, hl.center--point(curhlcontour, hltimes.y), yellow+.3);
        draw(pic, hlp.center--point(curhlpcontour, hlptimes.x), yellow+.3);
        draw(pic, hlp.center--point(curhlpcontour, hlptimes.y), yellow+.3);
        dot(pic, point(curhlcontour, hltimes.x), green+2);
        dot(pic, point(curhlcontour, hltimes.y), green+2);
        dot(pic, point(curhlpcontour, hlptimes.x), green+2);
        dot(pic, point(curhlpcontour, hlptimes.y), green+2);

        draw(arc(hl.center, hl.center + defaultSmAR * scale * unit(point(curhlcontour, hltimes.x) - hl.center), point(curhlcontour, hltimes.y), direction = CW), blue+.4);

        draw(arc(hlp.center, hlp.center + defaultSmAR * scale * unit(point(curhlpcontour, hlptimes.x) - hlp.center), point(curhlpcontour, hlptimes.y), direction = CCW), blue+.4);
    }

    pair[][] sections = new pair[][];
    
    if (mode == "free")
    {
        sections = free_sect_positions(curhlcontour, curhlpcontour, hltimes, hlptimes, n, defaultSR, defaultSP);
    }
    if (mode == "naive")
    {
        sections = naive_sect_positions(curhlcontour, subpath(curhlpcontour, hlptimes.x, hlptimes.y), hltimes, defaultSP*n, defaultSP);
    }

    draw_sections(pic, sections, viewdir, drawdashes, explain, scale, sectionpen, dashpen, mode);
}

void draw_horizontal_sections (picture pic, path[] g, real y, real ignore, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen)
{
    draw_sections(pic, h_cartsections(g, y, ignore), viewdir, drawdashes, explain, scale, sectionpen, dashpen, "naive");
}

void draw_vertical_sections (picture pic, path[] g, real x, real ignore, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen)
{
    draw_sections(pic, v_cartsections(g, x, ignore), viewdir, drawdashes, explain, scale, sectionpen, dashpen, "naive");
}

void draw (picture pic = currentpicture, smooth s, pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+grey, pair viewdir = (0,0), string mode = defaultSmMode, bool explain = defaultSmE, bool drawdashes = defaultSmDD, real margin = defaultSmM)
{
    viewdir = defaultSmVS*viewdir;

    xaxis(min(s.contour).x-margin, max(s.contour).x+margin, invisible);
    yaxis(min(s.contour).y-margin, max(s.contour).y+margin, invisible);

    path[] contour = (s.contour ^^ sequence(new path(int i){
        return reverse(s.holes[i].contour);
    }, s.holes.length));

    filldraw(pic = pic, contour, fillpen = smoothpen, drawpen = contourpen);

    if(s.label != "") label(s.label, polar_intersection(s.contour, s.center, s.labeldir), align = s.labelalign);

    if (mode == 'free' || mode == 'naive')
    {
        bool[][] holeConnected = new bool[s.holes.length][s.holes.length];

        for (int i = 0; i < s.holes.length; ++i)
        {
            for (int j = 0; j < s.holes.length; ++j)
            {
                holeConnected[i][j] = false;
            }

            holeConnected[i][i] = true;
        }

        for (int i = 0; i < s.holes.length; ++i)
        {
            hole hl = s.holes[i];

            if (!hl.drawsections) continue;

            if (hl.drawsections_smooth)
            {
                for (int j = 0; j < hl.sections.length; ++j)
                {
                    real[] data = hl.sections[j];
                    pair dir = (data[0], data[1]);
                    path curscontour = turn(s.contour, hl.center, -dir);
                    path curhlcontour = turn(hl.contour, hl.center, -dir);
                    real angle = data[2];
                    int n = ceil(data[3]);
                    real ratio = data[4];
                    int p = ceil(data[5]);

                    if (explain)
                    {
                        pair stimes = range(curscontour, hl.center, dir, angle);
                        pair hltimes = range(curhlcontour, hl.center, dir, angle);

                        draw(subpath(curscontour, stimes.x, stimes.y), lightred+1);    
                        draw(subpath(curhlcontour, hltimes.x, hltimes.y), lightred+1);

                        draw(pic = pic, hl.center -- point(curscontour, stimes.x), yellow + .3);
                        draw(pic = pic, hl.center -- point(curscontour, stimes.y), yellow + .3);

                        dot(pic, point(curhlcontour, range(curhlcontour, hl.center, dir, angle).x), green+2);
                        dot(pic, point(curhlcontour, range(curhlcontour, hl.center, dir, angle).y), green+2);
                        dot(pic, point(curscontour, range(curscontour, hl.center, dir, angle).x), green+2);
                        dot(pic, point(curscontour, range(curscontour, hl.center, dir, angle).y), green+2);

                        draw(arc(hl.center, hl.center + defaultSmAR * s.scale * unit(point(curhlcontour, range(curhlcontour, hl.center, dir, angle).x) - hl.center), point(curhlcontour, range(curhlcontour, hl.center, dir, angle).y), direction = CW), blue+.4);
                    }

                    pair[][] sections = new pair[][];
                    
                    if (mode == "free")
                    {
                        sections = free_sect_positions(curhlcontour, curscontour, range(curhlcontour, hl.center, dir, angle), range(curscontour, hl.center, dir, angle), n, ratio, p);
                    }
                    if (mode == "naive")
                    {
                        sections = naive_sect_positions(curhlcontour, curscontour, range(curhlcontour, hl.center, dir, angle), n*p, p);
                    }

                    draw_sections(pic, sections, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen, mode);
                }
            }
            else
            {
                if(hl.drawsections_neigh)
                {   
                    for (int j = 0; j < s.holes.length; ++j)
                    {
                        if (j == i || holeConnected[i][j] || holeConnected[j][i]) continue;

                        draw_hole_sections(pic, hl, s.holes[j], viewdir, drawdashes, explain, s.scale, mode, sectionpen, dashpen);

                        holeConnected[i][j] = true;
                        holeConnected[j][i] = true;
                    }
                }

                continue;
            }

            if(!holeConnected[i][(i+1)%s.holes.length] && !holeConnected[(i+1)%s.holes.length][i])
            {
                draw_hole_sections(pic, hl, s.holes[(i+1)%s.holes.length], viewdir, drawdashes, explain, s.scale, mode, sectionpen, dashpen);
            }
        }
    }

    if (mode == 'cart')
    {
        for (int i = 0; i < s.hsectratios.length; ++i)
        {
            draw_horizontal_sections(pic, contour, s.hsectratios[i], defaultSmCI, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen);
        }

        for (int i = 0; i < s.vsectratios.length; ++i)
        {
            draw_vertical_sections(pic, contour, s.vsectratios[i], defaultSmCI, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen);
        }
    }

    for (int i = 0; i < s.subsets.length; ++i)
    {
        subset sb = s.subsets[i];

        filldraw(pic = pic, sb.contour, fillpen = subsetpen, drawpen = subsetcontourpen);

        label(pic, sb.label, polar_intersection(sb.contour, sb.center, sb.labeldir), align = sb.labelalign);

        if(explain) dot(sb.center, red+3);
    }

    if(explain) draw(pic = pic, s.center -- s.center+unit(viewdir)*s.scale, purple+.5, arrow = Arrow(SimpleHead));
    
    if(explain)
    {
        dot(s.center, red+3);

        for (int i = 0; i < s.holes.length; ++i)
        {
            dot(s.holes[i].center, red+2.5);
        }
    }
}

smooth[] draw_intersection (picture pic = currentpicture, smooth sm1, smooth sm2, bool keepdata = true, pair shift = (0,0), pen ghostpen = mediumgrey, string label = dummystring, pair labeldir = dummypair, pair labelalign = dummypair, pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+grey, pair viewdir = (0,0), string mode = defaultSmMode, bool explain = defaultSmE, bool drawdashes = defaultSmDD, real margin = defaultSmM)
{
    smooth smp1 = sm1.copy().move(shift = shift);
    smooth smp2 = sm2.copy().move(shift = shift);
    
    smooth[] res = intersection(smp1, smp2, keepdata);

    if(res.length == 0) return res;

    res[0].set_label(label, labeldir, labelalign);

    smp1.subsets.delete();
    smp2.subsets.delete();

    draw(pic, smp1, contourpen = ghostpen, smoothpen = invisible, mode = "2d", margin = margin);
    draw(pic, smp2, contourpen = ghostpen, smoothpen = invisible, mode = "2d", margin = margin);

    for (int i = 0; i < res.length; ++i)
    {
        draw(pic, res[i], contourpen = contourpen, smoothpen = smoothpen, subsetcontourpen = subsetcontourpen, subsetpen = subsetpen, sectionpen = sectionpen, dashpen = dashpen, viewdir = viewdir, mode = mode, explain = explain, drawdashes = drawdashes);
    }

    return res;
}

void draw_arrow (picture pic = currentpicture, smooth s1, smooth s2, int ind1 = -1, int ind2 = -1, Label L = "", pen p = currentpen, pen ovpen1 = defaultSmP, pen ovpen2 = defaultSmP, pen bgpen = defaultBgC, real curve = 0, arrowbar arrow = Arrow(SimpleHead), bool overlap = false, real timemargin = defaultATM)
{
    path g1 = (ind1 == -1) ? s1.contour : s1.subsets[ind1].contour;
    path g2 = (ind2 == -1) ? s2.contour : s2.subsets[ind2].contour;

    path g = curved_path((ind1 == -1) ? s1.center : s1.subsets[ind1].center, (ind2 == -1) ? s2.center : s2.subsets[ind2].center, curve = curve);

    real[] intersect1 = intersect(g, g1);
    real[] intersect2 = intersect(g, g2);

    real time1 = (intersect1.length > 0) ? intersect1[0]+timemargin : timemargin;
    real time2 = (intersect2.length > 0) ? intersect2[0]-timemargin : length(g)-timemargin;

    path gs = subpath(g, time1, time2);

    if(overlap && intersect1.length > 0)
    {
        real ovlength = (arclength(s1.contour)+arclength(s2.contour))/2*defaultOL;

        path[] get_paths (path[] curpaths, int orient)
        {
            path[] res = new path[];
            
            for (int j = 0; j < curpaths.length; ++j)
            {
                path curpath = curpaths[j];

                real[][] ovtimes = intersections(gs, curpath);

                for (int i = 0; i < ovtimes.length; ++i)
                {
                    real ovtime = ovtimes[i][1];

                    int sign = (-1)^(i + ovtimes.length + 1 + orient);

                    real sang = abs(cross(dir(curpath, ovtime), dir(gs, intersect(gs, curpath)[0])));

                    if(sang == 0) continue;

                    real t1 = arctime(curpath, sub_arclength(curpath, 0, ovtime) - sign*ovlength/sang/2);
                    real t2 = arctime(curpath, sub_arclength(curpath, 0, ovtime) + sign*ovlength/sang/2);

                    res.push(subpath(curpath, t1, t2));
                }
            }

            return res;
        }

        void fill_overlap (path p1, path p2, pen ovpen, bool begin = false, bool end = false)
        {
            real curvep1 = curve * (dist(point(p1, 0), point(p2, 0)) / dist(point(gs, 0), point(gs, length(gs))));
            real curvep2 = curve * (dist(point(p1, length(p1)), point(p2, length(p2))) / dist(point(gs, 0), point(gs, length(gs))));

            path fillpath = reverse(p1)--curved_path(point(p1,0), point(p2,0), curve = curvep1)--p2--curved_path(point(p2, length(p2)), point(p1, length(p1)), curve = -curvep2)--cycle;

            fill(pic = pic, fillpath, ovpen);

            if(!begin) draw(p1, linewidth(p)+.5 + bgpen);
            if(!end) draw(p2, linewidth(p)+.5 + bgpen);
        }

        if (ind1 > -1)
        {
            path[] contour1 = s1.contour ^^ sequence(new path(int i){return s1.holes[i].contour;}, s1.holes.length) ^^ sequence(new path(int i){return s1.subsets[i].contour;}, s1.subsets.length);

            path[] ovpaths1 = new path[];

            ovpaths1.push((point(gs,0)+ovlength/2*(rotate(90)*dir(gs,0)))--(point(gs,0)+ovlength/2*(rotate(-90)*dir(gs,0))));

            ovpaths1.append(sort(get_paths(contour1, 0), new bool(path a, path b){return (sub_arclength(gs, 0, intersect(a, gs)[1]) < sub_arclength(gs, 0, intersect(b, gs)[1]));}));

            for (int i = 0; i < ovpaths1.length-1; i += 2)
            {
                fill_overlap(ovpaths1[i], ovpaths1[i+1], ovpen1, begin = (i == 0));
            }
        }

        if (ind1 > -1)
        {
            path[] contour2 = s2.contour ^^ sequence(new path(int i){return s2.holes[i].contour;}, s2.holes.length) ^^ sequence(new path(int i){return s2.subsets[i].contour;}, s2.subsets.length);

            path[] ovpaths2 = new path[];

            ovpaths2.append(sort(get_paths(contour2, 1), new bool(path a, path b){return (sub_arclength(gs, 0, intersect(a, gs)[1]) < sub_arclength(gs, 0, intersect(b, gs)[1]));}));

            ovpaths2.push((point(gs,length(gs))+ovlength/2*(rotate(90)*dir(gs,length(gs))))--(point(gs,length(gs))+ovlength/2*(rotate(-90)*dir(gs,length(gs)))));
            
            for (int i = 0; i < ovpaths2.length-1; i += 2)
            {
                fill_overlap(ovpaths2[i], ovpaths2[i+1], ovpen2, end = (i == ovpaths2.length-2));
            }
        }
    }

    draw(pic = pic, gs, p = p, arrow = arrow, L = L);
}

void compile (animation a, int seconds = 5, string format = "gif")
{
    int frames = a.pictures.length;

    if(format == "gif") a.movie(loops = 0, delay = 1000*seconds/frames);
    else a.pdf(delay = 1000*seconds/frames);
}

animation transform (smooth sm, string mode = "free", pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+opacity(.5), pair shift = (0,0), real scale = 1, real rotate = 0, bool drawdashes = defaultSmDD, bool explain = defaultSmE, real margin = defaultSmM, pair viewdir = (0,0), int frames = 10)
{
    animation a;

    smooth smp = sm.copy();

    int n = ceil(.5*frames);

    picture[] reverse;

    for (int i = 0; i < n; ++i)
    {
        save();
        smp.move(shift = shift/n, scale = scale^(1/n), rotate = rotate/n);
        draw(smp, mode = mode, contourpen = contourpen, smoothpen = smoothpen, subsetcontourpen = subsetcontourpen, subsetpen = subsetpen, sectionpen = sectionpen, dashpen = dashpen, viewdir = viewdir, drawdashes = drawdashes, explain = explain, margin = margin);
        a.add(currentpicture);
        reverse.push(currentpicture);
        restore();
    }

    while(reverse.length != 0) a.add(reverse.pop());

    return a;
}

animation turn_around (smooth sm, string mode = "free", pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+opacity(.5), bool drawdashes = defaultSmDD, bool explain = defaultSmE, real margin = defaultSmM, pair viewdir1 = dir(180 - defaultTAVAN), pair viewdir2 = dir(defaultTAVAN), real rotate = defaultTARN, int frames = 10)
{
    animation a;

    smooth smp = sm.copy();

    int n = ceil(.5*frames);

    picture[] reverse;

    if (degrees(viewdir1) < degrees(viewdir2)) rotate = -rotate;

    for (int i = 0; i < n; ++i)
    {
        save();
        smp.move(rotate = rotate/n);
        draw(smp, mode = mode, contourpen = contourpen, smoothpen = smoothpen, subsetcontourpen = subsetcontourpen, subsetpen = subsetpen, sectionpen = sectionpen, dashpen = dashpen, viewdir = ((n-i)/n*viewdir1 + i/n*viewdir2), drawdashes = drawdashes, explain = explain, margin = margin);
        a.add(currentpicture);
        reverse.push(currentpicture);
        restore();
    }

    while(reverse.length != 0) a.add(reverse.pop());

    return a;
}
