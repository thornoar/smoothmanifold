// This is an additional file with some useful path-dealing methods.

real defaultBSP = .0001;
real defaultNaP = .1;
bool defaultUBS = false;
real defaultCLB = .0000001;
real defaultGLB = .01;
real defaultSGUB = .55;
real defaultSpCh = .65;

import math;

path ucircle = reverse(unitcircle);

path[] roundsamplepath = new path[]{
    ucircle,
    scale(.4)*shift(-.4,.3)*((-3,0)..(-1,2)..(1.5, 1)..(3,-2.5)..(-1,-2)..cycle),
    scale(.5)*shift(-.8,-.4)*((-1,0)..(0,2.1)..(1.8,-1.5)..cycle),
    rotate(-100)*scale(.29)*shift(1,-1)*((-5,0)..(1,3.5)..(2,-1.9)..(-1,-1.8)..cycle),
    scale(.54)*shift(-.9,.4)*((-1.5,0)..(0,1)..(3,-1)..(-1,-1)..cycle),
    scale(.47)*shift(-.4,.2)*((-2,0)..(-.3, 2)..(0, -2.5)..(-1.3, -1.3).. cycle),
    (0.890573,-0.36047)..controls (-0.148296,-1.45705) and (-1.29345,-1.23691)..(-0.996593,0.106021)..controls (-0.669702,1.58481) and (2.03559,0.848164)..cycle,
    (-0.614919,1.31465)..controls (-0.614919,1.31465) and (-0.614919,1.31465)..(-0.614919,1.31465)..controls (-0.614919,1.31465) and (-0.614919,1.31465)..cycle,
    (0.989525,-0.664395)..controls (-0.155497,-1.61858) and (-1.40332,0.329701)..(-0.862301,0.79162)..controls (0.346334,1.82355) and (1.39766,-0.324279)..cycle,
    (0.28979,-0.834028)..controls (0.093337,-0.908653) and (-1.20138,-1.95019)..(-1.15209,0.0777484)..controls (-1.10261,2.11334) and (3.02512,0.204973)..cycle,
    (1.01073,-0.409946)..controls (0.812824,-1.99319) and (-2.2123,-0.523035)..(-0.897641,0.36047)..controls (0.779873,1.48783) and (1.20823,1.17008)..cycle,
    (0.636123,-0.975389)..controls (-0.853465,-1.50787) and (-1.37827,0.219109)..(-0.770416,0.961253)..controls (-0.154452,1.7133) and (2.19816,-0.417014)..cycle,
    (0.805756,0.918845)..controls (1.7034,-0.664395) and (-0.374882,-1.93278)..(-0.890573,-0.742144)..controls (-1.3712,0.367538) and (0.34086,1.73882)..cycle,
    (0.572511,-0.925913)..controls (-1.47015,-1.5479) and (-1.32586,0.925729)..(-0.28979,1.00366)..controls (1.30759,1.12382) and (1.65924,-0.595004)..cycle
};

path[] beansamplepath = new path[]{
    scale(.2)*shift(0, -1)*((-4.5,1)..(-2.3,7.5)..(2,2.8)..(5.6,1)..(2,-4)..(-3,-2.5)..cycle),
    (0.523035,-1.10261)..controls (-2.62474,-1.37362) and (0.932069,3.11139)..(0.558375,0.388742)..controls (0.508899,0.0282721) and (1.59031,-1.01073)..cycle,
    rotate(-90)*scale(.7)*shift(-.5, 0)*((-1.5, 0)..(-.7,.7)..(0, .4)..(1.5, 1.3)..(2.4, .3)..(1.3, -1)..(.1, -.8)..(-.7, -.7)..cycle),
    rotate(-90)*scale(.37)*shift(-3,-2)*((0,0)..(1,2)..(3,5)..(2,-1)..cycle),
    scale(.27)*((-5,0)..(-1,2)..(1.5, 5)..(1,-2.5)..(-1,-3)..cycle),
    scale(.23)*shift(1,0)*((-4,1)..(-1,6)..(1,2.5)..(3.5,1)..(2,-3)..(-4.7,-2.8)..cycle),
    scale(.3)*shift(-.8,-.8)*((-2,0)..(0,4)..(1.8,2)..(4,0)..(0,-2)..cycle)
};

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

bool inside(real a, real b, real c)
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

    return subpath(g, n, length(g))..subpath(g, 0, n)..cycle;
}

path reorient (path g, real time)
{
    return subpath(g, time, length(g))..subpath(g, 0, time)..cycle;
}

path turn (path g, pair a, pair b)
{
    return reorient(g, polar_intersection_time(g, a, b));
}

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

        if(intersect(line1, get_ellipse(c1, r2)).length == 0){l1 = c1;}
        else {r1 = c1;}

        if(intersect(line2, get_ellipse(r1, c2)).length == 0){l2 = c2;}
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

void draw_overlap (picture pic=currentpicture, Label L="", path g, align align = NoAlign, pen p = currentpen, arrowbar arrow = None, arrowbar bar = None, margin margin = NoMargin, Label legend = "", marker marker = nomarker, pen fillpen = white+linewidth(8pt))
{
    draw(pic = pic, g = g, align = align, p = fillpen, margin = margin);

    draw(pic = pic, L = L, g = g, align = align, p = p, arrow = arrow, bar = bar, margin = margin, legend = legend, marker = marker);
}