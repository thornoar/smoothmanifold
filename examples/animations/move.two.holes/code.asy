import export;

settings.render = 4;

// import graph;

size(25cm);
exportparams(dpi = 200);
setframe(bgpen = paleyellow, ymax = 2.2, ratio = 1);
animationparams(close = false);
currentpen = linewidth(2.2);
drawparams(sectionpenscale = .5);

pair shift = (.8,.6);
pair viewdir = dir(-45);
smooth sm = samplesmooth(2).view(viewdir);
int n = 30;

void animate (int mode)
{
	drawparams(mode = mode);
	move(sm = sm, n = n, shift = shift, back = false);
	move(sm = sm, n = n, shift = -shift, scale = 1.2, rotate = 100, back = false);
	move(sm = sm, n = n, scale = 1/1.2, rotate = -100, back = false);
	compile(fps = n, outprefix = "animation."+mode(mode), outformat = "mp4", exit = false);
}

animate(mode = free);
animate(mode = cartesian);

exit();
