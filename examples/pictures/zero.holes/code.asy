import export;

settings.render = 8;

size(10cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1 cm);

smooth sm = samplesmooth(0, 2).view(dir(-35));

draw(sm, help = true, dash = true, mode = plain, sectionpen = linewidth(.5));
export(prefix = "picture_plain", format = "pdf");
erase();

draw(sm, help = true, dash = true, mode = cartesian, sectionpen = linewidth(.5));
export(prefix = "picture_cartesian", format = "pdf");
erase();
