import smoothmanifold;

size(14cm);

config.drawing.smoothfill = nullpen;
config.drawing.gaplength = 0.1;
config.arrow.mar = 0.05;
config.drawing.subpenbrighten = .2;
config.arrow.currentarrow = delayedArrow(SimpleHead, angle = 15);

smooth x = smooth(
    contour = xscale(1.5)*usquare,
    shift = (-2,0),
    label = "$X$"
).addsubset(
    contour = concavepaths[2],
    scale = 0.75,
    shift = (0,-.1),
    unit = true,
    label = "$f^{-1}(U)$",
    dir = dir(100),
    align = 2*(N+.5*W)
).addsubset(
    index = 0,
    contour = concavepaths[0],
    shift = (.3,-.1),
    scale = .5,
    rotate = 70,
    unit = true,
    label = "$f^{-1}(B_\varepsilon)$",
    dir = dir(180)
);

pair a = x.unitadjust * (.35,-.15);
real del = .27;
x.addsubset(
    contour = circle(a, del),
    unit = false
).addelement(
    a,
    label = "$a$",
    unit = false
);

smooth y = smooth(
    contour = xscale(1.5)*usquare,
    shift = (2,0),
    label = "$Y$"
).addsubset(
    contour = convexpaths[4],
    scale = 0.8,
    shift = (.1,.05),
    unit = true,
    label = "$U$",
    dir = dir(210)
);
pair fa = y.unitadjust * (.2,.1);
real eps = 0.5;
y.addsubset(
    0,
    contour = circle(fa, eps),
    label = "$B_\varepsilon (f(a))$",
    dir = dir(-90),
    unit = false
).addelement(fa, label = "$f(a)$", unit = false);

draw(x, dpar(subsetcontourpens = new pen[]{purple, orange, heavygreen}));
draw(y, dpar(subsetcontourpens = new pen[]{purple, orange}));

drawarrow(x, y, curve = 0, L = Label("$f$", align = Relative(W)));
drawarrow("$a$", "$f(a)$", curve = -.2);

draw((fa + 0.04 * dir(45)) -- (fa + (eps - 0.02) * dir(45)), arrow = Arrows(TeXHead), L = Label("$\varepsilon$", position = MidPoint, align = Relative(E)));
