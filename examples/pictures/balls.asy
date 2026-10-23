import smoothmanifold;

size(11cm);

real xsep = 3.3;
real l = 1.4;

for (int i = -1; i < 2; ++i) {
    real pos = xsep * i;
    draw((pos-l, 0) -- (pos+l, 0), arrow = Arrow(SimpleHead));
    draw((pos, -l) -- (pos, l), arrow = Arrow(SimpleHead));
}

path d1 = shift((-xsep, 0)) * ((-1, 0) -- (0, 1) -- (1,0) -- (0,-1) -- cycle);
draw(
    shift((-xsep, 0)) * ((-1, 0) -- (0, 1) ^^ (0,1) -- (1,0) ^^ (1,0) -- (0,-1) ^^ (0,-1) -- (-1,0)),
    p = dashed + blue
);
label(
    (-xsep+.5, .5),
    "$B^{d_1}_1 (0)$", align = (E+N)/2
);
shaderegion(d1, angle = 0, p = blue);

path d2 = circle((0, 0), 1);
draw(
    d2,
    p = dashed + orange,
    L = Label("$B^{d_2}_1 (0)$", position = Relative(.17), align = Relative(E), p = currentpen)
);
shaderegion(d2, p = orange);

path d3 = shift((xsep, 0)) * ((-1, -1) -- (-1, 1) -- (1,1) -- (1,-1) -- cycle);
draw(
    shift((xsep,0)) * ((-1, -1) -- (-1, 1) ^^ (-1,1) -- (1,1) ^^ (1,1) -- (1,-1) ^^ (1,-1) -- (-1,-1)),
    p = dashed + red
);
label(
    (xsep+.9, 1),
    "$B^{d_\infty}_1 (0)$", align = N
);
shaderegion(d3, p = red);
