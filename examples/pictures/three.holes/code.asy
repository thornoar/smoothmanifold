import export;

settings.render = 8;

size(10cm);
defaultpen(.7);

export.background = paleyellow;
export.xmargin = 1cm;

smooth sm = samplesmooth(3);

dpar ds = dpar(help = true, dash = true, viewdir = dir(-35), sectionpen = linewidth(.5));

for (int mode = 0; mode < 4; ++mode)
{
    erase();
    draw(sm, ds.subs(mode = mode));
    export(prefix = "picture_"+mode(mode));
}

exit();
