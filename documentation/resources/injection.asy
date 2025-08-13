include common;
// config.drawing.elementcirclerad = .045;
config.drawing.fill = false;
config.drawing.gaplength = .15;
config.arrow.mar = .1;
// config.arrow.currentarrow = DeferredArrow(SimpleHead, arc = true);
size(0, 3.8cm);

smooth sm1 = smooth(
    contour = yscale(1.8) * ucircle
)
.addelement((.1,-.8), unit = true)
.addelement((-.2,-.3), unit = true)
.addelement((.2,.2), unit = true)
.addelement((-.1,.7), unit = true)
;

smooth sm2 = smooth(
    contour = yscale(1.8) * ucircle
)
.addelement((-.2,-.7), unit = true)
.addelement((.2,-.4), unit = true)
.addelement((.1,.2), unit = true)
.addelement((.2,.7), unit = true)
.move(shift = (2.7,0))
;

draw(sm1, sm2);

drawarrow(sm1, 0, sm2, 0, curve = .1, elements = true);
drawarrow(sm1, 1, sm2, 2, red, curve = .1, elements = true);
drawarrow(sm1, 2, sm2, 2, red, curve = -.1, elements = true);
drawarrow(sm1, 3, sm2, 3, curve = -.05, elements = true);
