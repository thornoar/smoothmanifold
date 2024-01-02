import export;
settings.render = 16;

size(15cm);
expar(bgpen = paleyellow);

pair viewdir = dir(45);

smooth sm1 = samplesmooth(1).setlabel("M", dir(140)).view(viewdir);
sm1.subsets.delete();

smooth sm2 = samplesmooth(2).setlabel("N", dir(-30)).view(viewdir);
sm2.move(shift = (1,-.2));

void mydraw ()
{ drawintersect(sm1, sm2, shift = (0, -2.5)); }

mydraw();
export("picture", "pdf", 1 cm);
