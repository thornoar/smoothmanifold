include common;
config.section.freedom = .9;
size(5cm);
smooth s = smooth(
  ellipse((0,0), 2, 1)
).addhole(ellipse((0,0), 1.1, .37), sections = new real[][]{
  r(0, 60, 3), r(90, 90, 1), r(180, 60, 3), r(270, 90, 1)
});
draw(s, dpar(mode = free, viewdir = 3.0*dir(90), help = false));
