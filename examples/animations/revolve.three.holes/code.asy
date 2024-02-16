import export;
settings.render = 4;

import graph;

size(25cm);
expar(dpi = 50, informat = "jpg", outformat = "gif", close = false, ymax = 1.6, ratio = 1, clip = false);
smpar(sectionpenscale = .5, scavoidsubsets = true, shiftsubsets = true, dash = false, scfreedom = .1);
defaultpen(linewidth(1.2));

pair viewdir0 = (0,0);
pair viewdir1 = dir(0);
pair viewdir2 = dir(180);
pair viewdir3 = dir(90);
pair viewdir4 = dir(-90);

smooth sm = samplesmooth(3).rmsubset(0).move(shift = (-.15,0));

int n = 30;

revolve(sm = sm, viewdir1 = viewdir0, viewdir2 = viewdir1, back = false, n = n);
revolve(sm = sm, viewdir1 = viewdir1, viewdir2 = viewdir3, back = false, n = 2*n);
revolve(sm = sm, viewdir1 = viewdir3, viewdir2 = viewdir4, back = false, n = 2*n);
revolve(sm = sm, viewdir1 = viewdir4, viewdir2 = viewdir2, back = false, n = 2*n);
revolve(sm = sm, viewdir1 = viewdir2, viewdir2 = viewdir0, back = false, n = n);
compile(fps = n, outprefix = "animation", exit = true);
