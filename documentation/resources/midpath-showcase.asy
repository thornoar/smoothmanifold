include common;
size(11cm);

path g = (0,.7){(4,1)} .. (1,1.3) .. (2,1) .. (3,1.1);
path h = (-.1,0) .. (1,-.1) .. (2.1,.1) .. (3.2,.1);
h = shift((0,.3))*h;

draw(g, L = Label("\texttt{g}", position = EndPoint, align = 1.5*Relative(N)));
draw(h, L = Label("\texttt{h}", position = EndPoint, align = 1.5*Relative(N)));
draw(
    midpath(g, h, n = 100),
    p = red + linewidth(1),
    L = Label("\texttt{midpath(g,h)}", position = EndPoint, align = 1.5*Relative(N))
);
