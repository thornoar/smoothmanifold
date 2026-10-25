import smoothmanifold;
size(10cm);

usepackage("xcolor");
config.section.freedom = 0.5;
defaultpen(0.7pt);

picture p;

smooth connected = smooth(
    contour = convexpaths[3],
    rotate = 80
)
.addelement((-.6,.4), unit = true)
.addelement((.4,-.6), unit = true)
;
draw(p, connected, dpar(smoothfill = palegrey, elementpen = heavygreen));
for (real rad = 0.55; rad >= .1; rad -= 0.1) {
    drawpath(p, connected, 0, angle = 10, radius = rad, p = heavygreen+.7, drawnow = true);
}
srand(13);
for (real rad = 0.5; rad >= 0; rad -= 0.1) {
    drawpath(p, connected, 1, angle = 160, radius = rad, range = 40, p = heavygreen+.7, drawnow = true);
}

label(p, position = (0,-1.4), "simply connected");

picture q;

smooth disconn = smooth(
    contour = xscale(.7)*unitcircle
)
.addhole(contour = xscale(.57)*unitcircle, unit = true, scale = .7)
.addsection(0, new real[]{180, 10, 1})
.move(shift = (0,-.1))
;

draw(q, disconn, dpar(
    smoothfill = palegrey,
    sectionpen = red + .7,
    mode = free,
    viewdir = (1,-1)
));
disconn.rmsection(0,0);
disconn.addsection(0, r(0,270,5));
draw(q, disconn, dpar(
    fill = false,
    drawcontour = false,
    mode = free,
    viewdir = (1,-1)
));

draw(q, midpath(disconn.contour, disconn.holes[0].contour), red + .7);

label(q, position = (0,-1.4), "{\color{red} not} simply connected");

add(shift(-1) * p);
add(shift(1) * q);
