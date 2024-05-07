import export;

settings.render = 8;

size(20 cm);
defaultpen(1);
smpar(minscale = .05, subsetoverlap = false, gaplength = .03, smoothfill = lightgreen, subsetfill = cyan, unit = false);

smooth sm = samplesmooth(0);

sm.addsubset(contour = convexpath[7], shift = (-.2,-.1), scale = .4);
sm.addsubset(contour = convexpath[4], shift = (.2,.1), scale = .4);
sm.addsubset(contour = convexpath[2], shift = (.3,-.2), scale = .4);
sm.addsubset(contour = convexpath[3], shift = (-.5,0), scale = .3);
sm.addsubset(contour = convexpath[8], shift = (-.1,-.1), scale = .2);
sm.addsubset(contour = convexpath[5], shift = (-.3,-.65), scale = .17);
sm.addsubset(contour = concavepath[2], shift = (.25,.45), scale = .4, rotate = 140, point = (0,0));
sm.addsubset(contour = unitcircle, scale = .2, shift = (.42,-.3));
sm.addsubset(contour = unitcircle, scale = .12, shift = (.42,-.33));

draw(sm, dpar(plain));

export(prefix = "picture", format = "pdf", margin = 1cm, bgpen = paleyellow);
