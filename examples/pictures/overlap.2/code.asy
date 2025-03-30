import export;
size(15cm);

defaultpen(.7);

config.drawing.gaplength = .03;
config.drawing.underdashes = true;

fitpath((0,0){up}..{down}(1,0), beginarrow = true, endarrow = true, beginbar = true, endbar = true, barsize = 10, p = blue);
fitpath((.5,-1.3){up}..(.6,.7), endarrow = true, arrow = TeXHead);
fitpath(circle(c = (.8,-.1), r = .4), covermode = 0, p = brown);
fillfitpath(circle((1.05,.15),.35), fillpen = lightred, covermode = 0);
fillfitpath(circle((.2,-.15),.4), fillpen = paleblue, covermode = 1);
fillfitpath(circle((.25,-.15),.22), fillpen = paleyellow, covermode = -1);
fillfitpath(circle((.8,-.75),.35), fillpen = lightgreen, covermode = 2);

export(prefix = "picture", margin = 1cm, bgpen = paleyellow);
