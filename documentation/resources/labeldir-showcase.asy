include common;
size(7cm);

path cntr = rotate(20)*convexpaths[4];
pair ctr = (0,-.1);
pair ldir = dir(130);
pair lalign = unit((.3,1));
pair pnt = intersection(cntr, ctr, ldir);

draw(cntr);
draw(ctr -- pnt, red + .7, arrow = Arrow(SimpleHead), L = Label("\texttt{labeldir}", position = MidPoint, align = Relative(E)));
draw(pnt -- (pnt + .5*lalign), blue+.7, arrow = Arrow(SimpleHead), L = Label("\texttt{labelalign}", position = EndPoint, align = Relative(E)));
label(currentpicture, position = pnt, "$S$", align = 2*lalign, filltype = Fill(white));
label(intersection(cntr, ctr, dir(0)), "\texttt{contour}", align = E);
dot(ctr);
dot(pnt);
