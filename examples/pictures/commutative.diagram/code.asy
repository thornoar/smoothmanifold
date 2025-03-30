import export;
size(8cm);

config.arrow.absmargins = true;
config.smooth.nodesize = .8;

smooth a = node("A", pos = (0,0));
smooth fa = node("F(A)", (5,2));
smooth g = node("G", (4,-3));

draw(a, fa, g, dspec = nodepar());
drawarrow(a, fa, L = Label("\varphi", align = Relative(W)));
drawarrow(g, a, L = Label("f", align = Relative(W)));
drawarrow(g, fa, p = dashed, L = Label("\exists!", align = Relative(E)));
drawcommuting(g, a, fa);

export("picture", margin = 1cm);
