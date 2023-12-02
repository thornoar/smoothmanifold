import export;

settings.render = 8;

size(30 cm);
exportparams(bgpen = paleyellow, margin = 1.5 cm, exit = false);

pair viewdir = dir(40);

smooth sm1 = samplesmooth(3).setlabel("M", dir(140)).view(viewdir);
smooth sm2 = samplesmooth(2).setlabel("N", dir(-30)).view(viewdir);
sm2.move(shift = (0,-1.5), scale = 1.1, rotate = 10);
smooth union = union(sm1, sm2, round = false)[0];
union.setlabel(labeldir = dir(110));
union.addholesection(0, a(1, -.15, 40, 1));
union.move(shift = (3.5,0));

draw(sm1, explain = false, mode = plain);
draw(sm2, explain = false, mode = plain);
draw(union, explain = true, mode = plain);
export(prefix = "picture (plain mode)", format = "pdf");

erase();

draw(sm1, explain = false, mode = strict);
draw(sm2, explain = false, mode = strict);
draw(union, explain = true, mode = strict);
export(prefix = "picture (strict mode)", format = "pdf");

erase();

draw(sm1, explain = false, mode = cartesian);
draw(sm2, explain = false, mode = cartesian);
draw(union, explain = true, mode = cartesian);
export(prefix = "picture (cartesian mode)", format = "pdf");

erase();

draw(sm1, explain = false, mode = free);
draw(sm2, explain = false, mode = free);
draw(union, explain = true, mode = free);
export(prefix = "picture (free mode)", format = "pdf");

exit();
