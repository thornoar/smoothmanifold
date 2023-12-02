import export;

settings.render = 8;

import graph;

size(15 cm);
exportparams(bgpen = paleyellow);
arrowparams(.09);
sectionparams(nl = 1);
drawparams(dragop = .7);

smooth sm = samplesmooth(1).setview(dir(-40)).setlabel(label = "M").setlabel(i(0), label = "S", labeldir = S);
smooth ts = tangentspace(sm = sm, ind = -1, angle = 45, ratio = .8, rotate = 10, size = .7);
smooth rn = rn(n = 1).move(shift = (2.5, .7), scale = .8).setlabel("\mathbb{R}^n", keepalign = true).move(scale = .9);
rn.addsubset(contour = convexpath[9], shift = (.4,-.2), scale = .4);

void draw ()
{
	draw(sm, mode = strict);
	draw(rn, sectionpen = currentpen, smoothfill = invisible, contourpen = invisible, subsetcontourpen = currentpen, mode = cartesian);

	drawarrow(ts, rn, arrow = Arrows(SimpleHead), curve = -.2, L = Label("$\cong$", align = Relative(W)));
	drawarrow(sm, rn, i(0), i(0), curve = .3, margin1 = .07, margin2 = .1, L = Label("$f$"));
}

draw();
export("picture", "pdf", 1 cm, exit = false);
erase();
drawparams(explain = true);
draw();
export("picture (marked)", "pdf", 1 cm);
