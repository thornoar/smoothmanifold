import export;

size(20 cm);
defaultpen(.7);
expar(margin = 1cm, bgpen = paleyellow);
smpar(dashop = .2, gaplength = .05);

smooth sm1 = samplesmooth(2).move(shift = (-.7,-.1), rotate = -40);
smooth sm2 = samplesmooth(1,1).move(shift = (.25,-.11), rotate = -20);

draw(sm1, dpar(plain));
draw(sm2, dpar(plain));

export(prefix = "picture", format = "pdf");
