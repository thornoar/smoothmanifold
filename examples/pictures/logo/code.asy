import export;

export.xmargin = .2cm;
export.prefix = "picture";
settings.outformat = "pdf";

size(11cm);
defaultpen(linewidth(.7pt));

config.arrow.absmargins = true;
config.drawing.labels = false;
config.drawing.underdashes = false;

smooth sm1 = smooth(
    contour = wavypath(r(.9,2,1.1,2,1.1,2), true),
    holes = new hole[]{
        hole(
            contour = convexpaths[1],
            shift = (-.84,.1),
            scale = .57,
            rotate = 30,
            sections = rr(180,235,8)
        )
    },
    subsets = new subset[]{
        subset(
            contour = convexpaths[4],
            shift = (.55,-.95),
            scale = .5,
            rotate = -40
        )
    },
    vratios = r(),
    hratios = r()
)
.addelement(index = 0, (-.3,.4), unit = true)
.addsubset(
    index = 0,
	contour = convexpaths[2],
    shift = (.2,-.2),
	scale = .5,
	unit = true
)
.addelement(index = 1, (-.2,.2), unit = true);

smooth sm2 = smooth(
    contour = concavepaths[4],
    subsets = new subset[]{
        subset(
            contour = convexpaths[6],
            shift = (.55,.55),
            scale = .5,
            rotate = -130
        ),
        subset(
            contour = reflect((0,0),(0,1))*concavepaths[2],
            shift = (-.15,-.1),
            scale = .6,
            rotate = 30
        )
    },
    shift = (1.2,.2),
    scale = .9,
    rotate = 110,
    vratios = r(),
    hratios = r()
)
.addelement(index = 0, (-.45,0), unit = true)
.addelement(index = 1, (.4,-.4), unit = true);

draw(sm1, dpar(mode = free, viewdir = (-1,0)));
draw(sm2);

drawpath(
    sm1,
    sm2,
    index1 = 0,
    index2 = 0,
    points = p((.3,-.1), (.45,.1))
);
drawpath(
    sm1,
    index1 = 0,
    points = p((0,-.4),(0,-.1),(.6,-.3))
);
drawpath(
    sm2,
    index1 = 0,
    index2 = 1,
    points = p((1.2,0.6), (1.5,.3))
);
drawarrow(
    start = sm2.elements[1].pos,
    finish = sm1.elements[1].pos,
    curve = -.4,
    beginmargin = .05
);
drawarrow(
    sm1,
    angle = 180,
    radius = 1.2,
    beginmargin = .05
);

picture pic;
// usepackage("tgschola");
defaultpen(fontsize(11pt));
label(pic, (0,0), L = minipage("
    \begin{center}
    \textrm{module}\\
    \textit{smoothmanifold}
    \end{center}
"));
add(shift((-.92,.03))*pic);
