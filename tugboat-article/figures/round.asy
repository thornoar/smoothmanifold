include common;

size(6cm);

path p = concavepaths[2];
path q = concavepaths[0];

draw(p, gray(.7), L = Label("\texttt{p}", black, position = Relative(.55), align = Relative(E)));
draw(q, gray(.7), L = Label("\texttt{q}", black, position = Relative(.85), align = Relative(E)));

path[] inter = intersection(p, q, true, 0.02);

filldraw(inter, drawpen = black, fillpen = gray(.8));
label(center(inter[0]) + (.2,0), minipage("\texttt{intersection\\(p, q, true, 0.02)}", width = 4cm));
