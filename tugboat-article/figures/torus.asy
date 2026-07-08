import smoothmanifold;
config.section.freedom = .9;
size(5cm);
smooth s = smooth(
  ellipse((0,0), 2, 1)
).addhole(ellipse((0,0), 1.1, .37), sections = new real[][]{
  r(0, 60, 3), r(90, 90, 1), r(180, 60, 3), r(270, 90, 1)
  // r(0, 170, 3), r(180, 170, 3)
});
// smooth s = smooth(
//   circle((0,0), 1)
// ).addhole(circle((0,0), .5), sections = new real[][]{
//   r(0, 350, 10)
// });
draw(s, dpar(mode = free, viewdir = dir(90), help = false));
