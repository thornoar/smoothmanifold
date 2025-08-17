include common;
size(5cm);

path g = wavypath(r(2,4,3,1,2,3,2));
draw(g);

shaderegion(
    g,
    angle = -20,
    density = .2,
    mar = .4,
    p = red
);
