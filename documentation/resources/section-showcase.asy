include common;
size(5cm);
// defaultpen(.7pt);
config.help.arcratio = .3;
config.help.arrowlength = -1;

smooth sm = smooth(
    contour = ucircle
).addhole(
    ucircle, scale = .5,
    sections = new real[][]{
        {60, 120, 5}, {-90, 50, 3}
    }
);

draw(sm, dpar(help = true, mode = free, viewdir = dir(-40)));
