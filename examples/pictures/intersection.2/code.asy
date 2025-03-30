import export;

settings.render = 16;
settings.outformat = "pdf";

size(15 cm);
defaultpen(.7);

export.background = paleyellow;
export.margin = 1cm;
export.autoexport = false;

config.section.freedom = .8;
config.smooth.interholenumber = 2;
config.smooth.interholeangle = 50;

smooth sm1 = samplesmooth(3,1)
    .move(scale = 1.1);
smooth sm2 = samplesmooth(1,1)
    .move(shift = (.5,.23), rotate = -60)
    .rmsubset(0);

dpar ds = ghostpar();
draw(sm1, ds);
draw(sm2, ds);

smooth sm3 = intersect(sm1, sm2);
sm3.setsection(1, 0, r(-1.5,4,230,7));
sm3.setsection(0, 0, r(2,-1,230,dn));

draw(sm3, dpar(help = false, mode = free, viewdir = dir(45)));

export(prefix = "picture");
