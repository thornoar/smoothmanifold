import export;
settings.render = 16;

size(20 cm);
defaultpen(.7);

export.background = paleyellow;

smooth sm1 = samplesmooth(3).move(rotate = 60);
smooth sm2 = samplesmooth(3,1).move(shift = (1.7,0), rotate = -90);
smooth sm3 = samplesmooth(2).move(shift = (3.3, -.3), rotate = 10);

draw(unite(sm1, sm2, sm3, round = true), dpar(viewdir = dir(75), mode = free));

export("picture", "pdf", 1 cm);
