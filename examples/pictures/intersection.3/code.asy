import smoothmanifold;

settings.render = 16;
size(15 cm);
setproduce(bgpen = paleyellow);
smoothdraw(smoothfill = cyan);

smooth sm1 = samplesmooth(2).move(shift = (-.7,-.1), rotate = -40);
smooth sm2 = samplesmooth(1,1).move(shift = (.7,-.15), rotate = -20);
smooth sm3 = samplesmooth(0).addhole(contour = convexpath[0], scale = .5).move(shift = (1,0));
smooth sm4 = samplesmooth(0,2).rmsubset(0).move(shift = (-1.5,0), scale = .8);

drawintersect(sm1, sm2, round = true);
draw(sm3, contourpen = mediumgrey, smoothfill = invisible, mode = plain);
draw(intersection(sm2, sm3, round = true));
draw(sm4, contourpen = mediumgrey, smoothfill = invisible, mode = plain);
draw(intersection(sm1, sm4, round = true));

produce("picture", "pdf", 1 cm);
