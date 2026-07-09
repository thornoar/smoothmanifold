include common;

size(5cm);

smooth sm = smooth(
    (-1.5,-1) -- (1.5,-1) -- (1.5,1) -- (-1.5,1) -- cycle,
    label = "$X$",
    labeldir = dir(90)
)
.addsubset(convexpaths[2], scale = .8, shift = (-.4,.05), label = "$A$", dir = dir(140))
.addsubset(convexpaths[3], scale = .8, shift = (.4,0), label = "$B$", dir = dir(40))
.setlabel(2, "$A \cap B$", dir = (0,0));

draw(sm, dpar(
    fill = false,
    drawnow = true,
    subsetfill = new pen[]{gray(.8), gray(0.5)}
));
