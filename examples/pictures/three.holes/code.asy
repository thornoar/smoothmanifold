import export;

settings.render = 8;

size(10cm);
exportparams(bgpen = paleyellow, margin = 1 cm, exit = false);

smooth sm = samplesmooth(3).view(dir(-35));

draw(sm, explain = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture (plain mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture (cartesian mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = free, sectionpen = linewidth(.5));
export(prefix = "picture (free mode)", format = "pdf");

exit();
