import export;

settings.render = 8;

size(20 cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1.5 cm);
smpar(dash = false, viewdir = dir(40), mode = free);

smooth sm1 = samplesmooth(3).setlabel("M", dir(140));
smooth sm2 = samplesmooth(2).setlabel("N", dir(-30));
sm2.move(shift = (0,-1.5), scale = 1.1, rotate = 10);
smooth union = union(sm1, sm2, round = false)[0];
union.setlabel(dir = dir(110));
union.addsection(0, r(1, -.15, 40, 1));
union.move(shift = (3.5,0));

draw(sm1);
draw(sm2);
draw(union, dpar(help = true));
export(prefix = "picture", format = "pdf");
