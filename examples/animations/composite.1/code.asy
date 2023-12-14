import export;

size(25 cm);
setframe(2);
exportparams(bgpen = paleyellow);
defaultpen(linewidth(1.2));
animationparams(informat = "jpg");
drawparams(sectionpen = linewidth(.6));

smooth sm1 = samplesmooth(3).move(shift = (-1.7,.1), scale = 1.2);
smooth sm2 = samplesmooth(1,0).move(shift = (1.9,.1), scale = .9);

int n = 90;

void update (int i)
{
	sm1.simplemove(rotate = 360/n);
	sm2.simplemove(rotate = 360/n);
	draw(sm1, plain);
	draw(sm2, plain);
	drawarrow(sm1, sm2, curve = .4);
	drawarrow(sm2, sm1, i(0), i(0), curve = .4);
}

animate(outprefix = "animation", outformat = "mp4", update = update, n = n, fps = ceil(n/3), compile = true);
exit();
