import export;

size(20 cm);
defaultpen(.7);
expar(margin = 1cm, bgpen = paleyellow);
smpar(dashop = .2);

smooth sm1 = samplesmooth(2).move(shift = (-.7,-.1), rotate = -40).view(angle = 39);
smooth sm2 = samplesmooth(1,1).move(shift = (.25,-.11), rotate = -20);

draw(sm1, plain);
draw(sm2, plain);

export(prefix = "picture", format = "pdf");
