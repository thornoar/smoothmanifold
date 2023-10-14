import smoothmanifold as smooth;

settings.render = 4;

import graph;

size(25cm);
background(paleyellow);

quality(300);
animationclose(false);

defaultpen(linewidth(2.2));
sectiondraw(thickness = 1.1);

pair xsh = (.03,0);
pair ysh = (0,.03);

pair viewdir0 = (0,0);
pair viewdir1 = dir(0);
pair viewdir2 = dir(180);
pair viewdir3 = dir(90);
pair viewdir4 = dir(-90);

setframe(1.6, 1);

smooth sm = samplesmooth(3).move(shift = (-.15,0));

int frames = 40;

revolve(sm = sm, viewdir1 = viewdir0, viewdir2 = viewdir1, shift = xsh, back = false, frames = frames);
revolve(sm = sm, viewdir1 = viewdir1, viewdir2 = viewdir3, shift = ysh-xsh, back = false, frames = 2*frames);
revolve(sm = sm, viewdir1 = viewdir3, viewdir2 = viewdir4, shift = -2*ysh, back = false, frames = 2*frames);
revolve(sm = sm, viewdir1 = viewdir4, viewdir2 = viewdir2, shift = -xsh+ysh, back = false, frames = 2*frames);
revolve(sm = sm, viewdir1 = viewdir2, viewdir2 = viewdir0, shift = xsh, back = false, frames = frames);

compile(outformat = "mp4", fps = frames);

printtime();
exit();
