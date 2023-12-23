import export;

settings.render = 8;

size(10 cm);
setframe(bgpen = paleyellow, margin = 1 cm);
exportparams(exit = false);

pair viewdir = dir(-35);
smooth sm = samplesmooth(2).view(viewdir);

draw(sm, explain = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture (plain mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture (cartesian mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = free, sectionpen = linewidth(.5));
export(prefix = "picture (free mode)", format = "pdf");

exit();
