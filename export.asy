/*

This is module export. It is an optional library aimed at simplifying the process of
framing a diagram into a final picture. The module supports features like background
setting, margin setting, format conversion, animation creation, and more.

Copyright (C) 2024 Maksimovich Roman Alekseevich. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

*/

// -- Default constants -- //
// Variable names are abbreviated to avoid really long names. Naming is hard...

// [Pr]ogress
private int defaultPrML = 50; // [M]essage [L]ength

// [An]imations
private string defaultAnFLN = ".animation_input_list.txt";

// -- Current values (can be changed by the user, though not directly) -- //

// [Ex]port
private string currentExP = outname(); // [P]refix
private bool currentExEOE = false; // [E]xit [O]n [E]xport
private int currentExRID = 300; // [R]asterized [I]mage [D]ensity
private pen currentExBG = nullpen; // [B]ack[G]round
private pen currentExFP = nullpen; // [F]rame [P]en
private real currentExM = 0; // [M]argin
private bool currentExR = true; // [R]estore
private bool currentExEF = false; // [E]xit [F]lag
private bool currentExFN = false; // [F]orce [N]ative

// [Fr]ame
private bool currentFrEP = false; // [E]nclose [P]icture
private bool currentFrCP = false; // [C]lip [P]icture
private pair currentFrFC = (0,0); // [F]rame [C]orner

// [An]imations
private int currentAnFPS = 30; // [FPS]
private int currentAnCC = 0; // [C]all [C]ount
private bool currentAnPC = true; // [P]re-[C]lean
private string currentAnDN = "animation/";
private string currentAnIF = "jpg"; // [I]nput [F]ormat
private string currentAnOP = outname(); // [O]otput [P]refix
private string currentAnOF = "mp4"; // [O]utput [F]ormat
private bool currentAnC = true; // [C]lose

// [Dr]awing
private bool currentDrIC = false; // [I]nvert [C]olors
private bool currentDrDG = false; // [D]raw [G]rid
private int currentHlGN = 10; // [H]elp [G]rid [N]umber
private int currentHlGP = 1; // [H]elp [G]rid [N]umber

string[] currentnatives = new string[]{};

void linux (string cmd)
// Run an arbitrary Linux command.
{
    string filename = "cmd.sh";
    file f = output(name = filename);
    write(f, s = cmd);
    close(f);
    system("chmod +x "+filename);
    system("./"+filename);
    delete(filename);
}

private bool contains (string[] strs, string s)
// Check if the `strs` array contains the string `s`.
{
    for (int i = 0; i < strs.length; ++i)
    { if (strs[i] == s) return true; }
    return false;
}

private bool native (string format)
// Check if the format is supported by Asymptote natively.
{ return format == "" || format == "eps" || format == "pdf" || contains(currentnatives, format); }

include smoothmanifold;

void expar (
    string prefix = currentExP,
    string format = settings.outformat,
    int dpi = currentExRID,
    bool exit = currentExEOE,
    bool autoexport = !currentExEF,
    bool restore = currentExR,
    bool drawgrid = currentDrDG,
    int gridnumber = currentHlGN,
    int gridplaces = currentHlGP,
        string dirname = currentAnDN,
        string informat = currentAnIF,
        string outprefix = currentAnOP,
        string outformat = currentAnOF,
        string[] natives = currentnatives,
        bool forcenative = currentExFN,
        bool close = currentAnC,
        bool preclean = currentAnPC,
            real ymax = -1,
            real ratio = 1.777777777,
            bool clip = currentFrCP,
            pen bgpen = currentExBG,
            pen framepen = currentExFP,
            real margin = currentExM,
            pair size = (defaultSyDN,defaultSyDN)
) // The main configuration function. It is called by the user to set all global system variables.
{
	if (dpi < 10)
	{ halt("Could not apply changes: inacceptable quality."); }
    if (find(dirname, "/") == -1)
    { halt("Could not apply changes: directory name must contain '/' at the end."); }
    if (find(dirname, "/") != rfind(dirname, "/"))
    { halt("Could not apply changes: directory name must be at depth one."); }
	if (find(outprefix, " ") > -1)
	{ halt("Could not apply changes: prefix should not contain spaces."); }
	if (find("eps|jpg|png|pdf", informat) == -1)
	{ write("> ? You have chosen an unfamiliar input format. Proceed with caution."); }
	if (find("mp4|gif|mkv|avi|flv|caf|wtv|oma", outformat) == -1)
	{ write("> ? You have chosen an unfamiliar output format. Proceed with caution."); }
	if (margin < 0)
	{ halt("Could not set margin: value must be positive."); }

    currentExP = prefix;
    settings.outformat = format;
    currentDrUO = currentDrUO && native(format);
	currentExRID = dpi;
	currentExEOE = exit;
	currentExEF = !autoexport;
    currentExR = restore;
    currentDrDG = drawgrid;
    currentHlGN = gridnumber;
    currentHlGP = gridplaces;
	
    currentAnDN = dirname;
	currentAnIF = informat;
	currentAnOP = outprefix;
	currentAnOF = outformat;
    currentnatives = natives;
    currentExFN = forcenative;
	currentAnC = close;
    currentExEOE = exit;
    currentAnPC = preclean;

    currentExM = margin;
    if (size.x >= 0 && size.y >= 0) size(size.x, size.y);
	currentExBG = bgpen;
    currentExFP = framepen;
    if (ymax > 0)
    {
        currentFrEP = true;
        currentFrFC = (ymax*ratio, ymax);
        currentFrCP = clip;
    }
}

void invertcolors ()
// Invert most colors (white -> black, blue -> yellow, etc.), e.g. the background of the picture, the contour and fill colors, etc. Must be called after all colors have been set, for correct working.
{
	currentExBG = inverse(currentExBG);
	currentpen = inverse(currentpen);
	smoothcolor = inverse(smoothcolor);
	subsetcolor = inverse(subsetcolor);
	currentDrIC = !currentDrIC;
    nextsubsetpen = new pen (pen p, real scale) { return inverse(scale*inverse(p)); };
    dashpenscale = new pen (pen p) { return .3*p+dashed; };
    shadepen = new pen (pen p) { return inverse(currentDrShS*inverse(p)); };
}

bool exists (string filename)
// Returns true if and only if a file exists.
{
    file f = input(filename, check = false);
    bool res = !error(f);
    close(f);
    return res;
}

private void drawgrid (
    picture pic = currentpicture,
    int places = currentHlGP,
    int number = currentHlGN,
    pair min = pic.userMin2(),
    pair max = pic.userMax2()
) // Draws an auxiliary coordinate grid on the given picture. It helps understand what coordinates paths have.
{
    pair margin = (max - min)*.1;
    if (abs(margin.x) > abs(margin.y)) margin = (margin.y, margin.y);
    else margin = (margin.x, margin.x);
    min -= margin;
    max += margin;
    pair diff = max - min;
    real lwidth = .2;

    int nx = number, ny = number;
    if (diff.y < diff.x) nx = floor(ny * (diff.x/diff.y));
    else ny = floor(nx * (diff.y/diff.x));

    draw(pic = pic, min -- (min.x,max.y) -- max -- (max.x, min.y) -- cycle, dashpen(linewidth(lwidth)));

    gauss count = (1,1);
    gauss exponent = (0,0);

    while (true)
    {
        int nxp = floor(diff.x*10^exponent.x) # count.x;
        if (nxp == nx) break;
        if (nxp > nx) { count.x += 1; continue; }
        if (nxp < nx)
        {
            if (exponent.x >= places) break;
            exponent.x += 1;
            continue;
        }
    }
    real stepx = count.x/10^exponent.x;
    real x;
    for (int i = floor(min.x/stepx)+1; (x = i*stepx) < max.x; ++i)
    {
        label(pic = pic, position = (x, min.y), L = (string)x, align = S);
        label(pic = pic, position = (x, max.y), L = (string)x, align = N);
        if (x != 0) draw(pic = pic, (x, min.y)--(x, max.y), dashpen(linewidth(lwidth)));
    }
    if (inside(min.x, max.x, 0))
    {
        draw(pic = pic, (0,min.y)--(0, max.y), currentpen+linewidth(lwidth));
    }

    while (true)
    {
        int nyp = floor(diff.y*10^exponent.y) # count.y;
        if (nyp == ny) break;
        if (nyp > ny) { count.y += 1; continue; }
        if (nyp < ny)
        {
            if (exponent.y >= places) break;
            exponent.y += 1;
            continue;
        }
    }
    real stepy = count.y/10^exponent.y;
    real y;
    for (int i = floor(min.y/stepy)+1; (y = i*stepy) < max.y; ++i)
    {
        label(pic = pic, position = (min.x, y), L = (string)y, align = W);
        label(pic = pic, position = (max.x, y), L = (string)y, align = E);
        if (y != 0) draw(pic = pic, (min.x, y)--(max.x, y), dashpen(currentpen+linewidth(lwidth)));
    }
    if (inside(min.y, max.y, 0))
    {
        draw(pic = pic, (min.x, 0)--(max.x, 0), currentpen+linewidth(lwidth));
    }
}

private void framepicture (picture pic)
// Enclose the given picture in a frame, and clip if if necessary.
{
    dot(pic, -currentFrFC, linewidth(0)+invisible);
    dot(pic, currentFrFC, linewidth(0)+invisible);
    if (currentFrCP) clip(pic, (-currentFrFC -- (currentFrFC.x, -currentFrFC.y) -- currentFrFC -- (-currentFrFC.x, currentFrFC.y) -- cycle));
}

void export (
    // Base parameters hadled by `shipout`:
    string prefix = currentExP,
    picture pic = currentpicture,
    orientation orientation = orientation,
    string format = settings.outformat,
    bool wait = false,
    bool view = true,
    string options = "",
    string script = "",
    light light = currentlight,
    projection P = currentprojection,
        // Additional settings -- background, quality control, deferred drawing, file conversion:
        pen bgpen = currentExBG,
        real margin = currentExM,
        pen framepen = currentExFP,
        int density = currentExRID,
        bool exit = currentExEOE,
        bool plainforce = false,
        bool drawdeferred = true,
        bool restore = currentExR,
        bool forcenative = currentExFN
) // The main function of the module. Analogous to the base `shipout`, but has more sophisticated settings.
{
    string oldformat = settings.outformat;
	bool native = forcenative || native(format);
	settings.outformat = native ? format : "pdf";
    restore = restore || currentFrEP;

    picture pic1 = restore ? pic.copy() : pic;

    void localshipout (string prefix1)
    {
        if (plainforce || (margin == 0 && bgpen == nullpen && framepen == nullpen))
        { plainshipout(prefix = prefix1, pic1, orientation, wait, view, options, script, light, P); }
        else
        {
            shipout(
                prefix = prefix1,
                bbox(pic1, xmargin = margin, p = framepen, filltype = (bgpen == nullpen ? NoFill : Fill(p = bgpen))),
                wait, view, options, script, light, P
            );
        }
    }

    if (drawdeferred) drawdeferred(pic1, flush = !restore);
    if (currentPrDP.length > 0) draw(pic = pic1, currentPrDP, red+1);
    if (currentDrDG) drawgrid(pic1, pic1.userMin2(), pic1.userMax2());
	if (currentFrEP) framepicture(pic1);

    if (native) localshipout(prefix);
    else
    {
        string tempprefix = "export_temp";
        localshipout(tempprefix);
        if (format == "svg")
        {
            system("pdf2svg "+tempprefix+".pdf"+" "+prefix+".svg");
            delete(tempprefix+".pdf");
        }
        else
        {
            convert(args = "-density "+(string)density+" "+tempprefix+".pdf", file = prefix+"."+format, format = format);
            delete(tempprefix+".pdf");
        }
    }

    settings.outformat = oldformat;
    if (exit) exit();
    if (restore) pic1.clear();
    currentExEF = true;
}

int numberoffiles (string dirname)
// Count the number of files in a given directory.
{
    linux("ls "+dirname+" -1 | wc -l > tmp_numberoffiles.txt");
    int res = input("tmp_numberoffiles.txt");
    delete("tmp_numberoffiles.txt");
    if (dirname == "." || dirname == "./") res -= 1;
    return res;
}

void clean ()
// Clean the cached animation frames.
{
    file f = input(name = defaultAnFLN, check = false);
    if (error(f)) return;
    while (true)
    {
        string fname = f;
        if (fname == "") break;
        delete(fname);
    }
    close(f);
    delete(defaultAnFLN);
}

void compile (
    int fps = currentAnFPS,
    string informat = currentAnIF,
    string outprefix = currentAnOP,
    string outformat = currentAnOF,
    bool clean = true,
    bool exit = true,
    int density = currentExRID
) // Compile an animation from a list of frame pictures.
{
	write("> Compiling... ", suffix = none);

    if (native(informat))
    {
        if (outformat != "gif")
        {
            halt("Could not compile: "+informat+" input format is incompatible with "+outformat+" output format. [ compile() ]");
        }

        string args="-loop 0 -delay "+(string)(100/fps)+" -density "+(string)density+" -alpha Off -dispose Background @"+defaultAnFLN;
        int rc=convert(args, outprefix+".gif", format=outformat);
        if(rc == 0) animate(file = outprefix+"."+outformat, format=outformat);
    }
	else
    {
        string input = "";
        file f = input(name = defaultAnFLN, check = false);
        if (error(f))
        { halt("Could not compile: input list text file not found. Try recompiling the program. [ compile() ]"); }
        int counter = 0;
        while (true)
        {
            string str = f;
            if (str == "") break;
            rename(str, "ffmpeg_frame_"+(string)counter+"."+informat);
            counter += 1;
        }
        string cmd = "nohup ffmpeg -y -hide_banner -loglevel error -framerate "+(string)fps+" -i ./ffmpeg_frame_%d."+informat+" "+outprefix+"."+outformat;
        system(cmd);
        f = input(name = defaultAnFLN, check = false);
        for (int i = 0; i <= counter; ++i)
        {
            string str = f;
            rename("ffmpeg_frame_"+(string)i+"."+informat, str);
        }
        close(f);
    }

	if (clean) clean();
	write("Done.");
    if (exit) exit();
}

void animate (
    void update (int),
    int n,
    bool back = false,
        pen bgpen = currentExBG,
        real margin = currentExM,
        pen framepen = currentExFP,
    int density = currentExRID,
    bool compile = false,
    string informat = currentAnIF,
    string outprefix = currentAnOP,
    string outformat = currentAnOF,
    int fps = currentAnFPS,
    bool clean = true,
    bool exit = currentExEOE
) // Produce a list of animation frames from an update function. These frames can later be compiled to an animation.
{
	string s = "> Writing animation...";
	write(s + repeatstring(" ", defaultPrML-2-length(s)) + "->|");
    write("|", suffix = none);
    if (currentAnPC && currentAnCC == 0) clean();
    if (!native(informat)) currentDrUO = false;
    if (!native(informat) && bgpen == nullpen) bgpen = white;
    
    string hash = (string)currentAnCC + (string)seconds();
    currentAnCC += 1;
    file f = output(name = defaultAnFLN, update = true);

	real ool = 1/(defaultPrML-1) - 0.000001;
	real oon = 1/n;
	real residue = 0;

	for (int i = 0; i < n; ++i)
	{
		save();

		update(i);
        drawdeferred(currentpicture, false);

		string str1 = hash+"_"+(string)(i);
		string str2 = hash+"_"+(string)(2n - 1 - i);
		export(prefix = str1, format = informat, bgpen = bgpen, margin = margin, framepen = framepen, exit = false, drawdeferred = false, density = density);
        write(f, s = str1+"."+informat, suffix = endl);
		if (back) export(prefix = str2, format = informat, bgpen = bgpen, margin = margin, framepen = framepen, exit = false, drawdeferred = false, density = density);
        
        restore();

		residue += oon;
		while (residue >= ool)
		{
			write("=", suffix = none);
			residue -= ool;
		}
    }
    if (back)
    {
        for (int i = 0; i < n; ++i)
        { write(f, s = hash+"_"+(string)(n+i)+"."+informat, suffix = endl); }
    }

	write("|");
    close(f);

	if (compile) compile(informat = informat, outprefix = outprefix, outformat = outformat, fps = fps, clean = clean, exit = exit, density = density);
}

void addframe (
    picture pic = currentpicture,
    string informat = currentAnIF,
        pen bgpen = currentExBG,
        real margin = currentExM,
        pen framepen = currentExFP
) // Add a single frame to the current frame pool.
{
    string hash = (string)currentAnCC + (string)seconds();
    currentAnCC += 1;
    drawdeferred(pic, false);
    export(pic = pic, prefix = hash, format = informat, bgpen = bgpen, margin = margin, framepen = framepen, exit = false, drawdeferred = false);
    file f = output(name = defaultAnFLN, update = true);
    write(f, s = hash+"."+informat, suffix = endl);
    close(f);
}

// -- Animations -- //

void move (
    smooth sm,
    int n,
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0,
    bool drag = true,
    dpar dspec = null,
    bool back = true,
    real margin = currentExM,
    int density = currentExRID,
    bool compile = false,
    int fps = currentAnFPS,
    bool close = currentAnC
) // Animate the process of shifting, scaling and rotating a given smooth object.
{
    smooth smp;
    if (back) smp = sm.copy();

	pair stepshift = close ? shift/(n-1) : shift/n;
	real stepscale = close ? scale^(1/(n-1)) : scale^(1/n);
	real steprotate = close ? rotate/(n-1) : rotate/n;

	void update (int i)
	{
		if (i > 0) sm.move(shift = stepshift, scale = stepscale, rotate = steprotate, drag = drag);
		draw(sm = sm, dspec = dspec);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

void revolve (
    smooth sm,
    int n,
    pair viewdir1,
    pair viewdir2,
    dpar dspec = null,
    bool back = true,
    bool arc = false,
    real margin = currentExM,
    int density = currentExRID,
    bool compile = false,
    int fps = currentAnFPS,
    bool close = currentAnC
) // Create the illusion of a given smooth objects being rotated in an axis perpendicular to the view direction (turning "to the left" and "to the right") by altering the `viewdir` parameter and stretching the object.
{
    smooth smp;
    if (back) smp = sm.copy();

	real l1 = length(viewdir1);
	real l2 = length(viewdir2);
	real deg1 = arc ? degrees(viewdir1) : 0;
	real deg2 = arc ? degrees(viewdir2) : 0;

    pair viewdir = viewdir1;

	void update (int i)
	{
        if (i > 0)
		{
			real coeff = close ? (n-i-1)/(n-1) : (n-i-1)/n;
			viewdir = arc ? (coeff*l1 + (1-coeff)*l2)*dir(coeff*deg1 + (1-coeff)*(deg2+360)) : (coeff*viewdir1 + (1-coeff)*viewdir2);
		}
		draw(sm = sm, dspec = dspec.subs(viewdir = viewdir));
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

// Redefining the `shipout` function to default to `export`.

shipout = new void (
    string prefix=currentExP,
	picture pic=currentpicture,
    orientation orientation=orientation,
    string format=settings.outformat,
	bool wait=false,
	bool view=true,
    string options="",
	string script="",
    light light=currentlight,
	projection P=currentprojection
)
{
    if (!currentExEF)
    { export(prefix, pic, orientation, format, wait, view, options, script, light, P); }
};
