include common;
size(10cm);

smooth sm = smooth(contour = convexpaths[2]);
draw(sm);

hole hl = hole(contour = convexpaths[3], scale = .7, shift = (.8,.3));
sm.addhole(hl);

pair sh = (5,0);
sm.addhole(hl, clip = true);
sm.shift(sh);

draw((1.9,0)--(3.6,0), arrow = Arrow(SimpleHead), L = Label("\texttt{addhole}", position = MidPoint, align = 2.5*S));

draw(sm);
