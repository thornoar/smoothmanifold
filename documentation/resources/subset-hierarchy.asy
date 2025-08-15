include common;
size(13cm);
config.drawing.subsetfill = new pen[]{lightred, lightyellow, lightgreen, lightblue};
config.drawing.subpenfactor = .1;
path cntr = intersection(
    xscale(5) * usquare,
    xscale(2) * yscale(1.5) * usquare,
    round = true,
    roundcoeff = .03
)[0];
smooth sm = smooth(contour = cntr)
.addsubsets(
    shift((-1.3,.4)) * scale(.5) * convexpaths[3],
    shift((-0.8,.4)) * scale(.5) * convexpaths[2],
    shift((-1.2,-.2)) * scale(.5) * convexpaths[5],
    shift((-0.4,-.5)) * scale(.5) * concavepaths[2],
    shift((0.0,.3)) * scale(.5) * rotate(180) * concavepaths[5],
    shift((-0.05,.25)) * scale(.5) * convexpaths[1],
    shift((0.15,-.25)) * scale(.5) * convexpaths[7],
    shift((-1.4,-.3)) * scale(.2) * convexpaths[2],
    shift((1.2,.3)) * scale(.6) * convexpaths[2],
    shift((1.2,.3)) * scale(.4) * convexpaths[4],
    shift((1.2,.3)) * scale(.25) * rotate(-50) * convexpaths[6],
    shift((1.25,-.1)) * scale(.6) * reflect((0,0), (0,1)) * rotate(-90) * concavepaths[2],
    shift((.7,-.6)) * scale(.3) * convexpaths[3],
    unit = false
)
;
draw(sm);
