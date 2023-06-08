import "smoothmanifold.asy" as smooth;

settings.outformat = "pdf";

settings.render = 16;

size(15cm);

real scale = .75;

smooth sm = smooth(
    contour = wavypath(new real[]{4,2,4,2,4,2}),
    holes = new hole[]{
        hole(
            contour = convex_sample_path[4],
            scale = scale,
            shift = (2.5,0),
            neighnumber = 1
        ),
        hole(
            contour = convex_sample_path[6],
            scale = scale,
            shift = (-1.1,-2.1)
        ),
        hole(
            contour = convex_sample_path[5],
            scale = scale,
            shift = (-1,1.8),
            neighnumber = 1
        )
    },
    subsets = new subset[]{
        subset(
            contour = convex_sample_path[2],
            scale = scale
        )
    }
).set_label(labeldir = dir(180)).move(rotate = -50);
sm.set_subset_label(labeldir = dir(180));

smooth smp = samplesmooth(1).set_label("\(N\)", labeldir = dir(30)).move(shift = (10,0), scale = 2.5, rotate = 90);
smp.set_subset_label("\(V\)");

pair viewdir = dir(24);

draw(sm, viewdir = viewdir);
draw(smp, viewdir = viewdir);

draw_arrow(sm, smp, curve = -.15, L = Label("\(f\)", align = N));
draw_arrow(sm, smp, ind1 = 0, ind2 = 0, curve = .34, overlap = true, L = "\(\begin{array}{c|c}    \lefteqn{f}\ & \\ & \hspace{-4pt} \lefteqn{U} \end{array}\)");