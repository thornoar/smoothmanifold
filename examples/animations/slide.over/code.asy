import export;

size(20 cm);
defaultpen(1);
setframe(2,1);
animationparams(informat = "jpg", outformat = "mp4");

smooth sm1 = samplesmooth(2).move(shift = (-1.4,-.1), rotate = -40).view(angle = 39);
smooth sm2 = samplesmooth(1,1).move(shift = (1.55,-.11), rotate = -20);

int n = 90;
void update (int i)
{
    sm1.move(shift = (1/n, 0));
    sm2.move(shift = (-1/n, 0));
    draw(sm1, plain);
    draw(sm2, plain);
}

animate(update, n = n, fps = 30, outprefix = "animation");
