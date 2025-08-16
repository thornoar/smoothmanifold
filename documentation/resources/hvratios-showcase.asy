include common;
size(6cm);

import contour;
real w = 1.5, h = 1;
real f (real x, real y) { return (x/w)^4 + (y/h)^4 - 1; }
path cntr = contour(f, (-2,-2), (2,2), new real[]{0})[0][0];
smooth sm = smooth(
    contour = cntr,
    hratios = new real[] {.15, .5},
    vratios = new real[] {.2, .6, .9}
);

draw(sm, dpar(mode = cartesian, viewdir = .7*dir(45)));

real sep = .2;

for (real r : sm.hratios) {
    real tr = 2 * h * r - h;
    pair p = point(cntr, intersect(cntr, (2*w,tr) -- (0,tr))[0]);
    draw(p -- (-w - sep, tr), blue + dashed, L = Label("\texttt{"+(string)r+"}", position = EndPoint, align = 1.5*W));
}
for (real r : sm.vratios) {
    real tr = 2 * w * r - w;
    pair p = point(cntr, intersect(cntr, (tr, 0) -- (tr, 2*h))[0]);
    draw(p -- (tr, -h - sep), red + dashed, L = Label("\texttt{"+(string)r+"}", position = EndPoint, align = 1.5*S));
}
