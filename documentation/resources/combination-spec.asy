include common;
size(4cm);

real ys = 3;
real ang = 40;
pair sh = (4,0);

// path p = rotate(ang) * yscale(ys) * unitcircle;
// path q = rotate(-ang) * yscale(ys) * unitcircle;
path p = shift((-.5,0)) * unitcircle;
path q = shift((.5,0)) * unitcircle;

draw(p ^^ q, grey + dashed);

save();

filldraw(difference(p, q), fillpen = lightgrey, drawpen = linewidth(.7));
shipout(prefix = "combination-difference");
// p = shift(sh) * p; q = shift(sh) * q;

restore();
save();

draw(p ^^ q, grey + dashed);
filldraw(symmetric(p, q), fillpen = lightgrey, drawpen = linewidth(.7));
shipout(prefix = "combination-symmetric");
// p = shift(sh) * p; q = shift(sh) * q;

restore();
save();

draw(p ^^ q, grey + dashed);
filldraw(intersection(p, q), fillpen = lightgrey, drawpen = linewidth(.7));
shipout(prefix = "combination-intersection");
// p = shift(sh) * p; q = shift(sh) * q;

restore();

draw(p ^^ q, grey + dashed);
filldraw(union(p, q), fillpen = lightgrey, drawpen = linewidth(.7));
shipout(prefix = "combination-union");

exit();
