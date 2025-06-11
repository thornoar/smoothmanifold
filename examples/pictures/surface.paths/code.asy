import export;
size(17cm);

defaultpen(.8);

export.background = paleyellow;
export.xmargin = 1.5cm;
export.autoexport = true;

config.smooth.interholeangle = 30;
config.section.freedom = .3;
config.drawing.gaplength = .1;
config.drawing.subsetoverlap = true;
config.drawing.pathrandom = true;
config.drawing.subpenbrighten = .4;
config.drawing.subpenfactor = .6;
config.smooth.unit = true;

smooth sm1 = samplesmooth(0)
    .setlabel("\mathcal{S}^2")
    .addelement((-.1,.4), "x_1", align = N+.5*E)
    .addelement((.3,-.5), "x_2", align = .5*W+S);

smooth sm2 = samplesmooth(1, 2)
    .move(rotate = 90, shift = (2.7,0))
    .setlabel("\mathcal{B}", dir(40))
    .setlabel(0, "\mathcal{C}", dir(-50))
    .setlabel(1, "\mathcal{D}", dir(80))
    .addelement((-.3,.5), "y", align = E)
    .movesubset(0, shift = (0,.1), inferlabels = true)
    .setlabel(2, dir = (0,0));

draw(sm1, dpar(mode = cartesian, viewdir = dir(-50)));
draw(sm2, dpar(mode = free, viewdir = dir(20)));

drawpath(sm1, 0, 1, range = 50, drawnow = true);
drawpath(sm1, 0, range = 50, radius = .3, angle = 200, drawnow = true);
drawpath(sm1, 1, sm2, 0, range = 50, drawnow = true);

export("picture", "pdf");
