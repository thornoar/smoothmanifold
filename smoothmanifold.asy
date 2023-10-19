/*

This is module smoothmanifold. It is designed to construct and render high-quality Asymptote objects of topological and diff. geometrical nature.

Copyright (C) 2023 Maksimovich Roman Alekseevich. All rights reserved.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

// -- General variables -- //
// 'default' means an unchangeable variable, 'current' indicates a mutable (often user-accessible) variable.

// [Sy]stem
private real defaultSySN = .000001; // [S]mall [N]umber
private int defaultSyDN = -10000; // [D]ummy [N]umber -- "the program knows what to do with it"
private pair defaultSyDP = (defaultSyDN, defaultSyDN); // [D]ummy [P]air
private real defaultSyRR = .03; // [R]ounded [P]ath [R]atio
int dn = defaultSyDN; // shorthand for [d]ummy[n]umber
private real defaultSyMaEH = .05; // [Ma]ximal [E]llipse [H]eight
private real defaultSyMiEHR = .0001; // [Mi]nimal [E]llipse [H]eight [R]atio
private string defaultversion = "v3.5.1-beta";

private bool currentSyEOP = true; // [E]xit [O]n [P]roduce
private real currentSyMaEH = defaultSyMaEH; // [Ma]ximal [E]llipse [H]eight
private int currentSyRID = 300; // [R]asterized [I]mage [D]ensity (in dpi)
private pen currentSyBG = white; // [B]ack[G]round
private real currentSyM = 0; // [M]argin

// [Se]ction
private real defaultSeWT = .65; // [N]ot [T]oo [W]ide

real[] currentsection = new real[]{defaultSyDN,defaultSyDN,220,7,.8,50};
private int currentSeNN = 1; // [Se]ction [N]eigh [N]umber
private real currentSeNA = 30; // [Se]ction [N]eigh [A]ngle

// [Sm]ooth
private real defaultSmNC = .15; // [Ne]igh [C]urve
private real defaultSmAR = 0.1; // [A]rc [R]atio
private real defaultSmVA = 15; // [V]iew [A]ngle in degrees
private real defaultSmEAL = .2; // [E]xplain [A]rrow [L]ength
private real defaultSmCEM = .07; // [C]art [E]dge [M]argin
private real defaultSmCSD = .1; // [C]art [S]tep [D]istance
private real defaultSmCMLR = .5; // [C]art [M]aximum [L]ength [R]atio
private real defaultSmSVS = .28; // [S]ubset [V]iew [S]hift

private bool currentSmIL = true; // [I]nfer [L]abels
private bool currentSmSS = true; // [S]hift [S]ubsets

// [Ar]rows
private real currentArOL = .065; // [Ar]row [O]verlap [L]ength (see "arrow")
private real currentArM = currentArOL*.7; // [A]rrow [M]argin (see "arrow")

// [Dr]awing
private pen defaultDrEP = linewidth(.3); // [E]xplain [P]en

private string currentDrM = "strict"; // [Sm]ooth [Mode]
private bool currentDrDC = false; // [Dr]aw [C]ache
private real currentDrSS = .5; // [S]ection [S]cale
private pen currentDrST = linewidth(.4); // [S]ection [T]hickness
private bool currentDrDD = true; // [D]raw [D]ashes
private real currentDrSS = .8; // [S]hade [S]cale
private pen currentDrEP = linewidth(2.5); // [E]lement [P]en
private bool currentDrE = false; // [E]xplain
private bool currentDrDS = false; // [D]raw [S]hade
private real currentDrDO = .8; // [D]rag [O]pacity
private real currentDrSPM = .2; // [S]ubset [P]en [M]ultiplier;

// [Fr]ame
private bool currentFrEP = false; // [E]nclose [P]icture
private bool currentFrCP = false; // [C]lip [P]icture
private pair currentFrFC = (0,0); // [F]rame [C]orner

// [Pr]ogress
private int defaultPrML = 80; // [M]essage [L]ength
private string defaultPrMP = "--"; // [M]essage [P]refix
private string defaultPrEP = "~"; // [E]rror [P]refix
private string defaultPrMPP = "> "; // [M]essage [P]ost [P]refix
private string defaultPrEPP = " :: "; // [E]rror [P]ost [P]refix
private bool defaultPrJBK = true; // [J]ust [B]egan [C]ompiling

private bool currentPrPM = true; // [P]rint [M]essages
private bool currentPrAE = true; // [A]bort on [E]rror
private int currentPrIL = 0; // The current [M]essage indent [L]evel.
private int currentPrTS = seconds(); // [T]ime in [S]econds
private path[] currentPrDP; // [D]ebug [P]aths
private int currentPrFC = 0; // [F]rame [C]ount

// [An]imations
private int defaultAnFPS = 3; // [S]econds
private int defaultAnFN = 30; // [F]rame [N]umber
private int defaultAnNL = 4; // [N]ame [L]ength

private string currentAnIP = ""; // [I]nput [P]refix
private string currentAnIF = "jpg"; // [I]nput [F]ormat
private string currentAnOP = "animation"; // [O]otput [P]refix
private string currentAnOF = "mp4"; // [O]otput [F]ormat
private bool currentAnC = true; // [C]lose

private bool vector (string format = currentAnIF) {return format == "" || format == "eps" || format == "pdf" || format == "svg";}

// [Pa]ths
private path defaultPaUC = reverse(unitcircle); // [U]nit [C]ircle
private path defaultPaUS = (1,1) -- (1,-1) -- (-1,-1) -- (-1,1) -- cycle; // [U]nit [S]quare
private path[] defaultPaCV = new path[]{ // [C]on[V]ex
    defaultPaUC,
	(
		(-1.36,0.12).. controls (-1.41582401154407,0.55520889431617) and (-1.0257435069498,0.909513009349874) ..(-0.56,0.92).. controls 
		(-0.19125699521161,0.928302862811423) and (0.136521131315988,0.729039581322326) ..(0.44,0.52).. controls (0.980220404034304,0.147890246293586) 
		and (1.3845331406982,-0.436724893999579) ..(1.04,-0.88).. controls (0.676761074059661,-1.34734190235919) and 
		(0.00872773210022468,-1.01537316934592) ..(-0.56,-0.68).. controls (-0.907218133872674,-0.475248869645885) and 
		(-1.30919263224224,-0.276098698989278) ..cycle
	),
	(
		(-0.9,-0.2).. controls (-0.98697538178619,0.235654776414453) and (-0.802491449341473,0.68992759626606) ..(-0.4,0.85).. controls 
		(0.757294206364072,1.31026037507916) and (1.55936164643754,-0.313112268122339) ..(0.5,-0.95).. controls (-0.0523592332287122,-1.28207811554792) 
		and (-0.762864236084435,-0.886905298259319) ..cycle
	),
	(
		(-1.16,-0.29).. controls (-1.51490974493491,0.472081630946601) and (-0.477254187508288,1.32777856008382) ..(0.58,0.725).. controls 
		(1.27874595396837,0.326619851712201) and (1.42032178500218,-0.540171661770456) ..(0.87,-0.841).. controls 
		(0.604809353021201,-0.985964026173039) and (0.294974401744962,-0.873430194586726) ..(0,-0.812).. controls 
		(-0.446281873437747,-0.71905911372773) and (-0.968891850910363,-0.700357878373073) ..cycle
	),
	(
		(-1.296,0.216).. controls (-1.26312498012001,0.569201604422407) and (-0.867914412848729,0.717747636150192) ..(-0.486,0.756).. controls 
		(0.434078114000025,0.848154581243612) and (1.29268841709499,0.385208414599532) ..(1.134,-0.324).. controls 
		(0.956228080358488,-1.11849618061162) and (-0.223352205726549,-1.14281592154973) ..(-1.026,-0.324).. controls 
		(-1.1748059346048,-0.172196594639885) and (-1.3155538271241,0.0059182072575597) ..cycle
	),
 	(
		 (-1.128,0.094).. controls (-1.21016526223606,0.573735885775383) and (-0.828320640135585,1.00438671484956) ..(-0.329,1.034).. controls 
		 (1.51338131904807,1.14326638911221) and (1.18983717454328,-1.38637374143692) ..(-0.188,-1.081).. controls 
		 (-0.469732848058533,-1.01855879469152) and (-0.632916087419128,-0.753035005305983) ..(-0.799,-0.517).. controls 
		 (-0.933882065353422,-0.325308411593601) and (-1.08829562994141,-0.137820730815523) ..cycle
 	),
    (
		(0.890573,-0.36047)..controls (-0.148296,-1.45705) and (-1.29345,-1.23691) .. (-0.996593,0.106021) .. controls (-0.669702,1.58481) and 
		(2.03559,0.848164)..cycle
    ),
    (
		(0.989525,-0.664395)..controls (-0.155497,-1.61858) and (-1.40332,0.329701)..(-0.862301,0.79162)..controls (0.346334,1.82355) and 
		(1.39766,-0.324279)..cycle
    ),
    (
		(0.28979,-0.834028)..controls (0.093337,-0.908653) and (-1.20138,-1.95019)..(-1.15209,0.0777484)..controls (-1.10261,2.11334) and 
		(3.02512,0.204973)..cycle
    ),
    (
		(1.01073,-0.409946)..controls (0.812824,-1.99319) and (-2.2123,-0.523035)..(-0.897641,0.36047)..controls (0.779873,1.48783) and 
		(1.20823,1.17008)..cycle
    ),
    (
		(0.636123,-0.975389)..controls (-0.853465,-1.50787) and (-1.37827,0.219109)..(-0.770416,0.961253)..controls (-0.154452,1.7133) and 
		(2.19816,-0.417014)..cycle
    ),
    (
		(0.805756,0.918845)..controls (1.7034,-0.664395) and (-0.374882,-1.93278)..(-0.890573,-0.742144)..controls (-1.3712,0.367538) and 
		(0.34086,1.73882)..cycle
    ),
    (
		(0.572511,-0.925913)..controls (-1.47015,-1.5479) and (-1.32586,0.925729)..(-0.28979,1.00366)..controls (1.30759,1.12382) and 
		(1.65924,-0.595004)..cycle
    )
};
private path[] defaultPaCC = new path[]{ // [C]on[C]ave
	(
		(-0.9,0).. controls (-1.07649842837266,0.638748977821067) and (-0.964116819714307,1.31556675048848) 
		..(-0.46,1.3).. controls (0.0281888161644762,1.28492509435253) and (0.0424415730404705,0.611597145023648) 
		..(0.4,0.36).. controls (0.623716050683286,0.202581476469435) and (0.955392557398132,0.2268850080704) 
		..(1.12,0).. controls (1.39778902724123,-0.382887703564746) and (1.00985460296201,-0.913845673503591) 
		..(0.4,-1).. controls (0.0314808795565626,-1.05206079689921) and (-0.356264634361184,-0.976905732695238) 
		..(-0.6,-0.7).. controls (-0.770480811250471,-0.506318160575248) and (-0.831474513408123,-0.247994188496873) 
		..cycle
	),
    (
		(0.523035,-1.10261)..controls (-2.62474,-1.37362) and (0.932069,3.11139)..(0.558375,0.388742)..controls 
		(0.508899,0.0282721) and (1.59031,-1.01073)..cycle
    ),
	(
		(-1.4,0).. controls (-1.4330976353941,0.309902105154151) and (-1.14752451684655,0.558611632511754) 
		..(-0.84,0.49).. controls (-0.66443424676999,0.450829617534925) and (-0.529507080118944,0.301231459889368) 
		..(-0.35,0.28).. controls (0.10216096608008,0.226520006851507) and (0.27539586949137,0.862356630570909) 
		..(0.7,0.91).. controls (1.05908418967551,0.950291602166852) and (1.33041677912753,0.603698618857815) 
		..(1.33,0.21).. controls (1.32951602626534,-0.247172104636948) and (1.00821765736334,-0.645111266508212) 
		..(0.56,-0.7).. controls (0.274611440338081,-0.734948682488405) and (0.00179568356868698,-0.609311459905892) 
		..(-0.28,-0.56).. controls (-0.46548899922109,-0.527541258147606) and (-0.65562744488586,-0.528541447729153) 
		..(-0.84,-0.49).. controls (-1.11441028298393,-0.432636963666203) and (-1.37134558383179,-0.268299042718725) 
		..cycle
	),
	(
		(-0.74,1.11).. controls (-0.45217186192491,1.16995417728509) and (-0.244186500029556,0.896228533675695) 
		..(-1.11022302462516e-16,0.74).. controls (0.394876451006404,0.487361263147939) and 
		(1.0095388806718,0.479180198886787) ..(1.11,1.1327982892113e-16).. controls 
		(1.33690476375748,-1.08229204047052) and (-0.898239052326633,-1.59366714480983) ..(-1.11,0.37).. controls 
		(-1.14560254698906,0.700143742564816) and (-1.03848931729363,1.04782511478409) ..cycle
	),
	(
		(-1.35,0).. controls (-1.18010190019904,0.416395394711846) and (-0.593260371382216,0.281172231186116) 
		..(-0.27,0.54).. controls (0.0113914268982608,0.76530418707376) and (0.0415625335934956,1.24549540856936) 
		..(0.405,1.35).. controls (1.23327036593247,1.5881649229556) and (1.85490272745839,-0.0949264215164867) 
		..(0.27,-0.675).. controls (0.0952777069905893,-0.738948268869059) and (-0.0857655726904087,-0.78403391700961) 
		..(-0.27,-0.81).. controls (-0.962087418222204,-0.907543111787485) and (-1.54255992615578,-0.471936216774976) 
		..cycle
	),
	(
		(-0.69,0.23).. controls (-0.56530943588509,0.830213108154057) and (-0.490658723837313,1.55646651437028) 
		..(0,1.38).. controls (0.325235552510512,1.26302830152094) and (0.237200927517758,0.801860482003199) 
		..(0.46,0.575).. controls (0.619891745450561,0.41219358416926) and (0.894509662874465,0.412735950982866) 
		..(1.035,0.23).. controls (1.25559773374585,-0.0569317384062731) and (1.01749624107123,-0.438647936878262) 
		..(0.69,-0.69).. controls (0.106935122935565,-1.13749997528092) and (-0.664799927016652,-1.18767474273486) 
		..(-0.851,-0.644).. controls (-0.950985536038634,-0.352058059741617) and 
		(-0.751751264242251,-0.0672471774939401) ..cycle
	),
	(
		(-0.84,-0.24).. controls (-1.18825254216645,0.432752580408028) and (-0.749760426462422,1.11594975136258) 
		..(-0.24,0.96).. controls (0.0302529853898903,0.877322170006355) and (0.10736936611544,0.557158491533225) 
		..(0.3,0.36).. controls (0.513175121412852,0.141814114802958) and (0.878268025246844,0.063643117790086) 
		..(0.96,-0.24).. controls (1.09910636339287,-0.756795171199751) and (0.418309528013558,-1.17658493090488) 
		..(-0.24,-0.84).. controls (-0.497994898468632,-0.708090630046164) and (-0.706794583247006,-0.497325581279094) 
		..cycle
	)
};

// User variables
path ucircle = defaultPaUC;
path usquare = defaultPaUS;
pen smoothcolor = lightgrey;
pen subsetcolor = grey;
path[] convexpath = copy(defaultPaCV);
path[] concavepath = copy(defaultPaCC);

// -- Low-level number and array functions -- //

int[] decompose (int n)
{
	int[] res;
	while (n > 0)
	{
		int e = floor(log(n)/log(2));
		res.push(e);
		n -= 2^e;
	}
	return res;
}

bool inside (real a, real b, real c)
{ return (a <= c && c <= b); }

transform srap (real scale, real rotate, pair point)
{ return shift(point)*scale(scale)*rotate(rotate)*shift(-point); }
// [S]cale [R]otate [A]round [P]oint

transform dirscale (real scale, pair center = (0,0), pair dir) 
{
	if (length(dir) == 0) return identity;
	return rotate(degrees(dir), center) * xscale(scale) * rotate(-degrees(dir), center);
}

real[] a (... real[] source)
{ return source; }
real[][] a (... real[][] source)
{ return source; }
real[][] aa (... real[] source)
{ return new real[][]{source}; }

int[] i (... int[] source)
{ return source; }
int[][] i (... int[][] source)
{ return source; }
int[][] ii (... int[] source)
{ return new int[][]{source}; }

int pop (int[] source)
{
	int i = source[0];
	source.delete(0);
	return i;
}

pair comb (pair a, pair b, real t)
{ return t*b + (1-t)*a;}

pair[] concat (pair[][] a)
{
	if (a.length == 1) return a[0];
	pair[] b = a.pop();
	return concat(concat(a), b);
}
int[] concat (int[][] a)
{
	if (a.length == 1) return a[0];
	int[] b = a.pop();
	return concat(concat(a), b);
}

bool contains (int[] source, int a)
{
	bool res = false;
	for (int i = 0; i < source.length; ++i)
	{
		if (source[i] == a)
		{
			res = true;
			break;
		}
	}
	return res;
}
int[] difference (int[] a, int[] b)
{
	int[] res = {};
	for (int i = 0; i < a.length; ++i)
	{ if (!contains(b, a[i])) res.push(a[i]); }
	return res;
}

string copychar (string str, int n)
{
	if (n == 0) return "";
	return copychar(str, n-1) + str;
}

void printversion ()
{
	write("This is module smoothmanifold, Roman Maksimovich, " + time(format = "%D") + ". Version " + defaultversion + ".");
	write();
}
void print (string str)
{ write(copychar(defaultPrMP, currentPrIL) + defaultPrMPP + str, suffix = none); }
void printbeginning (string str, bool indent = false)
{
	if (!currentPrPM) return;
	if (defaultPrJBK)
	{
		printversion();
		defaultPrJBK = false;
	}
	if (indent) write();
	string res = copychar(defaultPrMP, currentPrIL) + defaultPrMPP + str;
	while (length(res) < defaultPrML-9) res += " ";
	write(res, suffix = none);
}
void printmessage (string str)
{
	currentPrIL += 1;
	write(copychar(defaultPrEP, currentPrIL) + defaultPrEPP + str);
	write();
	currentPrIL -= 1;
}
void printsuccess ()
{
	if (!currentPrPM) return;
	write("[SUCCESS]");
}
void printwarning (string str)
{
	if (!currentPrPM) return;
	write("[WARNING] !");
	printmessage(str);
}
void printfailure (string str)
{
	write("[FAILURE] !");
	printmessage(str);
	if (currentPrAE)
	{
		write("Aborting...", suffix = none);
		exit();
	}
}
void printstarted ()
{
	if (!currentPrPM) return;
	write(".........");
	currentPrIL += 1;
}
void printfinished ()
{
	currentPrIL -= 1;
	if (!currentPrPM) return;
	string res = copychar(defaultPrMP, currentPrIL) + defaultPrMPP + "Finished.";
	while (length(res) < defaultPrML-9) res += " ";
	write(res + "^^^^^^^^^");
}
void printtime ()
{
	if (!currentPrPM) return;
	printbeginning("Compilation time:");
	write((string)(seconds()-currentPrTS) + " s.");
}

bool checksection (real[] section)
{
	if (section.length > 1 && section[0] == 0 && section[1] == 0)
	{ return false; }
	if (section.length > 2 && section[1] != defaultSyDN && !inside(0, 360, section[2]))
	{ return false; }
	if (section.length > 3 && section[2] != defaultSyDN && section[3] <= 0)
	{ return false; }
	if (section.length > 4 && section[3] != defaultSyDN && !inside(0, 1, section[4]))
	{ return false; }
	if (section.length > 5 && section[5] != defaultSyDN && section[5] <= 0)
	{ return false; }
	return true;
}

// -- User setting functions -- //

void printprogress (bool val) { currentPrPM = val; }
void setproduce (int dpi = currentSyRID, pen bgpen = currentSyBG, real margin = currentSyM, bool exit = currentSyEOP)
{
	printbeginning("Setting produce parameters...");
	if (dpi < 10)
	{
		printfailure("Could not apply changes: inacceptable quality.");
		return;
	}
	if (margin < 0)
	{
		printfailure("Could not set margin: value must be positive.");
		return;
	}
	currentSyRID = dpi;
	currentSyBG = bgpen;
	currentSyM = margin;
	currentSyEOP = exit;
	printsuccess();
}
void setsection (real[] section, int nn, real na)
{
	printbeginning("Setting default section parameters...");
	if (!checksection(section) || nn < 0 || !inside(0, 180, na))
	{
		printfailure("Could not change default section parameters: invalid intries");
		return;
	}
	for (int i = 0; i < section.length; ++i)
	{ if (section[i] != defaultSyDN) currentsection[i] = section[i]; }
	currentSeNN = nn;
	currentSeNA = na;

	printsuccess();
}
void inferlabels (bool val)
{
	printbeginning("Setting labeling patterns...");
	currentSmIL = val;
	printsuccess();
}
void shiftsubsets (bool val)
{
	printbeginning("Setting subset view behavior...");
	currentSmSS = val;
	printsuccess();
}
void arrowparams (real val, real sc = .7)
{
	printbeginning("Setting arrow draw parameters");
	currentArOL = val;
	currentArM = currentArOL*sc;
	if (val > 1) printwarning("Value looks too big: the result may be ugly.");
	else printsuccess();
}
void sectiondraw (bool drawdashes = currentDrDD, bool fill = currentDrDS, real scale = currentDrSS, real thickness = .4, real opacity = 1)
{
	printbeginning("Setting cross section draw parameters...");
	currentDrDS = fill;
	currentDrDD = drawdashes;
	currentDrSS = scale;
	currentDrST = linewidth(thickness) + opacity(opacity);
	printsuccess();
}
void elementdraw (real thickness = 2, real opacity = 1)
{
	printbeginning("Setting element draw parameters...");
	currentDrEP = linewidth(thickness) + opacity(opacity);
	printsuccess();
}
void smoothdraw (string mode = currentDrM, pen smoothfill = smoothcolor, pen subsetfill = subsetcolor, real minscale = currentDrSPM, bool cache = currentDrDC, bool explain = currentDrE, real dragop = currentDrDO)
{
	printbeginning("Setting draw parameters...");
	if (find("strict|free|cart|plain", mode) == -1)
	{
		printfailure("Could not set mode: invalid entry provided.");
		return;
	}
	if (!inside(0,1, minscale))
	{
		printfailure("Could not apply changes: subset color scale argument out of range: must be between 0 and 1.");
		return;
	}
	if (!inside(0,1, dragop))
	{
		printfailure("Could not set drag opacity: entry out of bounds: must be between 0 and 1.");
		return;
	}
	currentDrM = mode;
	smoothcolor = smoothfill;
	subsetcolor = subsetfill;
	currentDrSPM = minscale;
	currentDrDC = cache;
	currentDrE = explain;
	currentDrDO = dragop;
	printsuccess();
}
void abort (bool val)
{
	printbeginning("Setting abort patterns...");
	currentPrAE = val;
	printsuccess();
}
void drawdebug ()
{
	printbeginning("Drawing debug paths...");
	draw(currentPrDP);
	printsuccess();
}
void animationparams (string inprefix = currentAnIP, string informat = currentAnIF, string outprefix = currentAnOP, string outformat = currentAnOF, bool close = currentAnC)
{
	printbeginning("Setting animation details...");
	if (find(inprefix, " ") > -1 || find(outprefix, " ") > -1)
	{
		printfailure("Could not apply changes: prefix should not contain spaces.");
		return;
	}
	if (find("eps|jpg|png|pdf", informat) == -1)
	{ printwarning("You have chosen an unfamiliar input format. Proceed with caution."); }
	if (find("mp4|gif|mkv|avi|flv|caf|wtv|oma", informat) == -1)
	{ printwarning("You have chosen an unfamiliar output format. Proceed with caution."); }
	
	currentAnIP = inprefix;
	currentAnIF = informat;
	currentAnOP = outprefix;
	currentAnOF = outformat;
	currentAnC = close;
}
void setframe (real ymax, real ratio = 1.777777777, bool crop = true)
{
	printbeginning("Setting frame...");
	currentFrEP = true;
	currentFrFC = (ymax*ratio, ymax);
	if (crop) currentFrCP = true;
	printsuccess();
}

// -- Low-level path functions -- //

pair center (path p, int n = 10, bool arc = true)
{
    pair sum = (0,0);
    for (int i = 0; i < n; ++i)
    { sum += point(p, arc ? arctime(p, arclength(p)*i/n) : length(p) * i/n); }
	if (inside(p, sum/n)) return sum/n;
	real[] times = times(p, (0, ypart(sum/n)));
	return (point(p, times[0]) + point(p, times[1])) * .5;
}

real arclength (path g, real a, real b)
{ return arclength(subpath(g, a, b)); }

real intersectiontime (path g, pair point, pair dir)
// Returns the time of the intersection of `g` with a beam going from `point` in direction `dir`
{
    int dist = 2;
    while (dist < 1024)
    {
        path line = point -- (point + unit(dir)*dist);
        real[] isect = intersect(g, line);
        if (isect.length > 0) return isect[0];
        else dist *= 2;
    }
    return -1;
}

path connect (pair[] points)
{
	path res = nullpath;
	for (int i = 0; i < points.length; ++i)
	{ res = res..points[i]; }
	return res;
}

pair intersection (path g, pair point, pair dir)
{ return point(g, intersectiontime(g, point, dir)); }

path reorient (path g, real time)
{ return subpath(g, time, length(g))--subpath(g, 0, time)--cycle; }

path turn (path g, pair point, pair dir)
{ return reorient(g, intersectiontime(g, point, dir)); }

path subcyclic (path p, pair t)
{
    if (t.x <= t.y) return subpath(p, t.x, t.y);
    return subpath(p, t.x, length(p))--subpath(p, 0, t.y);
}

bool clockwise (path p)
{ return (windingnumber(p, inside(p)) == -1); }

bool meet (path p, path q)
{ return (intersect(p, q).length > 0); }

bool meet (path p, path[] q)
{
    for (int i = 0; i < q.length; ++i)
    { if (meet(p, q[i])) return true; }
    return false;
}

path[] concat (path[][] a)
// Same as the standard Asymptote `concat` function, but with more than two arguments.
{
    if (a.length == 1) return a[0];
    path[] b = a.pop();
    return concat(concat(a), b);
}

path ellipsepath (pair a, pair b, real curve = 0, bool abs = false)
// Returns half of an ellipse connecting points `a` and `b`. Curvature may be relative or absolute.
{
    if (!abs) curve = curve*length(b-a);
    pair mid = (a+b)*.5;
    path e = rotate(degrees(a-b), z = mid)*ellipse(mid, length(b-a)*.5, curve);
    return subpath(e, 0, reltime(e, .5));
}

path curvedpath (pair a, pair b, real curve = 0, bool abs = false)
// Constucts a curved path between two points.
{
    if (abs) curve = curve/length(b-a);
    pair mid = (a+b)*.5;
    return a .. (mid + curve * (rotate(-90) * (b-a))) .. b;
}

path cyclepath (pair a, real angle, real radius)
{ return shift(a)*rotate(angle)*scale(radius)*shift(1,0)*rotate(180)*reverse(unitcircle); }

pair range (path g, pair center, pair dir, real ang, real orientation = 1)
{
    return (intersectiontime(g, center, rotate(orientation*ang*.5)*dir), intersectiontime(g, center, rotate(-orientation*ang*.5)*dir));
}

bool isinside (path p, pair x)
{ return windingnumber(p, x) == windingnumber(p, inside(p)); }

bool insidepath (path p, path q)
// Checks if q is completely inside p (the direction of p does not matter). Shorthand for inside(p, q) == 1
{ return (inside(p, srap(scale = .99, rotate = 0, point = center(p))*q) == 1); }

bool outsidepath (path p, path q)
{ return !meet(p,q) && !insidepath(p,q); }

path midpath (path g, path h, int n = 20)
// Constructs the "mean" path between two given paths.
{
    path res;
    for (int i = 0; i < n; ++i)
    {
        res = res .. {(dir(g, reltime(g, i/n)) + dir(h, reltime(h, i/n)))*.5}((point(g, reltime(g, i/n)) + point(h, reltime(h, i/n)))*.5);
    }
    return res .. {(dir(g, reltime(g, 1)) + dir(h, reltime(h, 1)))*.5}((point(g, reltime(g, 1)) + point(h, reltime(h, 1)))*.5);
}

path pop (path[] source)
{
	path i = source[0];
	source.delete(0);
	return i;
}

real xsize (path p){return xpart(max(p)) - xpart(min(p));}
real ysize (path p){return ypart(max(p)) - ypart(min(p));}

real xsize (picture p){return xpart(max(p)) - xpart(min(p));}
real ysize (picture p){return ypart(max(p)) - ypart(min(p));}

path wavypath (real[] nums)
{
    if (nums.length == 1) return scale(nums[0])*defaultPaUC;
    
	pair[] points = sequence(new pair (int i){return nums[i]*dir(-360*(i/nums.length));}, nums.length);
    path getpath (pair[] arr)
    {
        if (arr.length == 2) return arr[0]{rotate(-90)*arr[0]}..{rotate(-90)*arr[1]}arr[1];
        pair a = arr.pop();
        return getpath(arr) .. {rotate(-90)*a}a;
    }
    
	return getpath(points)..cycle;
}
path wavypath (... real[] nums)
{ return wavypath(nums = nums); }

// -- More complicated path utilities -- //

struct gauss
// A Gaussian integer.
{
    int x;
    int y;

    void operator init (int x, int y)
    {
        this.x = x;
        this.y = y;
    }
}

bool operator == (gauss a, gauss b)
{ return a.x == b.x && a.y == b.y; }

gauss operator cast (pair p)
{ return gauss(floor(p.x), floor(p.y)); }
pair operator cast (gauss g)
{ return (g.x, g.y); }

path connect (path p, path q)
// Connects `p` and `q` smoothly.
{ return p -- (point(p, length(p)){dir(p, length(p))} .. {dir(q, 0)}point(q, 0)) -- q; }

path[] combination (path p, path q, int mode, bool round, real roundcoeff)
// A general way to "combine" two paths based on their intersection points.
{
    if (!meet(p, q)) return new path[];

	real proundlength = roundcoeff*arclength(p);
    real qroundlength = roundcoeff*arclength(q);
    
	real[][] times = intersections(p, q);
    for (int i = 0; i < times.length; ++i)
    {
        pair pdi = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = -1) : dir(p, times[i][0]);
        pair pdo = (times[i][0] == floor(times[i][0])) ? dir(p, floor(times[i][0]), sign = 1) : dir(p, times[i][0]);
        pair qdi = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = -1) : dir(q, times[i][1]);
        pair qdo = (times[i][1] == floor(times[i][1])) ? dir(q, floor(times[i][1]), sign = 1) : dir(q, times[i][1]);

        if (sgn(cross(qdi, pdi))*sgn(cross(pdo, qdo)) >= 0)
        {
            times.delete(i);
            --i;
        }
    }
    
	int n = times.length;
    int[] pinds = sort(sequence(n), new bool (int a, int b){return (times[a][1] <= times[b][1]);});
    int[] qinds = sort(sequence(n), new bool (int a, int b){return (times[pinds[a]][0] <= times[pinds[b]][0]);});
    
	path[] res;
    
	gauss start = (0, qinds[0]);
    gauss[] nextstarts;
    int visited = 0;
    gauss curind = start;
    path curpath;
    
	while (visited < n)
    {
        visited += 1;
        bool pway;
        gauss newind;
        pair pdir = (times[curind.x][0] == floor(times[curind.x][0])) ? dir(p, floor(times[curind.x][0]), sign = 1) : dir(p, times[curind.x][0]);
        pair qdir = (times[curind.x][1] == floor(times[curind.x][1])) ? dir(q, floor(times[curind.x][1]), sign = 1) : dir(q, times[curind.x][1]);
        if(cross(pdir, qdir)*mode < 0) pway = true;
        else pway = false;
        if(pway)
        {
            newind = ((curind.x+1)%n, qinds[(curind.x+1)%n]);
            if ((-(newind.y - curind.y)*windingnumber(q, inside(q)))%n > 1)
            { nextstarts.insert(i = 0, (pinds[(curind.y+1)%n], (curind.y+1)%n)); }
        }
        else
        {
            newind = (pinds[(curind.y+1)%n], (curind.y+1)%n);
            if ((-(newind.x - curind.x)*windingnumber(p, inside(p)))%n > 1)
            { nextstarts.insert(i = 0, ((curind.x+1)%n, qinds[(curind.x+1)%n])); }
        }
        path addpath = subcyclic(pway ? p : q, (times[curind.x][pway ? 0 : 1], times[newind.x][pway ? 0 : 1]));
        if (!round || curpath == nullpath) curpath = curpath -- addpath;
        else
        {
            path subcurpath = subpath(curpath, 0, arctime(curpath, arclength(curpath)- (pway ? qroundlength : proundlength)));
            path subaddpath = subpath(addpath, arctime(addpath, (pway ? proundlength : qroundlength)), length(addpath));
            curpath = connect(subcurpath, subaddpath);
        }
        if (newind == start)
        {
            path finpath;
            if (!round) finpath = curpath--cycle;
            else
            {
                real begin = arctime(curpath, (pway ? qroundlength : proundlength));
                real end = arctime(curpath, arclength(curpath)-(pway ? proundlength : qroundlength));
                finpath = subpath(curpath, begin, end)--(point(curpath, end){dir(curpath, end)}..{dir(curpath, begin)}point(curpath, begin))--cycle;
            }
            res.push(finpath);
            curpath = nullpath;
            if (nextstarts.length == 0) break;
            start = nextstarts.pop();
            curind = start;
        }
        else curind = newind;
    }

	res = sort(res, new bool (path i, path j){
		if (clockwise(i)) return true;
		else if (!clockwise(j)) return true;
		else return false;
	});

    return res;
}

// -- Set operations on paths! Cool, huh? -- //

path[] difference (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (windingnumber(p, point(q,0)) == -1) return new path[]{p, reverse(q)};
        if (windingnumber(q, point(p,0)) == -1) return new path[]{};
        return new path[]{p};
    }

    return combination(p, reverse(q), mode = -1, round = round, roundcoeff = roundcoeff);
}
path[] difference (path[] paths, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
        if (!clockwise(q)) q = reverse(q);
    }

    return concat(sequence(new path[] (int i){return difference(paths[i], q, correct = false, round = round, roundcoeff = roundcoeff);}, paths.length));
}
path[] operator - (path p, path q)
{ return difference(p, q); }
path[] operator - (path[] p, path q)
{ return difference(p, q); }

path[] intersection (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (insidepath(p,q)) return new path[]{q};
        if (insidepath(q,p)) return new path[]{p};
        return new path[];
    }

    return combination(p, q, mode = -1, round = round, roundcoeff = roundcoeff);
}
path[] intersection (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
    }
    if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return intersection(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);
	
	paths = sequence(new path (int i){return paths[i];}, paths.length);
    
	path p = paths.pop();
    path[] prev = intersection(paths, correct = false, round = round, roundcoeff = roundcoeff);
    
	return concat(sequence(new path[] (int i){return intersection(prev[i], p, correct);}, prev.length));
}
path[] intersection (bool correct = true, bool round = false, real roundcoeff = defaultSyRR ... path[] paths)
{return intersection(paths, correct, round, roundcoeff);}
path[] intersection (path p, path q, path[] holes, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
        for (int i = 0; i < holes.length; ++i)
        { if (!clockwise(holes[i])) holes[i] = reverse(holes[i]); }
    }
    
	path[] res = intersection(p, q, correct = false, round = round, roundcoeff = roundcoeff);
    for (int i = 0; i < holes.length; ++i)
    { res = difference(res, holes[i], correct = false, round = round, roundcoeff = roundcoeff); }
    
	return res;
}
path[] operator & (path p, path q)
{ return intersection(p, q); }

path[] union (path p, path q, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        if (!clockwise(p)) p = reverse(p);
        if (!clockwise(q)) q = reverse(q);
    }
    if (!meet(p, q))
    {
        if (insidepath(p,q)) return new path[]{p};
        if (insidepath(q,p)) return new path[]{q};
        return new path[]{p,q};
    }
    
	return combination(p, q, mode = 1, round = round, roundcoeff = roundcoeff);
}
path[] union (path[] paths, bool correct = true, bool round = false, real roundcoeff = defaultSyRR)
{
    if (correct)
    {
        for (int i = 0; i < paths.length; ++i)
        { if (!clockwise(paths[i])) paths[i] = reverse(paths[i]); }
    }
    
	if (paths.length == 0) return new path[];
    if (paths.length == 1) return paths;
    if (paths.length == 2) return union(paths[0], paths[1], correct = false, round = round, roundcoeff = roundcoeff);
    
	for (int i = 0; i < paths.length; ++i)
    {
        for (int j = i+1; j < paths.length; ++j)
        {
            if (meet(paths[i], paths[j]))
            {
                paths[i] = union(paths[i], paths[j], correct = false, round = round, roundcoeff = roundcoeff)[0];
                paths.delete(j);
                j = i;
            }
        }
    }
    
	return paths;
}
path[] union (bool correct = true, bool round = false, real roundcoeff = defaultSyRR ... path[] paths)
{return union(paths, correct, round, roundcoeff);}
path[] operator | (path p, path q)
{ return union(p, q); }

pair randomdir (pair dir, real angle)
{ return dir(degrees(dir) + (unitrand()-.5)*angle); }

path randompath (pair[] controlpoints, real angle)
{
	if (controlpoints.length < 2) return nullpath;

	pair outdir = randomdir(controlpoints[1]-controlpoints[0], angle);
	path res = controlpoints[0];
	for (int i = 1; i < controlpoints.length; ++i)
	{
		pair indir = randomdir(controlpoints[i]-controlpoints[i-1], angle);
		res = res{outdir} .. {indir}controlpoints[i];
		outdir = indir;
	}

	return res;
}

// -- All the functions that construct section positions -- //

real sectionissymmetric (pair p1, pair p2, pair dir1, pair dir2)
{ return abs(dot(unit(dir2), unit(p1-p2))-dot(unit(p2-p1), unit(dir1))); }

bool sectiontoowide (pair p1, pair p2, pair dir1, pair dir2)
{
    return (min(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) <= -defaultSeWT || max(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) >= defaultSeWT);
}

// -- Technical functions to construct horizontal and vertical sections -- //

pair[][] cartsectionpoints (path[] g, real r, bool horiz)
{
    real min = horiz ? ypart(min(g)) : xpart(min(g));
    real max = horiz ? ypart(max(g)) : xpart(max(g));
    pair[][] res = new pair[][];
    r = min*(1-r)+max*r;
	
	for (int i = 0; i < g.length; ++i)
    {
        real[] times = horiz ? times(g[i], (0, r)) : times(g[i], r);
        for (int j = 0; j < times.length; ++j)
        { res.push(new pair[] {point(g[i], times[j]), dir(g[i], times[j]), (i,0)}); }
    }
    
	return sort(res, new bool (pair[] i, pair[] j){ return ((horiz ? xpart(i[0]) : ypart(i[0])) < (horiz ? xpart(j[0]) : ypart(j[0]))); });
}
pair[][] cartsections (path[] g, real r, bool horiz)
// Marks the places where it is suitable to draw horizontal or vertical sections of `g` at ratio `r`.
{
    pair[][] presections = cartsectionpoints(g, r, horiz);
	if (presections.length % 2 == 1) return new pair[][];
    pair[][] sections;

	for (int i = 0; i < presections.length; i += 2)
	{
		if (sectiontoowide(presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]))
		{ continue; }
		if (length(presections[i][0]-presections[i+1][0]) > defaultSmCMLR*(horiz ? xsize(g[0]) : ysize(g[0])))
		{ continue; }
	
		bool exclude = false;
		for (int j = 0; j < g.length; ++j)
		{
			if (j == presections[i][2].x || j == presections[i+1][2].x) continue;
			if (meet(g[j], curvedpath(presections[i][0], presections[i+1][0], defaultSmNC)) || meet(g[j], curvedpath(presections[i+1][0], presections[i][0], defaultSmNC)))
			{
				exclude = true;
				break;
			}
		}

		if (!exclude)
		{
			sections.push(new pair[]{presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]});
		}
	}

	return sections;
}
pair ellipseparams (real l, real h, real cang1, real cang2, bool binsearch)
{
    if (!binsearch) 
    {
        real cang = (cang1 + cang2)*.5;
		if (abs(cang) < defaultSySN) return (l*.5, -l*.5);
        return (l*.5, sqrt(l*l*.25 - cang^2 * h^2 / (1 - cang^2)));
    }
    
	real r1 = 0;
    real l1 = l*.5;
    real r2 = 0;
    real l2 = l*.5;
    real want = defaultSySN;
    path line1 = -(cang1, sqrt(1-cang1^2)) -- (cang1, sqrt(1-cang1^2));
    path line2 = ((l,0) - (-cang2, sqrt(1-cang2^2))) -- ((l,0) + (-cang2, sqrt(1-cang2^2)));
	
	path ellipse (real d1, real d2)
	{ return ellipse(((d1 + l-d2)*.5, 0), (l-d1-d2)*.5, h); }
    
	while (l1-r1 >= want || l2-r2 >= want)
    {
        real c1 = (r1+l1)*.5;
        real c2 = (r2+l2)*.5;
        if(!meet(line1, ellipse(c1, r2))){l1 = c1;}
        else {r1 = c1;}
        if(!meet(line2, ellipse(r1, c2))){l2 = c2;}
        else {r2 = c2;}
    }
    
	return ((l1 + (l-l2))*.5, (l-l1-l2)*.5);
}

real sectionheight (real x, real max)
{
	real m2 = max/2;
	return (x < m2) ? x : (x - m2)/(1+(2*(x-m2)/max))+m2;
}

path[] sectionellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir, bool free)
// One of the most important technical functions of the module. Constructs an ellipse that touches `dir1` and `dir2` and whose center lies on the segment [p1, p2].
{
	if (length(viewdir) == 0) return new path[]{p1--p2};

    pair p1p2 = unit(p2-p1);
    real l = length(p2-p1);
    
	pair hv = (rotate(90)*p1p2) * cross(p2-p1, viewdir)*.5;
	if (length(hv) == 0) return new path[] {p1--p2};
    real h = sectionheight(length(hv), currentSyMaEH);
	if (h < defaultSyMiEHR*l) return new path[]{p1--p2};

	if(cross(p1p2, dir1) < 0) dir1 = rotate(180)*dir1;
    if(cross(dir2, -p1p2) < 0) dir2 = rotate(180)*dir2;
    
	real cang1 = dot(p1p2, unit(dir1));
    real cang2 = dot(unit(dir2), -p1p2);
    real sign = sgn(cross(p1p2, hv));
    path line1 = (p1 - 10*dir1) -- (p1 + 10*dir1);
    path line2 = (p2 - 10*dir2) -- (p2 + 10*dir2);
    real cang = (cang1+cang2)*.5;
    
	if (l*l*.25 - cang^2 * h^2 / (1 - cang^2) < 0) return new path[]{p1--p2};
    
	pair pos =  ellipseparams(l, h, cang1, cang2, binsearch = (free && sectionissymmetric(p1, p2, dir1, dir2) >= defaultSySN));
    real c = pos.x;
    real x = abs(pos.y);
    path pres = (sign < 0) ? rotate(180, (c,0))*ellipse((c, 0), x, h) : reverse(rotate(180, (c,0))*ellipse((c, 0), x, h));
    real tg1 = (abs(cang1) < defaultSySN) ? 0 : sqrt(1 - cang1^2)/cang1;
    real t1 = 0;
    
	if(tg1 != 0)
    {
        real r1 = abs(h/(tg1 * sqrt(1 + (x/h * tg1)^2)));
        real[] times1 = times(pres, r1);
        t1 = (times1.length == 2) ? times1[1 - floor((sgn(tg1)*sign + 1)*.5)] : 0;
    }
    
	pres = reorient(pres, t1);
    real t2 = intersect(pres, (c, 0)--(c+2*x, 0))[0];
    real tg2 = (abs(cang2) < defaultSySN) ? 0 : sqrt(1 - cang2^2)/cang2;
    
	if(tg2 != 0)
    {
        real r2 = l - abs(h/(tg2 * sqrt(1 + ((l-x)/h * tg2)^2)));
        real[] times2 = times(pres, r2);
        t2 = (times2.length == 2) ? times2[1 - floor((sgn(tg2)*sign + 1)*.5)] : intersect(pres, (c, 0)--(c+2*x, 0))[0];
    }
    
	return map(new path (path p){return shift(p1)*rotate(degrees(p1p2))*p;}, new path[] {subpath(pres, 0, t2), subpath(pres, t2, length(pres))});
}
pair[][] sectionparamsfree (path g, path h, int p, int step)
// Searches for potential section positions between two given paths in the way that first comes to mind. Has its benefits and limitations.
{
    pair[][] res = new pair[][];
    real arc = arclength(g);
    real[] gtimes = sequence(new real (int i){return arctime(g, arc*i/p);}, p);
	real suitableeps = defaultSySN*5000;

	for (int i = 0; i < gtimes.length; ++i)
    {
        pair p1 = point(g, gtimes[i]);
        pair dir1 = dir(g, gtimes[i]);
        real htime = intersectiontime(h, p1, rotate(90)*dir1);
        if (htime != -1)
        {
            pair p2 = point(h, htime);
            pair dir2 = dir(h, htime);
            if (sectionissymmetric(p1, p2, dir1, dir2) < suitableeps)
            {
                res.push(new pair[] {p2, p1, dir2, dir1});
                i += step;
            }
        }
    }
    return res;
}
pair[][] sectionparamsstrict (path g, path h, int n, real ratio, int p, bool addtimes = false)
// Searches for potential section positions between two given paths using a [clever] algorithm.
{
    real goddstep = arclength(g)/(n + (n-1)*(1 - ratio)/ratio);
    real gevenstep = goddstep*(1-ratio)/ratio;
    real hoddstep = arclength(h)/(n + (n-1)*(1-ratio)/ratio);
    real hevenstep = hoddstep*(1-ratio)/ratio;
    real[] gtimes = new real[];
    for(int i = 0; i < 2*n; ++i)
    {
        if(i % 2 == 0)
        { gtimes.push(arctime(g, i*.5*(goddstep + gevenstep))); }
        else
        { gtimes.push(arctime(g, goddstep*(i+1)*.5 + gevenstep*(i-1)*.5)); }
    }
    real[] htimes = new real[];
    for (int i = 0; i < 2*n; ++i)
    {
        if(i % 2 == 0)
        { htimes.push(arctime(h, i*.5*(hoddstep + hevenstep))); }
        else
        { htimes.push(arctime(h, hoddstep*(i+1)*.5 + hevenstep*(i-1)*.5)); }
    }
    pair[][] res = new pair[][];
    for (int i = 0; i < 2*n-1; i += 2)
    {
        int gi = 0;
        int hi = 0;
        real garcstep = arclength(g, gtimes[i], gtimes[i+1])/p;
        real harcstep = arclength(h, htimes[i], htimes[i+1])/p;
        real gcurtime = gtimes[i];
        real hcurtime = htimes[i];
        pair p1 = point(g, gtimes[i]);
        pair dir1 = dir(g, gtimes[i]);
        pair p2 = point(h, htimes[i]);
        pair dir2 = dir(h, htimes[i]);
        pair t;
        if(addtimes) t  = (gtimes[i], htimes[i]);
        while(gi < p-1 || hi < p-1)
        {
            if(gi < p-1) gcurtime = arctime(g, arclength(g, 0, gcurtime)+garcstep);
            if(hi < p-1) hcurtime = arctime(h, arclength(h, 0, hcurtime)+harcstep);
            pair p1new = point(g, gcurtime);
            pair dir1new = dir(g, gcurtime);
            pair p2new = point(h, hcurtime);
            pair dir2new = dir(h, hcurtime);
            if ((sectionissymmetric(p1, p2new, dir1new, dir2new) < sectionissymmetric(p1new, p2, dir1new, dir2) && hi < p-1) || gi == p-1)
            {
                hi += 1;
                if (sectionissymmetric(p1, p2new, dir1, dir2new) < sectionissymmetric(p1, p2, dir1, dir2))
                {
                    p2 = p2new;
                    dir2 = dir2new;
                    if(addtimes) t = (t.x, hcurtime);
                }
            }
            else
            {
                gi += 1;
                if (sectionissymmetric(p1new, p2, dir1new, dir2) < sectionissymmetric(p1, p2, dir1, dir2))
                {
                    p1 = p1new;
                    dir1 = dir1new;
                    if(addtimes) t = (gcurtime, t.y);
                }
            }
        }
        if(addtimes) res.push(new pair[] {p2, p1, dir2, dir1, t});
        else res.push(new pair[] {p2, p1, dir2, dir1});
    }
    return res;
}

// -- Here the module definitions start -- //

usepackage("amssymb"); // LaTeX package for mathematical symbols

struct element
{
	pair pos;
	string label;
	pair labelalign;

	void operator init (pair pos, string label = "", pair labelalign = S)
	{
		this.pos = pos;
		this.label = label;
		this.labelalign = labelalign;
	}

	element copy ()
	{ return element(this.pos, this.label, this.labelalign); }
}

pair operator cast (element elt)
{ return elt.pos; }
element operator cast (pair a)
{ return element(a); }

bool operator == (element a, element b)
{ return a.pos == b.pos; }

void elementadjust (element elt, pair shift, real scale, real rotate, pair point)
{ elt.pos = srap(scale, rotate, point)*shift(shift)*elt.pos; }

struct hole
{
    path contour;
    pair center;
    real[][] sections;
    int neighnumber;

    void operator init (path contour, pair center = center(contour), real[][] sections = {}, int neighnumber = currentSeNN, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = center, bool copy = false)
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.sections = sections;
            this.neighnumber = neighnumber;
        }
        else
        {
            path pseudocontour = shift(shift)*srap(scale, rotate, point)*contour;
            this.contour = (!clockwise(pseudocontour)) ? reverse(pseudocontour) : pseudocontour;
            this.center = shift(shift)*center;
            this.sections = new real[][];
            for (int i = 0; i < sections.length; ++i)
            {
                real[] arr = sections[i];
                while(arr.length < currentsection.length) {arr.push(currentsection[arr.length]);}
                this.sections.push(arr);
            }
            this.neighnumber = neighnumber;
        }
    }
    hole move (pair shift, real scale, real rotate, pair point = this.center, bool movesections = false)
    {
        this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
        this.center = shift(shift)*srap(scale, rotate, point)*this.center;
        if (!movesections) return this;
        for (int i = 0; i < this.sections.length; ++i)
        {
            pair sectdir = (this.sections[i][0], this.sections[i][1]);
            this.sections[i][0] = xpart(rotate(rotate)*sectdir);
            this.sections[i][1] = ypart(rotate(rotate)*sectdir);
        }
        
		return this;
    }
    hole copy ()
    { return hole(this.contour, this.center, copy(this.sections), this.neighnumber, copy = true); }
    hole replicate (hole h)
    { 
        this.contour = h.contour;
        this.center = h.center;
        this.sections = h.sections;
        this.neighnumber = h.neighnumber;

        return this;
    }
    bool isnull ()
    { return this.contour == nullpath; }
}

hole nullhole;

bool operator == (hole a, hole b)
{ return a.contour == b.contour; }

hole[] holecopy (hole[] holes)
{ return sequence(new hole (int i){return holes[i].copy();}, holes.length); }

path[] holecontours (hole[] h)
{ return sequence(new path (int i){return h[i].contour;}, h.length); }

void holeadjust (hole hl, pair shift, real scale, real rotate, pair point)
{ hl.move(shift, scale, rotate, shift(-shift) * point, false); }

struct subset
// A isintersection class representing a subset of a given object (see "smooth")
{
    path contour;
    pair center;
	string label;
    pair labeldir;
    pair labelalign;
	int layer;
	int[] subsets;
	bool isintersection;

    real xsize () { return xsize(this.contour); }
    real ysize () { return ysize(this.contour); }

	subset setcenter (pair center = center(this.contour))
	{ this.center = center; return this; }
    subset setlabel (string label = this.label, pair labeldir = this.labeldir, pair labelalign = defaultSyDP, bool keepalign = false)
    {
		this.label = label;
		this.labeldir = labeldir;
		this.labelalign = keepalign ? this.labelalign : (labelalign == defaultSyDP) ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;

        return this;
    }
    subset setlabel (string label = this.label, real angle)
    { return this.setlabel(label, dir(angle)); }
    subset move (pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.center, bool movelabel = false)
    {
		this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
		this.center = shift(shift)*srap(scale, rotate, point)*this.center;
		if (movelabel) this.setlabel(labeldir = rotate(rotate)*this.labeldir); else this.setlabel();

        return this;
    }

	void operator init (path contour, pair center = center(contour), string label = "", pair labeldir = defaultSyDP, pair labelalign = S, int layer = 0, int[] subsets = {}, bool isintersection = false, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = center, bool copy = false)
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
			this.layer = layer;
			this.subsets = subsets;
			this.isintersection = isintersection;
        }
        else
        {
            this.contour = (!clockwise(contour)) ? shift(shift)*srap(scale, rotate, point)*reverse(contour)             : shift(shift)*srap(scale, rotate, point)*contour;
            this.center = shift(shift)*srap(scale, rotate, point)*center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign == defaultSyDP ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;
			this.layer = layer;
			this.subsets = new int[]{};
			this.isintersection = isintersection;
        }
    }
    
	subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign, this.layer, copy(this.subsets), this.isintersection, copy = true);
    }
    subset replicate (subset s)
    { 
        this.contour = s.contour;
        this.center = s.center;
        this.label = s.label;
        this.labeldir = s.labeldir;
        this.labelalign = s.labelalign;
		this.layer = s.layer;
		this.subsets = copy(s.subsets);
		this.isintersection = s.isintersection;
        
        return this;
    }
    bool isnull ()
    { return this.contour == nullpath; }
}

subset nullsubset;

bool operator == (subset a, subset b)
{ return a.contour == b.contour; }

subset[] subsetcopy (subset[] subsets)
{ return sequence(new subset (int i){return subsets[i].copy();}, subsets.length); }

path[] subsetcontours (subset[] s)
{ return sequence(new path (int i){return s[i].contour;}, s.length); }

void subsetadjust (subset s, pair shift, real scale, real rotate, pair point)
{ s.move(shift, scale, rotate, shift(-shift) * point, true); }

subset[] subsetintersection (subset sb1, subset sb2, bool setlabel = currentSmIL)
{
	path[] contours = intersection(sb1.contour, sb2.contour);
	return sequence(new subset (int i){
		return subset(
			contour = contours[i],
			label = (currentSmIL && setlabel && length(sb1.label) > 0 && length(sb2.label) > 0 && contours.length == 1) ? (sb1.label + " \cap " + sb2.label) : "",
			labeldir = rotate(-90)*unit(sb1.center - sb2.center),
			labelalign = setlabel ? 2*(rotate(90)*unit(sb1.center - sb2.center)) : defaultSyDP,
			layer = max(sb1.layer, sb2.layer)+1,
			isintersection = true
		);
	}, contours.length);
}
void subsetdelete (subset[] subsets, int ind, bool recursive)
{
	subset cursb = subsets[ind];
	if (recursive)
	{
		for (int i = 0; i < cursb.subsets.length; ++i)
		{ subsetdelete(subsets, cursb.subsets[i], recursive); }
	}
	subsets.delete(ind);
	for (int i = 0; i < subsets.length; ++i)
	{
		for (int j = 0; j < subsets[i].subsets.length; ++j)
		{
			if (subsets[i].subsets[j] == ind) subsets[i].subsets.delete(j);
			if (subsets[i].subsets[j] > ind) subsets[i].subsets[j] -= 1;
		}
	}
}
void subsetsort (subset[] subsets, int[] range)
{ range = sort(range, new bool (int i, int j){return subsets[i].layer <= subsets[j].layer;}); }

int subsetgetindex (subset[] subsets, int[] ind)
{
	int res = ind[0];
	for (int i = 1; i < ind.length; ++i)
	{ res = subsets[res].subsets[ind[i]]; }
	return res;
}
int subsetgetindex (subset[] subsets ... int[] ind)
{ return subsetgetindex(subsets, ind); } // try to change later
subset subsetget (subset[] subsets, int[] ind)
{ return subsets[subsetgetindex(subsets, ind)]; }
subset subsetget (subset[] subsets ... int[] ind)
{ return subsets[subsetgetindex(subsets, ind)]; }

int[] subsetgetlayer (subset[] subsets, int[] range, int layer)
{
	int[] res;
	for (int i = 0; i < range.length; ++i)
	{ if (subsets[range[i]].layer == layer) res.push(range[i]); }
	return res;
}
int[] subsetgetall (subset[] subsets, subset s)
{
	bool[] wanted = array(subsets.length, false);
	void fill (subset sp)
	{
		for (int i = 0; i < sp.subsets.length; ++i)
		{
			wanted[sp.subsets[i]] = true;
			fill(subsets[sp.subsets[i]]);
		}
	}
	fill(s);
	int[] res;
	for (int i = 0; i < subsets.length; ++i)
	{ if (wanted[i]) res.push(i); }
	return res;
}
int[] subsetgetall (subset[] subsets, int ind)
{ return subsetgetall(subsets, subsets[ind]); }
int[] subsetgetall (subset[] subsets, int[] ind)
{ return subsetgetall(subsets, subsetget(subsets, ind)); }

int[] subsetgetallnot (subset[] subsets, subset s)
{ return difference(sequence(subsets.length), subsetgetall(subsets, s)); }
int[] subsetgetallnot (subset[] subsets, int ind)
{ return difference(sequence(subsets.length), subsetgetall(subsets, ind)); }
int[] subsetgetallnot (subset[] subsets, int[] ind)
{ return difference(sequence(subsets.length), subsetgetall(subsets, ind)); }

void subsetdeepen (subset[] subsets, subset s)
{
	s.layer += 1;
	for (int i = 0; i < s.subsets.length; ++i)
	{ if (s.layer == subsets[s.subsets[i]].layer) subsetdeepen(subsets, subsets[s.subsets[i]]); }
}

int subsetinsertindex (subset[] subsets, int layer)
{
	int insertindex = subsets.length;
	for (int i = 0; i < subsets.length; ++i)
	{
		if (subsets[i].layer > layer)
		{
			insertindex = i;
			break;
		}
	}
	
	return insertindex;
}
int subsetinsert (subset[] subsets, subset s)
{
	int ind = subsetinsertindex(subsets, s.layer);
	subsets.insert(ind, s);
	for (int i = 0; i < subsets.length; ++i)
	{
		for (int j = 0; j < subsets[i].subsets.length; ++j)
		{ if (subsets[i].subsets[j] >= ind) subsets[i].subsets[j] += 1; }
	}

	return ind;
}

int subsetmaxlayer (subset[] subsets, int[] range)
{
	int res = -1;
	for (int i = 0; i < range.length; ++i)
	{ if (subsets[range[i]].layer > res) res = subsets[range[i]].layer; }
	return res;
}

struct smooth
// The main class in the module. Represents the way a "smooth manifold" would be drawn on a piece of paper.
{
	path contour;
	pair center;
	string label;
	pair labeldir;
	pair labelalign;
	hole[] holes;
	subset[] subsets;
	element[] elements;
    real[] hratios;
    real[] vratios;
    pair shift;
    real scale;
    real rotate;
    pair viewdir;
    smooth[] attached;

	bool shiftsubsets;

    real xsize () { return xsize(this.contour); }
    real ysize () { return ysize(this.contour); }

	bool isinside (pair x)
	{
		if (!isinside(this.contour, x)) return false;
		for (int i = 0; i < this.holes.length; ++i)
		{ if (isinside(this.holes[i].contour, x)) return false; }
		return true;
	}
    real getyratio (real y)
    { return (y - ypart(min(this.contour)))/this.ysize(); }
    real getxratio (real x)
    { return (x - xpart(min(this.contour)))/this.xsize(); }
    real getypoint (real y)
    {
        y = y - floor(y);
        return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y);
    }
    real getxpoint (real x)
    {
        x = x - floor(x);
        return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x);
    }
    smooth simplemove (pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.center)
    {
		this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
        this.center = shift(shift)*rotate(rotate, point)*this.center;
        this.labeldir = rotate(rotate)*this.labeldir;
        this.labelalign = rotate(rotate)*this.labelalign;
		
		for (int i = 0; i < this.holes.length; ++i)
        { this.holes[i].move(shift, scale, rotate, point, true); }
        for (int i = 0; i < this.subsets.length; ++i)
        { this.subsets[i].move(shift, scale, rotate, point, true); }

        return this;
    }
    smooth xscale (real s)
    {
        pair center = this.center;
        this.simplemove(shift = -center);
        this.contour = scale(s,1)*this.contour;
		this.labelalign = rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir));
        
		for (int i = 0; i < this.holes.length; ++i)
        {
            this.holes[i].contour = scale(s,1)*this.holes[i].contour;
            this.holes[i].center = scale(s,1)*this.holes[i].center;

            for (int j = 0; j < this.holes[i].sections.length; ++j)
            {
                pair dir = (this.holes[i].sections[j][0], this.holes[i].sections[j][1]);
                this.holes[i].sections[j][0] = (scale(s,1)*dir).x;
                this.holes[i].sections[j][1] = (scale(s,1)*dir).y;
            }
        }
        for (int i = 0; i < this.subsets.length; ++i)
        {
			subset sb = this.subsets[i];
			sb.contour = scale(s,1) * sb.contour;
			sb.center = scale(s,1) * sb.center;
			sb.setlabel();
		}

        this.simplemove(shift = center);

        return this;
    }
    smooth yscale (real s)
    {
        pair center = this.center;
        this.simplemove(shift = -center);
        this.contour = scale(1,s)*this.contour;
		this.labelalign = rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir));
        
		for (int i = 0; i < this.holes.length; ++i)
        {
            this.holes[i].contour = scale(1,s)*this.holes[i].contour;
            this.holes[i].center = scale(1,s)*this.holes[i].center;

            for (int j = 0; j < this.holes[i].sections.length; ++j)
            {
                pair dir = (this.holes[i].sections[j][0], this.holes[i].sections[j][1]);
                this.holes[i].sections[j][0] = (scale(1,s)*dir).x;
                this.holes[i].sections[j][1] = (scale(1,s)*dir).y;
            }
        }
        for (int i = 0; i < this.subsets.length; ++i)
        {
			subset sb = this.subsets[i];
			sb.contour = scale(1,s) * sb.contour;
			sb.center = scale(1,s) * sb.center;
			sb.setlabel();
		}
        
		this.simplemove(shift = center);

        return this;
    }
    smooth dirscale (real s, pair dir)
    {
        if (length(dir) == 0) return this;
		
		real deg = degrees(dir);
        this.simplemove(rotate = -deg);
        this.xscale(s);
        this.simplemove(rotate = deg);
        
		return this;
    }
    smooth dropview ()
    {
		if (length(this.viewdir) == 0) return this;
        
		if (this.shiftsubsets)
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{ this.subsets[i].move(shift = -this.viewdir * defaultSmSVS * Sin(defaultSmVA)); }
		}
		this.dirscale(1/Cos(defaultSmVA * length(this.viewdir)), this.viewdir);
        this.viewdir = (0,0);

        return this;
    }
    smooth setview (pair viewdir)
    {
		if (viewdir == this.viewdir) return this;

        this.dirscale(Cos(defaultSmVA * length(viewdir)), viewdir);
		if (this.shiftsubsets)
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{ this.subsets[i].move(shift = viewdir * defaultSmSVS * Sin(defaultSmVA)); }
		}
        this.viewdir = viewdir;
        
		return this;
    }
    smooth setratios (real[] ratios, bool horiz)
    {
		printbeginning("Setting " + (horiz ? "horizontal" : "vertical") + " ratios for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");

		if (ratios.length == 0)
		{
			int count = 0;
			real[] curratios = horiz ? this.hratios : this.vratios;
			while (defaultSmCEM + count*defaultSmCSD < 1 - defaultSmCEM)
			{
				curratios.push(defaultSmCEM + count*defaultSmCSD);
				count += 1;
			}

			printsuccess();
			return this;
		}
		for (int i = 0; i < ratios.length; ++i)
		{
			if (!inside(0,1, ratios[i]))
			{
				printfailure("Could not set ratios: all entries must lie between 0 and 1.");
				return this;
			}
		}

		if (horiz) this.hratios = ratios;
		else this.vratios = ratios;
		printsuccess();
        
        return this;
    }
    smooth setcenter (int[] ind = {}, pair center = center(this.contour), bool unit = true)
    {
		printbeginning("Setting center for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		if (ind.length == 0) this.center = unit ? shift(this.shift)*center : center;
		else subsetget(this.subsets, ind).setcenter(unit ? shift(this.shift)*center : center);
        
		if (!this.isinside(this.center))
		{ printwarning("Center out of bounds: could cause problems later."); }
		else printsuccess();

        return this;
    }
    smooth setlabel (int[] ind = {}, string label = this.label, pair labeldir = this.labeldir, pair labelalign = defaultSyDP, bool keepalign = false)
    {
		printbeginning("Setting label " + (label == this.label ? "" : label + " ") + "for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		if (ind.length == 0)
		{
			this.label = label;
			this.labeldir = labeldir == defaultSyDP ? this.labeldir : labeldir;
			this.labelalign = keepalign ? this.labelalign : (labelalign == defaultSyDP) ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;
		}
		else
		{ subsetget(this.subsets, ind).setlabel(label, labeldir, labelalign, keepalign); }
		printsuccess();

        return this;
    }
    smooth setlabel (int[] ind = {}, string label = this.label, real angle)
    { return this.setlabel(ind, label, dir(angle)); }
	smooth addelement (element elt, bool unit = true)
	{
		printbeginning("Adding element to " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		
		if (unit) elementadjust(elt, this.shift, this.scale, 0, this.center);

		if (!this.isinside(elt.pos))
		{
			printfailure("Couldnot add element: position out of bound.");
			return this;
		}
		this.elements.push(elt);
		printsuccess();
		return this;
	}
	smooth addelement (pair pos, string label = "x_{" + /* (string)(this.elements.length + 1) */ + "}", pair labelalign = S, bool unit = true)
	{ return this.addelement(element(pos, label, labelalign), unit); }
    smooth addhole (hole hl, int ind = this.holes.length, bool unit = true)
    {
		printbeginning("Adding hole to " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
        
		if (unit) holeadjust(hl, this.shift, this.scale, 0, this.center);
		if (!insidepath(this.contour, hl.contour))
		{
			printfailure("Could not add hole: contour out of bounds.");
			currentPrDP.push(hl.contour);
			return this;
		}
		for (int i = 0; i < this.holes.length; ++i)
		{
			if (!outsidepath(this.holes[i].contour, hl.contour))
			{
				printfailure("Could not add hole: contour intersecting with other holes.");
				currentPrDP.push(hl.contour);
				return this;
			}
		}
		path[][] diff;
		bool abort = false;
		for (int i = 0; i < this.subsets.length; ++i)
		{
			diff.push(difference(this.subsets[i].contour, hl.contour));
			if (diff[i].length != 1)
			{
				abort = true;
				break;
			}
		}
		if (abort)
		{
			printfailure("Could not add hole: contour intervening with subsets");
			currentPrDP.push(hl.contour);
			return this;
		}
		else
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{
				this.subsets[i].contour = diff[i][0];
				this.subsets[i].setcenter();
				this.subsets[i].setlabel();
			}
		}
        pair holedir = (hl.center == this.center) ? (-1,0) : unit(hl.center - this.center);
        for (int i = 0; i < hl.sections.length; ++i)
		{
            if (hl.sections[i][0] == defaultSyDN || hl.sections[i][1] == defaultSyDN)
			{
				hl.sections[i][0] = (rotate(360*i/hl.sections.length)*holedir).x;
            	hl.sections[i][1] = (rotate(360*i/hl.sections.length)*holedir).y;
			}
            if (hl.sections[i][2] == defaultSyDN || hl.sections[i][2] <= 0) hl.sections[i][2] = currentsection[2];
            if (hl.sections[i][3] == defaultSyDN || hl.sections[i][3] <= 0 || hl.sections[i][3] != ceil(hl.sections[i][3])) hl.sections[i][3] = currentsection[3];
            if (hl.sections[i][4] == defaultSyDN || hl.sections[i][4] <= 0 || hl.sections[i][4] > 1) hl.sections[i][4] = currentsection[4];
            if (hl.sections[i][5] == defaultSyDN || hl.sections[i][5] <= 0 || hl.sections[i][5] != ceil(hl.sections[i][5])) hl.sections[i][5] = currentsection[5];
        }
        this.holes.insert(i = ind, hl);
		printsuccess();
        
		return this;
    }
    smooth addhole (path contour, real[][] sections = {}, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = center(contour), bool unit = true)
    {
		return this.addhole(hole(contour = contour, sections = sections, shift = shift, scale = scale, rotate = rotate, point = point), unit = unit);
	}
    smooth rmhole(int ind)
    {
		printbeginning("Removing hole from " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
     	this.holes.delete(ind);
        printsuccess();

        return this;
    }
    smooth addholesection (int ind, real[] section = {}, bool unit = false)
    {
		printbeginning("Adding hole section to " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		if (!checksection(section))
		{
			printfailure("Could not add section: invalid entries.");
			return this;
		}
		for (int i = 0; i < section.length; ++i)
		{ if (section[i] == defaultSyDN) section[i] = currentsection[i]; }
        while(section.length < currentsection.length)
        { section.push(currentsection[section.length]); }
		pair holedir = (this.holes[ind].center == this.center) ? (-1,0) : unit(this.holes[ind].center - this.center);
		if (section[0] == defaultSyDN || section[1] == defaultSyDN)
		{
			section[0] = holedir.x;
			section[1] = holedir.y;
		}
        this.holes[ind].sections.push(section);
        printsuccess();

        return this;
    }
    smooth setholesection (int ind, int ind2 = 0, real[] section = {}, bool unit = false)
    {
		printbeginning("Setting hole section for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
        this.holes[ind].sections.delete(ind2);
        while(section.length < currentsection.length)
        { section.push(currentsection[section.length]); }
		pair holedir = (this.holes[ind].center == this.center) ? (-1,0) : unit(this.holes[ind].center - this.center);
		if (section[0] == defaultSyDN || section[1] == defaultSyDN)
		{
			section[0] = holedir.x;
			section[1] = holedir.y;
		}
		if (!checksection(section)) return this;
        this.holes[ind].sections.insert(i = ind2, section);
        printsuccess();

        return this;
    }
    smooth rmholesection (int ind, int ind2 = 0)
    {
		printbeginning("Removing hole section from " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
        this.holes[ind].sections.delete(ind2);
        printsuccess();

        return this;
    }
	smooth addsubset (subset sb, int[] ind = {}, bool unit = true, bool findplace = false)
	{
		if (unit) subsetadjust(sb, this.shift, this.scale, 0, this.center);
		
		if (findplace)
		{
			int layer = 0;
			int index = -1;
			for (int i = 0; i < this.subsets.length; ++i)
			{
				subset cursb = this.subsets[i];
				if (cursb.layer >= layer && insidepath(cursb.contour, sb.contour))
				{
					index = i;
					layer = cursb.layer;
				}
			}

			return this.addsubset(sb, (index == -1 ? new int[]{} : i(index)), false, false);
		}
		
		printbeginning("Adding subset to " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		
		sb.subsets.delete();
		
		path pcontour;
		int[] range;
		
		bool sub = ind.length > 0;
		if (sub)
		{
			subset parent = subsetget(this.subsets, ind);
			sb.layer = parent.layer + 1;
			pcontour = parent.contour;
			range = subsetgetall(this.subsets, parent);
			subsetsort(this.subsets, range);
		}
		else
		{
			sb.layer = 0;
			pcontour = this.contour;
			range = sequence(this.subsets.length);
		}

		if (!insidepath(pcontour, sb.contour))
		{
			printfailure("Could not add subset: contour out of bounds.");
			currentPrDP.push(sb.contour);
			return this;
		}
		if (!sub)
		{
			for (int i = 0; i < this.holes.length; ++i)
			{
				if (meet(this.holes[i].contour, sb.contour) || isinside(this.holes[i].contour, inside(sb.contour)))
				{
					printfailure("Could not add subset: contour out of bounds.");
					currentPrDP.push(sb.contour);
					return this;
				}
			}
		}

		int insertindex = subsetinsert(this.subsets, sb);
		for (int k = 0; k < range.length; ++k)
		{ if (range[k] >= insertindex) range[k] += 1; }

		for (int i = 0; i < range.length; ++i)
		{
			subset curchild = this.subsets[range[i]];
			if (insidepath(curchild.contour, sb.contour))
			{
				subsetdelete(this.subsets, insertindex, true);
				printfailure("Could not add subset: contour is contained in another subset unlisted in `ind`.");
				currentPrDP.push(sb.contour);
				return this;
			}
			if (insidepath(sb.contour, curchild.contour))
			{
				sb.subsets.push(range[i]);
				if (sub)
				{
				 	subsetget(this.subsets, ind).subsets.delete(i);
					i -= 1;
				}
				subsetdeepen(this.subsets, curchild);
				continue;
			}
			subset[] intersection = subsetintersection(curchild, sb);
			for (int j = 0; j < intersection.length; ++j)
			{
				bool waitforsubset = false;
				for (int k = 0; k < curchild.subsets.length; ++k)
				{
					if (insidepath(this.subsets[curchild.subsets[k]].contour, intersection[j].contour))
					{
						waitforsubset = true;
						break;
					}
				}
				if (waitforsubset) continue;
				int intersectindex = subsetinsert(this.subsets, intersection[j]);
				for (int k = 0; k < range.length; ++k)
				{ if (range[k] >= intersectindex) range[k] += 1; }
				if (sb.layer - intersection[j].layer == -1) sb.subsets.push(intersectindex);
				int[] supsetrange = subsetgetlayer(this.subsets, (sub ? subsetgetall(this.subsets, ind) : sequence(this.subsets.length)), intersection[j].layer-1);
				for (int k = 0; k < supsetrange.length; ++k)
				{
					if (supsetrange[k] == insertindex) continue;
					if (insidepath(this.subsets[supsetrange[k]].contour, intersection[j].contour))
					{ this.subsets[supsetrange[k]].subsets.push(intersectindex); }
				}
			}
		}

		if (sub) subsetget(this.subsets, ind).subsets.push(insertindex);	
	
		printsuccess();
		return this;
	}
	smooth addsubset (int[] ind = {}, path contour, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = center(contour), bool unit = true, bool findplace = false)
	{
		return this.addsubset(sb = subset(contour = contour, shift = shift, scale = scale, rotate = rotate, point = point), ind = ind, unit = unit, findplace = findplace);
	}
	smooth rmsubset (int ind, bool recursive = true)
	{
		printbeginning("Removing subset from " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		subsetdelete(this.subsets, ind, recursive);
		printsuccess();
		return this;
	}
	smooth rmsubset (int[] ind, bool recursive = true)
	{ return this.rmsubset(subsetgetindex(this.subsets, ind), recursive); }
    smooth view (pair viewdir, bool shiftsubsets = this.shiftsubsets, bool drag = true)
    {
		printbeginning("Setting view for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		if (drag && this.attached.length > 0) printstarted();

		this.shiftsubsets = shiftsubsets;

		bool corrected = false;
		if (length(viewdir) > 1)
		{
			viewdir = unit(viewdir);
			corrected = true;
		}

		this.dropview();
		this.setview(viewdir);
		
		if (drag)
		{
			for (int i = 0; i < this.attached.length; ++i)
			{ this.attached[i].view(viewdir, drag = true); }
		}

		if (!drag || this.attached.length == 0)
		{
			if (corrected)
			{ printwarning("View direction exceeded 1 in length, so scaled it down."); }
			else printsuccess();
		}
		else printfinished();
        return this;
    }
	smooth view (real angle, bool shiftsubsets = true, bool drag = true)
	{ return this.view(dir(angle), shiftsubsets, drag); }
    smooth movehole (int ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.holes[ind].center, bool movesections = false, bool keepview = false)
    {
		printbeginning("Moving hole for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		pair viewdir = this.viewdir;    
		
		if (!keepview) this.dropview();
		this.holes[ind].move(shift, scale, rotate, point, movesections);
		if (!keepview) this.setview(viewdir);

		printsuccess();
        return this;
    }
	bool onlyprimary (int ind)
	{
		subset s = this.subsets[ind];
		
		bool res = true;
		for (int i = 0; i < s.subsets.length; ++i)
		{
			if (this.subsets[s.subsets[i]].isintersection)
			{
				res = false;
				break;
			}
		}

		return res;
	}
	bool onlysecondary (int ind)
	{
		subset s = this.subsets[ind];
		
		bool res = true;
		for (int i = 0; i < s.subsets.length; ++i)
		{
			if (!res || !this.subsets[s.subsets[i]].isintersection)
			{
				res = false;
				break;
			}
			res = res && onlysecondary(s.subsets[i]);
		}

		return res;
	}
	smooth movesubset (int[] ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = defaultSyDP, bool movelabel = false, bool recursive = true, bool keepview = false)
	{
		printbeginning("Moving subset for " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		
		bool sub = ind.length > 1;
		int index = subsetgetindex(this.subsets, ind);
		subset cursb = this.subsets[index];
		point = (point == defaultSyDP) ? cursb.center : point;
		int relindex = ind.pop();
		int[] allsubsets = subsetgetall(this.subsets, cursb);

		if (cursb.isintersection) 
		{
			printfailure("Could not move subset: subset is an intersection.");
			return this;
		}
		
		path pcontour;
		int[] range; 
		if (sub)
		{
			subset parent = subsetget(this.subsets, ind);
			pcontour = parent.contour;
			range = parent.subsets;
			range.delete(relindex);
		}
		else
		{
			pcontour = this.contour;
			range = sequence(this.subsets.length);
			range.delete(index);
			range = difference(range, allsubsets);
		}

		path newcontour = shift(shift)*srap(scale, rotate, point)*cursb.contour;
		if (!insidepath(pcontour, newcontour))
		{
			printfailure("Could not move subset: new contour out of bounds.");
			currentPrDP.push(newcontour);
			return this;
		}

		if (onlysecondary(index))
		{
			rmsubset(index);
			addsubset(cursb.move(shift, scale, rotate, point, movelabel));
			printsuccess();
			return this;
		}
		if (onlyprimary(index))
		{
			for (int i = 0; i < range.length; ++i)
			{
				if (range[i] == -1) continue;
				
				if (meet(newcontour, this.subsets[range[i]].contour) || insidepath(newcontour, this.subsets[range[i]].contour) || insidepath(this.subsets[range[i]].contour, newcontour))
				{
					printfailure("Could not move subset: new contour intersects with other subsets");
					currentPrDP.push(newcontour);
					return this;
				}
			}
			
			if (recursive)
			{
				for (int i = 0; i < allsubsets.length; ++i)
				{ this.subsets[allsubsets[i]].move(shift, scale, rotate, point, movelabel); }

				cursb.move(shift, scale, rotate, point, movelabel);
			}
			else
			{
				for (int i = 0; i < cursb.subsets.length; ++i)
				{
					if (!insidepath(newcontour, this.subsets[cursb.subsets[i]].contour))
					{
						printfailure("Could not move subset: new contour makes existing subsets out-of-bounds.");
						return this;
					}
				}

				cursb.move(shift, scale, rotate, point, movelabel);
			}

			printsuccess();
			return this;
		}

		printfailure("Could not move subset: situation too complicated: both primary and secondary subsets present.");
		return this;
	}
    smooth move (pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.center, bool keepview = false, bool drag = true)
    {
		printbeginning("Moving smooth object " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
		if (scale <= 0)
		{
			printfailure("Could not move: scale value must be positive.");
			return this;
		}
		if (drag && this.attached.length > 0) printstarted();
		
		this.rotate += rotate;
        this.scale *= scale;
		this.shift += shift + (srap(scale, rotate, point) * this.center - this.center);

		pair viewdir = this.viewdir;
        if (!keepview) this.dropview();
		this.simplemove(shift, scale, rotate, point);    
		if (!keepview) this.setview(viewdir);

        if (!drag) return this;
        for (int i = 0; i < this.attached.length; ++i)
        {
            this.attached[i].move(shift = shift, scale = scale, rotate = rotate, point = point, keepview = keepview, drag = true);
        }
		
		if (!drag || this.attached.length == 0) printsuccess();
		else printfinished();
        return this;
    }
    smooth attach (smooth sm)
    {
		printbeginning("Attaching " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label) + " to " + ((length(this.label) == 0) ? "[unlabeled]" : this.label) + "...");
        this.attached.push(sm);
		printsuccess();
        return this;
    }
	smooth fit (int[] ind = {}, picture pic = currentpicture, picture addpic, pair shift = (0,0))
	{
		path contour = (ind.length == 0) ? this.contour : subsetget(this.subsets, ind).contour;
		pair center = (ind.length == 0) ? this.center : subsetget(this.subsets, ind).center;
		addpic = shift(center)*shift(-shift)*addpic;
		clip(addpic, contour);
		pic.add(addpic);

		return this;
	}

    void operator init (path contour, pair center = center(contour), string label = "", pair labeldir = N, pair labelalign = defaultSyDP, hole[] holes = {}, subset[] subsets = {}, real[] hratios = {}, real[] vratios = {}, pair shift = (0,0), real scale = 1, real rotate = 0, pair viewdir = (0,0), smooth[] attached = {}, bool unit = true, bool copy = false, bool shiftsubsets = currentSmSS)
    {
		if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign == defaultSyDP ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;
            this.holes = holecopy(holes);
            this.subsets = subsetcopy(subsets);
            this.hratios = hratios;
            this.vratios = vratios;
            this.shift = shift;
            this.scale = scale;
            this.rotate = rotate;
            this.viewdir = viewdir;
			this.attached = attached;
			this.shiftsubsets = shiftsubsets;
        }
        else
        {
			printbeginning("Building smooth object " + ((length(label) == 0) ? "[unlabeled]" : label) + "...");
			if (scale <= 0)
			{
				printfailure("Could not build: scale value must be positive.");
				return;
			}
			printstarted();
            
			this.shift = shift;
            this.scale = scale;
            this.rotate = rotate;
            
            this.contour = shift(shift)*srap(scale, rotate, center)*((!clockwise(contour)) ? reverse(contour) : contour);
            this.center = shift(shift)*center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign == defaultSyDP ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;
            this.holes = new hole[];

            for (int i = 0; i < holes.length; ++i)
            { addhole(holes[i], unit = unit); }
            for (int i = 0; i < subsets.length; ++i)
            { addsubset(subsets[i], unit = unit, findplace = true); }

			this.setratios(hratios, true);
			this.setratios(vratios, false);

			this.shiftsubsets = shiftsubsets;
			this.setview(viewdir);
			
			this.attached = attached;
			
			printfinished();
        }
    }

    smooth copy ()
    {
        return smooth(this.contour, this.center, this.label, this.labeldir, this.labelalign, holecopy(this.holes), subsetcopy(this.subsets), this.hratios, this.vratios, this.shift, this.scale, this.rotate, this.viewdir, this.attached, copy = true);
    }
    smooth replicate (smooth sm)
    {
        this.contour = sm.contour;
        this.center = sm.center;
        this.label = sm.label;
        this.labeldir = sm.labeldir;
        this.labelalign = sm.labelalign;
        this.holes = holecopy(sm.holes);
        this.subsets = subsetcopy(sm.subsets);
        this.hratios = sm.hratios;
        this.vratios = sm.vratios;
        this.shift = sm.shift;
        this.scale = sm.scale;
        this.rotate = sm.rotate;
        this.viewdir = sm.viewdir;
		this.attached = sequence(new smooth (int i){return sm.attached[i].copy();}, sm.attached.length);

        return this;
    }
    bool isnull ()
    {return this.contour == nullpath;}

	void print ()
	{
		printbeginning("Printing information for smooth object " + (length(this.label) > 0 ? this.label : "[unlabeled]" + "..."));
		printstarted();
		write();
	}
}

smooth nullsmooth;

struct drawdata
{
	smooth sm;
	pen contourpen;
	pen smoothfill;
	pen subsetfill;

	void operator init (smooth sm, pen contourpen, pen smoothfill, pen subsetfill)
	{
		this.sm = sm;
		this.contourpen = contourpen;
		this.smoothfill = smoothfill;
		this.subsetfill = subsetfill;
	}
}

private drawdata[] currentdrawn;
void flushcache () {currentdrawn = new drawdata[];}

bool operator == (smooth a, smooth b)
{ return a.contour == b.contour; }


// -- Default pre-built smooth objects -- //

smooth samplesmooth (int type = 0, int num = 0)
{
    if (type == 0)
    {
        if(num == 0)
        {
            return smooth(
                contour = defaultPaCV[0],
                hratios = new real[] {.5}
            );
        }
        if(num == 1)
        {
            return smooth(
                contour = defaultPaCC[0]
            ); 
        }
        if(num == 2)
        {
            return smooth(
                contour = defaultPaCC[2],
                subsets = new subset[]{
                    subset(
                        contour = defaultPaCC[3],
                        scale = .48,
                        shift = (.13, -.55),
                        labeldir = dir(140)
                    )
                },
				rotate = -90,
                hratios = new real[]{.6, .83}
            );
        }
    }
    if (type == 1) 
    {
        if (num == 0)
        {
            return smooth(
                contour = defaultPaCV[1],
                labeldir = (-2,1),
                holes = new hole[]{
                    hole(
                        contour = defaultPaCV[2],
                        sections = new real[][]{
                            new real[] {defaultSyDN, defaultSyDN, 270, defaultSyDN, .35, defaultSyDN}
                        },
                        shift = (-.65, .25),
                        scale = .5
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = defaultPaCV[3],
                        labeldir = S,
                        shift = (.45,-.45),
                        scale = .43,
                        rotate = 10
                    )
                }
            );
        }
		if (num == 1)
		{
			return smooth(
				contour = rotate(50) * reflect((0,0), (0,1))*defaultPaCC[4],
				holes = new hole[]{
					hole(
						contour = rotate(45) * defaultPaCV[4],
						shift = (-.75,-.05),
						scale = .5,
						rotate = -70,
						sections = new real[][]{
							new real[] {defaultSyDN, defaultSyDN, 250, 10, .65, 200}
						}
					)
				},
				subsets = new subset[]{
					subset(
						contour = defaultPaCV[3],
						scale = .45,
						rotate = -130,
						shift = (.5,.35)
					)
				}
			);
		}
		if (num == 2)
		{
			return smooth(
				contour = wavypath(a(2,2,2,2,2, 3.15, 2,2,2)),
				holes = new hole[]{
					hole(contour = defaultPaCV[5], scale = .55, shift = (-2,.7), rotate = 10, sections = aa(-4,2,200,7))
				},
				subsets = new subset[]{
					subset(contour = defaultPaCC[3], shift = (-.3,-.35), rotate = -50),
					subset(contour = defaultPaCV[3], scale = .9, rotate = 10, shift = (.3,.5))
				}
			);
		}
    }
    if(type == 2)
    {
        return smooth(
            contour = defaultPaCC[4],
            holes = new hole[]{
                hole(
                    contour = defaultPaCV[4],
                    sections = new real[][]{
                        new real[]{-2,1.5, 60, 3},
                        new real[]{0, -1, 80, 4}
                    },
                    neighnumber = 2,
                    shift = (-.5, -.15),
                    scale = .45,
                    rotate = 15
                ),
                hole(
                    contour = defaultPaCV[3],
                    sections = new real[][]{
                        new real[]{defaultSyDN, defaultSyDN, 230, 10}
                    },
                    neighnumber = 2,
                    shift = (.57,.48),
                    scale = .47,
                    rotate = -83
                )
            }
        );
    }
    if(type == 3)
    {
        if (num == 0)
        {
            return smooth(
                contour = wavypath(new real[]{4,2,4,2,3.7,2}),
                holes = new hole[]{
                    hole(
                        contour = defaultPaCV[4],
                        sections = aa(),
                        scale = .75,
                        shift = (2.5,.1),
						rotate = 5,
                        neighnumber = 1
                    ),
                    hole(
                        contour = defaultPaCV[6],
                        sections = aa(),
                        scale = .75,
                        shift = (-1.1,-2.1)
                    ),
                    hole(
                        contour = defaultPaCV[5],
                        sections = aa(),
                        scale = .80,
                        shift = (-1,1.8),
						rotate = -20,
                        neighnumber = 1
                    )
                },
                subsets = new subset[]{
                    subset(
                        contour = defaultPaCV[2],
                        shift = (0, -.2),
                        scale = .95
                    )
                }
            ).simplemove(scale = .35);
        }

        return smooth(
            contour = defaultPaCC[5],
            holes = new hole[]{
                hole(
                    contour = defaultPaCV[5],
                    sections = new real[][]{
                        new real[]{3,-1, 140, 7}
                    },
                    shift = (.55,-.15),
                    neighnumber = 1,
                    scale = .37,
                    rotate = -90
                ),
                hole(
                    contour = reverse(ellipse(c = (0,0), a = 1, b = 2)),
                    sections = new real[][]{
                        new real[]{0,1,130,6}
                    },
                    shift = (-.1,.7),
                    scale = .25
                ),
                hole(
                    contour = defaultPaCC[6],
                    neighnumber = 1,
                    sections = new real[][]{
                        new real[]{-3,-1, 150, 6}
                    },
                    shift = (-.27,-.43),
                    scale = .39,
                    rotate = -15
                )
            }
        );
    }

    return smooth(defaultPaUC);
}

smooth rn (int n, pair labeldir = (1,1), pair shift = (0,0), real scale = 1, real rotate = 0)
// an alias for the comman diagram representation of the n-dimensional Eucledian space.
{
    return smooth(contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle, label = "$\mathbb{R}^" + ((n == -1) ? "n" : (string)n)  + "$", labeldir = (1,1), labelalign = (-1,-1.5), hratios = new real[]{.4}, vratios = new real[]{.4}, shift = shift, scale = scale, rotate = rotate);
}

// -- Set operations with smooth objects -- //

smooth[] intersection (smooth sm1, smooth sm2, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, bool addsubsets = false)
// Constructs the intersection of two given smooth objects.
{
	printbeginning("Intersecting " + ((length(sm1.label) == 0) ? "[unlabeled]" : sm1.label) + " and " + ((length(sm2.label) == 0) ? "[unlabeled]" : sm2.label) + "...");
	   
	path[] contours = intersection(sm1.contour, sm2.contour, round = round, roundcoeff = roundcoeff);
    int initialsize = contours.length;

    if (contours.length == 0)
	{
		printfailure("Smooth objects are not intersecting");
		return new smooth[];
	}
	printstarted();

    path[] contour1 = sm1.contour ^^ holecontours(sm1.holes);
    path[] contour2 = sm2.contour ^^ holecontours(sm2.holes);

    hole[] trueholes = concat(holecopy(sm1.holes), holecopy(sm2.holes));
    path[] holes = holecontours(concat(sm1.holes, sm2.holes));
    bool[] htaken = array(holes.length, false);
    int[] hrefs = sequence(holes.length);

    for (int i = 0; i < holes.length; ++i)
    {
        if (htaken[i]) continue;

		for (int j = 0; j < holes.length; ++j)
		{
			if (i == j) continue;
			if (insidepath(holes[i], holes[j]))
			{ htaken[j] = true; }
		}

        for (int j = i+1; j < holes.length; ++j)
        {
            if(meet(holes[i], holes[j]) && !htaken[j])
            {
				path[] holeunion = union(holes[i], holes[j], round = round, roundcoeff = roundcoeff);
                holes[i] = holeunion[0];
				for (int k = 1; k < holeunion.length; ++k)
				{ contours.push(holeunion[k]); }
                htaken[j] = true;
                hrefs[i] = -1;
                j = i;
            }
        }
    }

	subset[] subsets1 = addsubsets ? subsetcopy(sm1.subsets) : new subset[]{};
	subset[] subsets2 = addsubsets ? subsetcopy(sm2.subsets) : new subset[]{};

	for (int i = 0; i < subsets1.length; ++i)
	{
		path[] curcontours = intersection(p = subsets1[i].contour, q = sm2.contour, holes = holecontours(sm2.holes), round = round, roundcoeff = roundcoeff);
		if (curcontours.length == 0)
		{
			subsetdelete(subsets1, i, true);
			i -= 1;
			continue;
		}
		if (curcontours.length > 1)
		{
			subsetdelete(subsets1, i, true);
			i -= 1;
			continue;
		}
		subsets1[i].contour = curcontours[0];
		subsets1[i].setlabel();
	}
	for (int i = 0; i < subsets2.length; ++i)
	{
		path[] curcontours = intersection(p = subsets2[i].contour, q = sm1.contour, holes = holecontours(sm1.holes), round = round, roundcoeff = roundcoeff);
		if (curcontours.length == 0)
		{
			subsetdelete(subsets2, i, true);
			i -= 1;
			continue;
		}
		if (curcontours.length > 1)
		{
			subsetdelete(subsets2, i, true);
			i -= 1;
			continue;
		}
		subsets2[i].contour = curcontours[0];
		subsets2[i].setlabel();
	}

    smooth[] res;

    while (contours.length != 0)
    {
        path curcontour = contours.pop();
        smooth cursm = smooth(
            contour = curcontour,
            label = (currentSmIL && length(sm1.label) > 0 && length(sm2.label) > 0) ? (sm1.label+" \cap "+sm2.label) : "",
            labeldir = rotate(90)*unit(sm1.center - sm2.center),
			viewdir = (sm1.viewdir + sm2.viewdir)*.5,
			copy = true
        );

		for (int j = 0; j < holes.length; ++j)
		{
			if (htaken[j]) continue;
			if (meet(cursm.contour, holes[j]))
			{
				path[] diff = difference(cursm.contour, holes[j], round = round, roundcoeff = roundcoeff);
				cursm.contour = diff.pop();
				contours.append(diff);
				htaken[j] = true;
			}
			else if (insidepath(curcontour, holes[j]))
			{
				cursm.addhole((hrefs[j] == -1 || !keepdata) ? hole(contour = holes[j]) : trueholes[hrefs[j]], unit = false);
			}
		}

        pair cursize = max(cursm.contour)-min(cursm.contour);
        real rsize = min(cursize.x, cursize.y);
        pair size1 = max(sm1.contour)-min(sm1.contour);
        real rsize1 = min(size1.x, size1.y);
        pair size2 = max(sm2.contour)-min(sm2.contour);
        real rsize2 = min(size2.x, size2.y);
        real sm1 = sm1.scale * rsize/rsize1;
        real sm2 = sm2.scale * rsize/rsize2;
        cursm.scale = (sm1+sm2)*.5;
        cursm.shift = cursm.center;

        int curboundindex = -1;

		cursm.subsets = subsets1;
		for (int i = 0; i < cursm.subsets.length; ++i)
		{
			if (cursm.subsets[i].layer > 0) break;

			if (!insidepath(cursm.contour, cursm.subsets[i].contour))
			{ subsetdelete(cursm.subsets, i, true); }
		}

		bool[] subsetsadded = array(subsets2.length, false);
		bool[] subsets2inside = array(subsets2.length, false);
		void subset2add (int[] ind, int ind2)
		{
			if (subsetsadded[ind2]) return;

			if (subsets2inside[ind2] || insidepath(cursm.contour, subsets2[ind2].contour))
			{
				cursm.addsubset(subsets2[ind2], ind, unit = false);
				subsetsadded[ind2] = true;

				for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
				{
					subsets2inside[subsets2[ind2].subsets[i]] = true;
					subset2add(i(cursm.subsets.length-1), subsets2[ind2].subsets[i]);
				}
			}
			else
			{
				subsetsadded[ind2] = true;
				int[] allsubsets = subsetgetall(subsets2, ind2);
				for (int i = 0; i < allsubsets.length; ++i)
				{ subsetsadded[allsubsets[i]] = true; }
			}
		}
		for (int i = 0; i < subsets2.length; ++i)
		{ subset2add(ind = new int[]{}, ind2 = i); }

		cursm.setratios(new real[], true);
		cursm.setratios(new real[], false);

		res.push(cursm);
	}

	printfinished();
    return res;
}
smooth[] intersection (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, bool addsubsets = false)
{
	printbeginning("Intersecting an array of smooth objects...");
	printstarted();
	sms = sequence(new smooth (int i){return sms[i];}, sms.length);

	smooth[] getintersection (smooth[] smsp, bool keepdata, bool round, real roundcoeff, bool addsubsets)
	{
		if (smsp.length < 2)
		{ return smsp; }
		smooth lastsm = smsp.pop();
		smooth[] preintersection = getintersection(smsp, keepdata, round, roundcoeff, addsubsets);
		
		smooth[] res;
		for (int i = 0; i < preintersection.length; ++i)
		{ res.append(intersection(sm1 = preintersection[i], sm2 = lastsm, keepdata, round, roundcoeff, addsubsets)); }
		sms.push(lastsm);

		return res;
	}

	smooth[] res = getintersection(sms, keepdata, round, roundcoeff, addsubsets);
	printfinished();
	return res;
}
smooth[] intersection (bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, bool addsubsets = false ... smooth[] sms)
{ return intersection(sms, keepdata, round, roundcoeff, addsubsets); }

smooth intersect (smooth sm1, smooth sm2, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, bool addsubsets = false)
{ return intersection(sm1, sm2, keepdata, round, roundcoeff)[0]; }
smooth intersect (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR)
{ return intersection(sms, keepdata, round, roundcoeff)[0]; }
smooth intersect (bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR ... smooth[] sms)
{ return intersection(sms, keepdata, round, roundcoeff)[0]; }

smooth[] union (smooth sm1, smooth sm2, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR)
// Constructs the union of two given smooth objects. //
{
	printbeginning("Uniting " + ((length(sm1.label) == 0) ? "[unlabeled]" : sm1.label) + " and " + ((length(sm2.label) == 0) ? "[unlabeled]" : sm2.label) + "...");
    if (!meet(sm1.contour, sm2.contour) && !insidepath(sm1.contour, sm2.contour) && !insidepath(sm2.contour, sm1.contour))
	{
		printsuccess();
		return new smooth[]{sm1, sm2};
	}

	printstarted();

    path[] union = union(sm1.contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
    path contour; 
    hole[] trueholes = concat(holecopy(sm1.holes), holecopy(sm2.holes));
    path[] holes;
    int[] hrefs;
    bool[] used = array(value = false, sm2.holes.length);
    bool[] diffused = array(value = false, trueholes.length);

    for (int i = 0; i < sm1.holes.length; ++i)
    {
        if(!meet(sm1.holes[i].contour, sm2.contour)) continue;
        path[] diff = difference(sm1.holes[i].contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
        holes.append(diff);
        hrefs.append(array(value = -1, diff.length));
        diffused[i] = true;
    }
    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if(!meet(sm2.holes[i].contour, sm1.contour)) continue;
        path[] diff = difference(sm2.holes[i].contour, sm1.contour, correct = false, round = round, roundcoeff = roundcoeff);
        holes.append(diff);
        hrefs.append(array(value = -1, diff.length));
        diffused[sm1.holes.length + i] = true;
    }

    for (int i = 0; i < sm1.holes.length; ++i)
    {
        bool used1 = false;
        for (int j = 0; j < sm2.holes.length; ++j)
        {
            path[] intersect = intersection(sm1.holes[i].contour, sm2.holes[j].contour, correct = false, round = round, roundcoeff = roundcoeff);

            if (intersect.length > 0 || inside(sm2.holes[j].contour, sm1.holes[i].center))
            {
                used1 = true;
                used[j] = true;
                holes.append(intersect);
                hrefs.append(array(value = -1, intersect.length));
            }
        }

        if (!used1 && !diffused[i])
        {
            holes.push(sm1.holes[i].contour);
            hrefs.push(i);            
            for (int j = 0; j < trueholes[i].sections.length; ++j)
            {
                real[] section = trueholes[i].sections[j];
                pair center = trueholes[i].center;
                real dirang = degrees((section[0], section[1]));
                real ang = section[2];
                int num = floor(section[3]);
                real langlim = 1;
				
				if (intersectiontime(sm2.contour, center, (section[0], section[1])) != -1)
				{
					trueholes[i].sections.delete(j);
					j -= 1;
					continue;
				}

                while (ang > langlim && intersectiontime(sm2.contour, center, dir(dirang+ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang -= ang*.5;
                    num = ceil((real)num*.5);
                }
                while (ang > langlim && intersectiontime(sm2.contour, center, dir(dirang-ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang += ang*.5;
                    num = ceil((real)num*.5);
                }
                trueholes[i].sections[j] = new real[]{dir(dirang).x, dir(dirang).y, ang, num, section[4], section[5]};
            }
        }
    }

    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if (!used[i] && !diffused[sm1.holes.length + i])
        {
            holes.push(sm2.holes[i].contour);
            hrefs.push(i + sm1.holes.length);

            for (int j = 0; j < trueholes[sm1.holes.length + i].sections.length; ++j)
            {
                real[] section = trueholes[sm1.holes.length+i].sections[j];
                pair center = trueholes[sm1.holes.length+i].center;
                real dirang = degrees((section[0], section[1]));
                real ang = section[2];
                int num = floor(section[3]);
                real langlim = 1;
				
				if (intersectiontime(sm1.contour, center, (section[0], section[1])) != -1)
				{
					trueholes[sm1.holes.length + i].sections.delete(j);
					j -= 1;
					continue;
				}

                while (ang > langlim && intersectiontime(sm1.contour, center, dir(dirang+ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang -= ang*.5;
                    num = ceil((real)num*.5);
                }
                while (ang > langlim && intersectiontime(sm1.contour, center, dir(dirang-ang*.5)) != -1)
                {
                    ang /= 2;
                    dirang += ang*.5;
                    num = ceil((real)num*.5);
                }
                
                trueholes[sm1.holes.length+i].sections[j] = new real[]{dir(dirang).x, dir(dirang).y, ang, num, section[4], section[5]};
            }
        }
    }

	contour = pop(union);
	holes.append(union);
	hrefs.append(array(union.length, -1));

    smooth res = smooth(
        contour = contour,
        label = (currentSmIL && length(sm1.label) > 0 && length(sm2.label) > 0) ? (sm1.label+" \cup "+sm2.label) : "",
        labeldir = unit(sm1.center - sm2.center),
		viewdir = (sm1.viewdir + sm2.viewdir)*.5
    );

    pair cursize = max(res.contour)-min(res.contour);
    real rsize = min(cursize.x, cursize.y);
    pair size1 = max(sm1.contour)-min(sm1.contour);
    real rsize1 = min(size1.x, size1.y);
    pair size2 = max(sm2.contour)-min(sm2.contour);
    real rsize2 = min(size2.x, size2.y);
    real sc1 = sm1.scale * rsize/rsize1;
    real sc2 = sm2.scale * rsize/rsize2;

    res.scale = (sc1+sc2)*.5;
    res.shift = res.center;

    for (int i = 0; i < holes.length; ++i)
    { res.addhole((hrefs[i] == -1) ? hole(holes[i], copy = true) : trueholes[hrefs[i]], unit = false); }

	res.subsets = subsetcopy(sm1.subsets);
	subset[] subsets2 = subsetcopy(sm2.subsets);
	bool[] subsetsadded = array(subsets2.length, false);
	void subset2add (int[] ind, int ind2)
	{
		if (subsetsadded[ind2]) return;
		res.addsubset(subsets2[ind2], ind);
		subsetsadded[ind2] = true;
		for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
		{ subset2add(i(res.subsets.length-1), subsets2[ind2].subsets[i]); }
	}
	for (int i = 0; i < subsets2.length; ++i)
	{ subset2add(ind = new int[]{}, ind2 = i); }

	printfinished();
    return new smooth[]{res};
}
smooth[] union (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR)
{
	printbeginning("Uniting an array of smooth objects...");
	printstarted();
	sms = sequence(new smooth (int i){return sms[i];}, sms.length);

	smooth[] getunion (smooth[] smsp, bool keepdata, bool round, real roundcoeff)
	{
		if (smsp.length < 2) return smsp;
		smooth lastsm = smsp.pop();
		smooth[] res = getunion(smsp, keepdata, round, roundcoeff);

		for (int i = 0; i < res.length; ++i)
		{
			smooth[] curunion = union(sm1 = res[i], sm2 = lastsm, keepdata, round, roundcoeff);

			if (curunion.length == 1)
			{
				res[i] = curunion[0];
				return getunion(res, keepdata, round, roundcoeff);
			}
		}
		
		res.push(lastsm);
		return res;
	}

	smooth[] res = getunion(sms, keepdata, round, roundcoeff);
	printfinished();
	return res;
}
smooth[] union (bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR ... smooth[] sms)
{ return union(sms, keepdata, round, roundcoeff); }
smooth unite (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR)
{ return union(sms, keepdata, round, roundcoeff)[0]; }
smooth unite (bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR ... smooth[] sms)
{ return union(sms, keepdata, round, roundcoeff)[0]; }

smooth tangentspace (smooth sm, int ind = -1, pair center = (ind == -1) ? sm.center : sm.holes[ind].center, real angle, real ratio, real size = 1, real rotate = 45, string eltlabel = "x")
// Returns a tangent space to `sm` at point determined by `ind`, `dir` and `ratio` //
{
	printbeginning("Building tangent space for " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label) + "...");

	if (!inside(-1, sm.holes.length-1, ind))
	{
		printfailure("Could not build tangent space: index out of bounds.");
		return nullsmooth;
	}
	if (!sm.isinside(center))
	{
		printfailure("Could not build tangent space: center out of bouds");
		return nullsmooth;
	}
	if (!inside(0, 1, ratio))
	{
		printfailure("Could not build tangent space: ratio out of bounds.");
		return nullsmooth;
	}

	printstarted();

	pair dir = dir(angle);
    path dirpath = center -- (center + (sm.xsize()+sm.ysize()) * dir);
    pair start;
    pair finish;
    pair[] ipoints;

    if (ind > -1)
    {
        path[] fullcontour = sm.contour ^^ holecontours(sm.holes);
        ipoints = sort(concat(sequence(new pair[](int i){return intersectionpoints(dirpath, fullcontour[i]);}, fullcontour.length)), new bool (pair i, pair j){return length(i - center) <= length(j - center);});
        start = comb(ipoints[0], ipoints[1], .5);
        finish = (ratio > 0) ? ipoints[1] : ipoints[0];
    }
    else
    {
        ipoints = sort(intersectionpoints(dirpath, sm.contour), new bool (pair i, pair j){return length(i - center) <= length(j - center);});
        start = center;
        finish = ipoints[0];
    }
    pair x = comb(start, finish, abs(ratio));

    real incline = sqrt(1 - ratio * ratio);
	smooth res = smooth(
        contour = shift(x) * dirscale(scale = incline, dir = sgn(ratio) * dir) * scale(size) * rotate(rotate) * defaultPaUS,
        label = "T_{"+eltlabel+"}" + sm.label,
        labeldir = dirscale(scale = incline, dir = sgn(ratio) * dir) * rotate(rotate) * N
	).view(sm.viewdir);
	sm.attach(res);

	sm.addelement(element(x, eltlabel));

	printfinished();
	return res;
}

// -- From here starts the collection of the drawing functions provided by the module. -- //

void drawsections (picture pic, pair[][] sections, pair viewdir, bool dash, bool explain, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen, string mode)
// Renders the circular sections, given an array of control points.
{
    for (int k = 0; k < sections.length; ++k)
    {
		if (sections[k].length > 4) continue;
        path[] section = sectionellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir, (mode == "free"));
        if (shade && section.length == 2) fill(pic = pic, section[0]--section[1]--cycle, shadepen);
		if (section.length > 1 && dash) draw(pic, section[1], dashpen);
        draw(pic, section[0], sectionpen);
        if(explain)
        {
            dot(pic, point(section[0], arctime(section[0], arclength(section[0])*.5)), red+1);
            dot(pic, sections[k][0], blue+1.5);
            dot(pic, sections[k][1], blue+1);
            draw(pic, sections[k][0] -- sections[k][1], deepgreen + defaultDrEP);
            draw(pic, sections[k][0]-.5*defaultSmEAL*scale*sections[k][2] -- sections[k][0]+.5*defaultSmEAL*scale*sections[k][2], deepgreen+defaultDrEP, arrow = Arrow(SimpleHead));
            draw(pic, sections[k][1]-.5*defaultSmEAL*scale*sections[k][3] -- sections[k][1]+.5*defaultSmEAL*scale*sections[k][3], deepgreen+defaultDrEP, arrow = Arrow(SimpleHead));
        }
    }
}

void drawholesections (picture pic, hole hl1, hole hl2, pair viewdir, bool dash, bool explain, bool shade, real scale, string mode, pen sectionpen, pen dashpen, pen shadepen)
{
    int n = min(hl1.neighnumber, hl2.neighnumber);
    if (n <= 0) return;

	pair hl1times = range(hl1.contour, hl1.center, hl2.center-hl1.center, currentSeNA);
	pair hl2times = range(reverse(hl2.contour), hl2.center, hl1.center-hl2.center, currentSeNA, orientation = -1);
    path curhl1contour = subcyclic(hl1.contour, hl1times);
    path curhl2contour = subcyclic(reverse(hl2.contour), hl2times);

    if (explain)
    {
		pair hl1start = point(curhl1contour, 0);
		pair hl1finish = point(curhl1contour, length(curhl1contour));
		pair hl2start = point(curhl2contour, 0);
		pair hl2finish = point(curhl2contour, length(curhl2contour));
		pair hl1vec = defaultSmAR * scale * unit(hl1start - hl1.center);
		pair hl2vec = defaultSmAR * scale * unit(hl2start - hl2.center);
        draw(pic = pic, curhl1contour, lightred+(linewidth(currentpen)+.1));
        draw(pic = pic, curhl2contour, lightred+(linewidth(currentpen)+.1));
        draw(pic, (hl1.center + hl1vec)--hl1start, yellow+defaultDrEP);
        draw(pic, (hl1.center + rotate(-currentSeNA)*hl1vec)--hl1finish, yellow+defaultDrEP);
        draw(pic, (hl2.center + hl2vec)--hl2start, yellow+defaultDrEP);
        draw(pic, (hl2.center + rotate(currentSeNA)*hl2vec)--hl2finish, yellow+defaultDrEP);
        dot(pic, hl1start, green+1);
        dot(pic, hl1finish, green+1);
        dot(pic, hl2start, green+1);
        dot(pic, hl2finish, green+1);
        draw(pic = pic, arc(hl1.center, hl1.center + hl1vec, hl1finish, direction = CW), blue+defaultDrEP);
        draw(pic = pic, arc(hl2.center, hl2.center + hl2vec, hl2finish, direction = CCW), blue+defaultDrEP);
    }

    pair[][] sections = new pair[][];
	int p = floor(currentsection[5]);
    if (mode == "strict")
    { sections = sectionparamsstrict(curhl1contour, curhl2contour, n, currentsection[4], p); }
    if (mode == "free")
    { sections = sectionparamsfree(curhl1contour, curhl2contour, p*n, p); }
    drawsections(pic, sections, viewdir, dash, explain, shade, scale, sectionpen, dashpen, shadepen, mode);
}

void drawcartsections (picture pic, path[] g, real y, bool horiz, pair viewdir, bool dash, bool explain, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
{
    drawsections(pic, cartsections(g, y, horiz), viewdir, dash, explain, shade, scale, sectionpen, dashpen, shadepen, "free");
}

void draw (picture pic = currentpicture, smooth sm, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, string mode = currentDrM, bool explain = currentDrE, bool dash = currentDrDD, bool shade = currentDrDS, bool drag = true, bool cache = currentDrDC)
// The main drawing function of the module. It renders a given smooth object with substantial customization: all drawing pens can be altered, there are four section-drawing modes available: `free`, `strict`, `cart` and `plain`. The `explain` parameter may be tweaked to show auxillary information about the object. Used for debugging. 
{
	printbeginning("Drawing smooth object " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label) + " in mode " + mode + "...");
	if (mode != "strict" && mode != "cart" && mode != "plain" && mode != "free")
	{
		printfailure("Invalid mode specified.");
		return;
	}
	if (drag && sm.attached.length > 0) printstarted();

    pair viewdir = Sin(defaultSmVA)*sm.viewdir;
	currentSyMaEH = defaultSyMaEH*min(xsize(sm.contour), ysize(sm.contour));

    path[] contour = (sm.contour ^^ sequence(new path(int i){
        return reverse(sm.holes[i].contour);
    }, sm.holes.length));
    filldraw(pic = pic, contour, fillpen = smoothfill, drawpen = contourpen);

	if(sm.label != "") label(intersection(sm.contour, sm.center, sm.labeldir), "$"+sm.label+"$", align = sm.labelalign);

	if (mode == "strict" || mode == "free")
    {
        bool[][] holeconnected = new bool[sm.holes.length][sm.holes.length];

        for (int i = 0; i < sm.holes.length; ++i)
        {
            for (int j = 0; j < sm.holes.length; ++j)
            { holeconnected[i][j] = false; }
            holeconnected[i][i] = true;
        }
        for (int i = 0; i < sm.holes.length; ++i)
        {
            hole hl = sm.holes[i];
			for (int j = 0; j < hl.sections.length; ++j)
			{
				pair smrange = range(sm.contour, hl.center, (hl.sections[j][0], hl.sections[j][1]), hl.sections[j][2]);
				pair hlrange = range(hl.contour, hl.center, (hl.sections[j][0], hl.sections[j][1]), hl.sections[j][2]);
				path cursmcontour = subcyclic(sm.contour, smrange);
				path curhlcontour = subcyclic(hl.contour, hlrange);

				if (explain)
				{
					pair smstart = point(cursmcontour, 0);
					pair smfinish = point(cursmcontour, length(cursmcontour));
					pair hlstart = point(curhlcontour, 0);
					pair hlfinish = point(curhlcontour, length(curhlcontour));
					pair hlvec = defaultSmAR * sm.scale * unit(hlstart - hl.center);
					draw(pic = pic, cursmcontour, lightred+(linewidth(currentpen)+.1));
					draw(pic = pic, curhlcontour, lightred+(linewidth(currentpen)+.1));
					draw(pic = pic, (hl.center + hlvec) -- smstart, yellow + defaultDrEP);
					draw(pic = pic, (hl.center + rotate(-hl.sections[j][2])*hlvec) -- smfinish, yellow + defaultDrEP);
					dot(pic, hlstart, green+1);
					dot(pic, hlfinish, green+1);
					dot(pic, smstart, green+1);
					dot(pic, smfinish, green+1);
					draw(pic = pic, arc(hl.center, hl.center + hlvec, smfinish, direction = CW), blue+defaultDrEP);
				}

				pair[][] sections = new pair[][];
				if (mode == "strict")
				{
					sections = sectionparamsstrict(curhlcontour, cursmcontour, ceil(hl.sections[j][3]), hl.sections[j][4], ceil(hl.sections[j][5]));
				}
				if (mode == "free")
				{
					sections = sectionparamsfree(curhlcontour, cursmcontour, ceil(hl.sections[j][3])*ceil(hl.sections[j][5]), ceil(hl.sections[j][5]));
				}
				drawsections(pic, sections, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen, mode);
			}

            if (hl.neighnumber > 0)
            {   
                for (int j = 0; j < sm.holes.length; ++j)
                {
                    if (holeconnected[i][j] || holeconnected[j][i]) continue;                    

                    if (meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = defaultSmNC)) || meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = -defaultSmNC))) continue;
                    
                    bool near = true;
                    for (int k = 0; k < sm.holes.length; ++k)
                    {
                        if (k == i || k == j) continue;

                        if (intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = defaultSmNC)).length > 0 || intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = -defaultSmNC)).length > 0)
                        {
                            near = false;
                            break;
                        }
                    }

                    if (!near) continue;

                    drawholesections(pic, hl, sm.holes[j], viewdir, dash, explain, shade, sm.scale, mode, sectionpen, dashpen, shadepen);

                    holeconnected[i][j] = true;
                    holeconnected[j][i] = true;
                }
            }
        }
    }

    if (mode == "cart")
    {
        for (int i = 0; i < sm.hratios.length; ++i)
        {
            drawcartsections(pic, contour, sm.hratios[i], true, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen);
        }
        for (int i = 0; i < sm.vratios.length; ++i)
        {
            drawcartsections(pic, contour, sm.vratios[i], false, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen);
        }
    }

	int maxlayer = subsetmaxlayer(sm.subsets, sequence(sm.subsets.length));
	real penscale = (maxlayer > 0) ? currentDrSPM^(1/maxlayer) : 1;
	pen[] subsetpens = {subsetfill};
	for (int i = 1; i < maxlayer+1; ++i)
	{ subsetpens[i] = penscale*subsetpens[i-1]; }
    for (int i = 0; i < sm.subsets.length; ++i)
    {
        subset sb = sm.subsets[i];
        fill(pic = pic, sb.contour, subsetpens[sb.layer]);
        label(pic = pic, position = intersection(sb.contour, sb.center, sb.labeldir), L = Label("$"+sb.label+"$", align = sb.labelalign));

        if(explain) label(pic = pic, L = Label((string)i, position = sm.subsets[i].center, p = blue));
    }
    for (int i = 0; i < sm.subsets.length; ++i)
    { draw(pic = pic, sm.subsets[i].contour, subsetcontourpen); }

    if(explain) draw(pic = pic, sm.center -- sm.center+unit(viewdir)*defaultSmEAL, purple+defaultDrEP, arrow = Arrow(SimpleHead));
    if(explain)
    {
        dot(pic = pic, sm.center, red+1);
        for (int i = 0; i < sm.holes.length; ++i)
        {label(pic = pic, L = Label((string)i, position = sm.holes[i].center, p = red, filltype = Fill(currentSyBG)));}
    }

	if (drag)
	{
		for (int i = 0; i < sm.attached.length; ++i)
		{
			draw(pic = pic, sm = sm.attached[i], contourpen = contourpen, smoothfill =  smoothfill + opacity(currentDrDO), subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, explain = explain, dash = dash, drag = true);
		}
	}

	for (int i = 0; i < sm.elements.length; ++i)
	{
		element elt = sm.elements[i];
		dot(pic = pic, elt.pos, L = Label("$"+elt.label+"$", align = elt.labelalign), contourpen+currentDrEP);
	}

	if (cache) currentdrawn.push(drawdata(sm, contourpen, smoothfill, subsetfill));

	if (drag && sm.attached.length > 0) printfinished();
	else printsuccess();
}

void draw (picture pic = currentpicture, smooth[] sms, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, string mode = currentDrM, bool explain = currentDrE, bool dash = currentDrDD, bool shade = currentDrDS, bool drag = true)
{
	for (int i = 0; i < sms.length; ++i)
	{
		draw(pic = pic, sm = sms[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, explain, dash, shade, drag);
	}
}

smooth[] drawintersect (picture pic = currentpicture, smooth sm1, smooth sm2, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, pair shift = (0,0), pen ghostpen = mediumgrey, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, string mode = currentDrM, bool explain = currentDrE, bool dash = currentDrDD, bool shade = currentDrDS)
// Draws the intersection of two smooth objects, as well as their dim contours for comparison
{
	printbeginning("Drawing the intersection of " + ((length(sm1.label) == 0) ? "[unlabeled]" : sm1.label) + " and " + ((length(sm2.label) == 0) ? "[unlabeled]" : sm2.label) + "...");
	printstarted();
    
	smooth smp1 = sm1.copy().simplemove(shift = shift);
    smooth smp2 = sm2.copy().simplemove(shift = shift);
    
    smooth[] res = intersection(smp1, smp2, keepdata, round, roundcoeff);

    smp1.subsets.delete();
    smp2.subsets.delete();

    draw(pic, smp1, contourpen = ghostpen, smoothfill = invisible, mode = "plain");
    draw(pic, smp2, contourpen = ghostpen, smoothfill = invisible, mode = "plain");

    for (int i = 0; i < res.length; ++i)
    {
        draw(pic, res[i], contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, explain = explain, dash = dash, shade = shade);
    }

	printfinished();
    return res;
}
smooth[] drawintersect (picture pic = currentpicture, smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, pair shift = (0,0), pen ghostpen = mediumgrey, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, string mode = currentDrM, bool explain = currentDrE, bool dash = currentDrDD, bool shade = currentDrDS)
{
	printbeginning("Drawing the intersection of an array of smooth objects...");
	printstarted();

	smooth[] smsp = sequence(new smooth (int i){return sms[i].copy().move(shift = shift);}, sms.length);
	smooth[] res = intersection(smsp, keepdata, round, roundcoeff);

	for (int i = 0; i < smsp.length; ++i)
	{
		smsp[i].subsets.delete();
		draw(pic, smsp[i], contourpen = ghostpen, smoothfill = invisible, mode = "plain");
	}
	for (int i = 0; i < res.length; ++i)
	{
        draw(pic, res[i], contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, explain = explain, dash = dash, shade = shade);
	}

	printfinished();
	return res;
}
smooth[] drawintersect (picture pic = currentpicture, bool keepdata = true, bool round = false, real roundcoeff = defaultSyRR, pair shift = (0,0), pen ghostpen = mediumgrey, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, string mode = currentDrM, bool explain = currentDrE, bool dash = currentDrDD, bool shade = currentDrDS ... smooth[] sms)
{
	return drawintersect(pic, sms, keepdata, round, roundcoeff, shift, ghostpen, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, explain, dash, shade);
}

void overlap (picture pic=currentpicture, Label L="", path g, align align = NoAlign, pen p = currentpen, arrowbar arrow = None, arrowbar bar = None, margin margin = NoMargin, Label legend = "", marker marker = nomarker, pen fillpen = currentSyBG+linewidth(8pt))
// Draws a path with a stripe of filled space on the background.
{
    draw(pic = pic, g = g, align = align, p = fillpen, margin = margin);
    draw(pic = pic, L = L, g = g, align = align, p = p, arrow = arrow, bar = bar, margin = margin, legend = legend, marker = marker);
}

void arrow (picture pic, path gs, pair dir1, pair dir2, Label L, pen p, arrowbar arrow, bool overlap, bool fill, bool explain)
{
	if (overlap)
    {
		struct signedpath
		{
			path p;
			int sign;
			pen ovpen;
			real time;

			void operator init (path p, int sign, pen ovpen, real time)
			{
	 			this.p = p;
				this.sign = sign;
				this.ovpen = ovpen;
				this.time = time;
			}
		}
        signedpath[] getpaths (path gs, path[] curpaths, pen ovpen)
        {
            signedpath[] res;
            for (int j = 0; j < curpaths.length; ++j)
            {
                real[][] ovtimes = intersections(gs, curpaths[j]);
                for (int i = 0; i < ovtimes.length; ++i)
                {
					real curveovtime = ovtimes[i][0];
                    real ovtime = ovtimes[i][1];
					real cross = cross(dir(gs, curveovtime), dir(curpaths[j], ovtime));
                    int sign = sgn(cross);
                    real sang = abs(cross);

                    if(sang == 0) continue;

                    real t1 = arctime(curpaths[j], arclength(curpaths[j], 0, ovtime) + sign*currentArOL/sang*.5);
                    real t2 = arctime(curpaths[j], arclength(curpaths[j], 0, ovtime) - sign*currentArOL/sang*.5);
                    res.push(signedpath(subpath(curpaths[j], t1, t2), sign, ovpen, ovtimes[i][0]));
                }
            }
            return res;
        }

        void filloverlap (path p1, path p2, pen ovpen1, pen ovpen2, bool fill, pen fillpen)
        {
			if (fill)
			{
				real time1 = (ovpen1 == invisible) ? 0 : intersect(gs, p1)[0];
				real time2 = (ovpen2 == invisible) ? length(gs) : intersect(gs, p2)[0];
				real timem = (time1 + time2)*.5;
				path fillpath = reverse(p1){dir(gs, time1)} .. (point(gs, timem) + currentArOL*.5* (rotate(90)*(dir(gs, timem)))){dir(gs, timem)} .. {dir(gs, time2)}p2{-dir(gs, time2)} .. (point(gs, timem) + currentArOL*.5* (rotate(-90)*(dir(gs, timem)))){-dir(gs, timem)} .. {-dir(gs, time1)}cycle;
				fill(pic = pic, fillpath, fillpen);
				if (explain) draw(fillpath, red+defaultDrEP);
			}
            draw(pic = pic, p1, linewidth(p)+.3 + ovpen1);
            draw(pic = pic, p2, linewidth(p)+.3 + ovpen2);
        }

		void drawovpaths (drawdata di)
		{
			unravel di;

			signedpath[] ovpaths = new signedpath[];

			int[] subsetindeces = sequence(sm.subsets.length);
			for (int i = 0; i < subsetindeces.length; ++i)
			{
				if (sm.subsets[subsetindeces[i]].isintersection)
				{
					subsetindeces.delete(i);
					i -= 1;
				}
			}
			int maxlayer = subsetmaxlayer(sm.subsets, subsetindeces);
			real penscale = (maxlayer > 0) ? currentDrSPM^(1/maxlayer) : 1;
			pen[] subsetpens = {smoothfill, subsetfill};
			for (int i = 2; i < maxlayer+1; ++i)
			{ subsetpens[i] = penscale*subsetpens[i-1]; }

			for (int i = 0; i < maxlayer+1; ++i)
			{
				int[] curlayer = subsetgetlayer(sm.subsets, subsetindeces, i);
				ovpaths.append(getpaths(gs, sequence(new path (int j){return sm.subsets[curlayer[j]].contour;}, curlayer.length), subsetpens[i]));
			}

			ovpaths.append(getpaths(gs, sm.contour ^^ sequence(new path(int i){return reverse(sm.holes[i].contour);}, sm.holes.length), currentSyBG));

			ovpaths = sort(ovpaths, new bool(signedpath a, signedpath b){return (intersect(a.p, gs)[1] < intersect(b.p, gs)[1]);});

			int ovlevel = 0;
			int counter = 0;
			for (int i = 0; i < ovpaths.length; ++i)
			{
				counter += ovpaths[i].sign;
				if (counter < ovlevel) ovlevel = counter;
			}
			ovlevel = -ovlevel - 1;
			counter += ovlevel;

			if (ovlevel % 2 == 0)
			{
				pair curdir = currentArOL*.5/abs(cross(dir1, dir(gs, 0))) * dir1;
				pair pt1 = point(gs,0) - curdir;
				pair pt2 = point(gs,0) + curdir;
				ovpaths.insert(0, signedpath((pt1--pt2), 0, invisible, 0));
			}
			if (counter % 2 == 0)
			{
				pair curdir = -currentArOL*.5/abs(cross(dir2, dir(gs, length(gs)))) * dir2;
				pair pt1 = point(gs,length(gs)) - curdir;
				pair pt2 = point(gs,length(gs)) + curdir;
				ovpaths.push(signedpath((pt1--pt2), 0, invisible, length(gs)));
			}

			for (int i = 0; i < ovpaths.length - 1; i += 2)
			{
				ovlevel += ovpaths[i].sign;
				filloverlap(ovpaths[i].p, ovpaths[i+1].p, ovpaths[i].ovpen, ovpaths[i+1].ovpen, (fill && ovlevel == 0), smoothfill);
				ovlevel += ovpaths[i+1].sign;
			}

		}

		for (int i = 0; i < currentdrawn.length; ++i)
		{
			if (intersect(gs, currentdrawn[i].sm.contour).length == 0) continue;
			drawovpaths(currentdrawn[i]);
		}
    }

    draw(pic = pic, gs, p = p, arrow = arrow, L = L);
}

void drawarrow (picture pic = currentpicture, smooth sm1, smooth sm2 = sm1, int[] ind1 = {}, int[] ind2 = {}, real curve = 0, pair[] points = {}, Label L = "", pen p = currentpen, arrowbar arrow = Arrow(SimpleHead), bool overlap = true, bool fill = true, real margin1 = currentArM, real margin2 = currentArM, bool explain = currentDrE)
// Draws an arrow between two given smooth objects, or their subsets.
{
	string label1;
	string label2;
	path g1;
    path g2;
	pair center1;
	pair center2;
	
	if (ind1.length > 0)
	{
		subset sb1 = subsetget(sm1.subsets, ind1);
		label1 = sb1.label;
		g1 = sb1.contour;
		center1 = sb1.center;
	}
	else
	{
		label1 = sm1.label;
		g1 = sm1.contour;
		center1 = sm1.center;
	}
	if (ind2.length > 0)
	{
		subset sb2 = subsetget(sm2.subsets, ind2);
		label2 = sb2.label;
		g2 = sb2.contour;
		center2 = sb2.center;
	}
	else
	{
		label2 = sm2.label;
		g2 = sm2.contour;
		center2 = sm2.center;
	}

	printbeginning("Drawing an arrow between " + ((length(label1) == 0) ? "[unlabeled]" : label1) + " and " + ((length(label2) == 0) ? "[unlabeled]" : label2) + "...");
	if (center1 == center2)
	{
		printfailure("Could not draw arrow between object and itself.");
		return;
	}

    path g = (points.length == 0) ? curvedpath(center1, center2, curve = curve) : connect(concat(new pair[]{center1}, points, new pair[]{center2}));
	real[] intersect1 = intersect(g, g1);
    real[] intersect2 = intersect(g, g2);
	pair dir1;
	pair dir2;
	real time1 = arctime(g, margin1);
	real time2 = arctime(g, arclength(g)-margin2);
	if (intersect1.length > 0)
	{
		time1 = arctime(g, arclength(g, 0, intersect1[0])+margin1);
		dir1 = dir(g1, intersect1[1]);
	}
	if (intersect2.length > 0)
	{
		time2 = arctime(g, arclength(g, 0, intersect2[0])-margin2);
		dir2 = dir(g2, intersect2[1]);
	}
    path gs = subpath(g, time1, time2);

	arrow(pic, gs, dir1, dir2, L, p, arrow, overlap, fill, explain);
	printsuccess();
}

void drawarrow (picture pic = currentpicture, smooth sm, int[] ind = {}, real angle, real radius = sm.scale, pair[] points = {}, Label L = "", pen p = currentpen, arrowbar arrow = Arrow(SimpleHead), bool overlap = true, bool reverse = false, bool fill = true, real margin1 = currentArM, real margin2 = currentArM, bool explain = currentDrE)
{
	string label;
	path contour;
	pair center;
	
	if (ind.length > 0)
	{
		subset sb = subsetget(sm.subsets, ind);
		label = sb.label;
		contour = sb.contour;
		center = sb.center;
	}
	else
	{
		label = sm.label;
		contour = sm.contour;
		center = sm.center;
	}

	printbeginning("Drawing a cycle arrow for object " + ((length(label) == 0) ? "[unlabeled]" : label) + "...");

	path g = (points.length == 0) ? cyclepath(center, angle, radius) : connect(concat(new pair[]{center}, points, new pair[]{center}));
	if (reverse) g = reverse(g);
	real[][] intersection = intersections(g, contour);

	pair dir1;
	pair dir2;
	real time1 = arctime(g, margin1);
	real time2 = arctime(g, arclength(g)-margin2);
	if (intersection.length > 0)
	{
		time1 = arctime(g, arclength(g, 0, intersection[0][0])+margin1);
		dir1 = dir(contour, intersection[0][1]);
	}
	if (intersection.length > 1)
	{
		time2 = arctime(g, arclength(g, 0, intersection[intersection.length-1][0])-margin2);
		dir2 = dir(contour, intersection[intersection.length-1][1]);
	}

    path gs = subpath(g, time1, time2);

	arrow(pic, gs, dir1, dir2, L, p, arrow, overlap, fill, explain);
	printsuccess();
}

// -- Animations -- //

void clean ()
{
	for (int i = 0; i < currentPrFC; ++i)
	{ system("rm "+currentAnIP+"_"+copychar("0", defaultAnNL - length((string)i))+(string)i + "."+currentAnIF); }
	currentPrFC = 0;
}

void compile (int fps = defaultAnFPS, string outprefix = currentAnOP, string outformat = currentAnOF, bool clean = true)
{
	printbeginning("Compiling animation...");

	system("nohup ffmpeg -y -hide_banner -loglevel error -framerate "+(string)fps+" -i "+currentAnIP+"_%0"+(string)defaultAnNL+"d."+currentAnIF+" "+outprefix+"."+outformat);

	if (clean) clean();
	printsuccess();
}

picture framedpicture (picture pic)
{
	if (!currentFrEP) return pic;
	picture aux;
	aux = pic;
	draw(aux, (-currentFrFC)--currentFrFC, invisible);
	if (currentFrCP)
	{ clip(aux, (-currentFrFC -- (currentFrFC.x, -currentFrFC.y) -- currentFrFC -- (-currentFrFC.x, currentFrFC.y) -- cycle)); }
	return aux;
}

void shipnative (picture pic = currentpicture, string prefix, string format, real margin)
{
	picture aux = framedpicture(pic);
	shipout(bbox(aux, xmargin = margin, p = invisible, filltype = Fill(p = currentSyBG)), prefix = prefix, format = format);
}

void shipconvert (picture pic = currentpicture, string prefix, string format, real margin, int density = currentSyRID)
{
	picture aux = framedpicture(pic);
	shipout(bbox(aux, xmargin = margin, p = invisible, filltype = Fill(p = currentSyBG)), prefix = prefix, format = "eps");
	int width = ceil(density * 9.83);
	if (width % 2 == 1) width += 1;
	system("mogrify -density "+(string)density+" -resize "+(string)width+" -format "+format+" "+prefix+".eps");
	system("rm "+prefix+".eps");
}

void produce (picture pic = currentpicture, string prefix = "output", string format = settings.outformat, real margin = currentSyM, int density = currentSyRID, bool exit = currentSyEOP, bool time = true)
{
	printbeginning("Producing output file " + prefix+"."+format + " ...");

	if (vector(format))
	{ shipnative(pic, prefix, format, margin); }
	else
	{ shipconvert(pic, prefix, format, margin, density); }
	printsuccess();

	if (exit)
	{
		if (time) printtime();
		exit();
	}
}

void animate (void prefix () = new void (){
	printbeginning("Writing custom animation...");
	printstarted();
}, void update (int), int n = defaultAnFN, bool back = false, real margin = currentSyM, int density = currentSyRID, bool compile = true, string outprefix = currentAnOP, string outformat = currentAnOF, int fps = defaultAnFPS)
{
	prefix();
	bool pm = currentPrPM;

	real ool = 1/defaultPrML - defaultSySN;
	real oon = 1/n;
	real residue = 0;

	bool vector = vector();
	void ship (string prefix)
	{
		if (vector) { shipnative(prefix, currentAnIF, margin); }
		else { shipconvert(prefix, currentAnIF, margin, density); }
	}

	for (int i = 0; i < n; ++i)
	{
		save();
		currentPrPM = false;
		update(i);
		currentPrPM = pm;
		string str1 = (string)(currentPrFC+i);
		string str2 = (string)(currentPrFC + 2n - 1 - i);
		ship(prefix = currentAnIP+"_"+copychar("0", defaultAnNL - length(str1))+str1);
		if (back) ship(prefix = currentAnIP+"_"+copychar("0", defaultAnNL - length(str2))+str2);
        restore();

		residue += oon;
		while (residue >= ool)
		{
			write("=", suffix = none);
			residue -= ool;
		}
    }
	currentPrFC += n;

	write();

	if (compile) compile(fps = fps);
	printfinished();
}

void move (smooth sm, string mode = "strict", pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, pair shift = (0,0), real scale = 1, real rotate = 0, bool keepview = false, bool dash = currentDrDD, bool explain = currentDrE, bool shade = currentDrDS, int frames = defaultAnFN, bool back = true, bool drag = true, real margin = currentSyM, int density = currentSyRID, bool compile = false, int fps = defaultAnFPS, bool close = currentAnC)
// Animates the process of shifting, scaling and rotating a given smooth object. //
{
	void prefix ()
	{
		printbeginning("Animating the movement of " + (length(sm.label) > 0 ? sm.label : "[unlabeled]") + "...");
		if (mode != "strict" && mode != "cart" && mode != "plain" && mode != "free")
		{
			printfailure("Invalid mode specified.");
			return;
		}
		printstarted();
	}	

    smooth smp;
    if (back) smp = sm.copy();
	int n = back ? ceil(frames*.5) : frames;

	pair stepshift = close ? shift/(n-1) : shift/n;
	real stepscale = close ? scale^(1/(n-1)) : scale^(1/n);
	real steprotate = close ? rotate/(n-1) : rotate/n;

	void update (int i)
	{
		if (i > 0) sm.move(shift = stepshift, scale = stepscale, rotate = steprotate, keepview = keepview, drag = drag);
        draw(sm, mode = mode, contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, dash = dash, explain = explain, shade = shade, drag = drag, cache = false);
	}
	if (back) sm = smp;

	animate(prefix = prefix, update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}

void revolve (smooth sm, string mode = currentDrM, pair viewdir1 = sm.viewdir, pair viewdir2, pen contourpen = currentpen, pen smoothfill = smoothcolor, pen subsetcontourpen = contourpen, pen subsetfill = subsetcolor, pen sectionpen = currentDrSS*contourpen+currentDrST, pen dashpen = sectionpen+dashed+grey, pen shadepen = currentDrSS*smoothfill, bool dash = currentDrDD, bool explain = currentDrE, bool shade = currentDrDS, pair shift = (0,0), bool back = true, bool arc = false, bool shiftsubsets = currentSmSS, bool drag = true, int frames = defaultAnFN, real margin = currentSyM, int density = currentSyRID, bool compile = false, int fps = defaultAnFPS, bool close = currentAnC)
// Creates the illusion of a given smooth objects being rotated in an axis perpendicular to the view direction (turning "to the left" and "to the right") by altering the `viewdir` parameter and stretching the object.
{
	void prefix ()
	{
		printbeginning("Animating the revolution of " + (length(sm.label) > 0 ? sm.label : "[unlabeled]") + "...");
		if (mode != "strict" && mode != "cart" && mode != "plain" && mode != "free")
		{
			printfailure("Invalid mode specified.");
			return;
		}
		if (arc && (length(viewdir1) == 0 || length(viewdir2) == 0))
		{
			printfailure("One of the view directions is of length zero. Cannot animate in arc mode");
			return;
		}
		printstarted();
	}	

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

	animate(prefix = prefix, update = update, n = n, back = back, margin = margin, density = density, compile = compile, fps = fps);
}
