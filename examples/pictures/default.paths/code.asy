import smoothmanifold;

settings.render = 8;

size(15cm);
setproduce(bgpen = paleyellow);

real x = 3;
real y = -1.6;

for (int i = 0; i < concavepath.length; ++i)
{ draw(concavepath[i]); }

draw(unitcircle, red);
label((0,y), "Default concave paths");

for (int i = 0; i < convexpath.length; ++i)
{ draw(shift((x,0))*convexpath[i]); }

draw(shift((x,0))*unitcircle, red);
label((x,y), "Default convex paths");

produce("picture", "pdf", 2 cm);
