include common;
usepackage("rotating");
config.drawing.gaplength = .1;
size(9cm);

path g = (-1,0){(1,2)} .. {(1,1)}(.5,1) .. {(2,1)}(1.2,1.5) .. {(1,0)}(3,1.5);
pair ctr = (1.4,.2);
real dirang = 120;
pair dir = dir(dirang);
real ang = 70;
real l = 1.6;
real l2 = .8;

draw(g, L = Label("\texttt{g}", position = EndPoint, align = (1,0)));
fitpath(
    ctr -- (ctr + l*dir),
    blue,
    arrow = DeferredArrow(SimpleHead),
    L = Label("\texttt{dir}", position = EndPoint, align = .7*(1,1))
);
path a = arc(ctr, ctr + l2*dir(dirang - ang/2), ctr + l*dir(dirang + ang/2), CCW);
int lang = floor(dirang - ang/4);
fitpath(
    a,
    deepgreen,
    arrow = DeferredArrow(SimpleHead),
    L = Label(
        "
            \begin{turn}{"+(string)(lang - 90)+"}
                \texttt{ang}
            \end{turn}
        ",
        position = Relative((lang - dirang + ang/2)/ang),
        align = .05*Relative((1,0))
    )
);
drawdeferred();
// labelpath(currentpicture, subpath(a, 0, 2), L = Label("\texttt{ang}", position = Relative(.5)), p = deepgreen);
draw(ctr -- (ctr + l*dir(dirang - ang/2)), blue);
draw(ctr -- (ctr + l*dir(dirang + ang/2)), blue);
pair r = range(g, ctr, dir, ang);
draw(subpath(g, r.x, r.y), red+linewidth(1.5));


dot(ctr, L = Label("\texttt{center}", align = (1.5,0)));
