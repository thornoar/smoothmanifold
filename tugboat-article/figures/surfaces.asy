import smoothmanifold;

size(7cm);
defaultpen(.7pt);

draw(
    smooth(contour = unitcircle, hratios = new real[]{.5}, vratios = new real[]),
    dpar(mode = cartesian, viewdir = dir(-70))
);

draw(
    smooth(
        contour = concavepaths[4]
    )
    .addhole(convexpaths[6], scale = .35, shift = (.55,.53), rotate = 60, sections = rr(50, 250, 4))
    .addsubset(convexpaths[3], scale = .5, shift = (-.5,-.2))
    .shift((2.8,-.3))
    ,
    dpar(mode = free, viewdir = dir(40))
);
