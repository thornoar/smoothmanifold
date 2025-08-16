import export;

settings.render = 8;

size(17 cm);
defaultpen(.7);

export.background = paleyellow;
export.drawgrid = true;

config.arrow.absmargins = true;
config.drawing.gaplength = .09;
config.drawing.attachedopacity = .9;
config.help.enable = true;
config.system.insertdollars = true;

smooth sm = samplesmooth(1)
    .setlabel("M")
    .setlabel(0, "U", S+.5*E)
    .setsection(0, new real[] {153, 270, 9});

smooth ts = tangentspace(
    sm = sm,
	hlindex = -1,
	angle = 45,
	ratio = .8,
	rotate = 10,
	size = .7
);

smooth rn = rn(n = 1)
    .move(shift = (2.5, .7), scale = .72)
    .setlabel("\mathbb{R}^n")
    .addsubset(
        contour = convexpaths[9],
        label = "V",
        dir = dir(-50),
        shift = (.4,-.2),
        scale = .4,
        unit = true
    );

draw(sm, dpar(mode = free, viewdir = 1.5*dir(-45), overlap = false));
draw(rn, rnpar());

drawarrow(
    ts,
	rn,
	arrow = DeferredArrow(SimpleHead, begin = true),
	beginmargin = .07,
	endmargin = -.3,
	curve = -.2,
	L = Label("\cong", align = Relative(W))
);
drawarrow(
    sm,
	0,
	rn,
	0,
	curve = .3,
	beginmargin = .07,
	L = Label("f")
);

export("picture", "pdf", 1 cm);
