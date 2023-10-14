import smoothmanifold;

settings.render = 16;

size(25 cm);
background(paleyellow);
overlaplength(.1);
setmargin(2 cm);

pair viewdir = dir(30);

smooth sm1 = samplesmooth(3,0).move(rotate = -50);
sm1.setlabel("M", labeldir = dir(100));
sm1.setlabel(ind = i(0), label = "U", labeldir = dir(180));
sm1.view(viewdir);

smooth sm2 = samplesmooth(1).move(shift = (4,0), rotate = 90);

sm2.rmsubset(i(0));
sm2.addsubset(contour = convexpath[4], shift = (.55,.8), scale = .26, rotate = -20);
sm2.addsubset(contour = concavepath[2], shift = (0,.15), scale = .49, rotate = 150).setlabel(i(1), "W", labeldir = dir(-110));
sm2.addsubset(ind = i(1), contour = convexpath[2], shift = (-.25,.4), scale = .25, rotate = 0);
sm2.addsubset(ind = i(1), contour = convexpath[1], shift = (.45,.17), scale = .17, rotate = -20);
sm2.movesubset(ind = i(1), recursive = true, rotate = -10);
sm2.setlabel("N", labeldir = dir(-30));
sm2.setlabel(i(0), label = "V", labeldir = dir(150));
sm2.view(viewdir, false);

void draw ()
{
	draw(sm1);
	draw(sm2, shade = true);

	drawarrow(sm1, sm2, curve = -.15, L = Label("$f$", align = Relative(W)));
	drawarrow(sm1, sm2, ind1 = i(0), ind2 = i(0), curve = .34, L = Label("$f_U$", position = Relative(.4)));
	drawarrow(sm2, sm1, ind1 = i(1), ind2 = i(0), curve = .4, L = "$g$");
	drawarrow(sm1, i(0), angle = 190, radius = .6, L = Label("$\mathrm{id}_U$", position = Relative(.75), align = Relative(W)));
	drawarrow(sm2, i(1), angle = -70, radius = .8, reverse = true, L = Label("$\mathrm{id}_W$", position = Relative(.45), align = Relative(E)));
	drawarrow(sm2, i(1,0), angle = 150, radius = .7);
	drawarrow(sm1, angle = 70, radius = .9, L = Label("$\mathrm{id}_M$", align = Relative(W)));
}

draw();
produce("picture", "pdf", exit = false);
erase();
explain(true);
draw();
produce("picture (marked)", "pdf");
