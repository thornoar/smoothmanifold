include common;
size(7cm);

draw((-1.2,-1)--(2.4,2), red);
draw((-2.4,-1)--(3,1), blue);
draw(shift((-2,2)) * unitcircle);
draw(shift((1,1)) * unitcircle, deepgreen);

drawgrid(places = 1, number = 4);
