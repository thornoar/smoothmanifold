// -- System variables -- //

// -- Defaults -- //
// [Pr]ogress
private int defaultPrML = 50; // [M]essage [L]ength
// [An]imations
private string defaultAnFLN = ".animation_input_list.txt";
int defaultAnFN = 30; // [F]rame [N]umber
int defaultAnNL = 4; // [N]ame [L]ength

// -- Changeables -- //
// [Ex]port
private bool currentExEOE = true; // [E]xit [O]n [E]xport
private pen currentExFP = linewidth(0); // [F]rame [P]en
int currentExRID = 300; // [R]asterized [I]mage [D]ensity
pen currentExBG = white; // [B]ack[G]round
real currentExM = 0; // [M]argin
// [Fr]ame
private bool currentFrEP = false; // [E]nclose [P]icture
private bool currentFrCP = false; // [C]lip [P]icture
private pair currentFrFC = (0,0); // [F]rame [C]orner
// [An]imations
int currentAnFPS = 25; // [FPS]
private int currentAnCC = 0; // [C]all [C]ount
private string currentAnDN = "animation/";
private string currentAnIF = "jpg"; // [I]nput [F]ormat
private string currentAnOP = outname(); // [O]otput [P]refix
private string currentAnOF = "mp4"; // [O]utput [F]ormat
bool currentAnC = true; // [C]lose

import smoothmanifold;

void linux (string cmd)
{
    string filename = "cmd.sh";
    file f = output(name = filename);
    write(f, s = cmd);
    close(f);
    system("chmod +x "+filename);
    system("./"+filename);
    delete(filename);
}

private string copychar (string str, int n)
{
	if (n == 0) return "";
	return copychar(str, n-1) + str;
}

private bool native (string format = currentAnIF) {return format == "" || format == "eps" || format == "pdf";}

void exportparams (int dpi = currentExRID, pen bgpen = currentExBG, real margin = currentExM, bool exit = currentExEOE)
{
	if (dpi < 10)
	{ halt("Could not apply changes: inacceptable quality."); }
	if (margin < 0)
	{ halt("Could not set margin: value must be positive."); }
	currentExRID = dpi;
	currentExBG = bgpen;
	currentExM = margin;
	currentExEOE = exit;
}
void invertcolors ()
{
	currentExBG = inverse(currentExBG);
	defaultpen(inverse(currentpen));
	smoothcolor = inverse(smoothcolor);
	subsetcolor = inverse(subsetcolor);
	currentDrIC = !currentDrIC;
	currentDrExP = inverse(currentDrExP);
	currentDrSeP = currentDrSeP+inverse(currentDrSeP);
	currentDrElP = inverse(currentDrElP);
    nextsubsetpen = new pen (pen p, real scale) { return inverse(scale*inverse(p)); };
    dashpen = new pen (pen p) { return .5*p+dashed; };
    shadepen = new pen (pen p) { return currentDrShS*p; };
}

void animationparams (string dirname = currentAnDN, string informat = currentAnIF, string outprefix = currentAnOP, string outformat = currentAnOF, bool close = currentAnC)
{
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
	
    currentAnDN = dirname;
	currentAnIF = informat;
	currentAnOP = outprefix;
	currentAnOF = outformat;
	currentAnC = close;
}
void setframe (real ymax, real ratio = 1.777777777, bool crop = true, bool now = false, picture pic = currentpicture)
{
	if (now)
	{
		pair corner = (ymax*ratio, ymax);
		dot(pic, corner, linewidth(0));
		dot(pic, -corner, linewidth(0));
		return;
	}
	currentFrEP = true;
	currentFrFC = (ymax*ratio, ymax);
	if (crop) currentFrCP = true;
}

int numberoffiles (string dirname)
{
    linux("ls "+dirname+" -1 | wc -l > tmp_numberoffiles.txt");
    int res = input("tmp_numberoffiles.txt");
    delete("tmp_numberoffiles.txt");
    if (dirname == "." || dirname == "./") res -= 1;
    return res;
}

void clean (string informat = currentAnIF)
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

void compile (int fps = currentAnFPS, string informat = currentAnIF, string outprefix = currentAnOP, string outformat = currentAnOF, bool clean = true, int density = currentExRID)
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

	if (clean) clean(informat);
	write("Done.");
}

private picture framedpicture (picture pic)
{
	if (!currentFrEP) return pic;
	picture aux;
	aux = pic;
	dot(aux, currentFrFC, invisible+linewidth(0));
	dot(aux, -currentFrFC, invisible+linewidth(0));
	if (currentFrCP)
	{ clip(aux, (-currentFrFC -- (currentFrFC.x, -currentFrFC.y) -- currentFrFC -- (-currentFrFC.x, currentFrFC.y) -- cycle)); }
	return aux;
}

void export (picture pic = currentpicture, string prefix = outname(), string format = settings.outformat, pen bgpen = currentExBG, real margin = currentExM, pen framepen = currentExFP, int density = currentExRID, bool exit = currentExEOE, bool basic = false, bool drawcache = true)
{
	bool native = native(format);
	settings.outformat = native ? format : "pdf";

    if (drawcache) drawcache(pic);

	if (basic)
	{ plainshipout(pic, prefix = prefix); }
	else
	{
		picture aux = framedpicture(pic);
		shipout(bbox(aux, xmargin = margin, p = framepen, filltype = Fill(p = bgpen)), prefix = prefix);
	}
	if (native)
	{
		if (exit) exit();
		return;
	}

	if (format == "svg")
	{
		system("pdf2svg "+prefix+".pdf"+" "+prefix+".svg");
		system("rm "+prefix+".pdf");
	}
	else
	{
		system("mogrify -density "+(string)density+" -format "+format+" "+prefix+".pdf");
		system("rm "+prefix+".pdf");
	}

	if (exit) exit();
}

void animate (void update (int), int n = defaultAnFN, bool back = false, pen bgpen = currentExBG, real margin = currentExM, pen framepen = currentExFP, int density = currentExRID, bool compile = false, string informat = currentAnIF, string outprefix = currentAnOP, string outformat = currentAnOF, int fps = currentAnFPS, bool clean = true)
{
	string s = "> Writing animation...";
	write(s + copychar(" ", defaultPrML-2-length(s)) + "->|");
    write("|", suffix = none);
    
    string hash = (string)currentAnCC + (string)seconds();
    currentAnCC += 1;
    file f = output(name = defaultAnFLN, update = true);

	real ool = 1/(defaultPrML-1) - 0.000001;
	real oon = 1/n;
	real residue = 0;

	for (int i = 0; i < n; ++i)
	{
		save();
        savecache();

		update(i);

		string str1 = hash+"_"+(string)(i);
		string str2 = hash+"_"+(string)(2n - 1 - i);
		export(prefix = str1, format = informat, exit = false);
        write(f, s = str1+"."+informat, suffix = endl);
		if (back) export(prefix = str2, format = informat, exit = false, drawcache = false);
        
        restorecache();
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
        { write(f, s = hash + "_" + (string)(n+i)); }
    }

	write("|");

	if (compile) compile(informat = informat, outprefix = outprefix, outformat = outformat, fps = fps, clean = clean, density = density);
}

// -- Animations -- //

void move (smooth sm,
           int mode = currentDrM,
           pen contourpen = currentpen,
           pen smoothfill = smoothcolor,
           pen subsetcontourpen = contourpen,
           pen subsetfill = subsetcolor,
           pen sectionpen = currentDrSeP,
           pen dashpen = sectionpen+dashed+grey,
           pen shadepen = currentDrShS*smoothfill,
           pair shift = (0,0),
           real scale = 1,
           real rotate = 0,
           bool keepview = false,
           bool dash = currentDrDD,
           bool explain = currentDrE,
           bool shade = currentDrDS,
           int frames = defaultAnFN,
           bool back = true,
           bool drag = true,
           real margin = currentExM,
           int density = currentExRID,
           bool compile = false,
           int fps = currentAnFPS,
           bool close = currentAnC)
// Animates the process of shifting, scaling and rotating a given smooth object. //
{
    smooth smp;
    if (back) smp = sm.copy();
	int n = back ? ceil(frames*.5) : frames;

	pair stepshift = close ? shift/(n-1) : shift/n;
	real stepscale = close ? scale^(1/(n-1)) : scale^(1/n);
	real steprotate = close ? rotate/(n-1) : rotate/n;

	void update (int i)
	{
		if (i > 0) sm.move(shift = stepshift, scale = stepscale, rotate = steprotate, keepview = keepview, drag = drag);
        draw(sm, mode = mode, contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, dash = dash, explain = explain, shade = shade, drag = drag, drawnow = false);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

void revolve (smooth sm,
              int mode = currentDrM,
              pair viewdir1 = sm.viewdir,
              pair viewdir2,
              pen contourpen = currentpen,
              pen smoothfill = smoothcolor,
              pen subsetcontourpen = contourpen,
              pen subsetfill = subsetcolor,
              pen sectionpen = currentDrSeP,
              pen dashpen = sectionpen+dashed+grey,
              pen shadepen = currentDrShS*smoothfill,
              bool dash = currentDrDD,
              bool explain = currentDrE,
              bool shade = currentDrDS,
              pair shift = (0,0),
              bool back = true,
              bool arc = false,
              bool shiftsubsets = currentSmSS,
              bool drag = true,
              int frames = defaultAnFN,
              real margin = currentExM,
              int density = currentExRID,
              bool compile = false,
              int fps = currentAnFPS,
              bool close = currentAnC)
// Creates the illusion of a given smooth objects being rotated in an axis perpendicular to the view direction (turning "to the left" and "to the right") by altering the `viewdir` parameter and stretching the object.
{
    smooth smp;
    if (back) smp = sm.copy();
	int n = back ? ceil(frames*.5) : frames;

	real l1 = length(viewdir1);
	real l2 = length(viewdir2);
	real deg1 = arc ? degrees(viewdir1) : 0;
	real deg2 = arc ? degrees(viewdir2) : 0;

	void update (int i)
	{
        if (i > 0)
		{
			real coeff = close ? (n-i-1)/(n-1) : (n-i-1)/n;
			pair viewdir = arc ? (coeff*l1 + (1-coeff)*l2)*dir(coeff*deg1 + (1-coeff)*(deg2+360)) : (coeff*viewdir1 + (1-coeff)*viewdir2);
			sm.view(viewdir, shiftsubsets = shiftsubsets, drag = drag);
			sm.move(shift = shift/(n-1), keepview = true, drag = drag);
		}
        draw(sm, mode = mode, contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, dash = dash, explain = explain, shade = shade, drag = drag);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}
