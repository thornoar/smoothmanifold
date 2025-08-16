import export;
settings.render = 16;

size(15cm);
defaultpen(.7);

config.section.freedom = .5;
config.drawing.viewdir = dir(45);
config.drawing.mode = free;
config.system.insertdollars = true;

export.background = paleyellow;

smooth sm1 = samplesmooth(1).setlabel("M", dir(140));
sm1.subsets.delete();

smooth sm2 = samplesmooth(2).setlabel("N", dir(-30));
sm2.move(shift = (1,-.2));

drawintersect(sm1, sm2, shift = (0, -2.5), labeldir = dir(-55), labelalign = (4,-1.5));

export("picture", "pdf", 1 cm);
