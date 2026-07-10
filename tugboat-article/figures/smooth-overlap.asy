include common;

size(7cm);

config.drawing.underdashes = true;
config.drawing.gaplength = 0.15;

draw(
    samplesmooth(2), dpar(mode = free, viewdir = dir(30))
);
draw(samplesmooth(0).shift((1.2,.1)), dpar(mode = plain, viewdir =
dir(-50)));
