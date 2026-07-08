include common;

size(5cm);
// defaultpen(1pt);

pen ghost = gray(.7);

path p1 = (0,0){(.1,1)} .. (.3,.6) .. {(1,-1)}(2,.7);
path p2 = (.5,-.0){(.7,1)} .. {(1,-.7)}(1.9,.0);

// p1 = reflect((0,0),(1,0)) * p1;
// p2 = reflect((0,0),(1,0)) * p2;

draw(p1 ^^ p2, ghost);

pair[] ps = sectionparams(p1, p2, 5, .9, 100)[2];
// write(ps.length);
path[] ell = sectionellipse(ps[0], ps[1], ps[2], ps[3], .2*dir(40));

draw(ell[0], ghost);
draw(ell[1], dashed + ghost);

draw(ps[0] -- ps[1]);
draw((ps[0] - .4*ps[2]) -- (ps[0] + .4*ps[2]));
draw((ps[1] - .4*ps[3]) -- (ps[1] + .4*ps[3]));
draw(arc(ps[0], ps[0] + .1*ps[2], ps[1], CCW));
draw(arc(ps[1], ps[1] + .1*ps[3], ps[0], CW));

draw((0,0) .. (0,-.05), invisible);

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
