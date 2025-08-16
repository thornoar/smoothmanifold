import export;

export.background = paleyellow;
export.drawgrid = false;
export.gridnumber = 20;
export.xmargin = .5cm;
export.prefix = "picture";
settings.outformat = "pdf";

size(12cm);

pen pathpen = linewidth(.7pt);

smooth sm = smooth(
    contour = rotate(150)*convexpaths[3],
    holes = new hole[] {
    hole(
        contour = concavepaths[6],
        shift = (-.25,.2),
        scale = .5,
        rotate = -50,
        sections = rr(164,250,8)
    )
    },
    unit = false,
    label = "M",
    labeldir = dir(55),
    scale = .5
).addelement((.3,-.1), label = "*", align = 1.1*dir(160), unit = true);

smooth segment = smooth(
    contour = (-.1,0)--(-.1,1)--(.1,1)--(.1,0)--cycle,
    drawextra = new void (dpar dspec, smooth sm)
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
    p = pathpen
);
drawpath(
    sm, 0, angle = -15, radius = .15,
    L = Label("\mathrm{Im}\hspace{1pt} f_2", position = Relative(.7), align = Relative(1.5*E)),
    p = pathpen,
    overlap = true
);
for (real i = 0.13; i > 0.04; i -= 0.03)
{
    drawpath(sm, 0, angle = -15, radius = i, p = pathpen, overlap = true);
}

draw(segment, dspec = emptypar());

drawarrow(
    start = segment.relative((-.2,.5)),
    finish = sm.relative((.43,.32)),
    curve = .15,
    beginmargin = 0,
    endmargin = 0,
    L = Label("f_1")
);

drawarrow(
    start = segment.relative((-.2,-.9)),
    finish = sm.relative((.93,-.29)),
    curve = -.15,
    beginmargin = 0,
    endmargin = 0,
    L = Label("f_2", align = Relative(W))
);
