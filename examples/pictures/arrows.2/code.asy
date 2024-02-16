import export;
settings.render = 16;

size(20 cm);
defaultpen(.7);
expar(bgpen = paleyellow);
smpar(dash = false, gaplength = .2, arrowmargin = .12);

pair viewdir = dir(-50);

smooth sm1 = samplesmooth(1,2).move(scale = 2).view(viewdir);
sm1.setlabel(0, "U", labeldir = S);
sm1.setlabel(1, "V", labeldir = dir(70));
sm1.setlabel(2, "U \cap V", labeldir = dir(110), labelalign = (-1,1.5));
smooth sm2 = samplesmooth(0,2).move(shift = (5,-.2), scale = 1.2).setlabel(0, "W", E+3*N).view(viewdir);

draw(sm1);
draw(sm2, mode = cartesian);

drawarrow(sm1, sm2, curve = -.4);
drawarrow(sm1, 2, sm2, 0, curve = -.1);
drawarrow(sm2, 0, sm1, 0, curve = -.2);
drawarrow(sm2, angle = 95, radius = 1.2);

export("picture", "pdf", 1.5 cm);
