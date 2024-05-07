import export;
size(15cm);

defaultpen(.7);
expar(margin = 1cm, bgpen = paleyellow);
smpar(scholeangle = 30, scfreedom = .3, gaplength = .1, arrowmargin = .1, unit = true, mode = cartesian, scavoidsubsets = false, viewdir = dir(-20));

smooth sm1 = samplesmooth(3, 1).move(scale = 1.3).setlabel("M", dir(150));
sm1.addelement((-.45,.0), "x", align = W);

smooth sm2 = samplesmooth(1, 1).move(rotate = 90, shift = (3.5,0)).setlabel("N", dir(40));
sm2.setlabel(0, "S", dir(135));
sm2.addelement((-.2,0), "y", align = E);

draw("M");
draw("N");
drawmapping("x", "y", curve = .45, "g");
drawarrow("M", "N", curve = -.3, Label("f", align = Relative(W)));

export("picture", "pdf");
