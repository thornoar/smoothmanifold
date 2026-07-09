settings.outformat = "eps";
size(4cm);
path p = (0,1) .. (1,0) .. (2,1) .. (3,0);
path q = (0,0) .. (1,1) .. (2,0) .. (3,1);
draw(p ^^ q);
pair[] points = intersectionpoints(p, q);
for (int i = 0; i < points.length; ++i) {
  dot(Label((string)i, align = W),
      points[i], linewidth(4pt));
}
