import export;

expar(
    drawgrid = false,
	gridnumber = 20,
	margin = .5cm,
	bgpen = paleyellow,
    prefix = "picture",
    format = "pdf"
);

size(12cm);

pen pathpen = linewidth(.9pt);

smooth sm = smooth(
    contour = rotate(150)*convexpath[3],
    holes = new hole[] {
    hole(
        contour = concavepath[6],
        shift = (-.25,.2),
        scale = .5,
        rotate = -50,
        sections = rr(-5.5,1.5,250,8)
    )
    },
    unit = false,
    label = "M",
    labeldir = dir(55),
    scale = .5
).addelement((.3,-.1), label = "*", align = 1.1*dir(160), unit = true);

smooth segment = smooth(
    contour = (-.1,0)--(-.1,1)--(.1,1)--(.1,0)--cycle,
    postdraw = new void (dpar dspec, smooth sm)
    {
        transform adj = sm.unitadjust;
        draw(adj*((0,1.5)--(0,-1.5)), p = pathpen, L = Label("", position = MidPoint, align = E));
        draw(adj*((-.1,-1.5)--(.1,-1.5)), p = pathpen, L = Label("$0$", position = EndPoint, align = E));
        draw(adj*((-.1,1.5)--(.1,1.5)), p = pathpen, L = Label("$1$", position = EndPoint, align = E));
    },
    shift = (1,-.3),
    scale = .6
);

draw(sm, dspec = dpar(help = false, mode = free, viewdir = dir(-50)));
drawpath(
    sm, 0, points = new pair[]{
        (-.1,-.3),
        (-.4,-.07),
        (-.3,.35),
        (.07,.4)
    },
    L = Label("\mathrm{Im}\hspace{1pt} f_1", position = Relative(.1), p = currentpen, align = Relative(W)),
    overlap = true,
    p = linewidth(1.1pt)
);
drawpath(
    sm, 0, angle = -15, radius = .15,
    L = Label("\mathrm{Im}\hspace{1pt} f_2", position = Relative(.75), align = Relative(E)),
    p = pathpen,
    overlap = true
);

for (real i = 0.13; i > 0; i -= 0.03)
{
    drawpath(sm, 0, angle = -15, radius = i, p = pathpen, overlap = true);
}

draw(segment, dspec = emptypar());

sm.setcenter((.1,.1), unit = true);
segment.setcenter((0,.5), unit = true);
drawarrow(
    segment,
    sm,
    curve = .15,
    margin1 = -.01,
    margin2 = -.18,
    L = Label("f_1")
);

sm.setcenter((.7,-.3), unit = true);
segment.setcenter((0,-.5), unit = true);
drawarrow(
    segment,
    sm,
    curve = -.15,
    margin1 = -.02,
    margin2 = -.05,
    L = Label("f_2", align = Relative(W))
);
