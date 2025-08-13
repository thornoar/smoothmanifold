import smoothmanifold;
settings.render = 16;
settings.outformat = "svg";

size(21 cm);
defaultpen(linewidth(.8) + fontsize(15pt));

config.drawing.gaplength = .1;
config.smooth.shiftsubsets = true;
config.arrow.absmargins = true;
config.arrow.mar = .03;
config.drawing.fill = true;
config.smooth.unit = true;
config.drawing.mode = free;
config.drawing.viewdir = dir(-100);
config.section.freedom = 0.15;
config.help.enable = false;
// config.drawing.labels = false;

smooth sm1 = samplesmooth(3,0)
    .rotate(-50)
    .scale(1.2)
    .setsection(0, 0, r(dn,dn,6))
    .setsection(1, 0, r(dn,dn,6))
    .movesubset(0, shift = (0.05,.09))
    .setlabel("M", dir = dir(100))
    .setlabel(0, label = "U", dir = dir(180))
    .rotate(-90)
    .movehole(0, scale = .95, shift = (.05,-.0))
    .movehole(1, scale = .95, rotate = 10, shift = (.03,-.0))
    .movehole(2, scale = .95, rotate = 10, shift = (.02,-.05));

smooth sm2 = samplesmooth(1)
.move(shift = (1,-3), rotate = 90)
.rmsubset(0)
.setsection(0, r(dn,240,8))
.addsubset(
    contour = convexpaths[4],
    label = "V",
    dir = dir(150),
    shift = (.55,.8),
    scale = .23,
    rotate = -20
).addsubset(
    contour = concavepaths[2],
    label = "W",
    dir = dir(190),
    shift = (.07,.20),
    scale = .46,
    rotate = 150
).addsubset(
    1,
    contour = convexpaths[2],
    shift = (-.5,.3),
    scale = .4,
    rotate = 0
).addsubset(
    1,
    contour = convexpaths[1],
    shift = (.7,-.15),
    scale = .32,
    rotate = -20
);

sm2.movesubset(1, recursive = true, rotate = -10);
sm2.setlabel("N", dir = dir(-20));
sm2.rotate(-60);

draw(sm1, dpar(help = false, dash = true));
draw(sm2, dpar(mode = cartesian, shade = false, dash = true));

drawarrow(
    sm1,
	sm2,
	curve = -.2,
	L = Label("f", position = Relative(.35), align = Relative(W))
);
drawarrow(
    sm1,
	sm2,
	index1 = 0,
	index2 = 0,
	curve = .47,
	L = Label("f_U", position = Relative(.35))
);
drawarrow(
    sm2,
	sm1,
	index1 = 1,
	index2 = 0,
	curve = .32,
	L = "g"
);
drawarrow(
    sm1,
	0,
	angle = 98,
	radius = .75,
	L = Label(
        "\mathrm{id}_U",
        position = Relative(.22),
        align = Relative(W)
    )
);
drawarrow(
    sm2,
	1,
	angle = 179,
	radius = 1.02,
	reverse = true,
	L = Label(
        "\mathrm{id}_W",
        position = Relative(.55),
        align = Relative(E)
    )
);
drawarrow(
    sm2,
	2,
	angle = 135,
	radius = .6
);
drawarrow(
    sm1,
	angle = -20,
	radius = 1.2,
	L = Label("\mathrm{id}_M", align = Relative(W))
);

// shipout(rotate(90) * currentpicture);

// import export;
//
// export.xmargin = .2cm;
// settings.outformat = "svg";
//
// size(24cm);
// defaultpen(linewidth(.7pt) + fontsize(15pt));
//
// smooth sm1 = smooth(
//     contour = concavepaths[0],
//     holes = new hole[]{
//         hole(
//             contour = convexpaths[1],
//             scale = .35,
//             rotate = -50,
//             shift = (-.35,.65),
//             sections = rr(115,240,10)
//         )
//     },
//     subsets = new subset[]{
//         subset(
//             contour = convexpaths[4],
//             scale = .45,
//             rotate = 0,
//             shift = (.05,-.38)
//         ),
//         subset(
//             contour = convexpaths[3],
//             scale = .44,
//             rotate = 20,
//             shift = (.5,-.3)
//         )
//     }
// );
// sm1.holes[0].center += (.03,-.15);
// sm1.move(rotate = 40);
//
// smooth ctr = rn(-1, labeldir = (1,.5)).move(shift = (0,2.6), scale = 1.1)
//     .addsubset(contour = convexpaths[6], scale = .5, shift = (.2,-.3), unit = true)
//     .addsubset(0, contour = convexpaths[2], scale = .55, shift = (-.2,.1), unit = true)
//     .addsubset(contour = concavepaths[2], scale = .5, shift = (-.25,.4), rotate = 190, unit = true)
//     .addsubset(2, contour = convexpaths[3], scale = .4, shift = (-.6,-.2), rotate = 90, unit = true)
//     .addsubset(2, contour = convexpaths[6], scale = .28, shift = (.8,.2), rotate = -40, unit = true);
//
// // smooth ts = tangentspace(sm1, angle = 30, ratio = .7, size = .5, rotate = -50);
//
// draw(sm1, dpar(mode = free, viewdir = dir(-30), help = false));
// draw(ctr, rnpar());
//
// drawarrow(sm1, 0, ctr, 0, curve = -.45);
// drawarrow(sm1, 2, ctr, 1, curve = .25);
// drawarrow(ctr, 2, ctr, 0, curve = 1.5);
