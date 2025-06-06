import export;

settings.render = 8;

size(15cm);
defaultpen(.7);

export.background = paleyellow;

real x = 3.5;
real y = -1.6;

for (int i = 0; i < concavepaths.length; ++i)
{ draw(concavepaths[i]); }

draw(unitcircle, red);
label((0,y), "Default concave paths");

for (int i = 7; i < convexpaths.length; ++i)
{ draw(shift((x,0))*convexpaths[i]); }

draw(shift((x,0))*unitcircle, red);
label((x,y), "Default convex paths");

export("picture", "pdf", 2 cm);
