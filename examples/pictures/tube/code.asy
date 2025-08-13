import export;
config.drawing.fill = false;
config.drawing.postdrawover = true;
config.drawing.viewdir = (1,0);
config.system.insertdollars = false;
size(10cm);

real w = .2;
real h = .35;
path arch = (-1,0){(1,0)} .. (-.8,0){(1,0)} .. (-w,h) .. (w,h) .. {(1,0)}(.8,0) .. {(1,0)}(1,0);

real th = .5;
config.drawing.gaplength = th;

smooth sm = smooth(
    contour = (shift((0,th/2)) * arch) & ((1,th/2) -- (1,-th/2)) & (shift((0,-th/2)) * reflect((0,0), (1,0)) * reverse(arch)) & ((-1,-th/2) -- (-1,th/2)) & cycle,
    holes = new hole[]{
        hole(
            contour = yscale(0.9) * scale(.35) * ucircle,
            sections = new real[][] {
                r(45,5,1),
                r(135,5,1),
                r(225,5,1),
                r(315,5,1)
            }
        )
    },
    vratios = r(.05,.5,.95),
    hratios = r(),
    postdraw = new void(dpar dspec, smooth smp) {
        fitpath(smp.unitadjust * ((-1.3,0) -- (-.9,0)), invisible);
        fitpath(smp.unitadjust * ((.9,0) -- (1.3,0)), invisible);
    }
);

dpar spec = dpar(mode = combined, contourpen = linewidth(.7));

draw(sm.copy().move(shift = (-3,0)), spec);
draw(sm, spec);

real o = .4;

drawsections(currentpicture, pp((-1-o+.1,th/2), (-1-o+.1,-th/2), (1,0), (1,0)), viewdir = config.drawing.viewscale * config.drawing.viewdir, dash = true, help = false, shade = false, scale = 1, sectionpen = blue, dashpen(blue), nullpen);
draw((-1-o, th/2) -- (-1, th/2), blue + .7);
draw((-1-o, -th/2) -- (-1, -th/2), blue + .7);
drawsections(currentpicture, pp((1+o-.1,th/2), (1+o-.1,-th/2), (1,0), (1,0)), viewdir = config.drawing.viewscale * config.drawing.viewdir, dash = true, help = false, shade = false, scale = 1, sectionpen = blue, dashpen(blue), nullpen);
draw((1+o, th/2) -- (1, th/2), blue + .7);
draw((1+o, -th/2) -- (1, -th/2), blue + .7);


smooth lab = node(
    "open",
    size = .3
).move(shift = (0,-1.1));

draw(lab, nodepar(blue));

drawarrow(
    sm1 = lab,
    finish = (-1-o/2, -th/2-.1),
    curve = -.16,
    blue
);
drawarrow(
    sm1 = lab,
    finish = (1+o/2, -th/2-.1),
    curve = .16,
    blue
);

export(prefix = "picture", xmargin = .5cm);
