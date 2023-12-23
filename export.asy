// -- Defaults -- //
// [Pr]ogress
private int defaultPrML = 50; // [M]essage [L]ength
// [An]imations
private string defaultAnFLN = ".animation_input_list.txt";

// -- Changeables -- //
// [Ex]port
private string currentExP = outname(); // [P]refix
private bool currentExEOE = true; // [E]xit [O]n [E]xport
private int currentExRID = 300; // [R]asterized [I]mage [D]ensity
private pen currentExBG = white; // [B]ack[G]round
private pen currentExFP = nullpen; // [F]rame [P]en
private real currentExM = 0; // [M]argin
private bool currentExS = true; // [S]imple
private bool currentExR = false; // [R]estore
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
private bool currentAnE = false; // [E]xit

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

void exportparams (string prefix = currentExP, string format = settings.outformat, int dpi = currentExRID, bool exit = currentExEOE, bool restore = currentExR)
{
	if (dpi < 10)
	{ halt("Could not apply changes: inacceptable quality."); }
    currentExP = prefix;
    settings.outformat = format;
	currentExRID = dpi;
	currentExEOE = exit;
    currentExR = restore;
}
void invertcolors ()
{
	currentExBG = inverse(currentExBG);
	currentpen = inverse(currentpen);
	smoothcolor = inverse(smoothcolor);
	subsetcolor = inverse(subsetcolor);
	currentDrIC = !currentDrIC;
	currentDrExP = inverse(currentDrExP);
    nextsubsetpen = new pen (pen p, real scale) { return inverse(scale*inverse(p)); };
    dashpen = new pen (pen p) { return .3*p+dashed; };
    shadepen = new pen (pen p) { return inverse(currentDrShS*inverse(p)); };
}

void animationparams (string dirname = currentAnDN,
                      string informat = currentAnIF,
                      string outprefix = currentAnOP,
                      string outformat = currentAnOF,
                      bool close = currentAnC,
                      bool exit = currentAnE,
                      bool preclean = currentAnPC)
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
    currentAnE = exit;
    currentAnPC = preclean;
}
void setframe (real ymax = -1, real ratio = 1.777777777, bool crop = true, pen bgpen = currentExBG, pen framepen = currentExFP, real margin = currentExM)
{
	if (margin < 0)
	{ halt("Could not set margin: value must be positive."); }
	currentExBG = bgpen;
    currentExFP = framepen;
	currentExM = margin;
    if (ymax > 0)
    {
        currentFrEP = true;
        currentFrFC = (ymax*ratio, ymax);
        if (crop) currentFrCP = true;
    }
    currentExS = false;
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

void export (string prefix = currentExP,
             picture pic = currentpicture,
             orientation orientation = orientation,
             string format = settings.outformat,
             bool wait = false,
             bool view = true,
             string options = "",
             string script = "",
             light light = currentlight,
             projection P = currentprojection,
                 pen bgpen = currentExBG,
                 real margin = currentExM,
                 pen framepen = currentExFP,
                 int density = currentExRID,
                 bool exit = currentExEOE,
                 bool simple = currentExS,
                 bool drawdeferred = true,
                 bool restore = currentExR)
{
	bool native = native(format);
	settings.outformat = native ? format : "pdf";

    void localshipout (picture pic1)
    {
        if (simple && margin == 0 && bgpen == currentExBG && framepen == currentExFP)
        { plainshipout(prefix, pic1, orientation, wait, view, options, script, light, P); }
        else
        {
            picture aux = framedpicture(pic1);
            shipout(prefix, bbox(aux, xmargin = margin, p = framepen, filltype = Fill(p = bgpen)), wait, view, options, script, light, P);
        }
    }

    if (drawdeferred)
    {
        if (restore)
        {
            picture picp = pic.copy();
            drawdeferred(picp, false);
            localshipout(picp);
        }
        else
        {
            drawdeferred(pic, true);
            localshipout(pic);
        }
    }
    else localshipout(pic);

	if (native)
	{
		if (exit) exit();
		return;
	}

	if (format == "svg")
	{
		system("pdf2svg "+prefix+".pdf"+" "+prefix+".svg");
		delete(prefix+".pdf");
	}
	else
	{
		system("mogrify -density "+(string)density+" -format "+format+" "+prefix+".pdf");
		delete(prefix+".pdf");
	}

	if (exit) exit();
}

int numberoffiles (string dirname)
{
    linux("ls "+dirname+" -1 | wc -l > tmp_numberoffiles.txt");
    int res = input("tmp_numberoffiles.txt");
    delete("tmp_numberoffiles.txt");
    if (dirname == "." || dirname == "./") res -= 1;
    return res;
}

void clean ()
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

void compile (int fps = currentAnFPS,
              string informat = currentAnIF,
              string outprefix = currentAnOP,
              string outformat = currentAnOF,
              bool clean = true,
              bool exit = true,
              int density = currentExRID)
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

void animate (void update (int),
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
              bool exit = currentAnE)
{
	string s = "> Writing animation...";
	write(s + copychar(" ", defaultPrML-2-length(s)) + "->|");
    write("|", suffix = none);
    if (currentAnPC && currentAnCC == 0) clean();
    
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
		export(prefix = str1, format = informat, bgpen = bgpen, margin = margin, framepen = framepen, exit = false, drawdeferred = false);
        write(f, s = str1+"."+informat, suffix = endl);
		if (back) export(prefix = str2, format = informat, bgpen = bgpen, margin = margin, framepen = framepen, exit = false, drawdeferred = false);
        
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
    close(f);

	if (compile) compile(informat = informat, outprefix = outprefix, outformat = outformat, fps = fps, clean = clean, exit = exit, density = density);
}

void addframe (picture pic = currentpicture,
               string informat = currentAnIF,
                   pen bgpen = currentExBG,
                   real margin = currentExM,
                   pen framepen = currentExFP)
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

void move (smooth sm,
           int n,
           pair shift = (0,0),
           real scale = 1,
           real rotate = 0,
           bool keepview = true,
               pen contourpen = currentpen,
               pen smoothfill = smoothcolor,
               pen subsetcontourpen = contourpen,
               pen subsetfill = subsetcolor,
               pen sectionpen = sectionpen(contourpen),
               pen dashpen = dashpen(sectionpen),
               pen shadepen = shadepen(smoothfill),
               pen elementpen = elementpen(contourpen),
               int mode = currentDrM,
               bool fill = currentDrF,
               bool fillsubsets = currentDrFS,
               bool drawcontour = currentDrDC,
               bool explain = currentDrE,
               bool dash = currentDrDD,
               bool shade = currentDrDS,
               bool avoidsubsets = currentSeAS,
               bool drag = true,
               bool overlap = currentDrO,
               bool drawnow = currentDrDN,
           bool back = true,
           real margin = currentExM,
           int density = currentExRID,
           bool compile = false,
           int fps = currentAnFPS,
           bool close = currentAnC)
// Animates the process of shifting, scaling and rotating a given smooth object. //
{
    smooth smp;
    if (back) smp = sm.copy();

	pair stepshift = close ? shift/(n-1) : shift/n;
	real stepscale = close ? scale^(1/(n-1)) : scale^(1/n);
	real steprotate = close ? rotate/(n-1) : rotate/n;

	void update (int i)
	{
		if (i > 0) sm.move(shift = stepshift, scale = stepscale, rotate = steprotate, keepview = keepview, drag = drag);
		draw(sm = sm, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, explain, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

void revolve (smooth sm,
              int n,
              pair viewdir1 = sm.viewdir,
              pair viewdir2,
                  pen contourpen = currentpen,
                  pen smoothfill = smoothcolor,
                  pen subsetcontourpen = contourpen,
                  pen subsetfill = subsetcolor,
                  pen sectionpen = sectionpen(contourpen),
                  pen dashpen = dashpen(sectionpen),
                  pen shadepen = shadepen(smoothfill),
                  pen elementpen = elementpen(contourpen),
                  int mode = currentDrM,
                  bool fill = currentDrF,
                  bool fillsubsets = currentDrFS,
                  bool drawcontour = currentDrDC,
                  bool explain = currentDrE,
                  bool dash = currentDrDD,
                  bool shade = currentDrDS,
                  bool avoidsubsets = currentSeAS,
                  bool drag = true,
                  bool overlap = currentDrO,
                  bool drawnow = currentDrDN,
              bool back = true,
              bool arc = false,
              real margin = currentExM,
              int density = currentExRID,
              bool compile = false,
              int fps = currentAnFPS,
              bool close = currentAnC)
// Creates the illusion of a given smooth objects being rotated in an axis perpendicular to the view direction (turning "to the left" and "to the right") by altering the `viewdir` parameter and stretching the object.
{
    smooth smp;
    if (back) smp = sm.copy();

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
			sm.view(viewdir, shiftsubsets = sm.shiftsubsets, drag = drag);
			// sm.move(shift = shift/(n-1), keepview = true, drag = drag);
		}
		draw(sm = sm, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, explain, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

// shipout = new void (string prefix=outname(), picture pic=currentpicture,
// 	     orientation orientation=orientation,
// 	     string format=settings.outformat, bool wait=false, bool view=true,
// 	     string options="", string script="",
// 	     light light=currentlight, projection P=currentprojection)
// {
//     export(prefix, pic, orientation, format, wait, view, options, script, light, P);
// };
