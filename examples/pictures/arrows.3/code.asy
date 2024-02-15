import export;
size(15cm);

defaultpen(.7);
expar(margin = 1.5cm, bgpen = paleyellow);
smpar(scholeangle = 30, scfreedom = .3, gaplength = .1);

smooth sm1 = samplesmooth(3, 1).setlabel("M", dir(160));
sm1.addelement((-.4,.2), "x", labelalign = W);
sm1.view(20);

smooth sm2 = samplesmooth(1, 1).move(rotate = 90, shift = (3,0)).setlabel("N", dir(40));
sm2.setlabel(0, "S", dir(150));
sm2.addelement((-.35,.1), "y", labelalign = E);
sm2.view(20);

draw("N", contourpen = linewidth(.7));
draw("M", contourpen = linewidth(.7));
drawmapping("x", "y", curve = .5, "g");
drawarrow("M", "N", curve = -.3, Label("f", align = Relative(W)));

export("picture", "pdf");
