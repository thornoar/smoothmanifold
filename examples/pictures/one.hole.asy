import smoothmanifold;

settings.render = 8;
settings.outformat = "pdf";
// export.background = paleyellow;
// export.exitonexport = false;
// export.xmargin = 1cm;

size(10cm);
defaultpen(.7);

config.section.avoidsubsets = true;

smooth sm = samplesmooth(1);
dpar ds = dpar(help = true, dash = true, viewdir = dir(-40), sectionpen = linewidth(.5));

for (int mode = 0; mode < 4; ++mode)
{
    erase();
    draw(sm, ds.subs(mode = mode));
    shipout(prefix = "one.hole."+mode(mode));
}

exit();
