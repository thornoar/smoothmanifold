include common;
size(3.5cm);

defaultpen(1pt);

smooth sm = smooth(
    contour = ucircle
).addsubsets(
    scale(.8)*ucircle,
    scale(.6)*ucircle,
    scale(.4)*ucircle,
    scale(.2)*ucircle
);

draw(sm, dpar(
    subsetcontourpens = new pen[]{red, green, blue},
    subsetfill = new pen[]{cyan, magenta, yellow}
));
