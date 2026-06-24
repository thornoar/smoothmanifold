import export;
settings.render = 16;

size(20 cm);
defaultpen(.7);

export.background = paleyellow;

config.drawing.viewdir = dir(-60);
config.drawing.gaplength = .15;
config.arrow.mar = .1;
config.arrow.absmargins = true;
config.system.insertdollars = true;

smooth sm1 = samplesmooth(1,2).move(scale = 2);
sm1.setlabel(0, "U", dir = S);
sm1.setlabel(1, "V", dir = dir(70));
sm1.setlabel(2, "U \cap V", dir = dir(110), align = (-1,1.5));

smooth sm2 = samplesmooth(0,2)
    .move(shift = (5,-.2), scale = 1.2)
    .setlabel(0, "W", E+3*N);

// write(clockwise(sm1.contour));
// write(clockwise(sm1.holes[0].contour));

draw(sm1, dpar(mode = free, dash = false));
draw(sm2, dpar(mode = cartesian, dash = true));

tarrow myarrow = delayedArrow(HookHead, begin = true, size = 5.5, filltype = NoFill);

drawarrow(sm1, sm2, curve = -.4);
drawarrow(sm1, 2, sm2, 0, arrow = myarrow, curve = -.1);
drawarrow(sm2, 0, sm1, 0, arrow = myarrow, curve = -.2);
drawarrow(sm2, angle = 95, radius = 1.2);

export("picture", "pdf", 1.5 cm);
