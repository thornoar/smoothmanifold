import export;

size(20 cm);
defaultpen(1);
smpar(underdash = true);
expar(ymax = 2, ratio = 1, clip = true, informat = "png", outformat = "mp4");

smooth sm1 = samplesmooth(2).move(shift = (-1.5,-.1), rotate = -40);
smooth sm2 = samplesmooth(1,1).move(shift = (1.65,-.11), rotate = -20);

int n = 120;
void update (int i)
{
    sm1.move(shift = (1/n, 0));
    sm2.move(shift = (-1/n, 0));
    draw(sm1, dpar(plain));
    draw(sm2, dpar(plain));
}

animate(update, n = n, fps = 30, outprefix = "animation", compile = true, exit = true, density = 100, back = true);
