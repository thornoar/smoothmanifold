import export;

settings.render = 16;
settings.outformat = "pdf";

size(15 cm);
exportparams(bgpen = paleyellow, margin = 1.5cm, exit = false);
// sectionparams(ratio = .8);

pair viewdir = dir(45);
smooth sm1 = samplesmooth(3,1).move(scale = 1.1).view(viewdir);
smooth sm2 = samplesmooth(1,1).move(shift = (.5,.23), rotate = -60).view(viewdir);

draw(sm1, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);
draw(sm2, contourpen = mediumgrey, smoothfill = invisible, subsetcontourpen = invisible, subsetfill = invisible, mode = plain, drawnow = true);

smooth sm3 = intersect(sm1, sm2);
sm3.setsection(1, 0, a(-2,4,240,dn));
sm3.setsection(0, 0, a(dn,dn,220,dn));

save();

draw(sm3, explain = false, mode = free);
export(prefix = "picture (free mode)");
flushcache();
restore();
save();

draw(sm3, explain = false, mode = plain);
export(prefix = "picture (plain mode)");

exit();
