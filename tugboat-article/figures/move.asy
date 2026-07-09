include common;

size(7.5cm);

smooth sm = smooth(
    contour = concavepaths[4],
    label = "$X$",
    labeldir = dir(60)
)
.addhole(convexpaths[6], scale = .35, shift = (.55,.53), rotate = 60, sections = rr(50, 260, 6))
.addsubset(convexpaths[3], scale = .45, shift = (-.5,-.2), rotate = 0, label = "$S$", dir = (0,0))
.rotate(20)
;

smooth smp = sm.copy().move(shift = (5,0), scale = 1.5, rotate = 80);

draw(sm, smp, dspec = dpar(mode = free, viewdir = dir(40)));
drawarrow(sm, smp, curve = .25, beginmargin = .2, L = Label(minipage("\texttt{.move(shift = (5,0), scale = 1.5, rotate = 80)}", width = 4.7cm), position = MidPoint, align = 2*Relative(E)));
