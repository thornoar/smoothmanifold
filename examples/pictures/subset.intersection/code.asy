import export;

settings.render = 8;

size(20 cm);
defaultpen(1);

config.drawing.subsetoverlap = false;
config.drawing.gaplength = .03;
config.drawing.smoothfill = lightgreen;
config.drawing.subsetfill = new pen[]{cyan, yellow, red};
config.drawing.subpenfactor = .4;
config.smooth.unit = false;

smooth sm = samplesmooth(0);

sm.addsubset(contour = convexpaths[7], shift = (-.2,-.1), scale = .4);
sm.addsubset(contour = convexpaths[4], shift = (.2,.1), scale = .4);
sm.addsubset(contour = convexpaths[2], shift = (.3,-.2), scale = .4);
sm.addsubset(contour = convexpaths[3], shift = (-.5,0), scale = .3);
sm.addsubset(contour = convexpaths[8], shift = (-.1,-.1), scale = .2);
sm.addsubset(contour = convexpaths[5], shift = (-.3,-.65), scale = .17);
sm.addsubset(contour = concavepaths[2], shift = (.25,.45), scale = .4, rotate = 140, point = (0,0));
sm.addsubset(contour = unitcircle, scale = .2, shift = (.42,-.3));
sm.addsubset(contour = unitcircle, scale = .12, shift = (.42,-.33));

draw(sm, dpar(plain));

export(prefix = "picture", format = "pdf", xmargin = 1cm, bgpen = paleyellow);
