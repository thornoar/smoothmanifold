import export;
size(15cm);

defaultpen(.7);
// expar(xmargin = 1cm, bgpen = paleyellow);

export.xmargin = 1cm;
export.background = paleyellow;

config.section.avoidsubsets = false;
config.section.freedom = .3;
config.smooth.interholeangle = 30;
config.smooth.unit = true;
config.drawing.gaplength = .1;
config.drawing.mode = cartesian;
config.drawing.viewdir = dir(-20);
config.arrow.mar = .05;
config.arrow.absmargins = true;

smooth sm1 = samplesmooth(3, 1).move(scale = 1.3).setlabel("M", dir(150));
sm1.addelement((-.45,.0), "x", align = W);

smooth sm2 = samplesmooth(1, 1).move(rotate = 90, shift = (3.5,0)).setlabel("N", dir(40));
sm2.setlabel(0, "S", dir(135));
sm2.addelement((-.2,0), "y", align = E);

draw("M");
draw("N");
drawarrow(
    destlabel1 = "x",
	destlabel2 = "y",
	curve = .45,
	L = "g"
);
drawarrow("M", "N", curve = -.3, L = Label("f", align = Relative(W)));

export("picture", "pdf");
