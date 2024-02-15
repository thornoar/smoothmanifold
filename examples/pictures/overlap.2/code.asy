import export;
size(15cm);

defaultpen(.7);
smpar(gaplength = .03);

fitpath((0,0){up}..{down}(1,0), beginarrow = true, endarrow = true, beginbar = true, endbar = true, barsize = 10, p = blue);
fitpath((.5,-1.3){up}..(.6,.7), endarrow = true, arrow = TeXHead);
fitpath(circle(c = (.8,-.1), r = .4), covermode = 2, p = deepgreen);
fillfitpath(circle((1.05,.15),.35), fillpen = lightred, covermode = 0);
fillfitpath(circle((.2,-.15),.4), fillpen = lightblue, covermode = 1);
fillfitpath(circle((.8,-.8),.35), fillpen = lightgreen, covermode = 3);

export(prefix = "picture", margin = 1cm, bgpen = paleyellow);
