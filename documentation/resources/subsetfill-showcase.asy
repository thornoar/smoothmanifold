include common;
size(3.5cm);

defaultpen(1pt);

smooth sm = smooth(
    contour = unitcircle
).addsubsets(
    scale(.8)*unitcircle,
    scale(.6)*unitcircle,
    scale(.4)*unitcircle,
    scale(.2)*unitcircle
);

draw(sm, dpar(
    subsetcontourpens = new pen[]{red, green, blue},
    subsetfill = new pen[]{cyan, magenta, yellow}
));
