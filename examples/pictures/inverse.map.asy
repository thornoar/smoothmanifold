import smoothmanifold;
size(9cm);

pen op = opacity(.1);
pair a = (0,0);
pair fa = (3,0);

dot(a, L = Label("$a$", align = (0,-1.3)));

dot(fa, L = Label("$F(a)$", align = (0,-1.5)));

real eps = 1.2;

fillfitpath(
    circle(fa, eps),
    drawpen = orange,
    fillpen = orange+op,
    L = Label("$B_\varepsilon (F(a))$", position = Relative(.75), align = Relative(1.5*E))
);

pair y = (3.3,.6);

dot(y, L = Label("$y$", align = (1,0)));

real del = 1;
pair sh = (-.13,.04);
real sc = .75;
pair fix = a + sh/(1-sc); // + (.06,-.03);

pair c = a;
real r = del;

for (int i = 0; i < 8; ++i) {
    fillfitpath(
        circle(c, r),
        drawpen = heavygreen,
        fillpen = heavygreen + op,
        L = (i == 0) ? Label("$B_{\delta'} (a)$", position = Relative(.75), align = Relative(1*E)) : ""
    );
    r *= sc;
    c += sh;
    sh *= sc;
}

dot(fix, L = Label("$x$", align = (0,-1.3)));


fitpath(
    circle(a + (0,-.15), .1),
    covermode = 2,
    p = invisible
);
fitpath(
    circle(fix + (0,-.15), .1),
    covermode = 2,
    p = invisible
);


config.drawing.gaplength = .1;
drawarrow(
    start = fix,
    finish = y,
    beginmargin = .07,
    points = new pair[]{(.3,.3), (2.1,.8)},
    L = Label("$F$", position = MidPoint, align = Relative(W))
    // help = true
);
