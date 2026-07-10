include common;

size(4cm);

config.drawing.underdashes = true;
config.drawing.gaplength = 0.01;

fitpath(unitcircle);
fillfitpath(
  shift(1.2) * unitcircle,
  fillpen = gray(.85)
);
