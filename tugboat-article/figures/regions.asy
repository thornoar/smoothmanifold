include common;

size(7cm);
path g = (0,.7){(4,1)} .. (1,1.3) .. (2,1) .. (3,1.1);
path h = (-.1,0) .. (1,-.1) .. (2.1,.1) .. (3.2,.1);

draw(g, grey, L = Label("\texttt{g}", black, position = EndPoint, align = 2*E));
draw(h, grey, L = Label("\texttt{h}", black, position = EndPoint, align = 2*E));

int n = 5;
real r = 0.3;
int p = 20;

pair[] pres;

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
    fill(subpath(h, htimes[i], htimes[i+1]) -- subpath(g, gtimes[i+1],
    gtimes[i]) -- cycle, gray(.8));
    draw(subpath(g, gtimes[i], gtimes[i+1]), black + linewidth(1pt));
    draw(subpath(h, htimes[i], htimes[i+1]), black + linewidth(1pt));
}
