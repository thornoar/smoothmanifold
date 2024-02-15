import export;

settings.render = 8;

size(10 cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1 cm);

pair viewdir = dir(-35);
smooth sm = samplesmooth(2).view(viewdir);

draw(sm, help = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture (plain mode)", format = "pdf");
erase();

draw(sm, help = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture (cartesian mode)", format = "pdf");
erase();

draw(sm, help = true, dash = true, mode = free, sectionpen = linewidth(.5));
export(prefix = "picture (free mode)", format = "pdf");
