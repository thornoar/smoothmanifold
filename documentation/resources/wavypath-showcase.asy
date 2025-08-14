include common;
size(5cm);

real[] nums = {1,2,1,3,2,3,4};
bool normaldir = true;

draw(wavypath(nums, normaldir));

for (int i = 0; i < nums.length; ++i) {
    pair d = nums[i] * dir(-360*(i/nums.length));
    draw(
        (0,0) -- d, red, L = Label(
            "\texttt{"+(string)nums[i]+"}",
            position = EndPoint,
            align = 1.5*Relative(N)
        )
    );
    pair td = .5 * unit(rotate(-90) * d);
    draw((d - td) -- (d + td), red);
}
dot((0,0));
