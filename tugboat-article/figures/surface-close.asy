include common;

size(5cm);
// defaultpen(1pt);

path p1 = (0,0){(.1,1)} .. (.3,.6) .. {(1,-1)}(2,.7);
path p2 = (.5,-.2){(.5,1)} .. {(1,-1)}(1.9,-.3);

draw(p1 ^^ p2);

pair[] params = sectionparams(p1, p2, 1, .9, 100)[0];
write(params.length);
path[] ell = sectionellipse()

// smooth sm = 
//     smooth(
//         contour = concavepaths[4]
//     )
//     .addhole(convexpaths[6], scale = .35, shift = (.55,.53), rotate = 60, sections = rr(50, 250, 4))
//     .addsubset(convexpaths[3], scale = .5, shift = (-.5,-.2))
//     ;
//
// draw(sm, dpar(mode = free, viewdir = dir(40), help = true, drawnow =
// true));
//
// drawdelayed();
//
// path cp = circle((.64,1.16), .4);
// clip(cp);
// draw(cp);
