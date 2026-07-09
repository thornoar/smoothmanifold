include common;

size(7cm);
// path g = (0,.7){(4,1)} .. (1,1.3) .. (2,1) .. (3,1.1);
// path h = (-.1,0) .. (1,-.1) .. (2.1,.1) .. (3.2,.1);
path g = (0,1) .. (2,1.1) .. (3,.7);
path h = (0,0) .. (1,-.5) .. (3,-.2);

draw(g, L = Label("\texttt{g}", position = EndPoint, align = E));
draw(h, L = Label("\texttt{h}", position = EndPoint, align = E));

int n = 1;
real r = 0.3;
int p = 10;

pair[] pres;

real[] gtimes = {.1,1.8};
real[] htimes = {.2,1.9};

for (int i = 0; i < 2*n; i += 2)
{
    fill(subpath(h, htimes[i], htimes[i+1]) -- subpath(g, gtimes[i+1],
    gtimes[i]) -- cycle, paleblue);
    draw(subpath(g, gtimes[i], gtimes[i+1]), blue + linewidth(1pt));
    draw(subpath(h, htimes[i], htimes[i+1]), blue + linewidth(1pt));
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

        draw(point(g, curgtime) -- point(h, curhtime), red);
        dot(point(g, curgtime), red + linewidth(2pt));
        dot(point(h, curhtime), red + linewidth(2pt));
        label((string)gi, point(g, curgtime), align = rotate(90)* 1 * dir(g, curgtime));
        label((string)hi, point(h, curhtime), align = rotate(-90)* 1 * dir(h, curhtime));

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

    draw(point(g, optgtime) -- point(h, opthtime), deepgreen +
    linewidth(1pt));
    dot(point(g, optgtime), deepgreen + linewidth(3.5pt));
    dot(point(h, opthtime), deepgreen + linewidth(3.5pt));

    pres.push((optgtime, opthtime));
}

// real rp = r/(1-r);
// real gy = arclength(g)/(n*rp + n - 1);
// real gx = rp*gy;
// real hy = arclength(h)/(n*rp + n - 1);
// real hx = rp*hy;
// for (int i = 0; i < n; ++i)
// {
//     gtimes.push(arctime(g, i*(gx+gy)));
//     gtimes.push(arctime(g, i*(gx+gy)+gx));
// }
// for (int i = 0; i < n; ++i)
// {
//     htimes.push(arctime(h, i*(hx+hy)));
//     htimes.push(arctime(h, i*(hx+hy)+hx));
// }
//
// for (int i = 0; i < 2*n; i += 2)
// {
//     fill(subpath(h, htimes[i], htimes[i+1]) -- subpath(g, gtimes[i+1],
//     gtimes[i]) -- cycle, paleblue);
//     draw(subpath(g, gtimes[i], gtimes[i+1]), blue + linewidth(1pt));
//     draw(subpath(h, htimes[i], htimes[i+1]), blue + linewidth(1pt));
// }
