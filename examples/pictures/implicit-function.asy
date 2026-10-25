import smoothmanifold;
size(8cm);

pen op = opacity(.2);
// defaultpen(.7);

usepackage("xcolor");

config.drawing.gaplength = .1;

pair c = (2.2, 2);
real r = 1.5;

draw((0,0) -- (2,0), arrow = Arrow(SimpleHead), L = Label("$x$", position = EndPoint, align = (1,0)));
draw((0,0) -- (0,3), arrow = Arrow(SimpleHead), L = Label("$y$", position = EndPoint, align = (0,1)));
draw((0,0) -- (-.5,-.5), arrow = Arrow(SimpleHead), L = Label("$z$", position = EndPoint, align = dir(-135)));

smooth sp = smooth(
    contour = circle(c,r),
    hratios = r(.5),
    vratios = r()
);

draw(sp, dpar(mode = cartesian, smoothfill = palegrey, viewdir = (0,-1)));

pair x = c + (-.3, .6);

pair y = c + (r,0);
real ang = 30;

pair[] cs = {x+(-.5,-.35), x+(-.25,.4), x+(.4,.35), x+(.4,-.4)};

path good =
    curvedpath(cs[0], cs[1], curve = -.13)
    &
    curvedpath(cs[1], cs[2], curve = -.02)
    &
    curvedpath(cs[2], cs[3], curve = -.02)
    &
    curvedpath(cs[3], cs[0], curve = -.07)
    &
    cycle;

drawarrow(
    start = (4,3.1),
    finish = cs[2],
    endmargin = 0.07,
    curve = .2,
    L = Label("$\frac{\partial f}{\partial z} (p) \neq 0$", position = BeginPoint, align = Relative(S))
);

drawarrow(
    start = (4.7,1.1),
    finish = y,
    endmargin = 0.07,
    curve = .2,
    L = Label("$\frac{\partial f}{\partial z} (p) = 0$", position = BeginPoint, align = Relative(.7*S))
);

drawdelayed();

filldraw(good, drawpen = heavygreen, fillpen = heavygreen+op);
dot(x, heavygreen);
filldraw(
    arc(c, r, -ang, ang)
    &
    curvedpath(c+r*dir(ang), c+r*dir(-ang), curve = .1)
    &
    cycle,
    drawpen = red,
    fillpen = red + op
);
dot(y, red);
