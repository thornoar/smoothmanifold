import export;

settings.render = 4;

import graph;

size(25cm);
exportparams(dpi = 250, bgpen = paleyellow);

setframe(2.2, 1);
animationparams(close = false);

defaultpen(linewidth(2.2));
drawparams(sectionpen = linewidth(1.1));

pair shift = (.8,.6);
pair viewdir = dir(-45);
smooth sm = samplesmooth(2).view(viewdir);
int frames = 30;

void animate (int mode)
{
	drawparams(mode = mode);
	move(sm = sm, shift = shift, frames = frames, back = false);
	move(sm = sm, shift = -shift, scale = 1.2, rotate = 100, frames = frames, back = false);
	move(sm = sm, scale = 1/1.2, rotate = -100, frames = frames, back = false);
	compile(fps = frames, outprefix = "animation."+mode(mode), outformat = "mp4");
}

animate(mode = strict);
animate(mode = cartesian);

exit();
