import smoothmanifold;
config.drawing.fill = false;
config.drawing.drawextraover = true;
config.drawing.viewdir = (1,0);
config.system.insertdollars = false;
size(5cm);

real w = .2;
real h = .35;
path arch = (-2,0){(1,0)} .. (-.85,0){(1,0)} .. (-w,h) .. (w,h) .. {(1,0)}(.85,0) .. {(1,0)}(2,0);

real th = .5;
config.drawing.gaplength = th;

smooth sm = smooth(
    contour = (shift((0,th/2)) * arch) & ((2,th/2) -- (2,-th/2)) & (shift((0,-th/2)) * reflect((0,0), (2,0)) * reverse(arch)) & ((-2,-th/2) -- (-2,th/2)) & cycle,
    holes = new hole[]{
        hole(
            contour = yscale(0.9) * scale(.35) * unitcircle,
            sections = new real[][] {
                r(45,5,1),
                r(135,5,1),
                r(225,5,1),
                r(315,5,1)
            }
        )
    },
    vratios = r(.05,.165,.28,.5,.72,.835,.95),
    hratios = r(),
    drawextra = new void(dpar dspec, smooth smp) {
        fitpath(smp.unitadjust * ((-1.55,0) -- (-1.1,0)), invisible);
        fitpath(smp.unitadjust * ((1.1,0) -- (1.55,0)), invisible);
    }
);

dpar spec = dpar(mode = combined, contourpen = linewidth(.7));

draw(sm, spec);
