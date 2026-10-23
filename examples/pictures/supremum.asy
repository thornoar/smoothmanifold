import smoothmanifold;

size(15cm);

defaultpen(0.5pt + fontsize(10.5pt));
texpreamble("
\usepackage{microtype}
\usepackage[T1]{fontenc}
\usepackage[dvipsnames]{xcolor}
");

config.system.insertdollars = false;
config.drawing.smoothfill = nullpen;
config.paths.neighheight = .1;
config.paths.neighwidth = .02;

real maxlen = 2;

draw((-.1,0) -- (0,0));
draw((0,0) -- (1,0), red);

dot(0, L = Label("$0$", align = S));
draw(neigharc(1, dir = -1), L = Label("$1$", position = MidPoint, align = S+.7*E));

dot((1,0), heavygreen);
draw((1,0)--(maxlen,0), linewidth(.7) + heavygreen);

pair notpos = (.5, -.2);
string notlab = minipage("
{\color{red}{not}} upper\\
bounds of $[0,1)$
", width = 2.5cm);
frame f;
smooth not = smooth(
    contour = scale(.006)*box(f, Label(notlab)),
    label = notlab,
    labeldir = (0,0),
    labelalign = (0,0)
).move(shift = notpos);

pair allpos = (1.5, .2);
string alllab = minipage("
{\color{ForestGreen}{all}} upper\\
bounds of $\mathrm{[0,1)}$
", width = 2.5cm);
frame f;
smooth all = smooth(
    contour = scale(.006)*box(f, Label(alllab)),
    label = alllab,
    labeldir = (0,0),
    labelalign = (0,0)
).move(shift = allpos);

draw(not, all, dspec = dpar(fill = false, drawcontour = false));

void arr (smooth sm, pen p, real dest, real curve) {
    drawarrow(
        sm1 = sm,
        finish = (dest,0),
        beginmargin = 0,
        endmargin = .02,
        curve = curve,
        p = p
    );
}

arr(not, red, .05, -.25);
arr(not, red, .18, -.25);
arr(not, red, .33, -.25);
arr(not, red, .48, .05);
arr(not, red, .67, .15);
arr(not, red, .89, .33);

arr(all, heavygreen, 1, .2);
arr(all, heavygreen, 1.15, .2);
arr(all, heavygreen, 1.38, .05);
arr(all, heavygreen, 1.75, -.12);
arr(all, heavygreen, 1.95, -.18);
