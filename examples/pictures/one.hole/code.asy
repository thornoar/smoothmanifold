import export;

settings.render = 8;
settings.outformat = "pdf";

size(10cm);
expar(bgpen = paleyellow, margin = 1 cm, exit = false);
smpar(scavoidsubsets = true);

smooth sm = samplesmooth(1).view(dir(-40));

draw(sm, explain = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture (plain mode)");
erase();

draw(sm, explain = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture (cartesian mode)");
erase();

draw(sm, explain = true, dash = true, mode = free, sectionpen = linewidth(.5));
export(prefix = "picture (free mode)");

exit();
