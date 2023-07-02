import "smoothmanifold.asy" as smooth;

settings.render = 8;

size(15cm);

smooth sm1 = samplesmooth(1).set_label("$M$", dir(140));
sm1.subsets.delete();
smooth sm2 = samplesmooth(2).set_label("$N$", dir(-30));

sm2.move(shift = (1,-.2));

pair viewdir = dir(45);

draw(sm1, viewdir = viewdir);
draw(sm2, viewdir = viewdir);

draw_intersection(sm1, sm2, shift = (0, -2.5), labeldir = S, labelalign = 2*S, viewdir = viewdir);

shipout(prefix = "picture", format = "pdf");