import export;

settings.render = 4;

size(25cm);
// expar(dpi = 200, bgpen = paleyellow, ymax = 2.2, ratio = 1, clip = false, close = false);
export.rasterdensity = 200;
export.background = paleyellow;
export.enclose = true;
export.corner = (2.2,2.2);
export.clip = false;
export.animations.close = false;
currentpen = linewidth(2.2);
// smpar(sectionpenscale = .5, viewdir = dir(-45));
config.drawing.sectpenscale = .5;
config.drawing.viewdir = dir(-45);

pair shift = (.8,.6);
smooth sm = samplesmooth(2);
int n = 30;

void animate (int mode)
{
	config.drawing.mode = mode;
	move(sm = sm, n = n, shift = shift, back = false);
	move(sm = sm, n = n, shift = -shift, scale = 1.2, rotate = 100, back = false);
	move(sm = sm, n = n, scale = 1/1.2, rotate = -100, back = false);
	compile(fps = n, outprefix = "animation."+mode(mode), outformat = "mp4", exit = false);
}

animate(mode = free);
animate(mode = cartesian);

exit();
