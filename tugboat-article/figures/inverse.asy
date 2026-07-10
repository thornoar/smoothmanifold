include common;

// include common;
size(7.5cm);

pen dotpen = linewidth(3pt);
pen op = opacity(.05);
// pen op = opacity(0);
pair a = (0,0);

pair fa = (2.7,0);
dot(fa, dotpen, L = Label("$F(a)$", align = (0,-1.2)));

real eps = 1.2;

fillfitpath(
    circle(fa, eps),
    drawpen = black,
    fillpen = black+op,
    L = Label("$B_\varepsilon (F(a))$", position = Relative(.75), align = Relative(1.5*E))
);

pair y = (3.0,.6);

dot(y, dotpen, L = Label("$y$", align = (1,0)));

real del = 1;
pair sh = (-.135,.04);
real sc = .75;
pair fix = a + sh/(1-sc); // + (.06,-.03);

pair c = a;
real r = del;

for (int i = 0; i < 8; ++i) {
    fillfitpath(
        circle(c, r),
        drawpen = black,
        fillpen = black + op,
        L = (i == 0) ? Label("$B_{\delta'} (a)$", position = Relative(.75), align = Relative(1*E)) : ""
    );
    r *= sc;
    c += sh;
    sh *= sc;
}

dot(fix, dotpen, L = Label("$x$", align = (0,-1.1)));
dot(a, dotpen, L = Label("$a$", align = (0,-1.1)));

config.drawing.gaplength = .001;

fitpath(
    circle(a + (0,-.16), .12),
    covermode = 2,
    p = invisible
);
fitpath(
    circle(fix + (0,-.16), .12),
    covermode = 2,
    p = invisible
);


config.drawing.gaplength = .13;
drawarrow(
    start = fix,
    finish = y,
    beginmargin = .07,
    points = new pair[]{(.3,.3), (2.1,.8)},
    L = Label("$F$", position = MidPoint, align = Relative(W))
    // help = true
);
