import export;
settings.render = 16;

size(25 cm);
defaultpen(.7);
smpar(gaplength = .12, shiftsubsets = true, fill = true);
expar(bgpen = paleyellow, margin = 2 cm);

pair viewdir = dir(25);

smooth sm1 = samplesmooth(3,0).move(rotate = -50);
sm1.setlabel("M", dir = dir(100));
sm1.setlabel(0, label = "U", dir = dir(180));
sm1.view(viewdir);

smooth sm2 = samplesmooth(1).move(shift = (4,0), rotate = 90);

sm2.rmsubset(0);
sm2.addsubset(contour = convexpath[4], shift = (.55,.8), scale = .26, rotate = -20);
sm2.addsubset(contour = concavepath[2], shift = (0,.15), scale = .49, rotate = 150).setlabel(1, "W", dir = dir(-110));
sm2.addsubset(1, contour = convexpath[2], shift = (-.25,.4), scale = .25, rotate = 0);
sm2.addsubset(1, contour = convexpath[1], shift = (.45,.17), scale = .17, rotate = -20);
sm2.movesubset(1, recursive = true, rotate = -10);
sm2.setlabel("N", dir = dir(-30));
sm2.setlabel(0, label = "V", dir = dir(150));
sm2.view(viewdir, false);

draw(sm1);
draw(sm2, shade = true, dash = false);

drawarrow(sm1, sm2, curve = -.15, L = Label("f", align = Relative(W)));
drawarrow(sm1, sm2, index1 = 0, index2 = 0, curve = .34, L = Label("f_U", position = Relative(.4)));
drawarrow(sm2, sm1, index1 = 1, index2 = 0, curve = .4, L = "g");
drawarrow(sm1, 0, angle = 190, radius = .62, L = Label("\mathrm{id}_U", position = Relative(.22), align = Relative(W)));
drawarrow(sm2, 1, angle = -63, radius = .8, reverse = true, L = Label("\mathrm{id}_W", position = Relative(.45), align = Relative(E)));
drawarrow(sm2, 2, angle = 150, radius = .7);
drawarrow(sm1, angle = 70, radius = .9, L = Label("\mathrm{id}_M", align = Relative(W)));

export("picture", "pdf");
