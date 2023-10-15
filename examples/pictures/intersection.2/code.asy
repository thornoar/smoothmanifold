import smoothmanifold;

settings.render = 16;
settings.outformat = "pdf";

size(15 cm);
setproduce(bgpen = paleyellow, margin = 1.5cm, exit = false);

pair viewdir = dir(45);
smooth sm1 = samplesmooth(3,1).move(scale = 1.1).view(viewdir);
smooth sm2 = samplesmooth(1,1).move(shift = (.5,.23), rotate = -60).view(viewdir);

draw(sm1, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = "plain");
draw(sm2, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = "plain");

smooth sm3 = intersect(sm1, sm2);

save();

draw(sm3, explain = false, mode = "strict");
produce(prefix = "picture (strict mode)");
restore();

draw(sm3, explain = false, mode = "free");
produce(prefix = "picture (free mode)");
restore();

draw(sm3, explain = false, mode = "cart");
produce(prefix = "picture (cart mode)");
restore();

draw(sm3, explain = false, mode = "plain");
produce(prefix = "picture (plain mode)");
restore();

printtime();
exit();
