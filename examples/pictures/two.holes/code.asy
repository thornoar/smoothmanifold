import export;

settings.render = 8;

size(10 cm);
defaultpen(.7);

export.background = paleyellow;
export.margin = 1cm;

smooth sm = samplesmooth(2);

dpar ds = dpar(help = true, dash = true, viewdir = dir(-35), sectionpen = linewidth(.5));

for (int mode = 0; mode < 4; ++mode)
{
    erase();
    draw(sm, ds.subs(mode = mode));
    export(prefix = "picture_"+mode(mode));
}

exit();
