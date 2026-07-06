include common;

size(7cm);

draw(
    smooth(contour = unitcircle, hratios = new real[]{.5}, vratios = new real[]),
    dpar(mode = cartesian, viewdir = dir(-70))
);

smooth sm = 
    smooth(
        contour = concavepaths[4]
    )
    .addhole(convexpaths[6], scale = .35, shift = (.55,.53), rotate = 60, sections = rr(50, 250, 4))
    .addsubset(convexpaths[3], scale = .5, shift = (-.5,-.2))
    .shift((2.8,-.3))
    ;

draw(sm, dpar(mode = free, viewdir = dir(40)));
