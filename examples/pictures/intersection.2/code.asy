import export;

settings.render = 16;
settings.outformat = "pdf";

size(15 cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1.5cm, autoexport = false);
smpar(scfreedom = .8, scholenumber = 2, scholeangle = 50);

pair viewdir = dir(45);
smooth sm1 = samplesmooth(3,1)
    .move(scale = 1.1)
    .view(viewdir);
smooth sm2 = samplesmooth(1,1)
    .move(shift = (.5,.23), rotate = -60)
    .rmsubset(0)
    .view(viewdir);

draw(sm1, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);
draw(sm2, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);

smooth sm3 = intersect(sm1, sm2);
sm3.setsection(1, 0, r(-1.5,4,230,7));
sm3.setsection(0, 0, r(2,-1,230,dn));

draw(sm3, help = false, mode = free);

export(prefix = "picture");
