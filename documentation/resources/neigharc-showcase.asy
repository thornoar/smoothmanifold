include common;
size(12cm);

real w = .1, h = .2, x = 1;

draw((x,h) -- (x+2*w,h), dotted);
draw((x,0) -- (x,1.5*h), dotted);
draw((x+w,0) -- (x+w,h) -- (x+w,1.5*h), dotted);
draw((.2,0) -- (2,0));
draw(neigharc(x, h, w), red+.7, arrow = Arrow(SimpleHead), L = Label("\texttt{neigharc}", position = EndPoint, align = 1*E));

draw((x + 2*w, 0) -- (x + 2*w, h), blue, arrow = Arrows(TeXHead), L = Label("\texttt{h}", position = MidPoint, align = 1*E));
draw((x, 1.5*h) -- (x + w, 1.5*h), blue, arrow = Arrows(TeXHead), L = Label("\texttt{w}", position = MidPoint, align = 1*N));

draw((x - 5*w, -.5*h) -- (x - 2*w, -.5*h), blue, arrow = Arrow(SimpleHead), L = Label("\texttt{dir}", position = MidPoint, align = 1.5*S));

dot(x, L = Label("\texttt{x}", align = S+W));
