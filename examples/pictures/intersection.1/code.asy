import export;
settings.render = 16;

size(15cm);
exportparams(bgpen = paleyellow);

pair viewdir = dir(45);

smooth sm1 = samplesmooth(1).setlabel("M", dir(140)).view(viewdir);
sm1.subsets.delete();

smooth sm2 = samplesmooth(2).setlabel("N", dir(-30)).view(viewdir);
sm2.move(shift = (1,-.2));

void draw ()
{ drawintersect(sm1, sm2, shift = (0, -2.5)); }

draw();
export("picture", "pdf", 1 cm, exit = false);
erase();
drawparams(explain = true);
draw();
export("picture (marked)", "pdf", 1 cm);
