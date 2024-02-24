import export;

settings.render = 8;

size(17 cm);
defaultpen(.8);
expar(bgpen = paleyellow);
smpar(gaplength = .09, dragop = .9, help = true);

smooth sm = samplesmooth(1).view(dir(-40))
    .setlabel("M")
    .setlabel(0, "S", S);

smooth ts = tangentspace(sm = sm, ind = -1, angle = 45, ratio = .8, rotate = 10, size = .7);

smooth rn = rn(n = 1)
    .move(shift = (2.5, .7), scale = .72)
    .setlabel("\mathbb{R}^n")
    .addsubset(contour = convexpath[9], shift = (.4,-.2), scale = .4, unit = true);

draw(sm, mode = free, overlap = true);
draw(rn, sectionpen = currentpen, smoothfill = invisible, contourpen = invisible, subsetcontourpen = currentpen, mode = cartesian);

drawarrow(ts, rn, endarrow = true, beginarrow = true, curve = -.2, L = Label("\cong", align = Relative(W)));
drawarrow(sm, 0, rn, 0, curve = .3, margin1 = .07, margin2 = .1, L = Label("f"));

export("picture", "pdf", 1 cm);
