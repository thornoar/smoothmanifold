include common;

settings.render = 8;

size(0, 3.8cm);

config.arrow.absmargins = true;
config.drawing.gaplength = .1;
config.drawing.attachedopacity = .9;
config.drawing.underdashes = true;
config.drawing.smoothfill = gray(.92);

smooth sm = samplesmooth(1)
    .setlabel("M", dir = dir(-10))
    .setsection(0, new real[] {153, 270, 9})
    .rotate(20);

smooth ts = tangentspace(
    sm = sm,
	hlindex = -1,
	angle = 65,
	ratio = .8,
	rotate = 10,
	size = .7
);

draw(sm, dpar(mode = free, viewdir = 1.5*dir(-25), overlap = false));
