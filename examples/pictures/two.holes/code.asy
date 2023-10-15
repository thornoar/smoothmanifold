import smoothmanifold;

settings.render = 8;

size(10 cm);
setproduce(bgpen = paleyellow, margin = 1 cm, exit = false);

pair viewdir = dir(-35);
smooth sm = samplesmooth(2).view(viewdir);

draw(sm, explain = true, dash = true, mode = "plain", sectionpen = linewidth(.5));
produce(prefix = "picture (plain mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = "strict", sectionpen = linewidth(.5));
produce(prefix = "picture (strict mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = "cart", sectionpen = linewidth(.5));
produce(prefix = "picture (cartesian mode)", format = "pdf");
erase();

draw(sm, explain = true, dash = true, mode = "free", sectionpen = linewidth(.5));
produce(prefix = "picture (free mode)", format = "pdf");

printtime();
exit();
