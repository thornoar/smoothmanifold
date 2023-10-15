import smoothmanifold;

settings.render = 8;

size(20 cm);
setproduce(bgpen = paleyellow);

defaultpen(1);
smoothdraw(minscale = .1);

smooth sm = samplesmooth(0).move(scale = 1.5);

sm.addsubset(contour = convexpath[7], point = (0,0), shift = (-.2,-.1), scale = .4);
sm.addsubset(contour = convexpath[4], point = (0,0), shift = (.2,.1), scale = .4);
sm.addsubset(contour = convexpath[2], point = (0,0), shift = (.3,-.2), scale = .4);
sm.addsubset(contour = convexpath[3], point = (0,0), shift = (-.5,0), scale = .3);
sm.addsubset(contour = convexpath[8], point = (0,0), shift = (-.1,-.1), scale = .2, findplace = true);
sm.addsubset(contour = convexpath[5], point = (0,0), shift = (-.3,-.65), scale = .2);
sm.addsubset(contour = concavepath[2], point = (0,0), shift = (.25,.45), scale = .4, rotate = 140);

draw(sm, mode = 'plain', subsetfill = cyan);

produce("picture", "pdf", 1.5 cm);
