/*

This is module smoothmanifold. It is designed to construct and render
high-quality Asymptote figures that display sets as 2D or 3D surfaces on the plane.

Copyright (C) 2024 Maksimovich Roman Alekseevich. All rights reserved.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

*/

// -- Default constants -- //

// [Sy]stem
private string defaultversion = "v5.10.0-beta";
private int defaultSyDN = -10000; // [D]ummy [N]umber -- "the program knows what to do with it".
private string defaultSyDS = "-10000"; // [D]ummy [S]tring --||--
private pair defaultSyDP = (defaultSyDN, defaultSyDN); // [D]ummy [P]air --||--

// [Se]ction
private real defaultSeSN = 5.0e-4; // [S]mall [N]umber -- custom "epsilon" used in some algorithms.
private real defaultSeWUB = .65; // [W]idth [U]pper [B]oundary -- see `sectiontoowide()`.
real[] defaultsection = new real[]{defaultSyDN,defaultSyDN,235,7}; // -- default expressed in section notation.

private real defaultSeF = .3; // [F]reedom -- how freely sections can deviate from their target positions.
private int defaultSeP = 20; // [P]recision -- how many points to sample in search for good section position.
private real defaultSeEP = -1; // [E]llipse [P]recision -- precision used in bin. search to construct tangent ellipses for cross sections. A value of -1 uses exact formula instead of binary search.

// [Sm]ooth
private int defaultSmIHSN = 1; // [I]nter[h]ole [S]ection [N]umber -- default # of sections between holes.
private real defaultSmIHSA = 25; // [I]nter[h]ole [S]ection [Angle] -- range to be used for interhole sections.
private real defaultSmMSLR = -1; // [M]aximum [S]ection [L]ength [R]atio -- how long (in diameter) the section can be compared to the size of parent object. A value of -1 means no restriction.
private real defaultSmSRC = .15; // [S]ection [R]ejection [C]urve -- defines the condition for drawing sections between two holes (or in cartesian mode).
private real defaultSmVA = 7; // [V]iew [A]ngle -- angle (in degrees) of rotation of smooth objects when setting the 'viewdir' parameter.
private real defaultSmCEM = .07; // [C]artesian [E]dge [M]argin -- no point in explaining, see the use cases.
private real defaultSmCSD = .1; // [C]art [S]tep [D]istance --||--
private real defaultSmSVS = .3; // [S]ubset [V]iew [S]hift -- how much to shift subsets under different `viewdir` values.

// [Dr]awing
private real defaultDrGL = .1; // [G]ap [L]ength -- the length of the gap made on path overlaps.
private pen defaultDrSmC = lightgrey; // [Sm]ooth [C]olor -- the filling color of smooth objects.
private pen defaultDrSbC = grey; // [S]u[b]set [C]olor -- the filling color of layer 0 subsets.
private real defaultDrSePS = .6; // [Se]ction [P]en [S]cale -- how thinner the section pen is compared to the contour pen.
private real defaultDrElPW = 3.0; // [E]lement [P]en -- pen to draw element dots.
private real defaultDrShS = .85; // [S]hade [S]cale -- how darker shaded areas are compared to object filling color.
private real defaultDrDPS = .4; // [D]ash [P]en [S]cale -- how lighter dashed lines are compared to regular ones.
private real defaultDrDPO = .4; // [D]ash [P]en [O]pacity -- opacity of dashed pens.
private real defaultDrDO = .8; // [D]rag [O]pacity -- opacity of smooth objects attached to main object.
private real defaultDrSPM = .4; // [S]ubset [P]en [M]ultiplier -- how darker subsets get with each new layer.

// [H]e[l]p
private real defaultHlAR = 0.2; // [A]rc [R]atio
private real defaultHlAL = .2; // [A]rrow [L]ength
private pen defaultHlLW = linewidth(.3); // [L]ine [W]idth

// [Ar]rows
private real defaultArM = defaultDrGL*.7; // [M]argin (see "arrow")

// [Pa]ths
private path[] defaultPaCV = new path[]{ // [C]on[V]ex
	(-1.00195,0)..controls (-0.990469,1.33363) and (1.00998,1.31642)..(0.998502,-0.0172156)..controls (0.987026,-1.35085) and (-1.01342,-1.33363)..cycle,
	(-1.26284,0.599848)..controls (-0.829364,1.45475) and (1.64169,0.399899)..(1.07867,-0.86294)..controls (0.74517,-1.61099) and (-1.83112,-0.520921)..cycle,
	(-0.841836,0.446343)..controls (-0.227446,1.55993) and (1.50685,0.5614)..(0.858786,-0.590415)..controls (0.161022,-1.83057) and (-1.33903,-0.454818)..cycle,
    (-1.0522,0.0600251)..controls (-0.572004,1.31702) and (1.08045,1.07692)..(1.0522,-0.176544)..controls (1.0259,-1.34403) and (-1.457,-0.999597)..cycle,
	(-1.3015,0.292664)..controls (-1.16377,1.02949) and (1.58727,0.964071)..(1.08802,-0.447604)..controls (0.699265,-1.54686) and (-1.45274,-0.516484)..cycle,
 	(-0.7747,-0.578443)..controls (-1.27059,0.149293) and (-1.30873,0.619498)..(-0.623203,0.977844)..controls (-0.168712,1.21542) and (0.994515,0.849099)..(0.943412,-0.00688622)..controls (0.860778,-1.39102) and (-0.244461,-1.35659)..cycle,
    (0.890573,-0.36047)..controls (-0.148296,-1.45705) and (-1.29345,-1.23691) .. (-0.996593,0.106021) .. controls (-0.669702,1.58481) and (2.03559,0.848164)..cycle,
	(-0.723053,0.87455)..controls (-0.120509,1.45988) and (1.49431,0.148054)..(0.864221,-0.795359)..controls (0.400434,-1.48977) and (-1.84643,-0.216729)..cycle,
    (0.28979,-0.834028)..controls (0.093337,-0.908653) and (-1.20138,-1.95019)..(-1.15209,0.0777484)..controls (-1.10261,2.11334) and (3.02512,0.204973)..cycle,
    (1.01073,-0.409946)..controls (0.812824,-1.99319) and (-2.2123,-0.523035)..(-0.897641,0.36047)..controls (0.779873,1.48783) and (1.20823,1.17008)..cycle,
    (0.636123,-0.975389)..controls (-0.853465,-1.50787) and (-1.37827,0.219109)..(-0.770416,0.961253)..controls (-0.154452,1.7133) and (2.19816,-0.417014)..cycle,
    (0.805756,0.918845)..controls (1.7034,-0.664395) and (-0.374882,-1.93278)..(-0.890573,-0.742144)..controls (-1.3712,0.367538) and (0.34086,1.73882)..cycle,
    (0.572511,-0.925913)..controls (-1.47015,-1.5479) and (-1.32586,0.925729)..(-0.28979,1.00366)..controls (1.30759,1.12382) and (1.65924,-0.595004)..cycle,
	(-1.08848,-0.169633)..controls (-1.65294,0.930585) and (1.00971,1.66132)..(1.0178,0.0282721)..controls (1.02487,-1.39947) and (-0.671464,-0.982457)..cycle
};

private path[] defaultPaCC = new path[]{ // [C]on[C]ave
	(
		(-0.9,0).. controls
		(-1.07649842837266,0.638748977821067) and
		(-0.964116819714307,1.31556675048848) 
		..(-0.46,1.3).. controls
		(0.0281888161644762,1.28492509435253) and
		(0.0424415730404705,0.611597145023648) 
		..(0.4,0.36).. controls
		(0.623716050683286,0.202581476469435) and
		(0.955392557398132,0.2268850080704) 
		..(1.12,0).. controls
		(1.39778902724123,-0.382887703564746) and
		(1.00985460296201,-0.913845673503591) 
		..(0.4,-1).. controls
		(0.0314808795565626,-1.05206079689921) and
		(-0.356264634361184,-0.976905732695238) 
		..(-0.6,-0.7).. controls
		(-0.770480811250471,-0.506318160575248) and
		(-0.831474513408123,-0.247994188496873) 
		..cycle
	),
    (
		(0.523035,-1.10261)..controls
		(-2.62474,-1.37362) and
		(0.932069,3.11139)..(0.558375,0.388742)..controls
		(0.508899,0.0282721) and
		(1.59031,-1.01073)..cycle
    ),
	(
		(-1.4,0).. controls
		(-1.4330976353941,0.309902105154151) and
		(-1.14752451684655,0.558611632511754) 
		..(-0.84,0.49).. controls
		(-0.66443424676999,0.450829617534925) and
		(-0.529507080118944,0.301231459889368) 
		..(-0.35,0.28).. controls
		(0.10216096608008,0.226520006851507) and
		(0.27539586949137,0.862356630570909) 
		..(0.7,0.91).. controls
		(1.05908418967551,0.950291602166852) and
		(1.33041677912753,0.603698618857815) 
		..(1.33,0.21).. controls
		(1.32951602626534,-0.247172104636948) and
		(1.00821765736334,-0.645111266508212) 
		..(0.56,-0.7).. controls
		(0.274611440338081,-0.734948682488405) and
		(0.00179568356868698,-0.609311459905892) 
		..(-0.28,-0.56).. controls
		(-0.46548899922109,-0.527541258147606) and
		(-0.65562744488586,-0.528541447729153) 
		..(-0.84,-0.49).. controls
		(-1.11441028298393,-0.432636963666203) and
		(-1.37134558383179,-0.268299042718725) 
		..cycle
	),
	(
		(-0.74,1.11).. controls
		(-0.45217186192491,1.16995417728509) and
		(-0.244186500029556,0.896228533675695) 
		..(-1.11022302462516e-16,0.74).. controls
		(0.394876451006404,0.487361263147939) and
		(1.0095388806718,0.479180198886787) ..(1.11,1.1327982892113e-16).. controls
		(1.33690476375748,-1.08229204047052) and
		(-0.898239052326633,-1.59366714480983) ..(-1.11,0.37).. controls
		(-1.14560254698906,0.700143742564816) and
		(-1.03848931729363,1.04782511478409) ..cycle
	),
	(
		(-1.35,0).. controls
		(-1.18010190019904,0.416395394711846) and
		(-0.593260371382216,0.281172231186116) 
		..(-0.27,0.54).. controls
		(0.0113914268982608,0.76530418707376) and
		(0.0415625335934956,1.24549540856936) 
		..(0.405,1.35).. controls
		(1.23327036593247,1.5881649229556) and
		(1.85490272745839,-0.0949264215164867) 
		..(0.27,-0.675).. controls
		(0.0952777069905893,-0.738948268869059) and
		(-0.0857655726904087,-0.78403391700961) 
		..(-0.27,-0.81).. controls
		(-0.962087418222204,-0.907543111787485) and
		(-1.54255992615578,-0.471936216774976) 
		..cycle
	),
	(
		(-0.69,0.23).. controls
		(-0.56530943588509,0.830213108154057) and
		(-0.490658723837313,1.55646651437028) 
		..(0,1.38).. controls
		(0.325235552510512,1.26302830152094) and
		(0.237200927517758,0.801860482003199) 
		..(0.46,0.575).. controls
		(0.619891745450561,0.41219358416926) and
		(0.894509662874465,0.412735950982866) 
		..(1.035,0.23).. controls
		(1.25559773374585,-0.0569317384062731) and
		(1.01749624107123,-0.438647936878262) 
		..(0.69,-0.69).. controls
		(0.106935122935565,-1.13749997528092) and
		(-0.664799927016652,-1.18767474273486) 
		..(-0.851,-0.644).. controls
		(-0.950985536038634,-0.352058059741617) and
		(-0.751751264242251,-0.0672471774939401) ..cycle
	),
	(
		(-0.84,-0.24).. controls
		(-1.18825254216645,0.432752580408028) and
		(-0.749760426462422,1.11594975136258) 
		..(-0.24,0.96).. controls
		(0.0302529853898903,0.877322170006355) and
		(0.10736936611544,0.557158491533225) 
		..(0.3,0.36).. controls
		(0.513175121412852,0.141814114802958) and
		(0.878268025246844,0.063643117790086) 
		..(0.96,-0.24).. controls
		(1.09910636339287,-0.756795171199751) and
		(0.418309528013558,-1.17658493090488) 
		..(-0.24,-0.84).. controls
		(-0.497994898468632,-0.708090630046164) and
		(-0.706794583247006,-0.497325581279094) 
		..cycle
	)
};

path randomconvex ()
{ return defaultPaCV[rand()%defaultPaCV.length]; }

path randomconcave ()
{ return defaultPaCC[rand()%defaultPaCC.length]; }

// -- Current values (can be changed by the user) -- //

// [Sy]stem
private bool currentSyRL = false; // [R]epeat [L]abels -- whether to allow two entities to have one label.
private bool currentSyID = true; // [I]nsert [D]ollars -- whether to automatically insert dollars in labels.

// [Se]ction
private real[] currentsection = copy(defaultsection);
private real currentSeF = defaultSeF;
private real currentSeEP = defaultSeEP;
private bool currentSeAS = false; // [A]void [S]ubsets

// [Sm]ooth
private int currentSmIHSN = defaultSmIHSN;
private real currentSmIHSA = defaultSmIHSA;
private real currentSmMSLR = defaultSmMSLR;
private real currentSmMSL; // [M]aximum [L]ength
private bool currentSmIL = true; // [I]nfer [L]abels -- whether to create labels like "A \cap B" on intersection. 
private bool currentSmSS = false; // [S]hift [S]ubsets -- whether to shift subsets on view.
private bool currentSmAS = true; // [A]dd [S]ubsets -- whether to intersect subsets in smooth object intersections.
private bool currentSmU = false; // [U]nit

// [Dr]awing
private real currentDrGL = defaultDrGL;
private real currentDrSePS = defaultDrSePS;
private real currentDrElPW = defaultDrElPW;
private real currentDrShS = defaultDrShS;
private real currentDrDPS = defaultDrDPS;
private real currentDrDPO = defaultDrDPO;
private real currentDrDO = defaultDrDO;
private real currentDrSPM = defaultDrSPM;
private pen currentDrSeOP = nullpen; // [Se]ction [O]verride [P]en
private int currentDrM = 0; // [M]ode
private bool currentDrUO = false; // [U]se [O]pacity
private bool currentDrDD = true; // [D]raw [D]ashes
private bool currentDrDUD = false; // [D]raw [U]nder [D]ashes
private bool currentDrH = false; // [H]elp
private bool currentDrDS = false; // [D]raw [S]hade
private bool currentDrF = true; // [F]ill
private bool currentDrFS = false; // [F]ill [S]ubsets
private bool currentDrDC = true; // [D]raw [C]ontour
private bool currentDrO = false; // [O]verlap
private bool currentDrDN = false; // [D]raw [N]ow
private bool currentDrSCO = false; // [S]ubset [C]outour [O]verlap

// [H]e[l]p
private pen currentHlLW = defaultHlLW;
private int currentHlGN = 10; // [H]elp [G]rid [N]umber
private int currentHlGP = 1; // [H]elp [G]rid [N]umber

// [Ar]rows
private real currentArM = defaultArM;

// [Pr]ogress
private path[] currentPrDP; // [D]ebug [P]aths

// User variables
pen smoothcolor = defaultDrSmC;
pen subsetcolor = defaultDrSbC;
path[] convexpath = copy(defaultPaCV);
path[] concavepath = copy(defaultPaCC);
int free = 0;
int cartesian = 1;
int plain = 2;
int dn = defaultSyDN; // shorthand for [d]ummy[n]umber
arrowbar simple = Arrow(SimpleHead);
arrowbar simples = Arrows(SimpleHead);

// -- Auxiliary utilities -- //

include pathmethods;

// -- System functions -- //

void halt (string msg)
// write error and exit compilation.
{
    write();
    write("> ! "+msg);
    abort("");
}

string mode (int md)
{
	if (md == 0) return "free";
	if (md == 1) return "cartesian";
	if (md == 2) return "plain";
	return "";
}

private bool checksection (real[] section)
// Checks if array has valid section values in it (see 'struct hole').
{
	if (section.length > 1 && section[0] == 0 && section[1] == 0)
	{ return false; }
	if (section.length > 2 && section[2] != defaultSyDN && !inside(0, 360, section[2]))
	{ return false; }
	if (section.length > 3 && section[3] != defaultSyDN && section[3] <= 0)
	{ return false; }
	return true;
}

private real sectionsymmetryvalue (pair p1p2, pair dir1, pair dir2)
// A rating of how symmetric the section is (see 'sectionparams').
{ return abs(dot(dir2, p1p2)+dot(p1p2, dir1)); }

private bool sectiontoowide (pair p1, pair p2, pair dir1, pair dir2)
// Checks if the section is too wide (see 'cartsections').
{
    return (min(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) <= -defaultSeWUB || max(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) >= defaultSeWUB);
}

private pen inverse (pen p)
// Inverts the colors of `p`.
{
	real[] colors = colors(p);
	if (colors.length == 1) return colorless(p)+gray(1-colors[0]);
	if (colors.length == 3) return colorless(p)+rgb(1-colors[0], 1-colors[1], 1-colors[2]);
	return colorless(p);
}

private pen sectionpen (pen p)
// Derives a pen to draw cross sections (see 'draw').
{
    if (currentDrSeOP == nullpen) return p+linewidth(currentDrSePS*linewidth(p));
    else return currentDrSeOP;
}

private pen nextsubsetpen (pen p, real scale)
// Derives a pen to fill subsets of increasing layers (see 'struct subset' and 'draw').
{ return scale * p; }

private pen dashpenscale (pen p)
{ return inverse(currentDrDPS*inverse(p))+dashed; }

private pen dashpenopacity (pen p)
{ return p+dashed+opacity(currentDrDPO); }

private pen dashpen (pen p)
// Derives a pen to draw dashed lines, using either re-coloring or opacity.
{
    if (currentDrUO) return dashpenopacity(p);
    else return dashpenscale(p);
}

private pen shadepen (pen p)
// Derives a pen to fill shaded regions (see 'drawsections').
{ return currentDrShS*p; }

private pen elementpen (pen p)
// Derives a pen to render elements (see 'struct element' and 'draw').
{ return p + linewidth(currentDrElPW); }

private pen underpen (pen p)
// Derives a pen to draw paths that go under areas.
{ return dashpen(p); }

// -- User setting functions -- //

void smpar (
    real[] section = currentsection,
    real scfreedom = currentSeF,
    int scholenumber = currentSmIHSN,
    real scholeangle = currentSmIHSA,
    real scprecision = currentSeEP,
    real scmaxlength = currentSmMSLR,
    bool scavoidsubsets = currentSeAS,
        int mode = currentDrM,
        pen smoothfill = smoothcolor,
        pen subsetfill = subsetcolor,
        real minscale = currentDrSPM,
        bool overlap = currentDrO,
        bool subsetoverlap = currentDrSCO,
        bool drawnow = currentDrDN,
        bool help = currentDrH,
        int gridnumber = currentHlGN,
        int gridplaces = currentHlGP,
        pen explainpen = currentHlLW,
        real dragop = currentDrDO,
        bool dash = currentDrDD,
        bool underdash = currentDrDUD,
        bool useopacity = currentDrUO,
        real dashscale = currentDrDPS,
        real dashop = currentDrDPO,
        bool shade = currentDrDS,
        bool fill = currentDrF,
        bool fillsubsets = currentDrFS,
        real sectionpenscale = currentDrSePS,
        pen sectionpen = currentDrSeOP,
        real elementwidth = currentDrElPW,
        bool inferlabels = currentSmIL,
        bool shiftsubsets = currentSmSS,
        bool addsubsets = currentSmAS,
        bool unit = currentSmU,
        real gaplength = currentDrGL,
        real arrowmargin = currentArM,
            bool repeatlabels = currentSyRL,
            bool insertdollars = currentSyID
) // The configuration function. It is used by the user to set all global system variables.
{
	if (!checksection(section) || scfreedom >= 1 || scholenumber < 0 || !inside(0, 180, scholeangle))
	{ halt("Could not change default section parameters: invalid intries. [ smpar() ]"); }
	for (int i = 0; i < section.length; ++i)
	{ if (section[i] != defaultSyDN) currentsection[i] = section[i]; }
	if (!inside(0,2, mode))
	{ halt("Could not set mode: invalid entry provided. [ smpar() ]"); }
	if (!inside(0,1, minscale))
	{ halt("Could not apply changes: subset color scale argument out of range: must be between 0 and 1. [ smpar() ]"); }
	if (!inside(0,1, dragop))
	{ halt("Could not set drag opacity: entry out of bounds: must be between 0 and 1. [ smpar() ]"); }

    currentSeF = scfreedom;
	currentSmIHSN = scholenumber;
	currentSmIHSA = scholeangle;
    currentSeEP = scprecision;
	currentSmMSLR = scmaxlength;
    currentSeAS = scavoidsubsets;
	currentDrM = mode;
	smoothcolor = smoothfill;
	subsetcolor = subsetfill;
	currentDrSPM = minscale;
    currentDrO = overlap;
    currentDrDN = drawnow;
    currentDrSCO = subsetoverlap;
	currentDrH = help;
	currentHlGN = gridnumber;
	currentHlGP = gridplaces;
	currentHlLW = explainpen;
	currentDrDO = dragop;
	currentDrDD = dash;
	currentDrDUD = underdash;
    currentDrUO = useopacity;
    currentDrDPS = dashscale;
    currentDrDPO = dashop;
	currentDrDS = shade;
    currentDrF = fill;
    currentDrFS = fillsubsets;
	currentDrSePS = sectionpenscale;
    currentDrSeOP = sectionpen;
	currentDrElPW = elementwidth;
    currentSmIL = inferlabels;
    currentSmSS = shiftsubsets;
    currentSmAS = addsubsets;
    currentSmU = unit;
	currentDrGL = gaplength;
	currentArM = arrowmargin;
    currentSyRL = repeatlabels;
    currentSyID = insertdollars;

	if (gaplength > 1) write("> ? Value for gap length looks too big: the results may be ugly. [ smpar() ]");
}

void defaults ()
// Revert global settings to the default.
{
	currentsection = copy(defaultsection);
	currentSmIHSN = defaultSmIHSN;
	currentSmIHSA = defaultSmIHSA;
	currentSmMSLR = defaultSmMSLR;
	currentDrGL = defaultDrGL;
	currentArM = defaultArM;
	currentDrSePS = defaultDrSePS;
	currentHlLW = defaultHlLW;
	currentDrElPW = defaultDrElPW;
	currentDrShS = defaultDrShS;
    currentDrDPS = defaultDrDPS;
    currentDrDPO = defaultDrDPO;
	currentDrDO = defaultDrDO;
	currentDrSPM = defaultDrSPM;
	currentSyRPC = defaultSyRPC;
    currentSyRPR = defaultSyRPR;
}

// -- Technical functions to construct horizontal and vertical sections -- //

private pair[][] cartsectionpoints (path[] g, real r, bool horiz)
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

private pair[][] cartsections (path[] g, path[] avoid, real r, bool horiz)
// Marks the places where it is suitable to draw horizontal or vertical sections of `g` at ratio `r`.
{
    pair[][] presections = cartsectionpoints(g, r, horiz);
	if (presections.length % 2 == 1) return new pair[][];
    pair[][] sections;

	for (int i = 0; i < presections.length; i += 2)
	{
		if (sectiontoowide(presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]))
		{ continue; }
	    
		bool exclude = false;
        for (int j = 0; j < avoid.length; ++j)
        {
            if (meet(avoid[j], (path)(presections[i][0]--presections[i+1][0])))
            { exclude = true; }
        }
        if (exclude) continue;
    
		for (int j = 0; j < g.length; ++j)
		{
			if (j == presections[i][2].x || j == presections[i+1][2].x) continue;
			if (meet(g[j], curvedpath(presections[i][0], presections[i+1][0], defaultSmSRC)) || meet(g[j], curvedpath(presections[i+1][0], presections[i][0], defaultSmSRC)))
			{
				exclude = true;
				break;
			}
		}

		if (!exclude)
		{ sections.push(new pair[]{presections[i][0], presections[i+1][0], presections[i][1], presections[i+1][1]}); }
	}

	return sections;
}

private path[] sectionellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir)
// One of the most important technical functions of the module. Constructs an ellipse that touches `dir1` and `dir2` and whose center lies on the segment [p1, p2].
{
	if (length(viewdir) == 0) return new path[]{p1--p2};

    pair p1p2 = p2-p1;
    real l = length(p1p2);
    real d, x;

    real h = cross(p1p2, viewdir);
    int sgnh = sgn(h);
    h = abs(h);
    if (h < defaultSeSN*l) return new path[]{p1--p2};
    real lsang1 = cross(p1p2, dir1);
    real lsang2 = cross(dir2, -p1p2);
    if (lsang1 < 0) { dir1 = -dir1; lsang1 = -lsang1; }
    if (lsang2 < 0) { dir2 = -dir2; lsang2 = -lsang2; }
    pair hv = (rotate(90)*p1p2) * h;

    pair dir1p = l*(rotate(-degrees(p1p2, false))*dir1);
    pair dir2p = l*(rotate(-degrees(p1p2, false))*dir2);

    path line1 = (-dir1p) -- (dir1p);
    path line2 = ((l,0) - dir2p) -- ((l,0) + dir2p);

    if (currentSeEP <= 0)
    {
        real reciprocal1 = 1/lsang1;
        real reciprocal2 = 1/lsang2;
        d = l * 0.5 * (1.0 + h*h*(reciprocal1 - reciprocal2)*(reciprocal1 + reciprocal2));
        x = sqrt(d*d - h*h*((reciprocal1*l)^2-1));
    }
    else
    {
        real r1 = 0;
        real l1 = l*.5;
        real r2 = 0;
        real l2 = l*.5;

        path ellipse (real d1, real d2)
        { return ellipse(((d1 + l-d2)*.5, 0), (l-d1-d2)*.5, h); }

        while (l1-r1 >= currentSeEP || l2-r2 >= currentSeEP)
        {
            real c1 = (r1+l1)*.5;
            real c2 = (r2+l2)*.5;
            if (intersect(line1, ellipse(c1, r2)).length > 0){r1 = c1;}
            else {l1 = c1;}
            if (intersect(line2, ellipse(r1, c2)).length > 0){r2 = c2;}
            else {l2 = c2;}
        }

        d = (r1 + (l-r2))*.5;
        x = (l-r1-r2)*.5;
    }
    
    path pres = (sgnh < 0) ? rotate(180, (d,0))*ellipse((d, 0), x, h) : reverse(rotate(180, (d,0))*ellipse((d, 0), x, h));
    real t1 = 0;
    
	if (lsang1 < l*(1 - defaultSeSN))
    {
        real[] times1 = intersect(pres, line1);
        t1 = (times1.length > 0) ? times1[0] : 0;
    }
    
	pres = reorient(pres, t1);
    real t2 = intersect(pres, (d, 0)--(d+2*x, 0))[0];
    
	if (lsang2 < l*(1 - defaultSeSN))
    {
        real[] times2 = intersect(pres, line2);
        t2 = (times2.length > 0) ? times2[0] : intersect(pres, (d, 0)--(d+2*x, 0))[0];
    }
    
	return map(new path (path p){return shift(p1)*rotate(degrees(p1p2))*p;}, new path[] {subpath(pres, 0, t2), subpath(pres, t2, length(pres))});
}

private pair[][] sectionparams (path g, path h, int n, real r, int p)
// Searches for potential section positions between two given paths using a [clever] algorithm.
{
    pair[] pres;

    if (r < 0)
    {
        if (n == 1)
        { pres = new pair[]{(arctime(g, .5*arclength(g)), arctime(h, .5*arclength(h)))}; }
        else
        {
            real gl = arclength(g)/(n-1);
            real hl = arclength(h)/(n-1);
            pres = sequence(new pair (int i) {
                return (arctime(g, i*gl), arctime(h, i*hl));
            }, n);
        }
    }
    else
    {
        real[] gtimes;
        real[] htimes;

        real rp = r/(1-r);
        real gy = arclength(g)/(n*rp + n - 1);
        real gx = rp*gy;
        real hy = arclength(h)/(n*rp + n - 1);
        real hx = rp*hy;
        for (int i = 0; i < n; ++i)
        {
            gtimes.push(arctime(g, i*(gx+gy)));
            gtimes.push(arctime(g, i*(gx+gy)+gx));
        }
        for (int i = 0; i < n; ++i)
        {
            htimes.push(arctime(h, i*(hx+hy)));
            htimes.push(arctime(h, i*(hx+hy)+hx));
        }

        for (int i = 0; i < 2*n; i += 2)
        {
            real curgtime = gtimes[i];
            real curhtime = htimes[i];
            real optgtime = curgtime;
            real opthtime = curhtime;
            real gtimestep = (gtimes[i+1]-gtimes[i])/p;
            real htimestep = (htimes[i+1]-htimes[i])/p;

            int gi = 0;
            int hi = 0;
            real minval = sectionsymmetryvalue(point(g, curgtime)-point(h, curhtime), dir(g, curgtime), dir(h, curhtime));

            while (true)
            {
                bool changed = false;
                real val;

                if (gi < p && (val = sectionsymmetryvalue(point(g, curgtime+gtimestep)-point(h, curhtime), dir(g, curgtime+gtimestep), dir(h, curhtime))) < minval)
                {
                    curgtime += gtimestep;
                    minval = val;
                    gi += 1;
                    changed = true;
                    optgtime = curgtime;
                    opthtime = curhtime;
                    continue;
                }
                else if (hi == p) break;

                if (hi < p && (val = sectionsymmetryvalue(point(g, curgtime)-point(h, curhtime+htimestep), dir(g, curgtime), dir(h, curhtime+htimestep))) < minval)
                {
                    curhtime += htimestep;
                    minval = val;
                    hi += 1;
                    changed = true;
                    opthtime = curhtime;
                    optgtime = curgtime;
                    continue;
                }
                else if (gi == p) break;

                if (!changed)
                {
                    curgtime += gtimestep;
                    gi += 1;
                    curhtime += htimestep;
                    hi += 1;
                }
            }

            pres.push((optgtime, opthtime));
        }
    }

    return sequence(new pair[] (int i) {
        return new pair[]{point(h, pres[i].y), point(g, pres[i].x), dir(h, pres[i].y), dir(g, pres[i].x)};
    }, pres.length);
}

// -- The structures of the module -- //

usepackage("amssymb"); // LaTeX package for mathematical symbols

struct element
// An 'element' of a set, in a set-theoretical sense.
{
	pair pos;
	string label;
	pair labelalign;

	void operator init (pair pos, string label, pair labelalign)
	{
		this.pos = pos;
		this.label = label;
		this.labelalign = labelalign;
	}

    element move (pair shift, real scale, real rotate, pair point, bool movelabel)
    {
        this.pos = shift(shift)*srap(scale, rotate, point)*this.pos;
		if (movelabel) this.labelalign = rotate(rotate)*this.labelalign;

        return this;
    }

	element copy ()
	{ return element(this.pos, this.label, this.labelalign); }
}

pair operator cast (element elt)
{ return elt.pos; }

private element[] elementcopy (element[] elements)
{ return sequence(new element (int i) { return elements[i].copy(); }, elements.length); }

struct hole
// A cyclic area 'cut out' of a set.
{
    path contour; // The cyclic boundary of the hole.
    pair center; // The center of the hole.
    real[][] sections; // Data related to the positioning of cross sections around the hole.
    int scnumber; // The preferred number of cross sections between this hole and others.

    void operator init (
        path contour,
		pair center = center(contour),
		real[][] sections = {},
		int scnumber = currentSmIHSN,
		pair shift = (0,0),
		real scale = 1,
		real rotate = 0,
		pair point = center,
		bool copy = false
    )
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.sections = sections;
            this.scnumber = scnumber;
        }
        else
        {
            this.contour = shift(shift)*srap(scale, rotate, point)*contour;
            if (!clockwise(this.contour)) this.contour = reverse(this.contour);
            this.center = shift(shift)*srap(scale, rotate, point)*center;
            this.scnumber = scnumber;
            this.sections = new real[][];
            for (int i = 0; i < sections.length; ++i)
            {
                real[] arr = sections[i];
                while (arr.length < currentsection.length) { arr.push(currentsection[arr.length]); }
                this.sections.push(arr);
            }
        }
    }

    hole move (pair shift, real scale, real rotate, pair point, bool movesections)
    // Shift, scale, rotate around a point.
    {
        transform move = shift(shift)*srap(scale, rotate, point);

        this.contour = move*this.contour;
        this.center = move*this.center;
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
    { return hole(this.contour, this.center, copy(this.sections), copy = true); }

    hole replicate (hole h)
    { 
        this.contour = h.contour;
        this.center = h.center;
        this.sections = h.sections;

        return this;
    }
}

private hole[] holecopy (hole[] holes)
{ return sequence(new hole (int i){return holes[i].copy();}, holes.length); }

private path[] holecontours (hole[] h)
{ return sequence(new path (int i){return h[i].contour;}, h.length); }

// private void holeadjust (hole hl, pair shift, real scale, real rotate, pair point)
// { hl.move(shift, scale, rotate, shift(-shift) * point, false); }

struct subset
// A structure representing a subset of a given object (see "smooth")
{
    path contour;
    pair center;
	string label;
    pair labeldir;
    pair labelalign;
	int layer;
	int[] subsets;
	bool isderivative;
	bool isonboundary;

    pair shift;
    real scale;

    real xsize ()
    { return xsize(this.contour); }
    real ysize ()
    { return ysize(this.contour); }

	subset setcenter (pair center)
    { this.center = center; return this; }

    subset move (pair shift, real scale, real rotate, pair point, bool movelabel)
    {
		this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
		this.center = shift(shift)*srap(scale, rotate, point)*this.center;
		if (movelabel) this.labeldir = rotate(rotate)*this.labeldir;

        return this;
    }

	void operator init (
        path contour,
		pair center = center(contour),
		string label = "",
		pair labeldir = defaultSyDP,
		pair labelalign = defaultSyDP,
		int layer = 0,
		bool isderivative = false,
		bool isonboundary = false,
		pair shift = (0,0),
		real scale = 1,
		real rotate = 0,
		pair point = center,
		bool copy = false
    )
    {
        if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
			this.layer = layer;
			this.isderivative = isderivative;
			this.isonboundary = isonboundary;
        }
        else
        {
            this.contour = shift(shift)*srap(scale, rotate, point)*contour;
            if (!clockwise(this.contour)) this.contour = reverse(this.contour);
            this.center = shift(shift)*srap(scale, rotate, point)*center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
			this.layer = layer;
			this.isderivative = isderivative;
			this.isonboundary = isonboundary;
        }
    }
    
	subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign, this.layer, this.isderivative, this.isonboundary, copy = true);
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
		this.isderivative = s.isderivative;
		this.isonboundary = s.isonboundary;
        
        return this;
    }
}

private subset[] subsetcopy (subset[] subsets)
{ return sequence(new subset (int i) { return subsets[i].copy(); }, subsets.length); }

// private void subsetadjust (subset s, pair shift, real scale, real rotate, pair point)
// { s.move(shift, scale, rotate, shift(-shift) * point, true); }

private subset[] subsetintersection (subset sb1, subset sb2, bool inferlabels = currentSmIL)
{
	path[] contours = intersection(sb1.contour, sb2.contour);
	return sequence(new subset (int i){
		return subset(
			contour = contours[i],
			label = (currentSmIL && inferlabels && length(sb1.label) > 0 && length(sb2.label) > 0 && contours.length == 1) ? (sb1.label + " \cap " + sb2.label) : "",
			labeldir = (0,0),
			labelalign = defaultSyDP,
			layer = max(sb1.layer, sb2.layer)+1,
			isderivative = true
		);
	}, contours.length);
}

private void subsetdelete (subset[] subsets, int index, bool recursive)
{
	subset cursb = subsets[index];
	if (recursive)
	{
		for (int i = 0; i < cursb.subsets.length; ++i)
		{ subsetdelete(subsets, cursb.subsets[i], recursive); }
	}
	subsets.delete(index);
	for (int i = 0; i < subsets.length; ++i)
	{
		for (int j = 0; j < subsets[i].subsets.length; ++j)
		{
			if (subsets[i].subsets[j] > index) subsets[i].subsets[j] -= 1;
			if (subsets[i].subsets[j] == index) subsets[i].subsets.delete(j);
		}
	}
}

private int[] subsetgetlayer (subset[] subsets, int[] range, int layer)
{
	int[] res;
	for (int i = 0; i < range.length; ++i)
	{ if (subsets[range[i]].layer == layer) res.push(range[i]); }
	return res;
}

private int[] subsetgetall (subset[] subsets, subset s)
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

private int[] subsetgetall (subset[] subsets, int index)
{ return subsetgetall(subsets, subsets[index]); }

private int[] subsetgetallnot (subset[] subsets, subset s)
{ return difference(sequence(subsets.length), subsetgetall(subsets, s)); }

private int[] subsetgetallnot (subset[] subsets, int index)
{ return difference(sequence(subsets.length), subsetgetall(subsets, index)); }

private void subsetdeepen (subset[] subsets, subset s)
{
	s.layer += 1;
	for (int i = 0; i < s.subsets.length; ++i)
	{ if (s.layer == subsets[s.subsets[i]].layer) subsetdeepen(subsets, subsets[s.subsets[i]]); }
}

private int subsetinsertindex (subset[] subsets, int layer)
{
	int insertindex = subsets.length;
	for (int i = subsets.length-1; i >= 0; --i)
	{
		if (subsets[i].layer >= layer)
		{ insertindex = i; }
	}
	
	return insertindex;
}

private int subsetmaxlayer (subset[] subsets, int[] range)
{
	int res = -1;
	for (int i = 0; i < range.length; ++i)
	{ if (subsets[range[i]].layer > res) res = subsets[range[i]].layer; }
	return res;
}

private void subsetcleanreferences (subset[] subsets)
{
    bool[] visited = array(subsets.length, value = false);

    void clean (int i)
    {
        if (visited[i]) return;
        subset cursb = subsets[i];
        visited[i] = true;

        for (int j = 0; j < cursb.subsets.length; ++j)
        {
            if (cursb.subsets[j] >= subsets.length)
            {
                cursb.subsets.delete(j);
                j -= 1;
                continue;
            }
        }
        
        for (int j = 0; j < cursb.subsets.length; ++j)
        {
            clean(cursb.subsets[j]);
            cursb.subsets = difference(cursb.subsets, subsetgetall(subsets, subsets[cursb.subsets[j]]));
        }
    }

    for (int i = 0; i < subsets.length; ++i) { clean(i); }
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

    // pair shift;
    // real scale;
    // real rotate;

    pair viewdir;
    bool distort;
    smooth[] attached;

	bool shiftsubsets;
    bool isderivative;

    static smooth[] cache;
    
    private static bool repeats (string label)
    {
        if (label == "") return false;
        for (int i = 0; i < cache.length; ++i)
        {
            if (cache[i].label == label) return true;
            for (int j = 0; j < cache[i].subsets.length; ++j)
            { if (cache[i].subsets[j].label == label) return true; }
            for (int j = 0; j < cache[i].elements.length; ++j)
            { if (cache[i].elements[j].label == label) return true; }
        }
        return false;
    }

    // -- Supporting methods -- //

	bool inside (pair x)
	{
		if (!inside(this.contour, x)) return false;
		for (int i = 0; i < this.holes.length; ++i)
		{ if (inside(this.holes[i].contour, x)) return false; }
		return true;
	}

    real xsize ()
    { return xsize(this.contour); }
    real ysize ()
    { return ysize(this.contour); }

    private real getyratio (real y)
    { return (y - ypart(min(this.contour)))/this.ysize(); }

    private real getxratio (real x)
    { return (x - xpart(min(this.contour)))/this.xsize(); }

    private real getypoint (real y)
    { y = y - floor(y); return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y); }

    private real getxpoint (real x)
    { x = x - floor(x); return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x); }

    transform adjust (int index)
    {
        if (index >= 0)
        {
            subset sb = this.subsets[index];
            return shift(sb.center)*scale(size(sb.contour));
        }
        else
        { return shift(this.center)*scale(size(this.contour)); }
    }

    private int findlocalsubsetindex (string label)
    {
        int res = -1;
        bool found = false;
        for (int i = 0; i < this.subsets.length; ++i)
        {
            if (this.subsets[i].label == label)
            {
                if (!currentSyRL) return i;
                if (found) write("> ? More than one local subset with label \"" + label + "\". Returning the last one. [ findlocalsubsetindex() ]");
                found = true;
                res = i;
            }
        }

        if (!found) halt("Could not identify local subset: no subset with label \"" + label + "\". [ findlocalsubsetindex() ]");
        return res;
    }

    private int findlocalelementindex (string label)
    {
        int res = -1;
        bool found = false;
        for (int i = 0; i < this.elements.length; ++i)
        {
            if (this.elements[i].label == label)
            {
                if (!currentSyRL) return i;
                if (found) write("> ? More than one local element with label \"" + label + "\". Returning the last one. [ findlocalelementindex() ]");
                found = true;
                res = i;
            }
        }

        if (!found) halt("Could not identify local element: no element with label \"" + label + "\". [ findlocalelementindex() ]");
        return res;
    }

    // -- Methods for scaling smooth object -- //

    smooth simplemove (
        pair shift = (0,0),
		real scale = 1,
		real rotate = 0,
		pair point = this.center
    ) // Transforms a smooth object as a 2D figure.
    {
		this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;
        this.center = shift(shift)*rotate(rotate, point)*this.center;
        this.labeldir = rotate(rotate)*this.labeldir;
		
		for (int i = 0; i < this.holes.length; ++i)
        { this.holes[i].move(shift, scale, rotate, point, true); }
        for (int i = 0; i < this.subsets.length; ++i)
        { this.subsets[i].move(shift, scale, rotate, point, true); }
        for (int i = 0; i < this.elements.length; ++i)
        { this.elements[i].move(shift, scale, rotate, point, true); }

        return this;
    }

    private void xscale (real s)
    {
        pair center = this.center;
        this.simplemove(shift = -center);
        this.contour = scale(s,1)*this.contour;
        
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
            sb.labeldir = scale(1,s) * sb.labeldir;
		}

        this.simplemove(shift = center);
    }

    private void yscale (real s)
    {
        pair center = this.center;
        this.simplemove(shift = -center);
        this.contour = scale(1,s)*this.contour;
        
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
            sb.labeldir = scale(1,s) * sb.labeldir;
		}
        
		this.simplemove(shift = center);
    }

    smooth dirscale (pair dir, real s)
    // Scale smooth object along the direction given by `dir`.
    {
        if (length(dir) == 0) return this;
		
		real deg = degrees(dir);
        this.simplemove(rotate = -deg);
        this.xscale(s);
        this.simplemove(rotate = deg);
        
		return this;
    }

    // -- Methods for setting the direction of view -- //

    smooth dropview ()
    // Present smooth object under vertical view, not tilted in any direction.
    {
		if (length(this.viewdir) == 0) return this;
        
		if (this.shiftsubsets)
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{
                transform move = shift(-this.viewdir * defaultSmSVS * Sin(defaultSmVA));
                this.subsets[i].contour = move * this.subsets[i].contour;
                this.subsets[i].center = move * this.subsets[i].center;
            }
		}
		if (this.distort) this.dirscale(this.viewdir, 1/Cos(defaultSmVA * length(this.viewdir)));
        this.viewdir = (0,0);

        return this;
    }

    private void setview (pair viewdir)
    // Supporting function to tilt the object as if it were viewed from direction `viewdir`.
    {
		if (viewdir == this.viewdir) return;

        if (this.distort) this.dirscale(viewdir, Cos(defaultSmVA * length(viewdir)));
		if (this.shiftsubsets)
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{
                transform move = shift(viewdir * defaultSmSVS * Sin(defaultSmVA));
                this.subsets[i].contour = move * this.subsets[i].contour;
                this.subsets[i].center = move * this.subsets[i].center;
            }
		}
        this.viewdir = viewdir;
    }

    smooth view (
        explicit pair viewdir,
		bool shiftsubsets = this.shiftsubsets,
        bool distort = this.distort,
		bool drag = true
    ) // User function similar to `setview`, but with extended customization.
    {
		this.shiftsubsets = shiftsubsets;
		this.distort = distort;

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
			{ this.attached[i].view(viewdir, shiftsubsets, drag = true); }
		}

        return this;
    }

	smooth view (
        real angle,
		bool shiftsubsets = this.shiftsubsets,
        bool distort = this.distort,
		bool drag = true
    ) { return this.view(dir(angle), shiftsubsets, distort, drag); }

    // -- Methods for moving smooth object with respect to view direction -- //

    smooth move (
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = this.center,
        bool keepview = true,
        bool drag = true
    ) // Transforms the smooth object. Respects the current `viewdir`.
    {
		if (scale <= 0)
		{ halt("Could not move: scale value must be positive. [ move() ]"); }

		pair viewdir = this.viewdir;
        if (!keepview) this.dropview();
		this.simplemove(shift, scale, rotate, point);    
		if (!keepview) this.setview(viewdir);

        if (!drag) return this;
        for (int i = 0; i < this.attached.length; ++i)
        { this.attached[i].move(shift = shift, scale = scale, rotate = rotate, point = point, keepview = keepview, drag = true); }
		
        return this;
    }

    // -- Methods for setting other object parameters -- //

    smooth setratios (real[] ratios, bool horiz)
    // Controls horizontal (vertical) "ratios" that are used in `cartesian` draw mode.
    {
		if (ratios.length > 0 && ratios[0] == defaultSyDN)
		{
			int count = 0;
			real[] curratios = horiz ? this.hratios : this.vratios;
			while (defaultSmCEM + count*defaultSmCSD < 1 - defaultSmCEM)
			{
				curratios.push(defaultSmCEM + count*defaultSmCSD);
				count += 1;
			}

			return this;
		}
		for (int i = 0; i < ratios.length; ++i)
		{
			if (!inside(0,1, ratios[i]))
			{ halt("Could not set ratios: all entries must lie between 0 and 1. [ setratios() ]"); }
		}

		if (horiz) this.hratios = ratios;
		else this.vratios = ratios;
        
        return this;
    }

    smooth setcenter (
        int index = -1,
		pair center = defaultSyDP,
		bool unit = currentSmU
    ) // Sets the center of the object. The center is used for cross section positioning and arrows.
    {
		if (index == -1)
        {
            if (center == defaultSyDP) center = center(this.contour);
            else if (unit) center = this.adjust(index)*center;
            
            this.center = center;
            
            if (!this.inside(this.center))
            { write("> ? Center out of bounds: might cause problems later. [ setcenter() ]"); }
        }
		else
        {
            subset sb = this.subsets[index];

            if (center == defaultSyDP) center = center(sb.contour);
            else if (unit) center = this.adjust(index)*center;
            
            sb.center = center;
            
            if (!inside(sb.contour, sb.center))
            { write("> ? Center out of bounds: might cause problems later. [ setcenter() ]"); }
        }

        return this;
    }

    smooth setcenter (
        string destlabel,
        pair center,
        bool unit = currentSmU
    ) { return this.setcenter(findlocalsubsetindex(destlabel), center, unit); }

    smooth setlabel (
        int index = -1,
        string label = defaultSyDS,
        pair dir = defaultSyDP,
        pair align = defaultSyDP
    ) // Controls the label of the object, or one of its subsets under `indexpath`.
    {
        if (!currentSyRL)
        {
            void bad () { halt("Coult not assign label: duplicates not allowed. [ setlabel() ]"); }
            for (int i = 0; i < smooth.cache.length; ++i)
            {
                if (smooth.cache[i].label == label) bad();
                for (int j = 0; j < smooth.cache[i].subsets.length; ++j)
                { if (smooth.cache[i].subsets[j].label == label) bad(); }
                for (int j = 0; j < smooth.cache[i].elements.length; ++j)
                { if (smooth.cache[i].elements[j].label == label) bad(); }
            }
        }

		if (index == -1)
		{
            if (label != defaultSyDS) this.label = label;
            if (dir != defaultSyDP) this.labeldir = dir;
            if (align != defaultSyDP) this.labelalign = align;
		}
		else
		{
            subset sb = this.subsets[index];
            if (label != defaultSyDS) sb.label = label;
            if (dir != defaultSyDP) sb.labeldir = dir;
            if (align != defaultSyDP) sb.labelalign = align;
        }

        return this;
    }

    smooth setlabel (
		string destlabel,
        string label,
        pair dir = defaultSyDP,
        pair align = defaultSyDP
    ) { return this.setlabel(findlocalsubsetindex(destlabel), label, dir, align); }

    // -- Methods for manipulating elements -- //

	smooth addelement (
        element elt,
        int index = -1,
		bool unit = currentSmU
    )
	{
        if (!currentSyRL && repeats(elt.label))
        { halt("Could not add element: label \""+elt.label+"\" already assigned. [ addelement() ]"); }
        
        if (unit) { elt.pos = this.adjust(index)*elt.pos; }

		if (!this.inside(elt.pos))
		{ halt("Could not add element: position out of bounds. [ addelement() ]"); }

		this.elements.push(elt);
		return this;
	}

	smooth addelement (
        pair pos,
		string label = "",
		pair align = S,
		bool unit = currentSmU
    )
	{ return this.addelement(element(pos, label, align), unit); }

    smooth setelement (
        int ind,
		element elt,
        int index = -1,
		bool unit = currentSmU
    )
    {
        if (!currentSyRL && repeats(elt.label))
        { halt("Could not set element: label \""+elt.label+"\" already assigned. [ setelement() ]"); }
        
        if (unit) { elt.pos = this.adjust(index)*elt.pos; }

        this.elements[ind] = elt;
        return this;
    }

    smooth setelement (
        int index,
		pair pos = defaultSyDP,
		string label = defaultSyDS,
		pair labelalign = defaultSyDP,
		bool unit = currentSmU
    )
    {
        if (!currentSyRL && repeats(label))
        { halt("Could not set element: label \""+label+"\" already assigned. [ setelement() ]"); }
        
        if (pos != defaultSyDP)
        {
            if (unit) { pos = this.adjust(index)*pos; }
            this.elements[index].pos = pos;
        }

        if (label != defaultSyDS) this.elements[index].label = label;
        if (labelalign != defaultSyDP) this.elements[index].labelalign = labelalign;

        return this;
    }

    smooth setelement (
        string destlabel,
		element elt,
		bool unit = currentSmU
    ) { return this.setelement(findlocalelementindex(destlabel), elt, unit); }

    smooth setelement (
        string destlabel,
		pair pos = defaultSyDP,
		string label = defaultSyDS,
		pair labelalign = defaultSyDP,
		bool unit = currentSmU
    ) { return this.setelement(findlocalelementindex(destlabel), pos, label, labelalign, unit); }

    smooth rmelement (int index)
    {
        this.elements.delete(index);
        return this;
    }

    smooth rmelement (string destlabel)
    { this.elements.delete(findlocalelementindex(destlabel)); return this; }

    smooth movelement (int index, pair shift)
    {
        this.elements[index].pos += shift;
        return this;
    }

    smooth movelement (string destlabel, pair shift)
    { return this.movelement(findlocalelementindex(destlabel), shift); }

    // -- Methods for manipulating holes -- //

    smooth addhole (
        hole hl,
		int index = this.holes.length,
		bool unit = currentSmU
    )
    {
		if (unit)
        {
            transform adjust = this.adjust(-1);
            hl.contour = adjust * hl.contour;
            hl.center = adjust * hl.center;
        }
		if (!insidepath(this.contour, hl.contour))
		{
			currentPrDP.push(hl.contour);
			write("> ? Could not add hole: contour out of bounds. It will be drawn in red on the final picture. [ addhole() ]");
			return this;
		}
		for (int i = 0; i < this.holes.length; ++i)
		{
			if (!outsidepath(this.holes[i].contour, hl.contour))
			{
				currentPrDP.push(hl.contour);
				write("> ? Could not add hole: contour intersecting with other holes. It will be drawn in red on the final picture. [ addhole() ]");
				return this;
			}
		}
		path[][] diff;
        bool[] intersects;
		bool abort = false;
		for (int i = 0; i < this.subsets.length; ++i)
		{
            intersects.push(intersect(this.subsets[i].contour, hl.contour).length > 0);
            if (!intersects[i])
            {
                diff.push(new path[]);
                continue;
            }
			diff.push(difference(this.subsets[i].contour, hl.contour));
			if (diff[i].length != 1)
			{
				abort = true;
				break;
			}
		}
		if (abort)
		{
			currentPrDP.push(hl.contour);
			write("> ? Could not add hole: contour intervening with subsets. It will be drawn in red on the final picture. [ addhole() ]");
			return this;
		}
		else
		{
			for (int i = 0; i < this.subsets.length; ++i)
			{
                if (!intersects[i]) continue;
				this.subsets[i].contour = diff[i][0];
				this.subsets[i].setcenter(center(this.subsets[i].contour));
                this.subsets[i].isonboundary = true;
				// this.subsets[i].setlabel();
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
        }

        this.holes.insert(i = index, hl);
		return this;
    }

    smooth addhole (
        path contour,
        real[][] sections = {},
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center(contour),
        bool unit = currentSmU
    )
    {
		return this.addhole(hole(contour = contour, sections = sections, shift = shift, scale = scale, rotate = rotate, point = point), unit = unit);
	}

	smooth addholes (
        hole[] holes,
		bool unit = currentSmU
    )
	{
		for (int i = 0; i < holes.length; ++i)
		{ this.addhole(holes[i], unit = unit); }
		return this;
	}

	smooth addholes (
        bool unit = currentSmU
        ... hole[] holes
    )
	{ return this.addholes(holes, unit); }

    smooth addholes (
        path[] contours,
        bool unit = currentSmU
    )
    {
        return this.addholes(holes = sequence(new hole (int i) { return hole(contours[i]); }, contours.length), unit = unit);
    }

	smooth addholes (
        bool unit = currentSmU
        ... path[] contours
    )
	{ return this.addholes(contours, unit); }

    smooth rmhole (int index)
    { this.holes.delete(index); return this; }

    smooth rmholes (int[] indices)
    {
        indices = sort(indices);
        for (int i = indices.length-1; i >= 0; i -= 1)
        { this.holes.delete(indices[i]); }
        return this;
    }

    smooth rmholes (... int[] indices)
    { return this.rmholes(indices); }

    smooth movehole (
        int index,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = this.holes[index].center,
        bool movesections = false,
        bool keepview = true
    )
    {
		pair viewdir = this.viewdir;    
		
		if (!keepview) this.dropview();

        transform move = srap(scale, rotate, point) * shift(shift);
        path newcontour = move * this.holes[index].contour;

        bool outofbounds = false;

        if (!insidepath(this.contour, newcontour)) outofbounds = true;
        if (!outofbounds) for (int i = 0; i < this.holes.length; ++i)
        {
            if (i == index) continue;
            if (meet(newcontour, this.holes[i].contour))
            {
                outofbounds = true;
                break;
            }
        }
        if (!outofbounds) for (int i = 0; i < this.subsets.length; ++i)
        {
            if (meet(newcontour, this.subsets[i].contour))
            {
                outofbounds = true;
                break;
            }
        }

        if (outofbounds)
        {
            currentPrDP.push(newcontour);
            write("> ? Could not move hole: new contour out of bounds. It will be drawn in red on the final picture. [ movehole() ]");
            return this;
        }

        hole hl = this.holes[index];
        hl.contour = newcontour;
        hl.center = move * hl.center;
        if (movesections)
        {
            for (int i = 0; i < hl.sections.length; ++i)
            {
                pair sectdir = (hl.sections[i][0], hl.sections[i][1]);
                hl.sections[i][0] = xpart(rotate(rotate)*sectdir);
                hl.sections[i][1] = ypart(rotate(rotate)*sectdir);
            }
        }

		if (!keepview) this.setview(viewdir);

        return this;
    }

    smooth addsection (
        int index,
		real[] section = {},
		bool unit = false
    )
    {
        if (!checksection(section))
        {
            write("> ? Could not add hole section: invalid entries. [ addsection() ]");
            return this;
        }
		for (int i = 2; i < section.length; ++i)
		{ if (section[i] == defaultSyDN) section[i] = currentsection[i]; }
        while (section.length < currentsection.length)
        { section.push(currentsection[section.length]); }
		pair holedir = (this.holes[index].center == this.center) ? (-1,0) : unit(this.holes[index].center - this.center);
		if (section[0] == defaultSyDN || section[1] == defaultSyDN)
		{
			section[0] = holedir.x;
			section[1] = holedir.y;
		}

        this.holes[index].sections.push(section);
        return this;
    }

    smooth setsection (
        int index,
		int ind2 = 0,
		real[] section = {},
		bool unit = false
    )
    {
        while (section.length < currentsection.length)
        { section.push(currentsection[section.length]); }
        if (!checksection(section))
        {
            write("> ? Could not set hole section: invalid entries. [ setsection() ]");
            return this;
        }
        real[] cursection = this.holes[index].sections[ind2];
        int len = min(section.length, cursection.length);
        for (int i = 0; i < len; ++i)
        { if (section[i] != defaultSyDN) cursection[i] = section[i]; }

        return this;
    }

    smooth rmsection (
        int index,
		int ind2 = 0
    ) { this.holes[index].sections.delete(ind2); return this; }

    // -- Methods for manipulating subsets -- //

	smooth addsubset (
        subset sb,
		int index = -1, // the index of parent subset (or the entire smooth object, if index = -1).
        bool inferlabels = currentSmIL, // whether to create intersection labels.
        bool clip = false, // whether to complain if subset is out of bounds, or clip its contour instead.
		bool unit = currentSmU, // whether to fit the subset to the smooth object
        bool checkintersection = true
    ) // Add a subset to the smooth object.
	{
        if (!currentSyRL && repeats(sb.label))
        { halt("Could not add subset: label \""+sb.label+"\" already assigned. [ addsubset() ]"); }
        
		if (unit)
        {
            transform adjust = this.adjust(index);
            sb.contour = adjust * sb.contour;
            sb.center = adjust * sb.center;
        }
		
		if (index == -1)
		{
			int layer = -1;
			int newindex = -1;
            bool found = false;

            void findindex (int i)
            {
                subset cursb = this.subsets[i];
                if (cursb.layer > layer && insidepath(cursb.contour, sb.contour))
                {
                    newindex = i;
                    layer = cursb.layer;
                    for (int j = 0; j < cursb.subsets.length; ++j)
                    {
                        findindex(cursb.subsets[j]);
                        if (found) break;
                    }
                    found = true;
                }
            }

			for (int i = 0; i < this.subsets.length; ++i)
			{
                if (this.subsets[i].layer == 0) findindex(i);
                if (found) return this.addsubset(sb, newindex, inferlabels, clip, false);
			}
		}

        if (sb.subsets.length > 0)
        {
            write("> ? New subset already contains some subset indices. They will be removed. [ addsubset() ]");
            sb.subsets.delete();
        }
		
		path pcontour;
		int[] range;
		subset parent;
		bool sub = index > -1;

		if (sub)
		{
			parent = this.subsets[index];
			sb.layer = parent.layer + 1;
			pcontour = parent.contour;
			range = parent.subsets;
		}
		else
		{
			sb.layer = 0;
			pcontour = this.contour;
			range = subsetgetlayer(this.subsets, sequence(this.subsets.length), 0);
		}

        if (checkintersection && !sub)
        {
            bool meet = false;

            if (!insidepath(pcontour, sb.contour))
            {
                if (clip && meet(pcontour, sb.contour))
                {
                    sb.contour = intersection(pcontour, sb.contour)[0];
                    sb.isonboundary = true;
                    meet = true;
                }
                else
                {
                    currentPrDP.push(sb.contour);
                    write("> ? Could not add subset: contour out of bounds. It will be drawn in red on the final picture. [ addsubset() ]");
                    return this;
                }
            }

			for (int i = 0; i < this.holes.length; ++i)
			{
                if (meet(this.holes[i].contour, sb.contour))
                {
                    if (clip)
                    {
                        sb.contour = difference(sb.contour, this.holes[i].contour)[0];
                        sb.isonboundary = true;
                        meet = true;
                    }
                    else
                    {
                        currentPrDP.push(sb.contour);
                        write("> ? Could not add subset: contour out of bounds. It will be drawn in red on the final picture. [ addsubset() ]");
                        return this;
                    }
                }
				else if (inside(this.holes[i].contour, inside(sb.contour)))
				{
					currentPrDP.push(sb.contour);
					write("> ? Could not add subset: contour contained in a hole. It will be drawn in red on the final picture. [ addsubset() ]");
					return this;
				}
			}

            if (meet) return this.addsubset(sb, index = -2, inferlabels, false, false, false);
        }

        for (int i = 0; i < range.length; ++i)
        {
			if (insidepath(this.subsets[range[i]].contour, sb.contour))
			{
				currentPrDP.push(sb.contour);
				write("> ? Could not add subset: contour is contained in another subset under index "+(string)range[i]+". The contour will be drawn in red on the final picture. [ addsubset() ]");
				return this;
			}
        }

        int insertindex = this.subsets.length;
        int[] intersectionindices = array(this.subsets.length, value = -1);
        this.subsets.push(sb);
        int count = 0;
        bool deepened = false;
        bool terminate = false;

        void intersectwith (int i)
        {
            if (intersectionindices[i] > -1) return;
            if (intersectionindices[i] == -2) return;
            subset cursb = this.subsets[i];

            if (insidepath(sb.contour, cursb.contour))
            {
                deepened = true;
                subsetdeepen(this.subsets, cursb);
                for (int j = 0; j < cursb.subsets.length; ++j)
                { intersectionindices[cursb.subsets[j]] = cursb.subsets[j]; }
                intersectionindices[i] = i;
                return;
            }

            subset[] intersection = subsetintersection(cursb, sb, inferlabels);
            if (intersection.length > 1)
            {
                write("> ? Could not add subset: has disconnected intersection with existing subsets. It will be drawn in red on the final picture. [ addsubset() ]");
                this.subsets.delete(insertindex, this.subsets.length-1);
                subsetcleanreferences(this.subsets);
                terminate = true;
                return;
            }
            if (intersection.length == 0)
            {
                intersectionindices[i] = -2;
                return;
            }
            subset intersectsb = intersection[0];
            for (int j = 0; j < cursb.subsets.length; ++j)
            {
                if (insidepath(this.subsets[cursb.subsets[j]].contour, intersectsb.contour))
                {
                    intersectionindices[i] = -2;
                    return;
                }
            }
            this.subsets.push(intersectsb);
            int intersectindex = this.subsets.length-1;

            bool inside = false;

            for (int j = 0; j < cursb.subsets.length; ++j)
            {
                subset curchild = this.subsets[cursb.subsets[j]];
                if (insidepath(curchild.contour, sb.contour))
                {
                    inside = true;
                }
                
                intersectwith(cursb.subsets[j]);
                int newindex = intersectionindices[cursb.subsets[j]];
                if (newindex > -1) intersectsb.subsets.push(newindex);
            }

            cursb.subsets.push(intersectindex);
            intersectionindices[i] = intersectindex;
        }

        for (int i = 0; i < range.length; ++i)
        {
            if (terminate) return this;
            
            intersectwith(range[i]);
            int newindex = intersectionindices[range[i]];
            if (newindex > -1) sb.subsets.push(newindex);
        }

		if (sub) parent.subsets.push(insertindex);
        subsetcleanreferences(this.subsets);
		return this;
	}

	smooth addsubset (
        int index = -1,
        path contour,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center(contour),
        string label = "",
        pair dir = defaultSyDP,
        pair align = defaultSyDP,
        bool inferlabels = currentSmIL,
        bool clip = false,
        bool unit = currentSmU
    )
    {
        return this.addsubset(sb = subset(contour = contour, label = label, labeldir = dir, labelalign = align, shift = shift, scale = scale, rotate = rotate, point = point), index, inferlabels, clip, unit);
    }

    smooth addsubset (
        string destlabel,
		subset sb,
        bool inferlabels = currentSmIL,
        bool clip = false,
		bool unit = currentSmU
    ) { return this.addsubset(sb, findlocalsubsetindex(destlabel), inferlabels, clip, unit); }

    smooth addsubset (
        string destlabel,
        path contour,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = center(contour),
        string label = "",
        pair dir = defaultSyDP,
        pair align = defaultSyDP,
        bool inferlabels = currentSmIL,
        bool clip = false,
        bool unit = currentSmU
    )
    {
        return this.addsubset(destlabel, sb = subset(contour = contour, label = label, labeldir = dir, labelalign = align, shift = shift, scale = scale, rotate = rotate, point = point), inferlabels, clip, unit);
    }

    smooth addsubsets (
        subset[] sbs,
		int index = -1,
        bool inferlabels = currentSmIL,
        bool clip = false,
		bool unit = currentSmU
    )
    {
        for (int i = 0; i < sbs.length; ++i)
        { this.addsubset(sbs[i], index, inferlabels, clip, unit); }

        return this;
    }

    smooth addsubsets (
        int index = -1,
        bool inferlabels = currentSmIL,
        bool clip = false,
		bool unit = currentSmU
        ... subset[] sbs
    ) { return this.addsubsets(sbs, index, inferlabels, clip, unit); }

    smooth addsubsets (
        int index = -1,
        bool inferlabels = currentSmIL,
        bool clip = false,
        bool unit = currentSmU
        ... path[] contours
    )
    {
        return this.addsubsets(index = index, sbs = sequence(new subset (int i){ return subset(contours[i]); }, contours.length), inferlabels, clip, unit);
    }

    smooth addsubsets (
        string destlabel,
		subset[] sbs,
        bool inferlabels = currentSmIL,
        bool clip = false,
		bool unit = currentSmU
    ) { return this.addsubsets(sbs, findlocalsubsetindex(destlabel), inferlabels, clip, unit); }

    smooth addsubsets (
        string destlabel,
        bool inferlabels = currentSmIL,
        bool clip = false,
        bool unit = currentSmU
        ... subset[] sbs
    ) { return this.addsubsets(destlabel, sbs, inferlabels, clip, unit); }

    smooth addsubsets (
        string destlabel,
        bool inferlabels = currentSmIL,
        bool clip = false,
        bool unit = currentSmU
        ... path[] contours
    )
    {
        return this.addsubsets(destlabel, sbs = sequence(new subset (int i){ return subset(contours[i]); }, contours.length), inferlabels, clip, unit);
    }

	smooth rmsubset (
        int index,
		bool recursive = true
    ) { subsetdelete(this.subsets, index, recursive); return this; }

    smooth rmsubset (
        string destlabel,
		bool recursive = true
    ) { return this.rmsubset(findlocalsubsetindex(destlabel), recursive); }

    smooth rmsubsets (
        int[] indices,
		bool recursive = true
    )
    {
        for (int i = 0; i < indices.length; ++i)
        { this.rmsubset(indices[i], recursive); }
        return this;
    }

    smooth rmsubsets (
        bool recursive = true
        ... int[] indices
    ) { return this.rmsubsets(indices, recursive); }

    smooth rmsubsets (
        string[] destlabels,
		bool recursive = true
    )
    {
        for (int i = 0; i < destlabels.length; ++i)
        { this.rmsubset(destlabels[i], recursive); }
        return this;
    }

    smooth rmsubsets (
        bool recursive = true
        ... string[] destlabels
    ) { return this.rmsubsets(destlabels, recursive); }

    // -- Methods for moving subset globally or within containing subset -- //

	private bool onlyprimary (int index)
	{
		subset s = this.subsets[index];
		
		bool res = true;
		for (int i = 0; i < s.subsets.length; ++i)
		{
			if (this.subsets[s.subsets[i]].isderivative)
			{
				res = false;
				break;
			}
		}

		return res;
	}

	private bool onlysecondary (int index)
	{
		subset s = this.subsets[index];
		
		bool res = true;
		for (int i = 0; i < s.subsets.length; ++i)
		{
			if (!res || !this.subsets[s.subsets[i]].isderivative)
			{
				res = false;
				break;
			}
			res = res && onlysecondary(s.subsets[i]);
		}

		return res;
	}

	smooth movesubset (
        int index,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = defaultSyDP,
        bool movelabel = false,
        bool recursive = true,
        bool bounded = true,
        bool clip = false,
        bool inferlabels = currentSmIL,
        bool keepview = true
    )
	{
		subset cursb = this.subsets[index];
		point = (point == defaultSyDP) ? cursb.center : point;

		if (cursb.isderivative) 
		{
            halt("Could not move subset: subset under index "+(string)index+" is an intersection of subsets. [ movesubset() ]");
        }

        int parentindex = -1;
        int relindex = -1;
        bool found = false;
        if (bounded) for (int i = 0; i < this.subsets.length; ++i)
        {
            subset curparent = this.subsets[i];
            if (curparent.layer != cursb.layer - 1) continue;

            for (int j = 0; j < curparent.subsets.length; ++j)
            {
                if (curparent.subsets[j] == index)
                {
                    parentindex = i;
                    relindex = j;
                    found = true;
                    break;
                }
            }

            if (found) break;
        }

        bool sub = parentindex > -1;
		int[] allsubsets = subsetgetall(this.subsets, cursb);
		path pcontour;
		int[] range; 

		if (sub)
		{
			subset parent = this.subsets[parentindex];
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

        bool onlysecondary = onlysecondary(index);
        bool onlyprimary = onlyprimary(index);
        if (!onlysecondary && !onlyprimary)
        {
            halt("Could not move subset: situation too complicated: both primary and secondary subsets present. [ movesubset() ]");
            return this;
        }

        if (!clip && onlysecondary)
        {
            bool outofbounds = false;

            if (!insidepath(pcontour, newcontour)) outofbounds = true;
            if (!outofbounds) for (int i = 0; i < this.holes.length; ++i)
            {
                if (meet(this.holes[i].contour, newcontour))
                {
                    outofbounds = true;
                    break;
                }
            }

            if (outofbounds)
            {
                currentPrDP.push(newcontour);
                write("> ? Could not move subset: new contour out of bounds. It will be drawn in red on the final picture. [ movesubset() ]");
                return this;
            }
        }

		if (onlysecondary)
		{
			rmsubset(index, recursive = true);
			addsubset(cursb.move(shift, scale, rotate, point, movelabel), inferlabels, clip = clip, unit = false);
			return this;
		}
		if (onlyprimary)
		{
			for (int i = 0; i < range.length; ++i)
			{
				if (range[i] == -1) continue;
				
				if (meet(newcontour, this.subsets[range[i]].contour) || insidepath(newcontour, this.subsets[range[i]].contour) || insidepath(this.subsets[range[i]].contour, newcontour))
				{
					currentPrDP.push(newcontour);
					write("> ? Could not move subset: new contour intersects with other subsets. It will be drawn in red on the final picture. [ movesubset() ]");
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
						currentPrDP.push(newcontour);
						write("> ? Could not move subset: new contour makes existing subsets out-of-bounds. It will be drawn in red on the final picture. [ movesubset() ]");
						return this;
					}
				}

				cursb.move(shift, scale, rotate, point, movelabel);
			}

			return this;
		}

		return this;
	}

    smooth movesubset (
        string destlabel,
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair point = defaultSyDP,
        bool movelabel = false,
        bool recursive = true,
        bool bounded = true,
        bool clip = false,
        bool inferlabels = currentSmIL,
        bool keepview = true
    )
    {
        return this.movesubset(findlocalsubsetindex(destlabel), shift, scale, rotate, point, movelabel, recursive, bounded, clip, inferlabels, keepview);
    }

    // -- Methods for controlling relationships between smooth objects -- //

    smooth attach (smooth sm)
    { this.attached.push(sm); return this; }

	smooth fit (
        int index = -1,
		picture pic = currentpicture,
		picture addpic,
		pair shift = (0,0)
    )
	{
		path contour = (index == -1) ? this.contour : this.subsets[index].contour;
		pair center = (index == -1) ? this.center : this.subsets[index].center;
		addpic = shift(center)*shift(-shift)*addpic;
		clip(addpic, contour);
		pic.add(addpic);

		return this;
	}
    
    // Constructor
    void operator init (
        path contour,
        pair center = center(contour),
        string label = "",
        pair labeldir = N,
        pair labelalign = defaultSyDP,
        hole[] holes = {},
        subset[] subsets = {},
        element[] elements = {},
        real[] hratios = r(defaultSyDN),
        real[] vratios = r(defaultSyDN),
        pair shift = (0,0),
        real scale = 1,
        real rotate = 0,
        pair viewdir = (0,0),
        bool distort = true,
        smooth[] attached = {},
        bool copy = false,
        bool shiftsubsets = currentSmSS,
        bool isderivative = false
    )
    {
		if (copy)
        {
            this.contour = contour;
            this.center = center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;
            this.holes = holecopy(holes);
            this.subsets = subsetcopy(subsets);
            this.hratios = hratios;
            this.vratios = vratios;
            this.viewdir = viewdir;
            this.distort = distort;
			this.attached = attached;
			this.shiftsubsets = shiftsubsets;
            this.isderivative = isderivative;
        }
        else
        {
			if (scale <= 0)
			{ halt("Could not build: scale value must be positive. [ smooth() ]"); }
            
            this.contour = shift(shift)*srap(scale, rotate, center)*((!clockwise(contour)) ? reverse(contour) : contour);
            this.center = shift(shift)*center;
            this.label = label;
            this.labeldir = labeldir;
            this.labelalign = labelalign;

            for (int i = 0; i < holes.length; ++i)
            { addhole(holes[i].move(shift, scale, rotate, center, true), unit = false); }
            for (int i = 0; i < subsets.length; ++i)
            { addsubset(subsets[i].move(shift, scale, rotate, center, true), unit = false); }
            for (int i = 0; i < elements.length; ++i)
            { addelement(elements[i].move(shift, scale, rotate, center, true), unit = false); }

			this.setratios(hratios, true);
			this.setratios(vratios, false);

			this.shiftsubsets = shiftsubsets;
            this.isderivative = isderivative;

            this.distort = distort;
			this.setview(viewdir);
			
			this.attached = attached;
        }

        cache.push(this);
    }

    smooth copy ()
    {
        return smooth(
            contour = this.contour,
            center = this.center,
            label = this.label,
            labeldir = this.labeldir,
            labelalign = this.labelalign,
            holes = holecopy(this.holes),
            subsets = subsetcopy(this.subsets),
            elements = elementcopy(this.elements),
            hratios = this.hratios,
            vratios = this.vratios,
            viewdir = this.viewdir,
            attached = this.attached,
            copy = true
        );
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
        this.viewdir = sm.viewdir;
        this.attached = sequence(new smooth (int i){return sm.attached[i].copy();}, sm.attached.length);

        return this;
    }

    smooth shift (explicit pair shift)
    { return this.move(shift = shift); }

    smooth shift (real xshift, real yshift = 0)
    { return this.move(shift = (xshift, yshift)); }

    smooth scale (real scale)
    { return this.move(scale = scale); }

    smooth rotate (real rotate)
    { return this.move(rotate = rotate); }
}

smooth[] concat (smooth[][] smss)
{
    if (smss.length == 0) return new smooth[];
    if (smss.length == 1) return smss[0];
    smooth[] sms = smss.pop();
    return concat(concat(smss), sms);
}

private int[] findsetindex (string label)
{
    bool found = false;
    int smres;
    int sbres = -1;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        if (smooth.cache[i].label == label)
        {
            if (found) halt("Cannot identify smooth set: ambiguous label \""+label+"\". [ findsetindex() ]");
            found = true;
            if (!currentSyRL) return i(i, -1);
            smres = i;
        }

        for (int j = 0; j < smooth.cache[i].subsets.length; ++j)
        {
            if (smooth.cache[i].subsets[j].label == label)
            {
                if (found) halt("Cannot identify set: ambiguous label \""+label+"\". [ findsetindex() ]");
                found = true;
                if (!currentSyRL) return i(i, j);
                smres = i;
                sbres = j;
            }   
        }
    }

    if (!found) halt("Could not identify set: no object with label \""+label+"\". [ findsetindex() ]");
    return i(smres, sbres);
}

smooth findsm (string label)
{
    int[] indices = findsetindex (label);
    if (indices[1] != -1) halt("Could not identify smooth object: object with label \""+label+"\" is a subset. Use `findsb()` instead. [ findsm() ]");
    return smooth.cache[findsetindex(label)[0]];
}

smooth operator cast (string label)
{ return findsm(label); }

smooth[] operator cast (string[] labels)
{ return sequence(new smooth (int i) { return findsm(labels[i]); }, labels.length); }

subset findsb (string label)
{
    int[] indices = findsetindex (label);
    if (indices[1] == -1) halt("Could not identify subset: object with label \""+label+"\" is not a subset. Use `findsm()` instead. [ findsb() ]");
    return smooth.cache[indices[0]].subsets[indices[1]];
}

private int[] findelementindex (string label)
{
    bool found = false;
    int smres;
    int eltres;

    for (int i = 0; i < smooth.cache.length; ++i)
    {
        for (int j = 0; j < smooth.cache[i].elements.length; ++j)
        {
            if (smooth.cache[i].elements[j].label == label)
            {
                if (found) halt("Cannot identify element: ambiguous label \""+label+"\". [ findsetindex() ]");
                found = true;
                if (!currentSyRL) return i(i, j);
                smres = i;
                eltres = j;
            }   
        }
    }

    if (!found) halt("Could not identify element: no object with label \""+label+"\". [ findsetindex() ]");
    return i(smres, eltres);
}

element findelt (string label)
// 
{
    int[] indices = findelementindex (label);
    if (indices[1] == -1) halt("Could not identify element: object with label \""+label+"\" is not a element. Use `findsm()` instead. [ findsb() ]");
    return smooth.cache[indices[0]].elements[indices[1]];
}

element operator cast (string label)
{ return findelt(label); }

private string repeatstring (string str, int n)
{
	if (n == 0) return "";
	return repeatstring(str, n-1) + str;
}

void print (smooth sm)
// Print information about a given smooth object. Could be useful when drawing the object is too resource-consuming.
{
    string[] msg;
    msg.push("> SMOOTH OBJECT: " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label));
    msg.push("> DIRECTION: " + (string)round(sm.labeldir, 2) + " | ALIGN: " + (sm.labelalign == defaultSyDP ? "[normal]" : (string)round(sm.labelalign, 2)));
    msg.push("> CENTER: " + (string)round(sm.center, 2) + " | VIEW: " + (string)round(sm.viewdir, 2));

    msg.push("");
    msg.push("> HOLES: " + (string)sm.holes.length);
    if (sm.holes.length > 0)
    {
        int holeindexlength = length((string)(sm.holes.length - 1));
        int holecenterlength = max(sequence(
            new int (int i) { return length((string)round(sm.holes[i].center, 2)); },
            sm.holes.length
        ));
        for (int i = 0; i < sm.holes.length; ++i)
        {
            string index = (string)i + repeatstring(" ", holeindexlength - length((string)i));
            string center = (string)round(sm.holes[i].center, 2);
            center = center + repeatstring(" ", holecenterlength - length(center));

            msg.push("| " + index + " | CENTER: " + center + " | SECTIONS: " + (string)sm.holes[i].sections.length);
        }
    }

    msg.push("");
    msg.push("> SUBSETS: " + (string)sm.subsets.length);
    if (sm.subsets.length > 0)
    {
        int subsetindexlength = length((string)(sm.subsets.length - 1));
        int subsetcenterlength = max(sequence(
            new int (int i) { return length((string)round(sm.subsets[i].center, 2)); },
            sm.subsets.length
        ));
        int subsetlabellength = max(sequence(
            new int (int i) {
                if (sm.subsets[i].label == "") return length("[unlabeled]");
                return length(sm.subsets[i].label);
            },
            sm.subsets.length
        ));
        for (int i = 0; i < sm.subsets.length; ++i)
        {
            string index = (string)i + repeatstring(" ", subsetindexlength - length((string)i));
            string center = (string)round(sm.subsets[i].center, 2);
            center = center + repeatstring(" ", subsetcenterlength - length(center));
            string label = sm.subsets[i].label == "" ? "[unlabeled]" : sm.subsets[i].label;
            label = label + repeatstring(" ", subsetlabellength - length(label));
        
            string curmsg = "| " + index + " | CENTER: " + center + " | LABEL: " + label + " | SUBSETS: [";
            for (int j = 0; j < sm.subsets[i].subsets.length; ++j)
            { curmsg += ((string)sm.subsets[i].subsets[j] + (j < sm.subsets[i].subsets.length - 1 ? ", " : "")); }
            curmsg += "]";

            msg.push(curmsg);
        }
    }

    write("");
    string line = repeatstring("-", max(sequence(
        new int (int i) { return length(msg[i]); },
        msg.length
    )));
    write(line);
    for (int i = 0; i < msg.length; ++i)
    { write(msg[i]); }
    write(line);
}

void printall ()
{
    for (int i = 0; i < smooth.cache.length; ++i)
    { print(smooth.cache[i]); }
}

private struct deferredPath
{
    path[] g;
    pen p;
    int[] under;

    arrowhead arrow;
    bool beginarrow;
    bool endarrow;
    
    real barsize;
    bool beginbar;
    bool endbar;

    void operator init (path[] g, pen p, int[] under, arrowhead arrow, bool beginarrow, bool endarrow, real barsize, bool beginbar, bool endbar)
    {
        this.g = g;
        this.p = p;
        this.under = under;
        this.arrow = arrow;
        this.beginarrow = beginarrow;
        this.endarrow = endarrow;
        this.barsize = barsize;
        this.beginbar = beginbar;
        this.endbar = endbar;
    }
}

private deferredPath[][] deferredPaths;
private deferredPath[][] savedDeferredPaths;

private int extractdeferredindex (picture pic)
{
    string[] split;
    if (pic.nodes.length > 0 && (split = split(pic.nodes[0].key, "")).length > 1 && split[0] == defaultSyDS)
    { return (int)split[1]; }
    return -1;
}

private deferredPath[] extractdeferredpaths (picture pic, bool createlink)
{
    deferredPath[] res;
    int ind = extractdeferredindex(pic);
    if (ind >= 0) res =  deferredPaths[ind];
    else if (createlink)
    {
        deferredPaths.push(res);
        pic.nodes.insert(0, node(
            d = new void (frame f, transform t, transform T, pair lb, pair rt) {},
            key = defaultSyDS+" "+(string)(deferredPaths.length-1)
        ));
    }
    return res;
}

private void purgedeferredunder (deferredPath[] curdeferred)
{
    // deferredPath[] curdeferred = extractdeferredpaths(pic, false);
    for (int i = 0; i < curdeferred.length; ++i)
    {
        for (int j = 0; j < curdeferred[i].g.length; ++j)
        {
            if (curdeferred[i].under[j] > 0)
            {
                if (j == 0)
                {
                    curdeferred[i].beginarrow = false;
                    curdeferred[i].beginbar = false;
                }
                if (j == curdeferred[i].g.length-1)
                {
                    curdeferred[i].endarrow = false;
                    curdeferred[i].endbar = false;
                }
                curdeferred[i].g.delete(j);
                curdeferred[i].under.delete(j);
                j -= 1;
            }
        }
    }
}

// -- Default pre-built smooth objects -- //

smooth samplesmooth (int type, int num = 0)
{
    if (type == 0)
    {
        if (num == 0)
        {
            return smooth(
                contour = ucircle,
                hratios = new real[] {.5},
                vratios = r(),
                distort = false
            );
        }
        if (num == 1)
        {
            return smooth(
                contour = defaultPaCC[0]
            ); 
        }
        if (num == 2)
        {
            return smooth(
                contour = rotate(-90)*defaultPaCC[2],
                subsets = new subset[]{
                    subset(
                        contour = defaultPaCC[3],
                        scale = .48,
                        shift = (.13, -.55),
                        labeldir = dir(140)
                    )
                },
                hratios = new real[]{.6, .83},
                vratios = r()
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
                        sections = rr(defaultSyDN, defaultSyDN, 260, defaultSyDN, .35, defaultSyDN),
                        shift = (-.65, .25),
                        scale = .5
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = defaultPaCV[3],
                        labeldir = S,
                        shift = (.43,-.38),
                        scale = .5,
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
						shift = (-.73,-.08),
						scale = .51,
						rotate = -60,
						sections = new real[][]{
							new real[] {-5, -1, 280, 10, .65, 200}
						}
					)
				},
				subsets = new subset[]{
					subset(
						contour = defaultPaCV[6],
						scale = .45,
						rotate = 20,
						shift = (.5,.28)
					)
				}
			);
		}
		if (num == 2)
		{
			return smooth(
				contour = wavypath(2,2,2,2,2, 3.15, 2,2,2),
				holes = new hole[]{
					hole(contour = defaultPaCV[5], scale = .55, shift = (-2,.7), rotate = 10, sections = rr(-5,2,220,7))
				},
				subsets = new subset[]{
					subset(contour = defaultPaCC[3], shift = (-.3,-.35), rotate = -50),
					subset(contour = defaultPaCV[3], scale = .9, rotate = 10, shift = (.3,.5))
				},
                scale = .5,
                shift = (.3,-.1)
			);
		}
    }
    if (type == 2)
    {
        if (num == 0)
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
                        shift = (-.5, -.15),
                        scale = .45,
                        rotate = 15
                    ),
                    hole(
                        contour = defaultPaCV[3],
                        sections = new real[][]{
                            new real[]{defaultSyDN, defaultSyDN, 230, 10}
                        },
                        shift = (.57,.52),
                        scale = .47,
                        rotate = -113
                    )
                }
            );
        }
    }
    if (type == 3)
    {
        if (num == 0)
        {
            return smooth(
                contour = scale(.35)*wavypath(new real[]{4,2,4,2,3.7,2}),
                holes = new hole[]{
                    hole(
                        contour = scale(.35)*defaultPaCV[4],
                        sections = rr(),
                        scale = .75,
                        shift = (.9,.02),
						rotate = 5
                    ),
                    hole(
                        contour = scale(.35)*defaultPaCV[6],
                        sections = rr(),
                        scale = .75,
                        shift = (-.4,-.75)
                    ),
                    hole(
                        contour = scale(.35)*defaultPaCV[5],
                        sections = rr(),
                        scale = .80,
                        shift = (-.35,.6),
						rotate = -20
                    )
                },
                subsets = new subset[]{
                    subset(
                        contour = scale(.35)*defaultPaCV[2],
                        shift = (.05, -.1),
                        scale = .95
                    )
                }
            );
        }
        if (num == 1)
        {
            return smooth(
                contour = defaultPaCC[5],
                holes = new hole[]{
                    hole(
                        contour = defaultPaCV[5],
                        sections = new real[][]{
                            new real[]{3,0, 160, 7}
                        },
                        shift = (.57,-.13),
                        scale = .37,
                        rotate = 90
                    ),
                    hole(
                        contour = reverse(ellipse(c = (0,0), a = 1, b = 2)),
                        sections = new real[][]{
                            new real[]{0,1,190,6}
                        },
                        scnumber = -1,
                        shift = (-.12,.7),
                        scale = .25
                    ),
                    hole(
                        contour = defaultPaCV[6],
                        sections = new real[][]{
                            new real[]{-3,-2, 190, 6}
                        },
                        shift = (-.35,-.43),
                        scale = .32,
                        rotate = 75
                    )
                }
            );
        }
    }

	if (type == 5)
	{
        if (num == 0)
        {
            return smooth(
                contour = wavypath(1.05,2,1.1,2,1.15,2,1.1,2),
                holes = new hole[]{
                    hole(
                        contour = convexpath[4],
                        shift = (-.83,-.85),
                        scale = .4,
                        rotate = 60,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpath[1],
                        shift = (.9,-.8),
                        scale = .38,
                        rotate = -10,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpath[10],
                        shift = (-.9,.92),
                        scale = .35,
                        rotate = 15,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpath[3],
                        shift = (.9,.9),
                        scale = .34,
                        rotate = 70,
                        sections = rr()
                    ),
                    hole(
                        contour = convexpath[2],
                        shift = (-.05,.05),
                        scale = .56
                    )
                }
            );
        }
	}

    halt("Invalid input. [samplesmooth()]");

    return smooth(ucircle);
}

smooth sm (int type, int num = 0) = samplesmooth;

smooth rn (
    int n,
    pair labeldir = (1,1),
    pair shift = (0,0),
    real scale = 1,
    real rotate = 0
) // An alias for the common diagram representation of the n-dimensional Eucledian space.
{
    return smooth(
        contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle,
        label = "\mathbb{R}^" + ((n == -1) ? "n" : (string)n),
        labeldir = (1,1),
        labelalign = (-1.5,-1.5),
        hratios = new real[]{.4},
        vratios = new real[]{.4},
        shift = shift,
        scale = scale,
        rotate = rotate
    );
}

// -- Set operations with smooth objects -- //

// -- Intersections -- //

smooth[] intersection (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    bool addsubsets = currentSmAS
) // Constructs the intersection of two given smooth objects.
{
	path[] contours = intersection(sm1.contour, sm2.contour, round = round, roundcoeff = roundcoeff);
    int initialsize = contours.length;

    if (contours.length == 0)
	{
		write("> ? Smooth objects are not intersecting, so returning an empty array. [ intersection() ]");
		return new smooth[];
	}

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
            if (meet(holes[i], holes[j]) && !htaken[j])
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
		subsets1[i].center = center(curcontours[0]);
        if (meet(subsets1[i].contour, sm2.contour^^holecontours(sm2.holes))) subsets1[i].isonboundary = true;
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
		subsets2[i].center = center(curcontours[0]);
        if (meet(subsets2[i].contour, sm1.contour^^holecontours(sm1.holes))) subsets2[i].isonboundary = true;
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
            isderivative = true,
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

        // pair cursize = max(cursm.contour)-min(cursm.contour);
        // real rsize = min(cursize.x, cursize.y);
        // pair size1 = max(sm1.contour)-min(sm1.contour);
        // real rsize1 = min(size1.x, size1.y);
        // pair size2 = max(sm2.contour)-min(sm2.contour);
        // real rsize2 = min(size2.x, size2.y);

        // int curboundindex = -1;

		cursm.subsets = subsetcopy(subsets1);
            
		for (int i = 0; i < cursm.subsets.length; ++i)
		{
			if (cursm.subsets[i].layer > 0) break;

			if (!inside(cursm.contour, cursm.subsets[i].center))
			{ subsetdelete(cursm.subsets, i, true); }
		}

		bool[] subsetsadded = array(subsets2.length, false);
		bool[] subsets2inside = array(subsets2.length, false);
		void subset2add (int ind, int ind2)
		{
			if (subsetsadded[ind2]) return;

			if (subsets2inside[ind2] || inside(cursm.contour, subsets2[ind2].center))
			{
				cursm.addsubset(subsets2[ind2], ind, unit = false, clip = true, checkintersection = false);
				subsetsadded[ind2] = true;

				for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
				{
					subsets2inside[subsets2[ind2].subsets[i]] = true;
					subset2add(cursm.subsets.length-1, subsets2[ind2].subsets[i]);
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
		{ subset2add(ind = -1, ind2 = i); }

		cursm.setratios(new real[], true);
		cursm.setratios(new real[], false);

		res.push(cursm);
	}

    return res;
}

smooth[] intersection (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    bool addsubsets = currentSmAS
)
{
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
	return res;
}

smooth[] intersection (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    bool addsubsets = currentSmAS
    ... smooth[] sms
) { return intersection(sms, keepdata, round, roundcoeff, addsubsets); }

smooth[] operator ^^ (smooth sm1, smooth sm2)
{ return intersection(sm1, sm2); }

// -- Intersects -- //
 
// smooth intersect (
//     smooth sm1,
//     smooth sm2,
//     bool keepdata = true,
//     bool round = false,
//     real roundcoeff = currentSyRPC,
//     bool addsubsets = currentSmAS
// ) // an alternative to `intersection` that only returns one smooth object.
// {
//     smooth[] intersection = intersection(sm1, sm2, keepdata, round, roundcoeff, addsubsets);
//     if (intersection.length == 0)
//     { halt("Could not intersect: smooth objects do not intersect. [ intersect() ]"); }
//     if (intersection.length > 1)
//     { write("> ? Intersection produced more than one object. Returning only the 0-th one. [ intersect() ]"); }
//     return intersection[0];
// }

smooth intersect (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    bool addsubsets = currentSmAS
)
{
    smooth[] intersection = intersection(sms, keepdata, round, roundcoeff, addsubsets);
    if (intersection.length == 0)
    { halt("Could not intersect: smooth objects do not intersect. [ intersect() ]"); }
    if (intersection.length > 1)
    { write("> ? Intersection produced more than one object. Returning only the 0-th one. [ intersect() ]"); }
    return intersection[0];
}

smooth intersect (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    bool addsubsets = currentSmAS
    ... smooth[] sms
) { return intersect(sms, keepdata, round, roundcoeff, addsubsets); }

smooth operator ^ (smooth sm1, smooth sm2)
{ return intersect(sm1, sm2); }

// -- Unions -- //

smooth[] union (
    smooth sm1,
    smooth sm2,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC
) // Constructs the union of two given smooth objects.
{
    if (!meet(sm1.contour, sm2.contour) && !insidepath(sm1.contour, sm2.contour) && !insidepath(sm2.contour, sm1.contour))
	{ return new smooth[]{sm1, sm2}; }

    path[] union = union(sm1.contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
    path contour; 
    hole[] trueholes = concat(holecopy(sm1.holes), holecopy(sm2.holes));
    path[] holes;
    int[] hrefs;
    bool[] used = array(value = false, sm2.holes.length);
    bool[] diffused = array(value = false, trueholes.length);

    for (int i = 0; i < sm1.holes.length; ++i)
    {
        if (!meet(sm1.holes[i].contour, sm2.contour)) continue;
        path[] diff = difference(sm1.holes[i].contour, sm2.contour, correct = false, round = round, roundcoeff = roundcoeff);
        holes.append(diff);
        hrefs.append(array(value = -1, diff.length));
        diffused[i] = true;
    }
    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if (!meet(sm2.holes[i].contour, sm1.contour)) continue;
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
            if (inside(sm2.contour, sm1.holes[i].center)) continue;
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
                trueholes[i].sections[j] = new real[]{dir(dirang).x, dir(dirang).y, ang, num};
            }
        }
    }

    for (int i = 0; i < sm2.holes.length; ++i)
    {
        if (!used[i] && !diffused[sm1.holes.length + i])
        {
            if (inside(sm1.contour, sm2.holes[i].center)) continue;
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
                
                trueholes[sm1.holes.length+i].sections[j] = new real[]{dir(dirang).x, dir(dirang).y, ang, num};
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
        isderivative = true,
		viewdir = (sm1.viewdir + sm2.viewdir)*.5
    );

    pair cursize = max(res.contour)-min(res.contour);
    real rsize = min(cursize.x, cursize.y);
    pair size1 = max(sm1.contour)-min(sm1.contour);
    real rsize1 = min(size1.x, size1.y);
    pair size2 = max(sm2.contour)-min(sm2.contour);
    real rsize2 = min(size2.x, size2.y);

    for (int i = 0; i < holes.length; ++i)
    {
        // write(hrefs[i]);
        res.addhole((hrefs[i] == -1) ? hole(holes[i], copy = true) : trueholes[hrefs[i]], unit = false);
    }

	res.subsets = subsetcopy(sm1.subsets);
	subset[] subsets2 = subsetcopy(sm2.subsets);
	bool[] subsetsadded = array(subsets2.length, false);
	void subset2add (int ind, int ind2)
	{
		if (subsetsadded[ind2]) return;
		res.addsubset(subsets2[ind2], ind, unit = false);
		subsetsadded[ind2] = true;
		for (int i = 0; i < subsets2[ind2].subsets.length; ++i)
		{ subset2add(res.subsets.length-1, subsets2[ind2].subsets[i]); }
	}
	for (int i = 0; i < subsets2.length; ++i)
	{ subset2add(ind = -1, ind2 = i); }

    return new smooth[]{res};
}

smooth[] union (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC
)
{
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
	return res;
}

smooth[] union (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC
    ... smooth[] sms
) { return union(sms, keepdata, round, roundcoeff); }

smooth[] operator ++ (smooth sm1, smooth sm2)
{ return union(sm1, sm2); }

smooth unite (
    smooth[] sms,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC
) // An alternative to `union` that only returns one smooth object, if there is only one.
{
    smooth[] union = union(sms, keepdata, round, roundcoeff);
    if (union.length > 1) 
    { write("> ? Union produced more than one object. Returning only the 0-th one. [ intersect() ]"); }
    return union[0];
}

smooth unite (
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC
    ... smooth[] sms
) { return union(sms, keepdata, round, roundcoeff)[0]; }

smooth operator + (smooth sm1, smooth sm2)
{ return unite(sm1, sm2); }

smooth tangentspace (
    smooth sm,
    int ind = -1,
    pair center = defaultSyDP,
    real angle,
    real ratio,
    real size = 1,
    real rotate = 45,
    string eltlabel = "x",
    pair eltlabelalign = S
) // Returns a tangent space to `sm` at point determined by `ind`, `dir` and `ratio` //
{
	if (!inside(-1, sm.holes.length-1, ind))
	{ halt("Could not build tangent space: index out of bounds. [ tangentspace() ]"); }
    if (center == defaultSyDP) center = (ind == -1) ? sm.center : sm.holes[ind].center;
	if (!sm.inside(center))
	{ halt("Could not build tangent space: center out of bouds [ tangentspace() ]"); }
	if (!inside(0, 1, ratio))
	{ halt("Could not build tangent space: ratio out of bounds. [ tangentspace() ]"); }

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
        contour = shift(x) * dscale(scale = incline, dir = sgn(ratio) * dir) * scale(size) * rotate(rotate) * usquare,
        label = "T_{"+eltlabel+"}" + sm.label,
        labeldir = dscale(scale = incline, dir = sgn(ratio) * dir) * rotate(rotate) * N
	).view(sm.viewdir);
	sm.attach(res);
	sm.addelement(element(x, eltlabel, eltlabelalign));

	return res;
}

// -- From here starts the collection of the drawing functions provided by the module. -- //

private void fitpath (picture pic, bool overlap, int covermode, bool drawnow, path gs, Label L, pen p, arrowhead arrow, bool beginarrow, bool endarrow, real barsize, bool beginbar, bool endbar)
{
    if (currentSyID && length(L.s) > 0) L.s = "$"+L.s+"$";
    if (length(L.s) > 0) label(pic = pic, gs, L = L, p = p);

    deferredPath[] curdp = extractdeferredpaths(pic, true);

	if (!overlap)
    {
        bool gscyclic = cyclic(gs);

        int under (bool inside, int curunder)
        {
            int res = curunder;
            if (inside)
            {
                if (covermode == 1) { res += 1; }
                else if (covermode == -1) { res = max(0,res-1); }
            }
            return res;
        }

		for (int i = 0; i < curdp.length; ++i)
		{
            path[] g = curdp[i].g;
            path[] newg;
            int[] newunder;
            if (!gscyclic) covermode = 2;
            bool gjcyclic = (g.length == 1) && cyclic(g[0]);

            for (int j = 0; j < g.length; ++j)
            {
                real[] aligntest = intersect(g[j], gs);
                if (aligntest.length == 0)
                {
                    bool inside;
                    if (!gscyclic || !(inside = inside(gs, beginpoint(g[j]))) || covermode < 3)
                    {
                        newg.push(g[j]);
                        newunder.push(under(inside, curdp[i].under[j]));
                    }
                    continue;
                }

                real[][] times = intersections(g[j], gs);

                real[] cuttimes = new real[]{0};
                bool[] skipped = array(2*(times.length+1), value = false);
                real t1;
                real t2;
                real t3 = -1;

                gjcyclic = gjcyclic && cyclic(g[j]);

                for (int k = 0; k < times.length; ++k)
                {
                    pair gjdi = (times[k][0] == floor(times[k][0])) ? dir(g[j], floor(times[k][0]), sign = -1) : dir(g[j], times[k][0]);
                    pair gjdo = (times[k][0] == floor(times[k][0])) ? dir(g[j], floor(times[k][0]), sign = 1) : dir(g[j], times[k][0]);
                    pair gsdi = (times[k][1] == floor(times[k][1])) ? dir(gs, floor(times[k][1]), sign = -1) : dir(gs, times[k][1]);
                    pair gsdo = (times[k][1] == floor(times[k][1])) ? dir(gs, floor(times[k][1]), sign = 1) : dir(gs, times[k][1]);
                    if (sgn(cross(gjdi, gsdi))*sgn(cross(gjdo, gsdo)) <= 0) { continue; }

                    pair gjd = unit(gjdi+gjdo);
                    pair gsd = unit(gsdi+gsdo);
                    
                    real cross = cross(gjd, gsd);
                    real sang = max(abs(cross), .3);
                    t1 = relarctime(g[j], times[k][0], -currentDrGL/sang*.5);
                    t2 = relarctime(g[j], times[k][0], currentDrGL/sang*.5);
                    if (t1 < cuttimes[cuttimes.length-1])
                    {
                        cuttimes[cuttimes.length-1] = t2;
                        if (cuttimes.length > 2) skipped[cuttimes.length-3] = true;
                        if (gjcyclic && t1 < 0 && t3 < 0) t3 = abs(t1);
                        continue;
                    }
                    cuttimes.push(t1);
                    cuttimes.push(t2);
                }

                if (t2 < 0)
                {
                    if (gjcyclic) cuttimes[0] = abs(t2);
                    cuttimes.pop();
                }
                else if (t3 >= 0)
                {
                    if (t3 <= t2) cuttimes.pop();
                    // else cuttimes.insert(cuttimes.length-1, t3);
                    else cuttimes.push(t3);
                }
                else if (cuttimes.length % 2 == 1)
                {
                    if (gjcyclic)
                    { cuttimes[0] = cuttimes.pop(); }
                    else cuttimes.push(length(g[j]));
                }

                bool inside = gscyclic ? inside(gs, point(g[j], cuttimes[0])) : false;
                for (int k = 0; k < cuttimes.length-1; k += 2)
                {   
                    if (!inside || covermode < 3)
                    {
                        newg.push(gjcyclic ? subcyclic(g[j], (cuttimes[k], cuttimes[k+1])) : subpath(g[j], cuttimes[k], cuttimes[k+1]));
                        newunder.push(under(inside, curdp[i].under[j]));
                    }
                    if (!skipped[k]) inside = !inside;
                }
            }

            if (newg.length > 0 || newunder.length > 0)
            {
                if (newg.length > 0 && abs(beginpoint(newg[0]) - beginpoint(g[0])) > currentDrGL)
                {
                    curdp[i].beginarrow = false;
                    curdp[i].beginbar = false;
                }
                if (newg.length > 0 && abs(endpoint(newg[newg.length-1]) - endpoint(g[g.length-1])) > currentDrGL)
                {
                    curdp[i].endarrow = false;
                    curdp[i].endbar = false;
                }
                curdp[i].g = newg;
                curdp[i].under = newunder;
            }
            else
            {
                curdp.delete(i);
                i -= 1;
            }
		}
    }
    if (!drawnow)
    {
        curdp.push(deferredPath(
            g = new path[]{gs},
            p = p,
            under = new int[]{0},
            arrow = arrow,
            beginarrow = beginarrow,
            endarrow = endarrow,
            barsize = barsize,
            beginbar = beginbar,
            endbar = endbar
        ));
    }
    else
    {
        arrowbar truearrow;
        if (beginarrow && endarrow) truearrow = Arrows(arrow);
        else if (beginarrow) truearrow = BeginArrow(arrow);
        else if (endarrow) truearrow = EndArrow(arrow);
        else truearrow = None;
        arrowbar truebar;
        if (beginbar && endbar) truebar = Bars(barsize);
        else if (beginbar) truebar = BeginBar(barsize);
        else if (endbar) truebar = EndBar(barsize);
        else truebar = None;
        draw(pic = pic, gs, p = p, arrow = truearrow, bar = truebar);
    }
}

void fitpath (
    picture pic = currentpicture,
    path g,
    int covermode = 0,
    Label L = "",
    pen p = currentpen,
    bool drawnow = false,
    arrowhead arrow = SimpleHead,
    bool beginarrow = false,
    bool endarrow = false,
    real barsize = 0,
    bool beginbar = false,
    bool endbar = false
) { fitpath(pic, false, covermode, drawnow, g, L, p, arrow, beginarrow, endarrow, barsize, beginbar, endbar); }

void fitpath (
    picture pic = currentpicture,
    path[] g,
    int covermode = 0,
    Label L = "",
    pen p = currentpen,
    bool drawnow = false
)
{
    for (int i = 0; i < g.length; ++i)
    { fitpath(pic, false, covermode, drawnow, g[i], L, p, null, false, false, 0, false, false); }
}

void fillfitpath (
    picture pic = currentpicture,
    path g,
    int covermode = 1,
    Label L = "",
    pen drawpen = currentpen,
    pen fillpen = currentpen,
    bool drawnow = false
)
{
    fill(pic, g, fillpen);
    fitpath(pic, false, covermode, drawnow, g, L, drawpen, null, false, false, 0, false, false);
}

void fillfitpath (
    picture pic = currentpicture,
    path[] g,
    int covermode = 1,
    Label L = "",
    pen drawpen = currentpen,
    pen fillpen = currentpen,
    bool drawnow = false
)
{
    fill(pic, g, fillpen);
    for (int i = 0; i < g.length; ++i)
    { fitpath(pic, false, covermode, drawnow, g[i], L, drawpen, null, false, false, 0, false, false); }
}

private void drawsections (picture pic, pair[][] sections, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
// Renders the circular sections, given an array of control points.
{
    for (int k = 0; k < sections.length; ++k)
    {
		if (sections[k].length > 4) continue;
		if (currentSmMSLR > 0 && length(sections[k][1]-sections[k][0]) > currentSmMSL)
        { continue; }

        path[] section = sectionellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir);
        if (shade && currentDrF && section.length > 1) { fill(pic = pic, section[0]--section[1]--cycle, shadepen); }
		if (section.length > 1 && dash) { draw(pic, section[1], dashpen); }
        draw(pic, section[0], sectionpen);
        if (help)
        {
            dot(pic, point(section[0], arctime(section[0], arclength(section[0])*.5)), red+1);
            dot(pic, sections[k][0], blue+1.5);
            dot(pic, sections[k][1], blue+1);
            draw(pic, sections[k][0] -- sections[k][1], deepgreen + defaultHlLW);
            draw(pic, sections[k][0]-.5*defaultHlAL*scale*sections[k][2] -- sections[k][0]+.5*defaultHlAL*scale*sections[k][2], deepgreen+defaultHlLW, arrow = Arrow(SimpleHead));
            draw(pic, sections[k][1]-.5*defaultHlAL*scale*sections[k][3] -- sections[k][1]+.5*defaultHlAL*scale*sections[k][3], deepgreen+defaultHlLW, arrow = Arrow(SimpleHead));
        }
    }
}

private void drawcartsections (picture pic, path[] g, path[] avoid, real y, bool horiz, pair viewdir, bool dash, bool help, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
// Draw vertical and horizontal cross sections.
{
    drawsections(pic, cartsections(g, avoid, y, horiz), viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);
}

void draw (
    picture pic = currentpicture,
    smooth sm,
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
    bool drawnow = currentDrDN
) // The main drawing function of the module. It renders a given smooth object with substantial customization: all drawing pens can be altered, there are four section-drawing modes available: `free`, `strict`, `cart` and `plain`. The `help` parameter may be tweaked to show auxillary information about the object. Used for debugging. 
{
    // Configuring variables

	if (!inside(0,2, mode))
	{ halt("Invalid mode specified. [ draw() ]"); }

    pair viewdir = Sin(defaultSmVA)*sm.viewdir;
    if (currentSmMSLR > 0) currentSmMSL = currentSmMSLR*min(xsize(sm.contour), ysize(sm.contour));

    path[] holes = holecontours(sm.holes);
    path[] contour = reverse(sm.contour) ^^ holes;
    real scale = size(sm.contour);

    // Filling and drawing main contour

    if (fill) fill(pic = pic, contour, p = smoothfill);
    if (drawcontour)
    {
        for (int i = 0; i < contour.length; ++i)
        {
            fitpath(pic = pic, overlap = overlap || sm.isderivative, covermode = 1-2*sgn(i), drawnow = drawnow, gs = contour[i], L = "", p = contourpen, arrow = null, beginarrow = false, endarrow = false, barsize = 0, beginbar = false, endbar = false);
        }
    }

    // Drawing cross sections

	if (mode == free)
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

				if (help)
				{
					pair hlstart = point(curhlcontour, 0);
					pair hlfinish = point(curhlcontour, length(curhlcontour));
					pair hlvec = defaultHlAR * size(hl.contour) * unit(hlstart - hl.center);
					draw(pic = pic, (hl.center + hlvec) -- hlstart, yellow + defaultHlLW);
					draw(pic = pic, (hl.center + rotate(-hl.sections[j][2])*hlvec) -- hlfinish, yellow + defaultHlLW);
					draw(pic = pic, arc(hl.center, hl.center + hlvec, hlfinish, direction = CW), blue+defaultHlLW);
				}

				drawsections(pic, sectionparams(curhlcontour, cursmcontour, ceil(hl.sections[j][3]), currentSeF, defaultSeP), viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);
			}

            // Drawing sections between holes
            if (currentSmIHSN > 0)
            {   
                for (int j = 0; j < sm.holes.length; ++j)
                {
                    if (holeconnected[i][j] || holeconnected[j][i]) continue;                    

                    if (meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = defaultSmSRC)) || meet(sm.contour, curvedpath(hl.center, sm.holes[j].center, curve = -defaultSmSRC))) continue;
                    
                    bool near = true;
                    for (int k = 0; k < sm.holes.length; ++k)
                    {
                        if (k == i || k == j) continue;

                        if (intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = defaultSmSRC)).length > 0 || intersect(sm.holes[k].contour, curvedpath(hl.center, sm.holes[j].center, curve = -defaultSmSRC)).length > 0)
                        {
                            near = false;
                            break;
                        }
                    }

                    if (!near) continue;

                    hole hl1 = hl;
                    hole hl2 = sm.holes[j];

                    pair hl1times = range(hl1.contour, hl1.center, hl2.center-hl1.center, currentSmIHSA);
                    pair hl2times = range(reverse(hl2.contour), hl2.center, hl1.center-hl2.center, currentSmIHSA, -1);
                    path curhl1contour = subcyclic(hl1.contour, hl1times);
                    path curhl2contour = subcyclic(reverse(hl2.contour), hl2times);

                    if (help)
                    {
                        pair hl1start = point(curhl1contour, 0);
                        pair hl1finish = point(curhl1contour, length(curhl1contour));
                        pair hl2start = point(curhl2contour, 0);
                        pair hl2finish = point(curhl2contour, length(curhl2contour));
                        pair hl1vec = defaultHlAR * size(hl1.contour) * unit(hl1start - hl1.center);
                        pair hl2vec = defaultHlAR * size(hl2.contour) * unit(hl2start - hl2.center);
                        draw(pic, (hl1.center + hl1vec)--hl1start, yellow+defaultHlLW);
                        draw(pic, (hl1.center + rotate(-currentSmIHSA)*hl1vec)--hl1finish, yellow+defaultHlLW);
                        draw(pic, (hl2.center + hl2vec)--hl2start, yellow+defaultHlLW);
                        draw(pic, (hl2.center + rotate(currentSmIHSA)*hl2vec)--hl2finish, yellow+defaultHlLW);
                        draw(pic = pic, arc(hl1.center, hl1.center + hl1vec, hl1finish, direction = CW), blue+defaultHlLW);
                        draw(pic = pic, arc(hl2.center, hl2.center + hl2vec, hl2finish, direction = CCW), blue+defaultHlLW);
                    }

                    drawsections(pic, sectionparams(curhl1contour, curhl2contour, min(currentSmIHSN, abs(min(hl1.scnumber, hl2.scnumber))), currentSeF, defaultSeP), viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);

                    holeconnected[i][j] = true;
                    holeconnected[j][i] = true;
                }
            }
        }
    }
    if (mode == cartesian)
    {
        for (int i = 0; i < sm.hratios.length; ++i)
        {
            drawcartsections(pic, contour, (avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[]{}), sm.hratios[i], true, viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);
        }
        for (int i = 0; i < sm.vratios.length; ++i)
        {
            drawcartsections(pic, contour, (avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[]{}), sm.vratios[i], false, viewdir, dash, help, shade, scale, sectionpen, dashpen, shadepen);
        }
    }

    // Filling and drawing subsets

    if (fill || fillsubsets)
    {
        int maxlayer = subsetmaxlayer(sm.subsets, sequence(sm.subsets.length));
        real penscale = (maxlayer > 0) ? currentDrSPM^(1/maxlayer) : 1;
        pen[] subsetpens = {subsetfill};
        for (int i = 1; i < maxlayer+1; ++i)
        { subsetpens[i] = nextsubsetpen(subsetpens[i-1], penscale); }
        int[] orderindices = sort(sequence(sm.subsets.length), new bool (int i, int j){return sm.subsets[i].layer < sm.subsets[j].layer;});
        for (int i = 0; i < orderindices.length; ++i)
        {
            subset sb = sm.subsets[orderindices[i]];
            fill(pic = pic, sb.contour, subsetpens[sb.layer]);
        }
    }
    if (drawcontour)
    {
        for (int i = 0; i < sm.subsets.length; ++i)
        {
            if (!sm.subsets[i].isderivative)
            {
                fitpath(pic = pic, overlap = overlap || currentDrSCO || sm.subsets[i].isonboundary, covermode = 0, drawnow = drawnow, gs = sm.subsets[i].contour, L = "", p = subsetcontourpen, arrow = null, beginarrow = false, endarrow = false, barsize = 0, beginbar = false, endbar = false);
            }
        }
    }
    
    // Drawing the attached smooth objects

	if (drag)
	{
		for (int i = 0; i < sm.attached.length; ++i)
		{
			draw(pic = pic, sm = sm.attached[i], contourpen = contourpen, smoothfill =  smoothfill + opacity(currentDrDO), subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, help = help, dash = dash, drag = true);
		}
	}

    // Labels and explaination drawings

    for (int i = 0; i < sm.elements.length; ++i)
    {
        element elt = sm.elements[i];
        if (elt.label != "") label(pic = pic, position = elt.pos, L = Label((currentSyID ? ("$"+elt.label+"$") : elt.label), align = elt.labelalign));
        dot(pic = pic, elt.pos, elementpen);
    }
	if (sm.label != "") 
    {
        pair pos = (abs(sm.labeldir) == 0) ? sm.center : intersection(sm.contour, sm.center, sm.labeldir);
        pair align = sm.labelalign;
        if (sm.labelalign == defaultSyDP)
        {
            if (abs(sm.labeldir) == 0) align = (0,0);
            else align = rotate(90)*dir(sm.contour, intersectiontime(sm.contour, sm.center, sm.labeldir));
        }
        label(pic = pic, position = pos, L = Label((currentSyID ? ("$"+sm.label+"$") : sm.label), align = align));
        if (help && abs(sm.labeldir) > 0)
        {
            draw(pic = pic, sm.center -- pos, purple+defaultHlLW);
            draw(pic = pic, pos -- pos+scale*defaultHlAL*align, purple+defaultHlLW, arrow = Arrow(SimpleHead));
        }
    }

    for (int i = 0; i < sm.subsets.length; ++i)
    {
        subset sb = sm.subsets[i];
        if (sb.label != "")
        {
            pair pos = (abs(sb.labeldir) == 0) ? sb.center : intersection(sb.contour, sb.center, sb.labeldir);
            pair align = sb.labelalign;
            if (sb.labelalign == defaultSyDP)
            {
                if (abs(sb.labeldir) == 0) align = (0,0);
                else align = rotate(90)*dir(sb.contour, intersectiontime(sb.contour, sb.center, sb.labeldir));
            }
            label(pic = pic, position = pos, L = Label((currentSyID ? ("$"+sb.label+"$") : sb.label), align = align));
            if (help && abs(sb.labeldir) > 0)
            {
                draw(pic = pic, sb.center -- pos, purple+defaultHlLW);
                draw(pic = pic, pos -- pos+scale*defaultHlAL*align, purple+defaultHlLW, arrow = Arrow(SimpleHead));
            }
        }

        if (help) label(pic = pic, L = Label((string)i, position = sb.center, p = blue));
    }
    if (help)
    {
        draw(pic = pic, sm.center -- sm.center+unit(viewdir)*defaultHlAL, purple+defaultHlLW, arrow = Arrow(SimpleHead));
        dot(pic = pic, sm.center, red+1);
        for (int i = 0; i < sm.holes.length; ++i)
        { label(pic = pic, L = Label((string)i, position = sm.holes[i].center, p = red, filltype = NoFill)); }
        draw(sm.adjust(-1)*unitcircle, blue+defaultHlLW);
    }
}

void draw (
    picture pic = currentpicture,
    smooth[] sms,
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
    bool drawnow = currentDrDN
)
{
	for (int i = 0; i < sms.length; ++i)
	{
		draw(pic = pic, sm = sms[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
}

void draw (
    picture pic = currentpicture,
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
    bool drawnow = currentDrDN
    ... smooth[] sms
)
{
    draw(pic, sms, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, shade, avoidsubsets, drag, overlap, drawnow);
}

void phantom (
    picture pic = currentpicture,
	smooth sm
)
{
	dot(pic, max(sm.contour), invisible);
	dot(pic, min(sm.contour), invisible);
}

smooth[] drawintersect (
    picture pic = currentpicture,
    smooth sm1,
    smooth sm2,
    string label = defaultSyDS,
    pair labeldir = defaultSyDP,
    pair labelalign = defaultSyDP,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    pair shift = (0,0),
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
        bool avoidsubsets = currentSeAS,
        bool shade = currentDrDS,
        bool overlap = currentDrO,
        bool drawnow = currentDrDN,
    pen ghostpen = dashpen(contourpen)
) // Draws the intersection of two smooth objects, as well as their dim contours for comparison
{
	smooth smp1 = sm1.copy().simplemove(shift = shift);
    smooth smp2 = sm2.copy().simplemove(shift = shift);
    
    smooth[] res = intersection(smp1, smp2, keepdata, round, roundcoeff);

    smp1.subsets.delete();
    smp2.subsets.delete();
    smp1.label = "";
    smp2.label = "";
    draw(pic, smp1, contourpen = ghostpen, smoothfill = invisible, mode = plain, help = false);
    draw(pic, smp2, contourpen = ghostpen, smoothfill = invisible, mode = plain, help = false);

    if (res.length == 1)
    { res[0].setlabel(label, labeldir, labelalign); }

    for (int i = 0; i < res.length; ++i)
    {
        draw(pic, res[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, avoidsubsets, shade, overlap, drawnow);
    }

    return res;
}

smooth[] drawintersect (
    picture pic = currentpicture,
    smooth[] sms,
    string label = defaultSyDS,
    pair dir = defaultSyDP,
    pair align = defaultSyDP,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    pair shift = (0,0),
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
        bool avoidsubsets = currentSeAS,
        bool shade = currentDrDS,
        bool overlap = currentDrO,
        bool drawnow = currentDrDN,
    pen ghostpen = dashpen(contourpen)
)
{
	smooth[] smsp = sequence(new smooth (int i){return sms[i].copy().move(shift = shift);}, sms.length);
	smooth[] res = intersection(smsp, keepdata, round, roundcoeff);

	for (int i = 0; i < smsp.length; ++i)
	{
		smsp[i].subsets.delete();
        smsp[i].label = "";
		draw(pic, smsp[i], contourpen = ghostpen, smoothfill = invisible, mode = 3);
	}

    if (res.length == 1)
    { res[0].setlabel(label, dir, align); }

	for (int i = 0; i < res.length; ++i)
	{
        draw(pic, res[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, elementpen, mode, fill, fillsubsets, drawcontour, help, dash, avoidsubsets, shade, overlap, drawnow);
	}

	return res;
}

smooth[] drawintersect (
    picture pic = currentpicture,
    string label = defaultSyDS,
    pair dir = defaultSyDP,
    pair align = defaultSyDP,
    bool keepdata = true,
    bool round = false,
    real roundcoeff = currentSyRPC,
    pair shift = (0,0),
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
        bool avoidsubsets = currentSeAS,
        bool shade = currentDrDS,
        bool overlap = currentDrO,
        bool drawnow = currentDrDN,
    pen ghostpen = dashpen(contourpen)
    ... smooth[] sms
)
{
	return drawintersect(pic, sms, label, dir, align, keepdata, round, roundcoeff, shift, ghostpen, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, fill, fillsubsets, drawcontour, help, dash, avoidsubsets, shade, overlap, drawnow);
}

void drawarrow (
    picture pic = currentpicture,
    smooth sm1,
    int index1 = -1,
    smooth sm2 = sm1,
    int index2 = index1,
    real curve = 0,
    real angle = 0,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    arrowhead arrow = SimpleHead,
    bool beginarrow = false,
    bool endarrow = true,
    real barsize = 0,
    bool beginbar = false,
    bool endbar = false,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN,
    real margin1 = currentArM,
    real margin2 = currentArM
) // Draws an arrow between two given smooth objects, or their subsets.
{
    bool onself = sm2 == sm1 && index1 == index2;

	path g1;
    path g2;
	pair center1;
	pair center2;
	
	if (index1 > -1)
	{
		subset sb1 = sm1.subsets[index1];
		g1 = sb1.contour;
		center1 = sb1.center;
	}
	else
	{
		g1 = sm1.contour;
		center1 = sm1.center;
	}
    if (!onself)
    {
        if (index2 > -1)
        {
            subset sb2 = sm2.subsets[index2];
            g2 = sb2.contour;
            center2 = sb2.center;
        }
        else
        {
            g2 = sm2.contour;
            center2 = sm2.center;
        }
    }
    else center2 = center1;

    path g;

    if (points.length > 0)
    { g = connect(concat(new pair[]{center1}, points, new pair[]{center2})); }
    else if (onself)
    {
        if (radius == defaultSyDN) radius = size(sm1.contour);
        g = cyclepath(center1, angle, radius);
    }
    else
    { g = curvedpath(center1, center2, curve = curve); }
    if (reverse) g = reverse(g);

	real[][] intersection1 = intersections(g, g1);
    real[][] intersection2 = onself ? intersection1 : intersections(g, g2);
	real time1 = arctime(g, margin1);
	real time2 = arctime(g, arclength(g)-margin2);

	if (intersection1.length > 0)
	{ time1 = arctime(g, arclength(g, 0, intersection1[0][0])+margin1); }
	if (intersection2.length > (onself ? 1 : 0))
	{ time2 = arctime(g, arclength(g, 0, intersection2[intersection2.length-1][0])-margin2); }

    path gs = subpath(g, time1, time2);

	fitpath(pic, overlap = overlap, covermode = 0, drawnow = drawnow, gs = gs, L = L, p = p, arrow, beginarrow, endarrow, barsize, beginbar, endbar);
}

void drawarrow (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
    real curve = 0,
    real angle = 0,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    arrowhead arrow = SimpleHead,
    bool beginarrow = false,
    bool endarrow = true,
    real barsize = 0,
    bool beginbar = false,
    bool endbar = false,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN,
    real margin1 = currentArM,
    real margin2 = currentArM
)
{
    int[] indices1 = findsetindex(destlabel1);
    smooth sm1 = smooth.cache[indices1[0]];
    int index1 = indices1[1];
    smooth sm2;
    int index2;
    if (destlabel1 == destlabel2)
    {
        sm2 = sm1;
        index2 = index1;
    }
    else
    {
        int[] indices2 = findsetindex(destlabel2);
        sm2 = smooth.cache[indices2[0]];
        index2 = indices2[1];
    }

    drawarrow(pic, sm1, index1, sm2, index2, curve, angle, radius, points, L, p, arrow, beginarrow, endarrow, barsize, beginbar, endbar, overlap, drawnow, margin1, margin2);
}

void drawmapping (
    picture pic = currentpicture,
    smooth sm1,
    int index1,
    smooth sm2 = sm1,
    int index2 = index1,
    real curve = 0,
    real angle = 0,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    arrowhead arrow = SimpleHead,
    bool beginarrow = false,
    bool endarrow = true,
    real barsize = 0,
    bool beginbar = false,
    bool endbar = false,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN,
    real margin1 = currentArM,
    real margin2 = currentArM
)
{
    bool onself = sm2 == sm1 && index1 == index2;

	pair center1 = sm1.elements[index1].pos;
	pair center2 = onself ? center1 : sm2.elements[index2].pos;

    path g;

    if (points.length > 0)
    { g = connect(concat(new pair[]{center1}, points, new pair[]{center2})); }
    else if (onself)
    {
        if (radius == defaultSyDN) radius = size(sm1.contour);
        g = cyclepath(center1, angle, radius);
    }
    else
    { g = curvedpath(center1, center2, curve = curve); }
    if (reverse) g = reverse(g);

	g = subpath(g, arctime(g, margin1), arctime(g, arclength(g)-margin2));
	fitpath(pic, overlap = overlap, covermode = 0, drawnow = drawnow, gs = g, L = L, p = p, arrow, beginarrow, endarrow, barsize, beginbar, endbar);
}

void drawmapping (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
    real curve = 0,
    real angle = 0,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    arrowhead arrow = SimpleHead,
    bool beginarrow = false,
    bool endarrow = true,
    real barsize = 0,
    bool beginbar = false,
    bool endbar = false,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN,
    real margin1 = currentArM,
    real margin2 = currentArM
)
{
    int[] indices1 = findelementindex(destlabel1);
    smooth sm1 = smooth.cache[indices1[0]];
    int index1 = indices1[1];
    smooth sm2;
    int index2;
    if (destlabel1 == destlabel2)
    {
        sm2 = sm1;
        index2 = index1;
    }
    else
    {
        int[] indices2 = findelementindex(destlabel2);
        sm2 = smooth.cache[indices2[0]];
        index2 = indices2[1];
    }

    drawmapping(pic, sm1, index1, sm2, index2, curve, angle, radius, points, L, p, arrow, beginarrow, endarrow, barsize, beginbar, endbar, overlap, drawnow, margin1, margin2);
}

void drawpath (
    picture pic = currentpicture,
    smooth sm1,
    int index1,
    smooth sm2 = sm1,
    int index2 = index1,
    real range = currentSyRPR,
    real angle = defaultSyDN,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    bool help = currentDrH,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN
)
{
    bool onself = sm2 == sm1 && index1 == index2;

    path gs;

    if (help)
    {
        for (int i = 0; i < points.length; ++i)
        { dot(pic, points[i], elementpen(red)); }
    }
    if (points.length < 2 && onself)
    {
        element elt = sm1.elements[index1];

        if (angle == defaultSyDN)
        { angle = degrees(-elt.labelalign, warn = false); }
        if (radius == defaultSyDN)
        { radius = .05*size(sm1.contour); }

        pair dir1 = randomdir(dir(angle-range), range);
        pair dir2 = -randomdir(dir(angle+range), range);
        
        gs = elt.pos{dir1}..(elt.pos+2*radius*(1+.1*unitrand())*dir(angle))..{dir2}elt.pos;
    }
    else
    {
        pair center1 = sm1.elements[index1].pos;
        pair center2 = sm2.elements[index2].pos;

        points.insert(0, center1);
        points.push(center2);

        gs = randompath(points, range);
    }

    if (reverse) gs = reverse(gs);
    
    fitpath(pic, overlap = overlap, covermode = 0, drawnow = drawnow, gs = gs, L = L, p = p, null, false, false, 0, false, false);
}

void drawpath (
    picture pic = currentpicture,
    string destlabel1,
    string destlabel2 = destlabel1,
    real range = currentSyRPR,
    real angle = defaultSyDN,
    real radius = defaultSyDN,
    bool reverse = false,
    pair[] points = {},
    Label L = "",
    pen p = currentpen,
    bool help = currentDrH,
    bool overlap = currentDrO,
    bool drawnow = currentDrDN
)
{
    int[] indices1 = findelementindex(destlabel1);
    smooth sm1 = smooth.cache[indices1[0]];
    int index1 = indices1[1];
    smooth sm2;
    int index2;
    if (destlabel1 == destlabel2)
    {
        sm2 = sm1;
        index2 = index1;
    }
    else
    {
        int[] indices2 = findelementindex(destlabel2);
        sm2 = smooth.cache[indices2[0]];
        index2 = indices2[1];
    }

    drawpath(pic, sm1, index1, sm2, index2, range, angle, radius, reverse, points, L, p, help, overlap, drawnow);
}

void drawgrid (
    picture pic = currentpicture,
    int places = currentHlGP,
    int number = currentHlGN,
    pair min = pic.userMin2(),
    pair max = pic.userMax2()
)
{
    pair margin = (max - min)*.1;
    if (abs(margin.x) > abs(margin.y)) margin = (margin.y, margin.y);
    else margin = (margin.x, margin.x);
    min -= margin;
    max += margin;
    pair diff = max - min;

    int nx = number, ny = number;
    if (diff.y < diff.x) nx = floor(ny * (diff.x/diff.y));
    else ny = floor(nx * (diff.y/diff.x));

    draw(pic, min -- (min.x,max.y) -- max -- (max.x, min.y) -- cycle, dashpen(linewidth(.2)));

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
        label(pic = pic, position = (x, min.y), L = (string)x, align = S, p = overwrite(MoveQuiet));
        label(pic = pic, position = (x, max.y), L = (string)x, align = N, p = overwrite(MoveQuiet));
        draw(pic = pic, (x, min.y)--(x, max.y), dashpen(linewidth(.2)));
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
        label(pic = pic, position = (min.x, y), L = (string)y, align = W, p = overwrite(MoveQuiet));
        label(pic = pic, position = (max.x, y), L = (string)y, align = E, p = overwrite(MoveQuiet));
        draw(pic = pic, (min.x, y)--(max.x, y), dashpen(currentpen+linewidth(.2)));
    }
}

void drawdeferred (
    picture pic = currentpicture,
	bool flush = true
)
{
    deferredPath[] curdp = extractdeferredpaths(pic, false);
    if (!currentDrDUD)
    { purgedeferredunder(curdp); }

    void auxdraw (deferredPath p)
    {
        unravel p;

        int startind = 0;
        int finishind = g.length-1;
        pen underp = underpen(p);
        if (!beginarrow && !endarrow && !beginbar && !endbar)
        {
            for (int j = startind; j <= finishind; ++j)
            { draw(pic = pic, g[j], p = under[j] > 0 ? underp : p); }
            return;
        }

        if (!beginarrow && !beginbar)
        {
            draw(pic = pic, g[g.length-1], p = under[g.length-1] > 0 ? underp : p, arrow = endarrow ? EndArrow(arrow) : None, bar = endbar ? EndBar(barsize) : None);
            finishind -= 1;
        }
        else if (!endarrow && !endbar)
        {
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = beginarrow ? BeginArrow(arrow) : None, bar = beginbar ? BeginBar(barsize) : None);
            startind += 1;
        }
        else if (g.length > 1)
        {
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = beginarrow ? BeginArrow(arrow) : None, bar = beginbar ? BeginBar(barsize) : None);
            draw(pic = pic, g[g.length-1], p = under[g.length-1] > 0 ? underp : p, arrow = endarrow ? EndArrow(arrow) : None, bar = endbar ? EndBar(barsize) : None);
            startind += 1;
            finishind -= 1;
        }
        else
        {
            arrowbar truearrow;
            if (beginarrow && endarrow) truearrow = Arrows(arrow);
            else if (beginarrow) truearrow = BeginArrow(arrow);
            else if (endarrow) truearrow = EndArrow(arrow);
            else truearrow = None;
            arrowbar truebar;
            if (beginbar && endbar) truebar = Bars(barsize);
            else if (beginbar) truebar = BeginBar(barsize);
            else if (endbar) truebar = EndBar(barsize);
            else truebar = None;
            draw(pic = pic, g[0], p = under[0] > 0 ? underp : p, arrow = truearrow, bar = truebar);
            return;
        }

        for (int j = startind; j <= finishind; ++j)
        { draw(pic = pic, g[j], p = under[j] > 0 ? underp : p); }
    }

    for (int i = 0; i < curdp.length; ++i)
    { auxdraw(curdp[i]); }

    if (flush) curdp.delete();
}

void flushdeferred (
    picture pic = currentpicture
) { extractdeferredpaths(pic, false).delete(); }

// -- Redefining functions to execute `drawdeferred` and `flushdeferred` at call -- //

void plainshipout (
    string prefix=defaultfilename,
    picture pic=currentpicture,
    orientation orntn=orientation,
    string format="",
    bool wait=false,
    bool view=true,
    string options="",
    string script="",
    light lt=currentlight,
    projection P=currentprojection
) = shipout;

private void preshipout (picture pic)
{
    draw(pic = pic, currentPrDP, red+1);
    if (currentDrH)
    { drawgrid(pic, pic.userMin2(), pic.userMax2()); }
}

shipout = new void (
    string prefix=defaultfilename,
    picture pic=currentpicture,
    orientation orntn=orientation,
    string format="",
    bool wait=false,
    bool view=true,
    string options="",
    string script="",
    light lt=currentlight,
    projection P=currentprojection
)
{
    drawdeferred(pic = pic, flush = false);
    preshipout(pic);
    plainshipout(prefix, pic, orntn, format, wait, view, options, script, lt, P);
};

void plainerase (
    picture pic = currentpicture
) = erase;

erase = new void (
    picture pic = currentpicture
)
{
    flushdeferred();
    plainerase(pic);
};

add = new void (
    picture dest,
	picture src,
	bool group=true,
	filltype filltype=NoFill,
	bool above=true
)
{
    drawdeferred(src);
    dest.add(src, group, filltype, above);
};

add = new void (
    picture src,
	bool group=true,
	filltype filltype=NoFill,
	bool above=true
)
{
    drawdeferred(src);
    currentpicture.add(src, group, filltype, above);
};

add = new void (
    picture dest,
	picture src,
	pair position,
	bool group=true,
	filltype filltype=NoFill,
	bool above=true
)
{
    drawdeferred(src);
    add(dest, src.fit(identity()), position, group, filltype, above);
};

picture plainapply (transform t, picture p) { return t*p; }

picture operator * (transform t, picture p)
{
    deferredPath[] curdp = extractdeferredpaths(p, false);
    picture q = plainapply(t,p);
    if (curdp.length > 0)
    {
        for (int i = 0; i < curdp.length; ++i)
        { curdp[i].g = t*curdp[i].g; }
        q.nodes.insert(0, p.nodes[0]);
    }
    return q;
}

void plainsave () { save(); }

void save ()
{
    deferredPath[] curdp = extractdeferredpaths(currentpicture, false);
    savedDeferredPaths.push(copy(curdp));
    plainsave();
};

void plainrestore () { restore(); }

void restore ()
{
    int ind = extractdeferredindex(currentpicture);
    plainrestore();
    if (ind >= 0 && savedDeferredPaths.length > 0)
    {
        deferredPaths[ind] = savedDeferredPaths.pop();
        if (extractdeferredindex(currentpicture) == -1)
        {
            currentpicture.nodes.insert(0, node(
                d = new void (frame f, transform t, transform T, pair lb, pair rt) {},
                key = (string)defaultSyDN+" "+(string)ind
            ));
        }
    }
}
