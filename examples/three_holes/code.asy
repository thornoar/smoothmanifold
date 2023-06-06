import "Smooth.asy" as smooth;

settings.render = 8;

size(10cm);

smooth sm = samplesmooth(3);

pair viewdir = dir(-35);

draw(sm, explain = true, drawdashes = true, mode = "2d", sectionpen = linewidth(.5));

shipout(prefix = "picture (2d mode)", format = "pdf");

erase();

draw(sm, viewdir = viewdir, explain = true, drawdashes = true, mode = "free", sectionpen = linewidth(.5));

shipout(prefix = "picture (free mode)", format = "pdf");

erase();

draw(sm, viewdir = viewdir, explain = true, drawdashes = true, mode = "cart", sectionpen = linewidth(.5));

shipout(prefix = "picture (cartesian mode)", format = "pdf");

erase();

draw(sm, viewdir = viewdir, explain = true, drawdashes = true, mode = "naive", sectionpen = linewidth(.5));

shipout(prefix = "picture (naive mode)", format = "pdf");