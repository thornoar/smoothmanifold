import smoothmanifold as smooth;

settings.render = 4;

import graph;

size(25cm);
background(paleyellow);

setframe(2.2, 1);
quality(250);
animationclose(false);

defaultpen(linewidth(2.2));
sectiondraw(thickness = 1.1);

pair shift = (.8,.6);
pair viewdir = dir(-45);

smooth sm = samplesmooth(2).view(viewdir);

int frames = 40;

move(sm = sm, shift = shift, frames = frames, back = false);
move(sm = sm, shift = -shift, scale = 1.2, rotate = 100, frames = frames, back = false);
move(sm = sm, scale = 1/1.2, rotate = -100, frames = frames, back = false);

compile(fps = frames, outformat = "mp4");

printtime();
exit();
