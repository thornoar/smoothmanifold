import smoothmanifold;

size(13cm);

config.drawing.drawnow = true;
config.drawing.gaplength = .1;

smooth U = smooth(
    contour = convexpaths[3],
    label = "$U$",
    labeldir = dir(120)
);

draw(U, dpar(smoothfill = palegreen, contourpen = dashed));

real mar = .03;
real penscale = .25;

void drawball (picture pic, pair pos, real rad, real ang) {
    filldraw(pic, circle(pos, rad), drawpen = orange+dashed, fillpen = paleyellow);
    draw(
        pic, (pos + mar*dir(ang)) -- (pos + (rad - mar) * dir(ang)), orange,
        L = Label("$\varepsilon$", position = MidPoint, align = Relative(W)),
        arrow = ArcArrows(SimpleHead)
    );
    dot(pic, pos);
}

drawball(currentpicture, (-.1,-.1), .6, 30);

pair c1 = (1,0);
pair x1 = (.97,0);
dot(x1);
real r1 = .1;
path p1 = circle(c1, r1);
real sc1 = 8;
pair sh1 = (2.1,0);

picture clip1 = currentpicture.copy();
clip(clip1, p1);
clip1 = shift(-c1)*clip1;
add(shift(sh1)*scale(sc1)*clip1);
pair s2b = unit(sh1 - c1);
draw((c1 + r1*s2b) -- (sh1 - sc1*r1*s2b));
draw(p1);
fitpath(shift(sh1)*scale(sc1)*shift(-c1)*p1, drawnow = false);
drawball(currentpicture, sh1 + sc1*(x1 - c1), .4, 100);

pair c2 = (2.42, -.4);
pair x2 = (2.4, -.4);
dot(x2);
real r2 = .12;
path p2 = circle(c2, r2);
real sc2 = 8;
pair sh2 = (4.1,0);

pair s2b = unit(sh2 - c2);
fitpath((path)((c2 + r2*s2b) -- (sh2 - sc2*r2*s2b)));
draw(p2);
draw(shift(sh2)*scale(sc2)*shift(-c2)*p2);
drawdelayed();
picture clip2 = currentpicture.copy();
clip(clip2, p2);
clip2 = shift(-c2)*clip2;
add(shift(sh2)*scale(sc2)*clip2);
drawball(currentpicture, sh2 + sc2*(x2 - c2), .55, -120);
