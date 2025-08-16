include common;
size(7cm);

pair p1 = (1,1), p2 = (4,1);
pair dir1 = dir(55), dir2 = dir(140);
pair viewdir = .2*dir(90);
path[] ell = sectionellipse(p1, p2, dir1, dir2, viewdir);

draw(p1 -- (p1 + 1.5*dir1), red, arrow = Arrow(SimpleHead), L = Label("\texttt{dir1}", position = EndPoint, align = N));
draw(p2 -- (p2 + 1.5*dir2), red, arrow = Arrow(SimpleHead), L = Label("\texttt{dir2}", position = EndPoint, align = N));
draw(p1 -- p2);
draw(ell[0], deepgreen, L = Label("\texttt{ell[0]}", position = Relative(.4), align = Relative(W)));
draw(ell[1], blue, L = Label("\texttt{ell[1]}", position = Relative(.35), align = Relative(1.5*W)));
draw(((p1+p2)/2) -- ((p1+p2)/2 + 8*viewdir), purple, arrow = Arrow(SimpleHead), L = Label("\texttt{viewdir}", position = EndPoint, align = N));
dot((p1+p2)/2, purple);
dot(p1, L = Label("\texttt{p1}", align = W));
dot(p2, L = Label("\texttt{p2}", align = E));
dot(point(ell[0], 0), deepgreen);
dot(point(ell[1], 0), blue);
