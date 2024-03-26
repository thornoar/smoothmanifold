import export;

settings.render = 8;
settings.outformat = "pdf";

size(10cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1 cm, exit = false);
smpar(scavoidsubsets = true);

smooth sm = samplesmooth(1).view(dir(-40));

draw(sm, help = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture_plain");
erase();

draw(sm, help = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture_cartesian");
erase();

draw(sm, help = true, dash = true, mode = free, sectionpen = linewidth(.5));
export(prefix = "picture_free");

exit();
