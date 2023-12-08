import export;
settings.render = 16;

size(20 cm);
exportparams(bgpen = paleyellow);
drawparams(smoothfill = lightcyan, subsetfill = lightblue, dash = false);

arrowparams(.12);

pair viewdir = dir(-50);

smooth sm1 = samplesmooth(1,2).view(viewdir);
sm1.setlabel(i(0), "U", labeldir = S);
sm1.setlabel(i(1), "V", labeldir = dir(70));
sm1.setlabel(i(0,0), "U \cap V", angle = 110);
smooth sm2 = samplesmooth(0,2).move(shift = (4,-.2), scale = 1.2).setlabel(i(0), "W", E+3*N).view(viewdir);

void draw ()
{
	draw(sm1);
	draw(sm2, mode = cartesian);

	drawarrow(sm1, sm2, curve = -.4);
	drawarrow(sm1, sm2, i(2), i(0), curve = -.1);
	drawarrow(sm2, sm1, i(0), i(0), curve = -.2);
	drawarrow(sm2, angle = 95, radius = 1.1);
}

draw();
export("picture", "pdf", 1.5 cm, exit = false);
erase();
drawparams(fill = false);
draw();
export("picture (hollow)", "pdf", 1.5 cm);
