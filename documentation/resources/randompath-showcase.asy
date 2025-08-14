include common;
size(15cm);

real angle = 60;
pair[] ctrl = {
    (0,0), (.7,.5), (1.5,.2), (2.3,0.4), (3.1,.1)
};
pair[] aligns = {
    (-1.5,0), (-.2,1.6), (.1,1.6), (0,1.5), (1.5,0)
};
real sc = .6;
srand(10);
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
draw(randompath(ctrl, angle));
for (int i = 0; i < ctrl.length; ++i) {
    pair c = ctrl[i];
    if (i < ctrl.length-1) {
        pair d;
        if (i > 0) d = ctrl[i+1] - ctrl[i-1];
        else d = ctrl[1] - ctrl[0];
        real dd = degrees(d);
        draw(c -- (c + sc*dir(dd + angle/2)), red+.7);
        draw(c -- (c + sc*dir(dd - angle/2)), red+.7);
        fill(c -- arc(c, c + sc*dir(dd + angle/2), c + dir(dd - angle/2), CW) -- cycle, red + opacity(.1));
        if (i == 1) {
            real sa = 10;
            real sca = .05;
            draw(
                arc(c, c + (sc + sca)*dir(dd + angle/2 - sa), c + dir(dd - angle/2 + sa), CW),
                red + .7,
                arrow = Arrow(SimpleHead),
                L = Label("\texttt{angle}", position = MidPoint, align = Relative(W))
            );
        }
    }
    dot(c, L = Label("\texttt{"+(string)i+"}", align = aligns[i]));
}
