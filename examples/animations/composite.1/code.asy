import smoothmanifold;

size(25 cm);
setframe(2);
exportparams(bgpen = paleyellow);
defaultpen(linewidth(1.2));
drawparams(sectionpen = linewidth(.6));

pair viewdir = dir(45);

smooth sm1 = samplesmooth(3).move(shift = (-1.7,.1), scale = 1.2).view(viewdir);
smooth sm2 = samplesmooth(1,0).move(shift = (1.9,.1), scale = .9).view(viewdir, shiftsubsets= false);

int n = 90;

void update (int i)
{
	sm1.move(rotate = 360/n);
	sm2.move(rotate = 360/n);
	draw(sm1);
	draw(sm2);
	drawarrow(sm1, sm2, curve = .4);
	drawarrow(sm2, sm1, i(0), i(0), curve = .4);
	flushcache();
}

animate(outprefix = "animation", update = update, n = n, fps = ceil(n/3));
exit();
