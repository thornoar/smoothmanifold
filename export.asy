// -- System variables -- //

// -- Defaults -- //
// [Pr]ogress
private int defaultPrML = 50; // [M]essage [L]ength
// [An]imations
int defaultAnFPS = 3; // [S]econds
int defaultAnFN = 30; // [F]rame [N]umber
int defaultAnNL = 4; // [N]ame [L]ength

// -- Changeables -- //
// [Ex]port
private bool currentExEOE = true; // [E]xit [O]n [E]xport
private pen currentExFP = linewidth(0); // [F]rame [P]en
int currentExRID = 300;
pen currentExBG = white; // [B]ack[G]round
real currentExM = 0; // [M]argin
// [Pr]ogress
private int currentPrFC = 0; // [Pr]ogress [F]rame [C]ount
// [Fr]ame
private bool currentFrEP = false; // [E]nclose [P]icture
private bool currentFrCP = false; // [C]lip [P]icture
private pair currentFrFC = (0,0); // [F]rame [C]orner
// [An]imations
private string currentAnIF = "jpg"; // [I]nput [F]ormat
private string currentAnOP = outname(); // [O]otput [P]refix
private string currentAnOF = "mp4"; // [O]otput [F]ormat
bool currentAnC = true; // [C]lose

private string copychar (string str, int n)
{
	if (n == 0) return "";
	return copychar(str, n-1) + str;
}

private bool native (string format = currentAnIF) {return format == "" || format == "eps" || format == "pdf";}

pen inverse (pen p)
{
	real[] colors = colors(p);
	if (colors.length == 1) return gray(1-colors[0]);
	if (colors.length == 3) return rgb(1-colors[0], 1-colors[1], 1-colors[2]);
	return invisible;
}

void exportparams (int dpi = currentExRID, pen bgpen = currentExBG, real margin = currentExM, bool exit = currentExEOE)
{
	if (dpi < 10)
	{ abort("Could not apply changes: inacceptable quality."); }
	if (margin < 0)
	{ abort("Could not set margin: value must be positive."); }
	currentExRID = dpi;
	currentExBG = bgpen;
	currentExM = margin;
	currentExEOE = exit;
}
void animationparams (string informat = currentAnIF, string outprefix = currentAnOP, string outformat = currentAnOF, bool close = currentAnC)
{
	if (find(outprefix, " ") > -1)
	{ abort("Could not apply changes: prefix should not contain spaces."); }
	if (find("eps|jpg|png|pdf", informat) == -1)
	{ write("> ! You have chosen an unfamiliar input format. Proceed with caution."); }
	if (find("mp4|gif|mkv|avi|flv|caf|wtv|oma", outformat) == -1)
	{ write("> ! You have chosen an unfamiliar output format. Proceed with caution."); }
	
	currentAnIF = informat;
	currentAnOP = outprefix;
	currentAnOF = outformat;
	currentAnC = close;
}
void setframe (real ymax, real ratio = 1.777777777, bool crop = true)
{
	currentFrEP = true;
	currentFrFC = (ymax*ratio, ymax);
	if (crop) currentFrCP = true;
}

void clean ()
{
	for (int i = 0; i < currentPrFC; ++i)
	{ system("rm _"+copychar("0", defaultAnNL - length((string)i))+(string)i + "."+currentAnIF); }
	currentPrFC = 0;
}

void compile (int fps = defaultAnFPS, string outprefix = currentAnOP, string outformat = currentAnOF, bool clean = true)
{
	write("> Compiling... ", suffix = none);
	system("nohup ffmpeg -y -hide_banner -loglevel error -framerate "+(string)fps+" -i _%0"+(string)defaultAnNL+"d."+currentAnIF+" "+outprefix+"."+outformat);
	if (clean) clean();
	write("Done.");
}

private picture framedpicture (picture pic)
{
	if (!currentFrEP) return pic;
	picture aux;
	aux = pic;
	draw(aux, (-currentFrFC)--currentFrFC, invisible);
	if (currentFrCP)
	{ clip(aux, (-currentFrFC -- (currentFrFC.x, -currentFrFC.y) -- currentFrFC -- (-currentFrFC.x, currentFrFC.y) -- cycle)); }
	return aux;
}

void export (picture pic = currentpicture, string prefix = outname(), string format = settings.outformat, pen bgpen = currentExBG, real margin = currentExM, pen framepen = currentExFP, int density = currentExRID, bool exit = currentExEOE, bool basic = false)
{
	bool native = native(format);
	settings.outformat = native ? format : "pdf";

	if (basic)
	{ shipout(pic, prefix = prefix); }
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

void animate (void update (int), int n = defaultAnFN, bool back = false, pen bgpen = currentExBG, real margin = currentExM, pen framepen = currentExFP, int density = currentExRID, bool compile = true, string outprefix = currentAnOP, string outformat = currentAnOF, int fps = defaultAnFPS, bool clean = true)
{
	string s = "> Writing animation...";
	write(s + copychar(" ", defaultPrML-2-length(s)) + "->|");
	write("|", suffix = none);

	real ool = 1/(defaultPrML-1) - 0.000001;
	real oon = 1/n;
	real residue = 0;

	for (int i = 0; i < n; ++i)
	{
		save();
		update(i);
		string str1 = (string)(currentPrFC+i);
		string str2 = (string)(currentPrFC + 2n - 1 - i);
		export(prefix = "_"+copychar("0", defaultAnNL - length(str1))+str1, format = currentAnIF, exit = false);
		if (back) export(prefix = "_"+copychar("0", defaultAnNL - length(str2))+str2, format = currentAnIF, exit = false);
        restore();

		residue += oon;
		while (residue >= ool)
		{
			write("=", suffix = none);
			residue -= ool;
		}
    }
	currentPrFC += back ? 2*n : n;

	write("|");

	if (compile) compile(outprefix = outprefix, outformat = outformat, fps = fps, clean = clean);
}
