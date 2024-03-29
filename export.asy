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
private pen currentExBG = nullpen; // [B]ack[G]round
private pen currentExFP = nullpen; // [F]rame [P]en
private real currentExM = 0; // [M]argin
// private bool currentExS = false; // [S]imple
private bool currentExR = false; // [R]estore
private bool currentExEF = false; // [E]xit [F]lag
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

include smoothmanifold;

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

private bool native (string format = currentAnIF)
{return format == "" || format == "eps" || format == "pdf";}

void expar (
    string prefix = currentExP,
    string format = settings.outformat,
    int dpi = currentExRID,
    bool exit = currentExEOE,
    bool autoexport = !currentExEF,
    bool restore = currentExR,
        string dirname = currentAnDN,
        string informat = currentAnIF,
        string outprefix = currentAnOP,
        string outformat = currentAnOF,
        bool close = currentAnC,
        bool preclean = currentAnPC,
            real ymax = -1,
            real ratio = 1.777777777,
            bool clip = currentFrCP,
            pen bgpen = currentExBG,
            pen framepen = currentExFP,
            real margin = currentExM,
            pair size = (dn,dn)
)
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
	
    currentAnDN = dirname;
	currentAnIF = informat;
	currentAnOP = outprefix;
	currentAnOF = outformat;
	currentAnC = close;
    currentExEOE = exit;
    currentAnPC = preclean;

    // if (margin > 0 || bgpen != currentExBG || framepen != currentExFP) currentExS = false;
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
{
	currentExBG = inverse(currentExBG);
	currentpen = inverse(currentpen);
	smoothcolor = inverse(smoothcolor);
	subsetcolor = inverse(subsetcolor);
	currentDrIC = !currentDrIC;
	// currentDrHP = inverse(currentDrHP);
    nextsubsetpen = new pen (pen p, real scale) { return inverse(scale*inverse(p)); };
    dashpenscale = new pen (pen p) { return .3*p+dashed; };
    shadepen = new pen (pen p) { return inverse(currentDrShS*inverse(p)); };
}

private void framepicture (picture pic)
{
    dot(pic, -currentFrFC, linewidth(0)+invisible);
    dot(pic, currentFrFC, linewidth(0)+invisible);
    if (currentFrCP) clip(pic, (-currentFrFC -- (currentFrFC.x, -currentFrFC.y) -- currentFrFC -- (-currentFrFC.x, currentFrFC.y) -- cycle));
}

bool exists (string filename)
{
    file f = input(filename, check = false);
    bool res = !error(f);
    close(f);
    return res;
}

void export (
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
        pen bgpen = currentExBG,
        real margin = currentExM,
        pen framepen = currentExFP,
        int density = currentExRID,
        bool exit = currentExEOE,
        bool simple = false,
        bool drawdeferred = true,
        bool restore = currentExR
)
{
	bool native = native(format);
	settings.outformat = native ? format : "pdf";
    restore = restore || currentFrEP;

    picture pic1 = restore ? pic.copy() : pic;

    void localshipout (string prefix1)
    {
        if ((simple || (margin == 0 && bgpen == nullpen && framepen == nullpen)))
        { plainshipout(prefix=prefix1, pic1, orientation, wait, view, options, script, light, P); }
        else
        {
            shipout(prefix=prefix1, bbox(pic1, xmargin = margin, p = framepen, filltype = bgpen == nullpen ? NoFill : Fill(p = bgpen)), wait, view, options, script, light, P);
        }
    }

    if (drawdeferred) drawdeferred(pic1, flush = !restore);
    preshipout(pic1);
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
    // if (exit) exit();
    if (exit) currentExEF = true;
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

void compile (
    int fps = currentAnFPS,
    string informat = currentAnIF,
    string outprefix = currentAnOP,
    string outformat = currentAnOF,
    bool clean = true,
    bool exit = true,
    int density = currentExRID
)
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
)
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
)
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
        bool help = currentDrH,
        bool dash = currentDrDD,
        bool shade = currentDrDS,
        bool avoidsubsets = currentSeAS,
        bool drag = true,
        bool overlap = currentDrO,
        bool drawnow = overlap,
    bool back = true,
    real margin = currentExM,
    int density = currentExRID,
    bool compile = false,
    int fps = currentAnFPS,
    bool close = currentAnC
) // Animates the process of shifting, scaling and rotating a given smooth object. //
{
    smooth smp;
    if (back) smp = sm.copy();

	pair stepshift = close ? shift/(n-1) : shift/n;
	real stepscale = close ? scale^(1/(n-1)) : scale^(1/n);
	real steprotate = close ? rotate/(n-1) : rotate/n;

	void update (int i)
	{
		if (i > 0) sm.move(shift = stepshift, scale = stepscale, rotate = steprotate, keepview = keepview, drag = drag);
		draw(sm = sm, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

void revolve (
    smooth sm,
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
        bool help = currentDrH,
        bool dash = currentDrDD,
        bool shade = currentDrDS,
        bool avoidsubsets = currentSeAS,
        bool drag = true,
        bool overlap = currentDrO,
        bool drawnow = overlap,
    bool back = true,
    bool arc = false,
    real margin = currentExM,
    int density = currentExRID,
    bool compile = false,
    int fps = currentAnFPS,
    bool close = currentAnC
) // Creates the illusion of a given smooth objects being rotated in an axis perpendicular to the view direction (turning "to the left" and "to the right") by altering the `viewdir` parameter and stretching the object.
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
		}
		draw(sm = sm, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
	if (back) sm = smp;

	animate(update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

shipout = new void (
    string prefix=outname(),
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
    if (!currentExEF) export(prefix, pic, orientation, format, wait, view, options, script, light, P);
    // else write("Exit flag is true -- will not shipout picture");
};
