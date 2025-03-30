import export;
settings.render = 16;

size(25 cm);
defaultpen(.5);

config.drawing.gaplength = .07;
config.smooth.shiftsubsets = true;
config.arrow.absmargins = true;
config.drawing.fill = true;
config.smooth.unit = true;
config.drawing.mode = free;
config.drawing.viewdir = dir(15);
config.section.freedom = 0.15;
config.help.enable = false;

export.background = paleyellow;
export.margin = 2cm;

smooth sm1 = samplesmooth(3,0)
    .rotate(-50)
    .setsection(0, 0, r(dn,dn,dn,6))
    .setsection(1, 0, r(dn,dn,dn,6))
    .movesubset(0, shift = (0.05,.09))
    .setlabel("M", dir = dir(100))
    .setlabel(0, label = "U", dir = dir(180));

smooth sm2 = samplesmooth(1)
.move(shift = (4,0), rotate = 90)
.rmsubset(0)
.setsection(0, r(dn,dn,240,5))
.addsubset(
    contour = convexpath[4],
    label = "V",
    dir = dir(150),
    shift = (.55,.8),
    scale = .23,
    rotate = -20
).addsubset(
    contour = concavepath[2],
    label = "W",
    dir = dir(-110),
    shift = (.07,.20),
    scale = .46,
    rotate = 150
).addsubset(
    1,
    contour = convexpath[2],
    shift = (-.5,.3),
    scale = .4,
    rotate = 0
).addsubset(
    1,
    contour = convexpath[1],
    shift = (.7,-.15),
    scale = .32,
    rotate = -20
);

sm2.movesubset(1, recursive = true, rotate = -10);
sm2.setlabel("N", dir = dir(-30));

draw(sm1);
draw(sm2, dpar(shade = true, dash = false));

drawarrow(
    sm1,
	sm2,
	curve = -.15,
    margin = .02,
	L = Label("f", align = Relative(W))
);
drawarrow(
    sm1,
	sm2,
	index1 = 0,
	index2 = 0,
	curve = .34,
    margin = .015,
	L = Label("f_U", position = Relative(.4))
);
drawarrow(
    sm2,
	sm1,
	index1 = 1,
	index2 = 0,
	curve = .4,
    margin1 = .015,
    margin2 = .03,
	L = "g"
);
drawarrow(
    sm1,
	0,
	angle = 185,
	radius = .62,
    margin = .02,
	L = Label(
        "\mathrm{id}_U",
        position = Relative(.22),
        align = Relative(W)
    )
);
drawarrow(
    sm2,
	1,
	angle = -63,
	radius = .8,
	reverse = true,
    margin = .02,
	L = Label(
        "\mathrm{id}_W",
        position = Relative(.45),
        align = Relative(E)
    )
);
drawarrow(
    sm2,
	2,
    margin = .01,
	angle = 150,
	radius = .7
);
drawarrow(
    sm1,
	angle = 70,
	radius = .9,
    margin1 = .02,
    margin2 = .01,
	L = Label("\mathrm{id}_M", align = Relative(W))
);

export("picture", "pdf");
