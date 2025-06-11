import export;

settings.render = 16;
size(15 cm);
defaultpen(.7);

export.background = paleyellow;

config.drawing.smoothfill = cyan;
config.drawing.mode = free;
config.drawing.drawnow = true;
config.smooth.addsubsets = false;

smooth sm1 = samplesmooth(2).move(shift = (-.7,-.1), rotate = -40);
smooth sm2 = samplesmooth(1,1).move(shift = (.7,-.15), rotate = -20);
smooth sm3 = samplesmooth(0).addhole(contour = convexpaths[0], scale = .5).move(shift = (1,0));
smooth sm4 = samplesmooth(0,2).rmsubset(0).move(shift = (-1.5,0), scale = .8);

dpar ds = dpar(mode = plain, contourpen = mediumgrey, fill = false, fillsubsets = false, drawsubsetcontour = false);
draw(sm1, ds);
draw(sm2, ds);
draw(intersection(sm1, sm2, round = true));
draw(sm3, ds);
draw(intersection(sm2, sm3, round = true));
draw(sm4, ds);
draw(intersection(sm1, sm4, round = true));

export("picture", "pdf", 1 cm);
