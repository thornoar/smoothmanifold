include common;

size(8cm);

real ys = 3;
real ang = 40;
pair sh = (0,-5.5);

path p = rotate(ang) * yscale(ys) * unitcircle;
path q = rotate(-ang) * yscale(ys) * unitcircle;
draw(p ^^ q, grey + dashed);
filldraw(
    combination(p, q, 1, false, 0),
    drawpen = linewidth(.7),
    fillpen = lightgrey
);
p = shift(sh) * p; q = shift(sh) * q;
draw(p ^^ q, grey + dashed);
filldraw(
    combination(p, q, 1, true, .04),
    drawpen = linewidth(.7),
    fillpen = lightgrey
);
