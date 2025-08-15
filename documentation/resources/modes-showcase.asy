include common;
size(4.3cm);

smooth sm = samplesmooth(3);
dpar dspec = dpar(viewdir = dir(-30));

save();

draw(sm, dspec.subs(mode = plain));
shipout(prefix = "mode-plain-showcase");
restore();
save();

draw(sm, dspec.subs(mode = free));
shipout(prefix = "mode-free-showcase");
restore();
save();

draw(sm, dspec.subs(mode = cartesian));
shipout(prefix = "mode-cartesian-showcase");
restore();

draw(sm, dspec.subs(mode = combined));
shipout(prefix = "mode-combined-showcase");

exit();
