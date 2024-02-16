import export;
size(17cm);

defaultpen(1);
expar(margin = 1.5cm, bgpen = paleyellow, autoexport = true);
smpar(scholeangle = 30, scfreedom = .3, gaplength = .1, subsetoverlap = true);

smooth sm1 = samplesmooth(0)
    .setlabel("\mathcal{S}^2")
    .addelement((-.1,.4), "x_1", labelalign = N+.5*E)
    .addelement((.3,-.5), "x_2", labelalign = .5*W+S)
    .view(-50, distort = false);

smooth sm2 = samplesmooth(1, 2)
    .move(rotate = 90, shift = (2.7,0))
    .setlabel("\mathcal{B}", dir(40))
    .setlabel(0, "\mathcal{C}", dir(-50))
    .setlabel(1, "\mathcal{D}", dir(80))
    .addelement((-.35,.6), "y", labelalign = E)
    .movesubset(0, shift = (0,.1), inferlabels = true)
    .setlabel(2, labeldir = (0,0))
    .view(20);

draw(sm1, mode = cartesian);
draw(sm2, help = false);

drawpath(sm1, 0, 1, range = 50, drawnow = true);
drawpath(sm1, 0, range = 50, radius = .3, angle = 200, drawnow = true);
drawpath(sm1, 1, sm2, 0, range = 50, drawnow = true);

export("picture", "pdf");
