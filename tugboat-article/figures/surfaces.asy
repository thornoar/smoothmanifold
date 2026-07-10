include common;

size(7.7cm);

draw(
    smooth(contour = unitcircle, hratios = new real[]{.5}, vratios = new real[]),
    dpar(mode = cartesian, viewdir = dir(-70))
);

smooth sm = 
    smooth(
        contour = concavepaths[4]
    )
    .addhole(convexpaths[6], scale = .35, shift = (.55,.53), rotate = 60, sections = rr(50, 260, 3))
    .addhole(convexpaths[1], scale = .35, shift = (-.4,-.13), rotate =
    30, sections = rr(200, 110, 2))
    .shift((2.6,-.3))
    ;

draw(sm, dpar(
    mode = free, viewdir = dir(0)
    // sectionpen = gray(.6) + .5pt,
    // dashpen = gray(.7) + dashed + .5pt
));
