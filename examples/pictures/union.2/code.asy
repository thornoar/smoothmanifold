import smoothmanifold;
settings.render = 16;

size(20 cm);
background(paleyellow);

smooth sm1 = samplesmooth(3).move(rotate = 60);
smooth sm2 = samplesmooth(3,1).move(shift = (1.7,0), rotate = -90);
smooth sm3 = samplesmooth(2).move(shift = (3.3, -.3), rotate = 10);

smooth union = unite(sm1, sm2, sm3, round = true).view(dir(75));

void draw ()
{ draw(union); }

draw();
produce("picture", "pdf", 1 cm, exit = false);
erase();
explain(true);
draw();
produce("picture (marked)", "pdf", 1 cm);
