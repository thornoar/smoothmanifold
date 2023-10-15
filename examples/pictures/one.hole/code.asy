import smoothmanifold;

settings.render = 8;
settings.outformat = "pdf";

size(10cm);
setproduce(bgpen = paleyellow, exit = false, margin = 1 cm);

smooth sm = samplesmooth(1).setview(dir(-35));

draw(sm, explain = true, dash = true, mode = "plain", sectionpen = linewidth(.5));
produce(prefix = "picture (plain mode)");
erase();

draw(sm, explain = true, dash = true, mode = "strict", sectionpen = linewidth(.5));
produce(prefix = "picture (strict mode)");
erase();

draw(sm, explain = true, dash = true, mode = "cart", sectionpen = linewidth(.5));
produce(prefix = "picture (cartesian mode)");
erase();

draw(sm, explain = true, dash = true, mode = "free", sectionpen = linewidth(.5));
produce(prefix = "picture (free mode)");

printtime();
exit();
