import export;

settings.render = 16;
settings.outformat = "pdf";

size(15 cm);
expar(bgpen = paleyellow, margin = 1.5cm);
smpar(scfreedom = .8);

pair viewdir = dir(45);
smooth sm1 = samplesmooth(3,1).move(scale = 1.1).view(viewdir);
smooth sm2 = samplesmooth(1,1).move(shift = (.5,.23), rotate = -60).view(viewdir);

draw(sm1, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);
draw(sm2, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);

smooth sm3 = intersect(sm1, sm2);
sm3.setsection(1, 0, r(-2,4,240,dn));
sm3.setsection(0, 0, r(dn,dn,220,dn));

draw(sm3, explain = false, mode = free);
export(prefix = "picture");
