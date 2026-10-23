import smoothmanifold;
size(10cm);
config.drawing.gaplength = .1;

path g = concavepaths[3];

path[] f = {};

real sc = .2;
pair sh = (2.9,-4);
real step = .47;

path box = box((-1.25,-1.15), (1.3,1.4));

int i = 0;
for (real r = 4; r < 8; r += step) {
    f[i] = circle(sh, r);
    real[][] isections = intersections(f[i], box);
    if (isections.length == 0) continue;
    f[i] = subpath(f[i], isections[0][0], isections[isections.length-1][0]);
    fitpath(f[i], L = Label("$f = c_"+(string)(i+1)+"$", position = BeginPoint, align = -1.5*dir(f[i],0)));
    i += 1;
}

i -= 1;

fitpath(g, orange, L = Label("$g(x,y) = 0$", position = Relative(.52), align = Relative(2*E)));

real gf = 0.72;
draw(
    shift(point(f[i], gf)) * ((0,0) -- rotate(-90) * 0.6 * dir(f[i], gf)),
    black,
    arrow = Arrow(SimpleHead),
    L = Label("$\nabla f$", position = Relative(1), align = .25*Relative(E))
);

real gt = 4.21;
draw(
    shift(point(g, gt)) * ((0,0) -- rotate(-90) * 0.35 * dir(g, gt)),
    orange,
    arrow = Arrow(SimpleHead),
    L = Label("$\nabla g$", position = Relative(.7), align = .5*Relative(E))
);
