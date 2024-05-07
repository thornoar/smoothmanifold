import export;

settings.render = 8;
settings.outformat = "pdf";

size(10cm);
defaultpen(.7);
expar(bgpen = paleyellow, margin = 1 cm, exit = false);
smpar(scavoidsubsets = true);

smooth sm = samplesmooth(1);
dpar ds = dpar(help = true, dash = true, viewdir = dir(-40), sectionpen = linewidth(.5));

for (int mode = 0; mode < 4; ++mode)
{
    erase();
    draw(sm, ds.subs(mode = mode));
    export(prefix = "picture_"+mode(mode));
}

exit();
