/*

This is module smoothmanifold. It is designed to construct and render
high-quality Asymptote figures that display sets as 2D or 3D surfaces on the plane.

Copyright (C) 2023 Maksimovich Roman Alekseevich. All rights reserved.

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
private string defaultversion = "v5.0.0-beta";
private real defaultSySN = .000001; // [S]mall [N]umber
private int defaultSyDN = -10000; // [D]ummy [N]umber -- "the program knows what to do with it"
private pair defaultSyDP = (defaultSyDN, defaultSyDN); // [D]ummy [P]air
int dn = defaultSyDN; // shorthand for [d]ummy[n]umber

// [Se]ction
private real defaultSeWT = .65; // [W]idth [T]est
real[] defaultsection = new real[]{defaultSyDN,defaultSyDN,220,7,.8,50};
private int defaultSeNN = 1; // [N]eigh [N]umber
private real defaultSeNA = 25; // [N]eigh [A]ngle
private real defaultSeMLR = .6; // [M]aximum [L]ength [R]atio
private real defaultSeMaEHR = .05; // [Ma]ximal [E]llipse [H]eight
private real defaultSeMiEHR = .00005; // [Mi]nimal [E]llipse [H]eight [R]atio

// [Sm]ooth
private real defaultSmNC = .15; // [Ne]igh [C]urve
private real defaultSmAR = 0.1; // [A]rc [R]atio
private real defaultSmVA = 15; // [V]iew [A]ngle in degrees
private real defaultSmEAL = .2; // [E]xplain [A]rrow [L]ength
private real defaultSmCEM = .07; // [C]art [E]dge [M]argin
private real defaultSmCSD = .1; // [C]art [S]tep [D]istance
private real defaultSmSVS = .28; // [S]ubset [V]iew [S]hift

// [Ar]rows
private real defaultArOL = .065; // [O]verlap [L]ength (see "arrow")
private real defaultArM = defaultArOL*.7; // [M]argin (see "arrow")

// [Dr]awing
private pen defaultDrExP = linewidth(.3); // [E]xplain [P]en
private pen defaultDrSeP = black+linewidth(.4); // [Se]ction [P]en
private pen defaultDrElP = black+linewidth(2.5); // [E]lement [P]en
private real defaultDrShS = .9; // [S]hade [S]cale
private real defaultDrDO = .8; // [D]rag [O]pacity
private real defaultDrSPM = .4; // [S]ubset [P]en [M]ultiplier;
private arrowbar defaultDrBA = None; // [B]egin [A]rrow
private arrowbar defaultDrEA = EndArrow(SimpleHead); // [E]nd [A]rrow
private arrowbar defaultDrBB = None; // [B]egin [B]ar
private arrowbar defaultDrEB = None; // [E]nd [B]ar

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

// -- Current values (subject to change) -- //

// [Se]ction
real[] currentsection = copy(defaultsection);
private int currentSeNN = defaultSeNN;
private real currentSeNA = defaultSeNA;
private real currentSeMLR = defaultSeMLR;
private real currentSeML; // [M]aximum [L]ength
private real currentSeMaEHR; // [Ma]ximum [E]llipse [H]eight [R]atio
private bool currentSeRL = false; // [R]estrict [L]ength
private bool currentSeAS = false; // [A]void [S]ubsets

// [Sm]ooth
bool currentSmIL = true; // [I]nfer [L]abels
bool currentSmSS = true; // [S]hift [S]ubsets

// [Ar]rows
real currentArOL = defaultArOL;
real currentArM = defaultArM;

// [Dr]awing
pen currentDrSeP = defaultDrSeP;
pen currentDrExP = defaultDrExP;
pen currentDrElP = defaultDrElP;
real currentDrShS = defaultDrShS;
real currentDrDO = defaultDrDO;
real currentDrSPM = defaultDrSPM;
int currentDrM = 0; // [M]ode
bool currentDrDD = true; // [D]raw [D]ashes
bool currentDrE = false; // [E]xplain
bool currentDrDS = false; // [D]raw [S]hade
bool currentDrIC = false; // [I]nvert [C]olors
private bool currentDrF = true; // [F]ill
private bool currentDrDC = true; // [D]raw [C]ontour
private bool currentDrO = false; // [O]verlap
private bool currentDrSCO = false; // [S]ubset [C]outour [O]verlap
private bool currentDrDN = false; // [D]raw [N]ow
private arrowbar currentDrBA = defaultDrBA;
private arrowbar currentDrEA = defaultDrEA;
private arrowbar currentDrBB = defaultDrBB;
private arrowbar currentDrEB = defaultDrEB;

// [Pr]ogress
private path[] currentPrDP; // [D]ebug [P]aths

// User variables
pen smoothcolor = lightgrey;
pen subsetcolor = grey;
path[] convexpath = copy(defaultPaCV);
path[] concavepath = copy(defaultPaCC);
int strict = 0;
int free = 1;
int cartesian = 2;
int plain = 3;

// -- Auxiliary utilities -- //

import pathmethods;
// import export;

// -- System functions -- //

private bool checksection (real[] section)
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
string mode (int md)
{
	if (md == 0) return "strict";
	if (md == 1) return "free";
	if (md == 2) return "cartesian";
	if (md == 3) return "plain";
	return "";
}
private real sectionissymmetric (pair p1, pair p2, pair dir1, pair dir2)
{ return abs(dot(unit(dir2), unit(p1-p2))-dot(unit(p2-p1), unit(dir1))); }
private bool sectiontoowide (pair p1, pair p2, pair dir1, pair dir2)
{
    return (min(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) <= -defaultSeWT || max(dot(unit(dir2), unit(p1-p2)), dot(unit(p2-p1), unit(dir1))) >= defaultSeWT);
}
pen inverse (pen p)
{
	real[] colors = colors(p);
	if (colors.length == 1) return gray(1-colors[0])+linewidth(p);
	if (colors.length == 3) return rgb(1-colors[0], 1-colors[1], 1-colors[2])+linewidth(p);
	return invisible;
}
pen nextsubsetpen (pen p, real scale)
{ return scale * p; }
pen dashpen (pen p)
{ return inverse(.5*inverse(p))+dashed; }
pen shadepen (pen p)
{ return inverse(currentDrShS*inverse(p)); }
pen underpen (pen p)
{ return dashpen(p); }

// -- User setting functions -- //

void sectionparams (real[] section = currentsection, int nn = currentSeNN, real na = currentSeNA, real nl = currentSeMLR, bool restrictlength = currentSeRL, bool avoidsubsets = currentSeAS)
{
	if (!checksection(section) || nn < 0 || !inside(0, 180, na))
	{ abort("Could not change default section parameters: invalid intries"); }
	if (nl <= 0)
	{ abort("Could not change default section parameters: section length value must be positive"); }
	for (int i = 0; i < section.length; ++i)
	{ if (section[i] != defaultSyDN) currentsection[i] = section[i]; }
	currentSeNN = nn;
	currentSeNA = na;
	currentSeMLR = nl;
    currentSeRL = restrictlength;
    currentSeAS = avoidsubsets;
}
void inferlabels (bool val) { currentSmIL = val; }
void shiftsubsets (bool val) { currentSmSS = val; }
void arrowparams (real ovlength = defaultArOL, real margin = defaultArM)
{
	currentArOL = ovlength;
	currentArM = margin;
	if (ovlength > 1) write("> ! Value for arrow overlap length looks too big: the result may be ugly.");
}
void drawparams (int mode = currentDrM,
                 pen smoothfill = smoothcolor,
                 pen subsetfill = subsetcolor,
                 real minscale = currentDrSPM,
                 bool overlap = currentDrO,
                 bool subsetoverlap = currentDrSCO,
                 bool drawnow = currentDrDN,
                 bool explain = currentDrE,
                 pen explainpen = currentDrExP,
                 real dragop = currentDrDO,
                 bool dash = currentDrDD,
                 bool shade = currentDrDS,
                 bool fill = currentDrF,
                 pen sectionpen = currentDrSeP,
                 pen elementpen = currentDrElP)
{
	if (!inside(0,3, mode))
	{ abort("Could not set mode: invalid entry provided."); }
	if (!inside(0,1, minscale))
	{ abort("Could not apply changes: subset color scale argument out of range: must be between 0 and 1."); }
	if (!inside(0,1, dragop))
	{ abort("Could not set drag opacity: entry out of bounds: must be between 0 and 1."); }
	currentDrM = mode;
	smoothcolor = smoothfill;
	subsetcolor = subsetfill;
	currentDrSPM = minscale;
    currentDrO = overlap;
    currentDrSCO = subsetoverlap;
	currentDrDN = drawnow;
	currentDrE = explain;
	currentDrExP = explainpen;
	currentDrDO = dragop;
	currentDrDD = dash;
	currentDrDS = shade;
    currentDrF = fill;
	currentDrSeP = sectionpen;
	currentDrElP = elementpen;
}
void drawdebug () { draw(currentPrDP); }
void defaults ()
{
	currentsection = copy(defaultsection);
	currentSeNN = defaultSeNN;
	currentSeNA = defaultSeNA;
	currentSeMLR = defaultSeMLR;
	currentArOL = defaultArOL;
	currentArM = defaultArM;
	currentDrSeP = defaultDrSeP;
	currentDrExP = defaultDrExP;
	currentDrElP = defaultDrElP;
	currentDrShS = defaultDrShS;
	currentDrDO = defaultDrDO;
	currentDrSPM = defaultDrSPM;
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
			if (meet(g[j], curvedpath(presections[i][0], presections[i+1][0], defaultSmNC)) || meet(g[j], curvedpath(presections[i+1][0], presections[i][0], defaultSmNC)))
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
private pair ellipseparams (real l, real h, real cang1, real cang2, bool binsearch)
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
        if (!meet(line1, ellipse(c1, r2))){l1 = c1;}
        else {r1 = c1;}
        if (!meet(line2, ellipse(r1, c2))){l2 = c2;}
        else {r2 = c2;}
    }
    
	return ((l1 + (l-l2))*.5, (l-l1-l2)*.5);
}

private real sectionheight (real x, real max)
{
	real m2 = max/2;
	return (x < m2) ? x : (x - m2)/(1+(2*(x-m2)/max))+m2;
}
private path[] sectionellipse (pair p1, pair p2, pair dir1, pair dir2, pair viewdir, bool free)
// One of the most important technical functions of the module. Constructs an ellipse that touches `dir1` and `dir2` and whose center lies on the segment [p1, p2].
{
	if (length(viewdir) == 0) return new path[]{p1--p2};

    pair p1p2 = unit(p2-p1);
    real l = length(p2-p1);
    
	pair hv = (rotate(90)*p1p2) * cross(p2-p1, viewdir)*.5;
	if (length(hv) == 0) return new path[] {p1--p2};
    real h = sectionheight(length(hv), currentSeMaEHR);
	if (h < defaultSeMiEHR*l) return new path[]{p1--p2};

	if (cross(p1p2, dir1) < 0) dir1 = rotate(180)*dir1;
    if (cross(dir2, -p1p2) < 0) dir2 = rotate(180)*dir2;
    
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
    
	if (tg1 != 0)
    {
        real r1 = abs(h/(tg1 * sqrt(1 + (x/h * tg1)^2)));
        real[] times1 = times(pres, r1);
        t1 = (times1.length == 2) ? times1[1 - floor((sgn(tg1)*sign + 1)*.5)] : 0;
    }
    
	pres = reorient(pres, t1);
    real t2 = intersect(pres, (c, 0)--(c+2*x, 0))[0];
    real tg2 = (abs(cang2) < defaultSySN) ? 0 : sqrt(1 - cang2^2)/cang2;
    
	if (tg2 != 0)
    {
        real r2 = l - abs(h/(tg2 * sqrt(1 + ((l-x)/h * tg2)^2)));
        real[] times2 = times(pres, r2);
        t2 = (times2.length == 2) ? times2[1 - floor((sgn(tg2)*sign + 1)*.5)] : intersect(pres, (c, 0)--(c+2*x, 0))[0];
    }
    
	return map(new path (path p){return shift(p1)*rotate(degrees(p1p2))*p;}, new path[] {subpath(pres, 0, t2), subpath(pres, t2, length(pres))});
}
private pair[][] sectionparamsfree (path g, path h, int p, int step)
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
private pair[][] sectionparamsstrict (path g, path h, int n, real ratio, int p, bool addtimes = false)
// Searches for potential section positions between two given paths using a [clever] algorithm.
{
    real goddstep = arclength(g)/(n + (n-1)*(1 - ratio)/ratio);
    real gevenstep = goddstep*(1-ratio)/ratio;
    real hoddstep = arclength(h)/(n + (n-1)*(1-ratio)/ratio);
    real hevenstep = hoddstep*(1-ratio)/ratio;
    real[] gtimes = new real[];
    for (int i = 0; i < 2*n; ++i)
    {
        if (i % 2 == 0)
        { gtimes.push(arctime(g, i*.5*(goddstep + gevenstep))); }
        else
        { gtimes.push(arctime(g, goddstep*(i+1)*.5 + gevenstep*(i-1)*.5)); }
    }
    real[] htimes = new real[];
    for (int i = 0; i < 2*n; ++i)
    {
        if (i % 2 == 0)
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
        if (addtimes) t  = (gtimes[i], htimes[i]);
        while(gi < p-1 || hi < p-1)
        {
            if (gi < p-1) gcurtime = arctime(g, arclength(g, 0, gcurtime)+garcstep);
            if (hi < p-1) hcurtime = arctime(h, arclength(h, 0, hcurtime)+harcstep);
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
                    if (addtimes) t = (t.x, hcurtime);
                }
            }
            else
            {
                gi += 1;
                if (sectionissymmetric(p1new, p2, dir1new, dir2) < sectionissymmetric(p1, p2, dir1, dir2))
                {
                    p1 = p1new;
                    dir1 = dir1new;
                    if (addtimes) t = (gcurtime, t.y);
                }
            }
        }
        if (addtimes) res.push(new pair[] {p2, p1, dir2, dir1, t});
        else res.push(new pair[] {p2, p1, dir2, dir1});
    }
    return res;
}

// -- The structures of the module -- //

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

private void elementadjust (element elt, pair shift, real scale, real rotate, pair point)
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

private void holeadjust (hole hl, pair shift, real scale, real rotate, pair point)
{ hl.move(shift, scale, rotate, shift(-shift) * point, false); }

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

	void operator init (path contour, pair center = center(contour), string label = "", pair labeldir = defaultSyDP, pair labelalign = S, int layer = 0, int[] subsets = {}, bool isderivative = false, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = center, bool copy = false)
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
			this.isderivative = isderivative;
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
			this.isderivative = isderivative;
        }
    }
    
	subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign, this.layer, copy(this.subsets), this.isderivative, copy = true);
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

private void subsetadjust (subset s, pair shift, real scale, real rotate, pair point)
{ s.move(shift, scale, rotate, shift(-shift) * point, true); }

private subset[] subsetintersection (subset sb1, subset sb2, bool setlabel = currentSmIL)
{
	path[] contours = intersection(sb1.contour, sb2.contour);
	return sequence(new subset (int i){
		return subset(
			contour = contours[i],
			label = (currentSmIL && setlabel && length(sb1.label) > 0 && length(sb2.label) > 0 && contours.length == 1) ? (sb1.label + " \cap " + sb2.label) : "",
			labeldir = rotate(-90)*unit(sb1.center - sb2.center),
			labelalign = setlabel ? 2*(rotate(90)*unit(sb1.center - sb2.center)) : defaultSyDP,
			layer = max(sb1.layer, sb2.layer)+1,
			isderivative = true
		);
	}, contours.length);
}
private void subsetdelete (subset[] subsets, int ind, bool recursive)
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
private void subsetsort (subset[] subsets, int[] range)
{ range = sort(range, new bool (int i, int j){return subsets[i].layer < subsets[j].layer;}); }

private int subsetgetindex (subset[] subsets, int[] ind)
{
	int res = ind[0];
	for (int i = 1; i < ind.length; ++i)
	{ res = subsets[res].subsets[ind[i]]; }
	return res;
}
private int subsetgetindex (subset[] subsets ... int[] ind)
{ return subsetgetindex(subsets, ind); } // try to change later
private subset subsetget (subset[] subsets, int[] ind)
{ return subsets[subsetgetindex(subsets, ind)]; }
private subset subsetget (subset[] subsets ... int[] ind)
{ return subsets[subsetgetindex(subsets, ind)]; }

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
private int[] subsetgetall (subset[] subsets, int ind)
{ return subsetgetall(subsets, subsets[ind]); }
private int[] subsetgetall (subset[] subsets, int[] ind)
{ return subsetgetall(subsets, subsetget(subsets, ind)); }

private int[] subsetgetallnot (subset[] subsets, subset s)
{ return difference(sequence(subsets.length), subsetgetall(subsets, s)); }
private int[] subsetgetallnot (subset[] subsets, int ind)
{ return difference(sequence(subsets.length), subsetgetall(subsets, ind)); }
private int[] subsetgetallnot (subset[] subsets, int[] ind)
{ return difference(sequence(subsets.length), subsetgetall(subsets, ind)); }

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
private int subsetinsert (subset[] subsets, subset s)
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

    for (int i = 0; i < subsets.length; ++i)
    { clean(i); }
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
    bool isderivative;

    // -- System methods -- //

    real xsize () { return xsize(this.contour); }
    real ysize () { return ysize(this.contour); }
    private real getyratio (real y)
    { return (y - ypart(min(this.contour)))/this.ysize(); }
    private real getxratio (real x)
    { return (x - xpart(min(this.contour)))/this.xsize(); }
    private real getypoint (real y)
    {
        y = y - floor(y);
        return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y);
    }
    private real getxpoint (real x)
    {
        x = x - floor(x);
        return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x);
    }
	bool isinside (pair x)
	{
		if (!isinside(this.contour, x)) return false;
		for (int i = 0; i < this.holes.length; ++i)
		{ if (isinside(this.holes[i].contour, x)) return false; }
		return true;
	}

    // -- User functions for manipulating smooth object -- //

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

    // -- User functions for setting the direction of view -- //

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
    private smooth setview (pair viewdir)
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
    smooth view (pair viewdir, bool shiftsubsets = this.shiftsubsets, bool drag = true)
    {
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

        return this;
    }
	smooth view (real angle, bool shiftsubsets = true, bool drag = true)
	{ return this.view(dir(angle), shiftsubsets, drag); }

    // -- User function for moving smooth object with respect to view direction -- //

    smooth move (pair shift = (0,0),
                 real scale = 1,
                 real rotate = 0,
                 pair point = this.center,
                 bool keepview = false,
                 bool drag = true)
    {
		if (scale <= 0)
		{ abort("Could not move: scale value must be positive."); }
		
		this.rotate += rotate;
        this.scale *= scale;
		this.shift += shift + (srap(scale, rotate, point) * this.center - this.center);

		pair viewdir = this.viewdir;
        if (!keepview) this.dropview();
		this.simplemove(shift, scale, rotate, point);    
		if (!keepview) this.setview(viewdir);

        if (!drag) return this;
        for (int i = 0; i < this.attached.length; ++i)
        { this.attached[i].move(shift = shift, scale = scale, rotate = rotate, point = point, keepview = keepview, drag = true); }
		
        return this;
    }

    // -- User function for setting other object parameters -- //

    smooth setratios (real[] ratios, bool horiz)
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
			{ abort("Could not set ratios: all entries must lie between 0 and 1."); }
		}

		if (horiz) this.hratios = ratios;
		else this.vratios = ratios;
        
        return this;
    }
    smooth setcenter (int[] ind = {}, pair center = center(this.contour), bool unit = true)
    {
		if (ind.length == 0) this.center = unit ? shift(this.shift)*center : center;
		else subsetget(this.subsets, ind).setcenter(unit ? shift(this.shift)*center : center);
        
		if (!this.isinside(this.center))
		{ write("> ! Center out of bounds: might cause problems later."); }

        return this;
    }
    smooth setlabel (int[] ind = {},
                     string label = this.label,
                     pair labeldir = this.labeldir,
                     pair labelalign = defaultSyDP,
                     bool keepalign = false)
    {
		if (ind.length == 0)
		{
			this.label = label;
			this.labeldir = labeldir == defaultSyDP ? this.labeldir : labeldir;
			this.labelalign = keepalign ? this.labelalign : (labelalign == defaultSyDP) ? rotate(90)*dir(this.contour, intersectiontime(this.contour, this.center, this.labeldir)) : labelalign;
		}
		else
		{ subsetget(this.subsets, ind).setlabel(label, labeldir, labelalign, keepalign); }

        return this;
    }
    smooth setlabel (int[] ind = {}, string label = this.label, real angle)
    { return this.setlabel(ind, label, dir(angle)); }

    // -- User functions for manipulating elements -- //

    int getelement (string label)
    {
        for (int i = 0; i < this.elements.length; ++i)
        { if (this.elements[i].label == label) return i; }
        write("> ! Could not find element: no element with such label. Returning -1.");
        return -1;
    }
	smooth addelement (element elt, bool unit = true)
	{
		if (unit) elementadjust(elt, this.shift, this.scale, 0, this.center);

		if (!this.isinside(elt.pos))
		{ abort("Could not add element: position out of bounds."); }

		this.elements.push(elt);
		return this;
	}
	smooth addelement (pair pos, string label = "", pair labelalign = S, bool unit = true)
	{ return this.addelement(element(pos, label, labelalign), unit); }
    smooth setelement (int ind, element elt, bool unit = true)
    {
        if (unit) elementadjust(elt, this.shift, this.scale, 0, this.center);
        this.elements[ind] = elt;
        return this;
    }
    smooth setelement (int ind, pair pos, string label = "", pair labelalign = S, bool unit = true)
    { return this.setelement(ind, element(pos, label, labelalign), unit); }
    smooth setelement (string label, element elt, bool unit = true)
    { return this.setelement(this.getelement(label), elt, unit); }
    smooth setelement (string label, pair pos, string newlabel = "", pair labelalign = S, bool unit = true)
    { return this.setelement(this.getelement(label), pos, newlabel, labelalign, unit); }
    smooth rmelement (int ind)
    {
        this.elements.delete(ind);
        return this;
    }
    smooth movelement (int ind, pair shift)
    {
        this.elements[ind].pos += shift;
        return this;
    }
    smooth movelement (string label, pair shift)
    { return this.movelement(this.getelement(label), shift); }

    // -- User functions for manipulating holes -- //

    smooth addhole (hole hl, int ind = this.holes.length, bool unit = true)
    {
		if (unit) holeadjust(hl, this.shift, this.scale, 0, this.center);
		if (!insidepath(this.contour, hl.contour))
		{
			currentPrDP.push(hl.contour);
			write("> ! Could not add hole: contour out of bounds. Call `drawdebug()` in the end to adjust.");
			return this;
		}
		for (int i = 0; i < this.holes.length; ++i)
		{
			if (!outsidepath(this.holes[i].contour, hl.contour))
			{
				currentPrDP.push(hl.contour);
				write("> ! Could not add hole: contour intersecting with other holes. Call `drawdebug()` in the end to adjust.");
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
			currentPrDP.push(hl.contour);
			write("> ! Could not add hole: contour intervening with subsets. Call `drawdebug()` in the end to adjust.");
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
		return this;
    }
    smooth addhole (path contour,
                    real[][] sections = {},
                    pair shift = (0,0),
                    real scale = 1,
                    real rotate = 0,
                    pair point = center(contour),
                    bool unit = true)
    {
		return this.addhole(hole(contour = contour, sections = sections, shift = shift, scale = scale, rotate = rotate, point = point), unit = unit);
	}
	smooth addholes (hole[] holes, bool unit = true)
	{
		for (int i = 0; i < holes.length; ++i)
		{ this.addhole(holes[i], unit = unit); }
		return this;
	}
	smooth addholes (bool unit = true ... hole[] holes)
	{ return this.addholes(holes, unit); }
    smooth addholes (path[] contours,
                     real[][][] sections = {},
                     pair[] shifts = array(contours.length, value = (0,0)),
                     real[] scales = array(contours.length, value = 1),
                     real[] rotates = array(contours.length, value = 0),
                     pair[] points = sequence(new pair(int i){return center(contours[i]);}, contours.length),
                     bool unit = true)
    {
        return this.addholes(holes = sequence(new hole (int i){
            return hole(contour = contours[i], sections = sections[i], shift = shifts[i], scale = scales[i], rotate = rotates[i], point = points[i]);
        }, contours.length), unit = unit);
    }
    smooth addholes (bool unit = true
                     ... path[] contours)
    { return this.addholes(contours = contours, unit = unit); }
    smooth rmhole (int ind)
    {
     	this.holes.delete(ind);
        return this;
    }
    smooth rmholes (int[] inds)
    {
        inds = sort(inds);
        for (int i = inds.length-1; i >= 0; i -= 1)
        { this.holes.delete(inds[i]); }
        return this;
    }
    smooth rmholes (... int[] inds)
    { return this.rmholes(inds); }
    smooth movehole (int ind,
                     pair shift = (0,0),
                     real scale = 1,
                     real rotate = 0,
                     pair point = this.holes[ind].center,
                     bool movesections = false,
                     bool keepview = false)
    {
		pair viewdir = this.viewdir;    
		
		if (!keepview) this.dropview();
		this.holes[ind].move(shift, scale, rotate, point, movesections);
		if (!keepview) this.setview(viewdir);

        return this;
    }
    smooth addholesection (int ind, real[] section = {}, bool unit = false)
    {
		if (!checksection(section))
		{ abort("Could not add section: invalid entries."); }
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
        return this;
    }
    smooth setholesection (int ind, int ind2 = 0, real[] section = {}, bool unit = false)
    {
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
        return this;
    }
    smooth rmholesection (int ind, int ind2 = 0)
    {
        this.holes[ind].sections.delete(ind2);
        return this;
    }

    // -- User functions for manipulating subsets -- //

    int getsubset (string label)
    {
        for (int i = 0; i < this.subsets.length; ++i)
        {
            if (this.subsets[i].label == label) return i;
        }
        write("> ! Could not find subset: no subset with such label. Returning -1.");
        return -1;
    }
	smooth addsubset (subset sb, int[] ind = i(defaultSyDN), bool unit = true)
	{
		if (unit) subsetadjust(sb, this.shift, this.scale, 0, this.center);
		
		if (ind.length > 0 && ind[0] == defaultSyDN)
		{
			int layer = -1;
			int index = -1;
            bool found = false;

            void findindex (int i)
            {
                subset cursb = this.subsets[i];
                if (cursb.layer > layer && insidepath(cursb.contour, sb.contour))
                {
                    index = i;
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
                if (found) return this.addsubset(sb, i(index), false);
			}
            ind = new int[] {};
		}
        if (sb.subsets.length > 0)
        {
            write("> ! New subset already contains some subset indices. They will be removed.");
            sb.subsets.delete();
        }
		
		path pcontour;
		int[] range;
		subset parent;
		bool sub = ind.length > 0;

		if (sub)
		{
			parent = subsetget(this.subsets, ind);
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

		if (!insidepath(pcontour, sb.contour))
		{
			currentPrDP.push(sb.contour);
			write("> ! Could not add subset: contour out of bounds. Call `drawdebug()` in the end to adjust.");
			return this;
		}
		if (!sub)
		{
			for (int i = 0; i < this.holes.length; ++i)
			{
				if (meet(this.holes[i].contour, sb.contour) || isinside(this.holes[i].contour, inside(sb.contour)))
				{
					currentPrDP.push(sb.contour);
					write("> ! Could not add subset: contour out of bounds. Call `drawdebug()` in the end to adjust.");
					return this;
				}
			}
		}

        for (int i = 0; i < range.length; ++i)
        {
			if (insidepath(this.subsets[range[i]].contour, sb.contour))
			{
				currentPrDP.push(sb.contour);
				write("> ! Could not add subset: contour is contained in another subset unlisted in `ind`. Call `drawdebug()` in the end to adjust.");
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

            subset[] intersection = subsetintersection(cursb, sb);
            if (intersection.length > 1)
            {
                write("> ! Could not add subset: has disconnected intersection with existing subsets. Call `drawdebug()` in the end to adjust.");
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
                int ind = intersectionindices[cursb.subsets[j]];
                if (ind > -1) intersectsb.subsets.push(ind);
            }

            cursb.subsets.push(intersectindex);
            intersectionindices[i] = intersectindex;
        }

        for (int i = 0; i < range.length; ++i)
        {
            if (terminate) return this;
            
            intersectwith(range[i]);
            int ind = intersectionindices[range[i]];
            if (ind > -1) sb.subsets.push(ind);
        }

		if (sub) parent.subsets.push(insertindex);
        subsetcleanreferences(this.subsets);
		return this;
	}
	smooth addsubset (int[] ind = i(defaultSyDN),
                      path contour,
                      pair shift = (0,0),
                      real scale = 1,
                      real rotate = 0,
                      pair point = center(contour),
                      bool unit = true)
	{
		return this.addsubset(sb = subset(contour = contour, shift = shift, scale = scale, rotate = rotate, point = point), ind = ind, unit = unit);
	}
    smooth addsubset (string label,
                      subset sb,
                      bool unit = true)
    { return this.addsubset(sb, i(this.getsubset(label)), unit); }
    smooth addsubset (string label,
                      path contour,
                      pair shift = (0,0),
                      real scale = 1,
                      real rotate = 0,
                      pair point = center(contour),
                      bool unit = true)
    { return this.addsubset(i(this.getsubset(label)), contour, shift, scale, rotate, point, unit); }
    smooth addsubsets (subset[] sbs, int[] ind = i(defaultSyDN), bool unit = true)
    {
        for (int i = 0; i < sbs.length; ++i)
        { this.addsubset(sbs[i], ind, unit); }

        return this;
    }
    smooth addsubsets (int[] ind = i(defaultSyDN),
                       bool unit = true
                       ... subset[] sbs)
    { return this.addsubsets(sbs, ind, unit); }
    smooth addsubsets (int[] ind = i(defaultSyDN),
                       path[] contours,
                       pair[] shifts = array(contours.length, value = (0,0)),
                       real[] scales = array(contours.length, value = 1),
                       real[] rotates = array(contours.length, value = 0),
                       pair[] points = sequence(new pair (int i){return center(contours[i]);}, contours.length),
                       bool unit = true)
    {
        return this.addsubsets(sbs = sequence(new subset(int i){
            return subset(contour = contours[i], shift = shifts[i], scale = scales[i], rotate = rotates[i], point = points[i]);
        }, contours.length), ind = ind, unit = unit);
    }
    smooth addsubsets (int[] ind = i(defaultSyDN),
                       bool unit = true
                       ... path[] contours)
    { return this.addsubsets(ind = ind, contours = contours, unit = unit); }
    smooth addsubsets (string label, subset[] sbs, bool unit)
    { return this.addsubsets(sbs, i(this.getsubset(label)), unit); }
    smooth addsubsets (string label,
                       bool unit = true
                       ... subset[] sbs)
    { return this.addsubsets(sbs, i(this.getsubset(label)), unit); }
    smooth addsubsets (string label,
                       path[] contours,
                       pair[] shifts = array(contours.length, value = (0,0)),
                       real[] scales = array(contours.length, value = 1),
                       real[] rotates = array(contours.length, value = 0),
                       pair[] points = sequence(new pair (int i){return center(contours[i]);}, contours.length),
                       bool unit = true)
    { return this.addsubsets(i(this.getsubset(label)), contours, shifts, scales, rotates, points, unit); }
    smooth addsubsets (string label,
                       bool unit = true
                       ... path[] contours)
    { return this.addsubsets(i(this.getsubset(label)), contours = contours, unit = unit); }

	smooth rmsubset (int ind, bool recursive = true)
	{
		subsetdelete(this.subsets, ind, recursive);
		return this;
	}
	smooth rmsubset (int[] ind, bool recursive = true)
	{ return this.rmsubset(subsetgetindex(this.subsets, ind), recursive); }
    smooth rmsubset (string label, bool recursive = true)
    { return this.rmsubset(this.getsubset(label), recursive); }
    smooth rmsubsets (int[] inds, bool recursive = true)
    {
        for (int i = 0; i < inds.length; ++i)
        { this.rmsubset(inds[i], recursive); }
        return this;
    }
    smooth rmsubsets (bool recursive = true ... int[] inds)
    { return this.rmsubsets(inds, recursive); }
    smooth rmsubsets (string[] labels, bool recursive = true)
    { return this.rmsubsets(sequence(new int (int i){return this.getsubset(labels[i]);}, labels.length), recursive); }
    smooth rmsubsets (bool recursive = true ... string[] labels)
    { return this.rmsubsets(labels, recursive); }

    // -- User function for moving subset globally or within containing subset -- //

	private bool onlyprimary (int ind)
	{
		subset s = this.subsets[ind];
		
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
	private bool onlysecondary (int ind)
	{
		subset s = this.subsets[ind];
		
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
	smooth movesubset (int[] ind,
                       pair shift = (0,0),
                       real scale = 1,
                       real rotate = 0,
                       pair point = defaultSyDP,
                       bool movelabel = false,
                       bool recursive = true,
                       bool keepview = false)
	{
		bool sub = ind.length > 1;
		int index = subsetgetindex(this.subsets, ind);
		subset cursb = this.subsets[index];
		point = (point == defaultSyDP) ? cursb.center : point;
		int relindex = ind.pop();
		int[] allsubsets = subsetgetall(this.subsets, cursb);

		if (cursb.isderivative) 
		{ abort("Could not move subset: subset under index "+(string)index+" is an intersection of subsets."); }
		
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
			currentPrDP.push(newcontour);
			write("> ! Could not move subset: new contour out of bounds. Call `drawdebug()` in the end to adjust.");
			return this;
		}

		if (onlysecondary(index))
		{
			rmsubset(index);
			addsubset(cursb.move(shift, scale, rotate, point, movelabel));
			return this;
		}
		if (onlyprimary(index))
		{
			for (int i = 0; i < range.length; ++i)
			{
				if (range[i] == -1) continue;
				
				if (meet(newcontour, this.subsets[range[i]].contour) || insidepath(newcontour, this.subsets[range[i]].contour) || insidepath(this.subsets[range[i]].contour, newcontour))
				{
					currentPrDP.push(newcontour);
					write("> ! Could not move subset: new contour intersects with other subsets. Call `drawdebug()` in the end to adjust.");
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
						write("> ! Could not move subset: new contour makes existing subsets out-of-bounds. Call `drawdebug()` in the end to adjust.");
						return this;
					}
				}

				cursb.move(shift, scale, rotate, point, movelabel);
			}

			return this;
		}

		abort("Could not move subset: situation too complicated: both primary and secondary subsets present.");
		return this;
	}
    smooth movesubset (int ind,
                       pair shift = (0,0),
                       real scale = 1,
                       real rotate = 0,
                       pair point = this.subsets[ind].center,
                       bool movelabel = false,
                       bool recursive = true,
                       bool keepview = false)
    { return this.movesubset(i(ind), shift, scale, rotate, point, movelabel, recursive, keepview); }
    smooth movesubset (string label,
                       pair shift = (0,0),
                       real scale = 1,
                       real rotate = 0,
                       pair point = this.subsets[this.getsubset(label)].center,
                       bool movelabel = false,
                       bool recursive = true,
                       bool keepview = false)
    { return this.movesubset(this.getsubset(label), shift, scale, rotate, point, movelabel, recursive, keepview); }

    // -- User functions for controlling relationships between smooth objects -- //

    smooth attach (smooth sm)
    {
        this.attached.push(sm);
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
    
    // Constructor
    void operator init (path contour,
                        pair center = center(contour),
                        string label = "",
                        pair labeldir = N,
                        pair labelalign = defaultSyDP,
                        hole[] holes = {},
                        subset[] subsets = {},
                        real[] hratios = a(defaultSyDN),
                        real[] vratios = a(defaultSyDN),
                        pair shift = (0,0),
                        real scale = 1,
                        real rotate = 0,
                        pair viewdir = (0,0),
                        smooth[] attached = {},
                        bool unit = true,
                        bool copy = false,
                        bool shiftsubsets = currentSmSS,
                        bool isderivative = false)
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
            this.isderivative = isderivative;
        }
        else
        {
			if (scale <= 0)
			{ abort("Could not build: scale value must be positive."); }
            
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
            { addsubset(subsets[i], unit = unit); }

			this.setratios(hratios, true);
			this.setratios(vratios, false);

			this.shiftsubsets = shiftsubsets;
            this.isderivative = isderivative;

			this.setview(viewdir);
			
			this.attached = attached;
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
    { return this.contour == nullpath; }
}

void print (smooth sm)
{
    write("--- Smooth object ---");
    write("LABEL: " + ((length(sm.label) == 0) ? "[unlabeled]" : sm.label) + "  |  DIRECTION: ~" + (string)round(sm.labeldir, 2) + "  |  ALIGN: ~" + (string)round(sm.labelalign, 2));
    write("CENTER: ~" + (string)round(sm.center, 2));
    write("VIEW: ~" + (string)round(sm.viewdir, 2));
    write("HOLES: " + (string)sm.holes.length);

    write("SUBSETS: " + (string)sm.subsets.length);
}

smooth nullsmooth;

private struct pathinfo
{
    path[] g;
    pen p;
    bool under;
    arrowbar beginarrow;
    arrowbar endarrow;
    arrowbar beginbar;
    arrowbar endbar;

    void operator init (path[] g, pen p, bool under, arrowbar beginarrow = None, arrowbar endarrow = None, arrowbar beginbar = None, arrowbar endbar = None)
    {
        this.g = g;
        this.p = p;
        this.under = under;
        this.beginarrow = beginarrow;
        this.endarrow = endarrow;
        this.beginbar = beginbar;
        this.endbar = endbar;
    }
}

private pathinfo[] currentdrawn;
private pathinfo[] currentsaved;

// -- Default pre-built smooth objects -- //

smooth samplesmooth (int type = 0, int num = 0)
{
    if (type == 0)
    {
        if (num == 0)
        {
            return smooth(
                contour = defaultPaCV[0],
                hratios = new real[] {.5},
                vratios = a()
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
                hratios = new real[]{.6, .83},
                vratios = a()
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
					hole(contour = defaultPaCV[5], scale = .55, shift = (-2,.7), rotate = 10, sections = aa(-4,2,200,7))
				},
				subsets = new subset[]{
					subset(contour = defaultPaCC[3], shift = (-.3,-.35), rotate = -50),
					subset(contour = defaultPaCV[3], scale = .9, rotate = 10, shift = (.3,.5))
				}
			);
		}
    }
    if (type == 2)
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
    if (type == 3)
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

	if (type == 5)
	{
		return smooth(
			contour = wavypath(1.05,2,1.1,2,1.15,2,1.1,2),
			holes = new hole[]{
				hole(
					contour = convexpath[4],
					shift = (-.83,-.85),
					scale = .4,
					rotate = 60,
					sections = aa()
				),
				hole(
					contour = convexpath[1],
					shift = (.9,-.8),
					scale = .38,
					rotate = -10,
					sections = aa()
				),
				hole(
					contour = convexpath[10],
					shift = (-.9,.92),
					scale = .35,
					rotate = 15,
					sections = aa()
				),
				hole(
					contour = convexpath[3],
					shift = (.9,.9),
					scale = .34,
					rotate = 70,
					sections = aa()
				),
				hole(
					contour = convexpath[2],
					shift = (-.05,.05),
					scale = .56
				)
			}
		);
	}

    return smooth(ucircle);
}

smooth rn (int n, pair labeldir = (1,1), pair shift = (0,0), real scale = 1, real rotate = 0)
// an alias for the comman diagram representation of the n-dimensional Eucledian space.
{
    return smooth(contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle,
                  label = "\mathbb{R}^" + ((n == -1) ? "n" : (string)n),
                  labeldir = (1,1),
                  labelalign = (-1,-1.5),
                  hratios = new real[]{.4},
                  vratios = new real[]{.4},
                  shift = shift,
                  scale = scale,
                  rotate = rotate);
}

// -- Set operations with smooth objects -- //

smooth[] intersection (smooth sm1,
                       smooth sm2,
                       bool keepdata = true,
                       bool round = false,
                       real roundcoeff = currentSyRR,
                       bool addsubsets = false)
// Constructs the intersection of two given smooth objects.
{
	path[] contours = intersection(sm1.contour, sm2.contour, round = round, roundcoeff = roundcoeff);
    int initialsize = contours.length;

    if (contours.length == 0)
	{
		write("> ! Smooth objects are not intersecting, so returning an empty array.");
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

    return res;
}
smooth[] intersection (smooth[] sms,
                       bool keepdata = true,
                       bool round = false,
                       real roundcoeff = currentSyRR,
                       bool addsubsets = false)
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

smooth[] intersection (bool keepdata = true,
                       bool round = false,
                       real roundcoeff = currentSyRR,
                       bool addsubsets = false
                       ... smooth[] sms)
{ return intersection(sms, keepdata, round, roundcoeff, addsubsets); }

smooth intersect (smooth sm1,
                  smooth sm2,
                  bool keepdata = true,
                  bool round = false,
                  real roundcoeff = currentSyRR,
                  bool addsubsets = false)
{ return intersection(sm1, sm2, keepdata, round, roundcoeff)[0]; }

smooth intersect (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = currentSyRR)
{ return intersection(sms, keepdata, round, roundcoeff)[0]; }

smooth intersect (bool keepdata = true, bool round = false, real roundcoeff = currentSyRR ... smooth[] sms)
{ return intersection(sms, keepdata, round, roundcoeff)[0]; }

smooth[] union (smooth sm1, smooth sm2, bool keepdata = true, bool round = false, real roundcoeff = currentSyRR)
// Constructs the union of two given smooth objects. //
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
        isderivative = true,
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

    return new smooth[]{res};
}
smooth[] union (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = currentSyRR)
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
smooth[] union (bool keepdata = true, bool round = false, real roundcoeff = currentSyRR ... smooth[] sms)
{ return union(sms, keepdata, round, roundcoeff); }

smooth unite (smooth[] sms, bool keepdata = true, bool round = false, real roundcoeff = currentSyRR)
{ return union(sms, keepdata, round, roundcoeff)[0]; }

smooth unite (bool keepdata = true, bool round = false, real roundcoeff = currentSyRR ... smooth[] sms)
{ return union(sms, keepdata, round, roundcoeff)[0]; }

smooth tangentspace (smooth sm,
                     int ind = -1,
                     pair center = (ind == -1) ? sm.center : sm.holes[ind].center,
                     real angle,
                     real ratio,
                     real size = 1,
                     real rotate = 45,
                     string eltlabel = "x")
// Returns a tangent space to `sm` at point determined by `ind`, `dir` and `ratio` //
{
	if (!inside(-1, sm.holes.length-1, ind))
	{ abort("Could not build tangent space: index out of bounds."); }
	if (!sm.isinside(center))
	{ abort("Could not build tangent space: center out of bouds"); }
	if (!inside(0, 1, ratio))
	{ abort("Could not build tangent space: ratio out of bounds."); }

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
	sm.addelement(element(x, eltlabel));

	return res;
}

// -- From here starts the collection of the drawing functions provided by the module. -- //

private void drawsections (picture pic,
                           pair[][] sections,
                           pair viewdir,
                           bool dash,
                           bool explain,
                           bool shade,
                           real scale,
                           pen sectionpen,
                           pen dashpen,
                           pen shadepen,
                           int mode)
// Renders the circular sections, given an array of control points.
{
    for (int k = 0; k < sections.length; ++k)
    {
		if (sections[k].length > 4) continue;
		if (currentSeRL && length(sections[k][1]-sections[k][0]) > currentSeML)
        { continue; }

        path[] section = sectionellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir, (mode == 1));
        if (shade && currentDrF && section.length == 2) fill(pic = pic, section[0]--section[1]--cycle, shadepen);
		if (section.length > 1 && dash) draw(pic, section[1], dashpen);
        draw(pic, section[0], sectionpen);
        if (explain)
        {
            dot(pic, point(section[0], arctime(section[0], arclength(section[0])*.5)), red+1);
            dot(pic, sections[k][0], blue+1.5);
            dot(pic, sections[k][1], blue+1);
            draw(pic, sections[k][0] -- sections[k][1], deepgreen + defaultDrExP);
            draw(pic, sections[k][0]-.5*defaultSmEAL*scale*sections[k][2] -- sections[k][0]+.5*defaultSmEAL*scale*sections[k][2], deepgreen+defaultDrExP, arrow = Arrow(SimpleHead));
            draw(pic, sections[k][1]-.5*defaultSmEAL*scale*sections[k][3] -- sections[k][1]+.5*defaultSmEAL*scale*sections[k][3], deepgreen+defaultDrExP, arrow = Arrow(SimpleHead));
        }
    }
}

private void drawholesections (picture pic, hole hl1, hole hl2, pair viewdir, bool dash, bool explain, bool shade, real scale, int mode, pen sectionpen, pen dashpen, pen shadepen)
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
        draw(pic, (hl1.center + hl1vec)--hl1start, yellow+defaultDrExP);
        draw(pic, (hl1.center + rotate(-currentSeNA)*hl1vec)--hl1finish, yellow+defaultDrExP);
        draw(pic, (hl2.center + hl2vec)--hl2start, yellow+defaultDrExP);
        draw(pic, (hl2.center + rotate(currentSeNA)*hl2vec)--hl2finish, yellow+defaultDrExP);
        draw(pic = pic, arc(hl1.center, hl1.center + hl1vec, hl1finish, direction = CW), blue+defaultDrExP);
        draw(pic = pic, arc(hl2.center, hl2.center + hl2vec, hl2finish, direction = CCW), blue+defaultDrExP);
    }

    pair[][] sections;
	int p = floor(currentsection[5]);
    if (mode == 0)
    { sections = sectionparamsstrict(curhl1contour, curhl2contour, n, currentsection[4], p); }
    if (mode == 1)
    { sections = sectionparamsfree(curhl1contour, curhl2contour, p*n, p); }
    drawsections(pic, sections, viewdir, dash, explain, shade, scale, sectionpen, dashpen, shadepen, mode);
}

private void drawcartsections (picture pic, path[] g, path[] avoid, real y, bool horiz, pair viewdir, bool dash, bool explain, bool shade, real scale, pen sectionpen, pen dashpen, pen shadepen)
{
    drawsections(pic, cartsections(g, avoid, y, horiz), viewdir, dash, explain, shade, scale, sectionpen, dashpen, shadepen, 1);
}

private void fitpath (picture pic,
                      bool overlap,
                      bool changeunder,
                      bool drawnow,
                      path gs,
                      Label L,
                      pen p,
                      arrowbar beginarrow,
                      arrowbar endarrow,
                      arrowbar beginbar,
                      arrowbar endbar)
{
    label(pic = pic, gs, L = L, p = p);

	if (!overlap)
    {
        int length = currentdrawn.length;

		for (int i = 0; i < length; ++i)
		{
            path[] g = currentdrawn[i].g;
            path[] newg;
            path[] altg;
            bool putunder = changeunder && cyclic(gs);
            bool underdir = !currentdrawn[i].under;
            bool stolenbeginarrow = putunder ? inside(gs, beginpoint(g[0])) : false;
            bool stolenendarrow = putunder ? inside(gs, endpoint(g[g.length-1])) : false;

            for (int j = 0; j < g.length; ++j)
            {
                real[] aligntest = intersect(g[j], gs);
                if (aligntest.length == 0)
                {
                    if (putunder && inside(gs, beginpoint(g[j]))) { altg.push(g[j]); }
                    else newg.push(g[j]);
                    continue;
                }
                if (abs(cross(dir(g[j], aligntest[0]), dir(gs, aligntest[1]))) < defaultSySN) continue;

                real[][] times = intersections(g[j], gs);

                real[] cuttimes = new real[]{0};
                bool[] skipped = array(2*(times.length+1), value = false);
                bool gjcyclic = cyclic(g[j]);
                real t1;
                real t2;

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
                    real sang = max(abs(cross), .2);
                    t1 = relarctime(g[j], times[k][0], -currentArOL/sang*.5);
                    t2 = relarctime(g[j], times[k][0], currentArOL/sang*.5);
                    if (t1 < cuttimes[cuttimes.length-1])
                    {
                        cuttimes[cuttimes.length-1] = t2;
                        if (cuttimes.length > 2) skipped[cuttimes.length-3] = true;
                        continue;
                    }
                    cuttimes.push(t1);
                    cuttimes.push(t2);
                }

                if (cuttimes[cuttimes.length-1] == -2) { cuttimes.pop(); }
                else if (gjcyclic) { cuttimes[0] = t2; cuttimes.delete(cuttimes.length-1); }
                else { cuttimes.push(length(g[j])); }

                bool understart = putunder ? isinside(gs, point(g[j], cuttimes[0])) : false;
                for (int k = 0; k < cuttimes.length-1; k += 2)
                {
                    ((putunder && understart) ? altg : newg).push(gjcyclic ? subcyclic(g[j], (cuttimes[k], cuttimes[k+1])) : subpath(g[j], cuttimes[k], cuttimes[k+1]));
                    if (!skipped[k]) understart = !understart;
                }
            }

            if (newg.length > 0)
            {
                currentdrawn[i] = pathinfo(
                    g = newg,
                    p = currentdrawn[i].p,
                    under = currentdrawn[i].under,
                    beginarrow = (stolenbeginarrow ? None : currentdrawn[i].beginarrow),
                    endarrow = (stolenendarrow ? None : currentdrawn[i].endarrow),
                    beginbar = (stolenbeginarrow ? None : currentdrawn[i].beginbar),
                    endbar = (stolenendarrow ? None : currentdrawn[i].endbar)
                );
            }
            else
            {
                currentdrawn.delete(i);
                length -= 1;
                i -= 1;
            }
            if (altg.length > 0)
            {
                currentdrawn.push(pathinfo(
                    g = altg,
                    p = currentdrawn[i].p,
                    under = !currentdrawn[i].under,
                    beginarrow = (!stolenbeginarrow ? None : currentdrawn[i].beginarrow),
                    endarrow = (!stolenendarrow ? None : currentdrawn[i].endarrow),
                    beginbar = (!stolenbeginarrow ? None : currentdrawn[i].beginbar),
                    endbar = (!stolenendarrow ? None : currentdrawn[i].endbar)
                ));
            }
		}
    }
    if (!drawnow)
    {
        currentdrawn.push(pathinfo(
            g = new path[]{gs},
            p = p,
            under = false,
            beginarrow = beginarrow,
            endarrow = endarrow,
            beginbar = beginbar,
            endbar = endbar
        ));
    }
    else
    {
        if (beginarrow == None && beginbar == None)
        { draw(pic = pic, gs, p = p, arrow = endarrow, bar = endbar); return; }
        if (endarrow == None && endbar == None)
        { draw(pic = pic, gs, p = p, arrow = beginarrow, bar = beginbar); return; }
        if (length(gs) <= 2)
        {
            draw(pic = pic, subpath(gs, 0, length(gs)*.5), p = p, arrow = beginarrow, bar = beginbar);
            draw(pic = pic, subpath(gs, length(gs)*.5, length(gs)), p = p, arrow = beginarrow, bar = beginbar);
        }
        else
        {
            int node = ceil(length(gs)*.5);
            draw(pic = pic, subpath(gs, 0, node), p = p, arrow = beginarrow, bar = beginbar);
            draw(pic = pic, subpath(gs, node, length(gs)), p = p, arrow = endarrow, bar = endbar);
        }
    }
}

void draw (picture pic = currentpicture,
           smooth sm,
           pen contourpen = currentpen,
           pen smoothfill = smoothcolor,
           pen subsetcontourpen = contourpen,
           pen subsetfill = subsetcolor,
           pen sectionpen = currentDrSeP,
           pen dashpen = dashpen(sectionpen),
           pen shadepen = shadepen(smoothfill),
           int mode = currentDrM,
           bool fill = currentDrF,
           bool drawcontour = currentDrDC,
           bool explain = currentDrE,
           bool dash = currentDrDD,
           bool shade = currentDrDS,
           bool avoidsubsets = currentSeAS,
           bool drag = true,
           bool overlap = currentDrO,
           bool drawnow = currentDrDN)
// The main drawing function of the module. It renders a given smooth object with substantial customization: all drawing pens can be altered, there are four section-drawing modes available: `free`, `strict`, `cart` and `plain`. The `explain` parameter may be tweaked to show auxillary information about the object. Used for debugging. 
{
    // Configuring variables

	if (!inside(0,3, mode))
	{ abort("Invalid mode specified."); }

    pair viewdir = Sin(defaultSmVA)*sm.viewdir;
    currentSeMaEHR = defaultSeMaEHR*min(xsize(sm.contour), ysize(sm.contour));
    if (currentSeRL) currentSeML = currentSeMLR*min(xsize(sm.contour), ysize(sm.contour));

    mode = (length(viewdir) == 0) ? plain : mode;

    path[] contour = (sm.contour ^^ sequence(new path(int i){
        return reverse(sm.holes[i].contour);
    }, sm.holes.length));

    // Filling interiors

    if (fill)
    {
        fill(pic = pic, contour, p = smoothfill);
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

    // Drawing cross sections

	if (mode < 2)
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
					pair hlvec = defaultSmAR * sm.scale * unit(smstart - hl.center);
					draw(pic = pic, (hl.center + hlvec) -- smstart, yellow + defaultDrExP);
					draw(pic = pic, (hl.center + rotate(-hl.sections[j][2])*hlvec) -- smfinish, yellow + defaultDrExP);
					draw(pic = pic, arc(hl.center, hl.center + hlvec, smfinish, direction = CW), blue+defaultDrExP);
				}

				pair[][] sections = new pair[][];
				if (mode == 0)
				{
					sections = sectionparamsstrict(curhlcontour, cursmcontour, ceil(hl.sections[j][3]), hl.sections[j][4], ceil(hl.sections[j][5]));
				}
				if (mode == 1)
				{
					sections = sectionparamsfree(curhlcontour, cursmcontour, ceil(hl.sections[j][3])*ceil(hl.sections[j][5]), ceil(hl.sections[j][5]));
				}
				drawsections(pic, sections, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen, mode);
			}
            
            // Drawing sections between holes
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
    if (mode == 2)
    {
        for (int i = 0; i < sm.hratios.length; ++i)
        {
            drawcartsections(pic, contour, (avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[]{}), sm.hratios[i], true, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen);
        }
        for (int i = 0; i < sm.vratios.length; ++i)
        {
            drawcartsections(pic, contour, (avoidsubsets ? sequence(new path (int j){return sm.subsets[j].contour;}, sm.subsets.length) : new path[]{}), sm.vratios[i], false, viewdir, dash, explain, shade, sm.scale, sectionpen, dashpen, shadepen);
        }
    }

    // Drawing the contours

    if (drawcontour)
    {
        for (int i = 0; i < contour.length; ++i)
        {
            fitpath(pic = pic, overlap = overlap || sm.isderivative, changeunder = true, drawnow = drawnow, gs = contour[i], L = "", p = contourpen, beginarrow = None, endarrow = None, beginbar = None, endbar = None);
        }
        for (int i = 0; i < sm.subsets.length; ++i)
        {
            if (!sm.subsets[i].isderivative)
            {
                fitpath(pic = pic, overlap = overlap || currentDrSCO, changeunder = false, drawnow = drawnow, gs = sm.subsets[i].contour, L = "", p = subsetcontourpen, beginarrow = None, endarrow = None, beginbar = None, endbar = None);
            }
        }
    }
    
    // Drawing the attached smooth objects

	if (drag)
	{
		for (int i = 0; i < sm.attached.length; ++i)
		{
			draw(pic = pic, sm = sm.attached[i], contourpen = contourpen, smoothfill =  smoothfill + opacity(currentDrDO), subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, explain = explain, dash = dash, drag = true);
		}
	}

    // Labels and explain drawings

    for (int i = 0; i < sm.elements.length; ++i)
    {
        element elt = sm.elements[i];
        dot(pic = pic, elt.pos, L = Label("$"+elt.label+"$", align = elt.labelalign), contourpen+currentDrElP);
    }
	if (sm.label != "") label(intersection(sm.contour, sm.center, sm.labeldir), "$"+sm.label+"$", align = sm.labelalign);
    for (int i = 0; i < sm.subsets.length; ++i)
    {
        subset sb = sm.subsets[i];
        if (sb.label != "") label(pic = pic, position = intersection(sb.contour, sb.center, sb.labeldir), L = Label("$"+sb.label+"$", align = sb.labelalign));
        if (explain) label(pic = pic, L = Label((string)i, position = sb.center, p = blue));
    }
    if (explain) draw(pic = pic, sm.center -- sm.center+unit(viewdir)*defaultSmEAL, purple+defaultDrExP, arrow = Arrow(SimpleHead));
    if (explain)
    {
        dot(pic = pic, sm.center, red+1);
        for (int i = 0; i < sm.holes.length; ++i)
        { label(pic = pic, L = Label((string)i, position = sm.holes[i].center, p = red, filltype = NoFill)); }
    }
}

void draw (picture pic = currentpicture,
           smooth[] sms,
           pen contourpen = currentpen,
           pen smoothfill = smoothcolor,
           pen subsetcontourpen = contourpen,
           pen subsetfill = subsetcolor,
           pen sectionpen = currentDrSeP,
           pen dashpen = dashpen(sectionpen),
           pen shadepen = shadepen(smoothfill),
           int mode = currentDrM,
           bool fill = currentDrF,
           bool drawcontour = currentDrDC,
           bool explain = currentDrE,
           bool dash = currentDrDD,
           bool shade = currentDrDS,
           bool avoidsubsets = currentSeAS,
           bool drag = true,
           bool overlap = currentDrO,
           bool drawnow = currentDrDN)
{
	for (int i = 0; i < sms.length; ++i)
	{
		draw(pic = pic, sm = sms[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, fill, drawcontour, explain, dash, shade, avoidsubsets, drag, overlap, drawnow);
	}
}

void phantom (picture pic = currentpicture, smooth sm)
{
	dot(pic, max(sm.contour), invisible);
	dot(pic, min(sm.contour), invisible);
}

smooth[] drawintersect (picture pic = currentpicture,
                        smooth sm1,
                        smooth sm2,
                        bool keepdata = true,
                        bool round = false,
                        real roundcoeff = currentSyRR,
                        pair shift = (0,0),
                        pen ghostpen = mediumgrey,
                        pen contourpen = currentpen,
                        pen smoothfill = smoothcolor,
                        pen subsetcontourpen = contourpen,
                        pen subsetfill = subsetcolor,
                        pen sectionpen = currentDrSeP,
                        pen dashpen = dashpen(sectionpen),
                        pen shadepen = shadepen(smoothfill),
                        int mode = currentDrM,
                        bool fill = currentDrF,
                        bool drawcontour = currentDrDC,
                        bool explain = currentDrE,
                        bool dash = currentDrDD,
                        bool avoidsubsets = currentSeAS,
                        bool shade = currentDrDS,
                        bool overlap = currentDrO,
                        bool drawnow = currentDrDN)
// Draws the intersection of two smooth objects, as well as their dim contours for comparison
{
	smooth smp1 = sm1.copy().simplemove(shift = shift);
    smooth smp2 = sm2.copy().simplemove(shift = shift);
    
    smooth[] res = intersection(smp1, smp2, keepdata, round, roundcoeff);

    smp1.subsets.delete();
    smp2.subsets.delete();

    draw(pic, smp1, contourpen = ghostpen, smoothfill = invisible, mode = 3);
    draw(pic, smp2, contourpen = ghostpen, smoothfill = invisible, mode = 3);

    for (int i = 0; i < res.length; ++i)
    {
        draw(pic, res[i], contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, fill, drawcontour, explain, dash, avoidsubsets, shade, overlap, drawnow);
    }

    return res;
}
smooth[] drawintersect (picture pic = currentpicture,
                        smooth[] sms,
                        bool keepdata = true,
                        bool round = false,
                        real roundcoeff = currentSyRR,
                        pair shift = (0,0),
                        pen ghostpen = mediumgrey,
                        pen contourpen = currentpen,
                        pen smoothfill = smoothcolor,
                        pen subsetcontourpen = contourpen,
                        pen subsetfill = subsetcolor,
                        pen sectionpen = currentDrSeP,
                        pen dashpen = dashpen(sectionpen),
                        pen shadepen = shadepen(smoothfill),
                        int mode = currentDrM,
                        bool explain = currentDrE,
                        bool dash = currentDrDD,
                        bool shade = currentDrDS)
{
	smooth[] smsp = sequence(new smooth (int i){return sms[i].copy().move(shift = shift);}, sms.length);
	smooth[] res = intersection(smsp, keepdata, round, roundcoeff);

	for (int i = 0; i < smsp.length; ++i)
	{
		smsp[i].subsets.delete();
		draw(pic, smsp[i], contourpen = ghostpen, smoothfill = invisible, mode = 3);
	}
	for (int i = 0; i < res.length; ++i)
	{
        draw(pic, res[i], contourpen = contourpen, smoothfill = smoothfill, subsetcontourpen = subsetcontourpen, subsetfill = subsetfill, sectionpen = sectionpen, dashpen = dashpen, shadepen = shadepen, mode = mode, explain = explain, dash = dash, shade = shade);
	}

	return res;
}
smooth[] drawintersect (picture pic = currentpicture,
                        bool keepdata = true,
                        bool round = false,
                        real roundcoeff = currentSyRR,
                        pair shift = (0,0),
                        pen ghostpen = mediumgrey,
                        pen contourpen = currentpen,
                        pen smoothfill = smoothcolor,
                        pen subsetcontourpen = contourpen,
                        pen subsetfill = subsetcolor,
                        pen sectionpen = currentDrSeP,
                        pen dashpen = dashpen(sectionpen),
                        pen shadepen = shadepen(smoothfill),
                        int mode = currentDrM,
                        bool explain = currentDrE,
                        bool dash = currentDrDD,
                        bool shade = currentDrDS
                        ... smooth[] sms)
{
	return drawintersect(pic, sms, keepdata, round, roundcoeff, shift, ghostpen, contourpen, smoothfill, subsetcontourpen, subsetfill, sectionpen, dashpen, shadepen, mode, explain, dash, shade);
}

void drawarrow (picture pic = currentpicture,
                smooth sm1,
                smooth sm2 = sm1,
                int[] ind1 = {},
                int[] ind2 = {},
                real curve = 0,
                pair[] points = {},
                Label L = "",
                pen p = currentpen,
                arrowbar beginarrow = currentDrBA,
                arrowbar endarrow = currentDrEA,
                arrowbar beginbar = currentDrBB,
                arrowbar endbar = currentDrEB,
                bool overlap = currentDrO,
                bool drawnow = currentDrDN,
                real margin1 = currentArM,
                real margin2 = currentArM)
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

	if (center1 == center2) { abort("Could not draw arrow between object and itself."); }

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
		dir2 = -dir(g2, intersect2[1]);
	}
    path gs = subpath(g, time1, time2);

	fitpath(pic, overlap = overlap, changeunder = false, drawnow = drawnow, gs = gs, L = L, p = p, beginarrow, endarrow, beginbar, endbar);
}

void drawarrow (picture pic = currentpicture,
                smooth sm1,
                int ind1,
                smooth sm2 = sm1,
                int ind2,
                real curve = 0,
                pair[] points = {},
                Label L = "",
                pen p = currentpen,
                arrowbar beginarrow = currentDrBA,
                arrowbar endarrow = currentDrEA,
                arrowbar beginbar = currentDrBB,
                arrowbar endbar = currentDrEB,
                bool overlap = currentDrO,
                bool drawnow = currentDrDN,
                real margin1 = currentArM,
                real margin2 = currentArM)
{
	element el1 = sm1.elements[ind1];
	element el2 = sm2.elements[ind2];
	if (el1.pos == el2.pos) { abort("Could not draw arrow between object and itself."); }

    path g = (points.length == 0) ? curvedpath(el1.pos, el2.pos, curve = curve) : connect(concat(new pair[]{el1.pos}, points, new pair[]{el2.pos}));
	g = subpath(g, arctime(g, margin1), arctime(g, arclength(g)-margin2));
	fitpath(pic, overlap = overlap, changeunder = false, drawnow = drawnow, gs = g, L = L, p = p, beginarrow, endarrow, beginbar, endbar);
}

void drawarrow (picture pic = currentpicture,
                smooth sm,
                int[] ind = {},
                real angle,
                real radius = sm.scale,
                pair[] points = {},
                bool reverse = false,
                Label L = "",
                pen p = currentpen,
                arrowbar beginarrow = currentDrBA,
                arrowbar endarrow = currentDrEA,
                arrowbar beginbar = currentDrBB,
                arrowbar endbar = currentDrEB,
                bool overlap = currentDrO,
                bool drawnow = currentDrDN,
                real margin1 = currentArM,
                real margin2 = currentArM)
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
		dir2 = -dir(contour, intersection[intersection.length-1][1]);
	}

    path gs = subpath(g, time1, time2);
	fitpath(pic, overlap = overlap, changeunder = false, drawnow = drawnow, gs, L = L, p = p, beginarrow, endarrow, beginbar, endbar);
}

void drawcache (picture pic = currentpicture)
{
    void auxdraw (pathinfo pinf)
    {
        unravel pinf;

        int startind = 0;
        int finishind = g.length-1;
        pen curp = under ? underpen(p) : p;

        if (beginarrow == None && beginbar == None)
        {
            draw(pic = pic, g[g.length-1], p = curp, arrow = endarrow, bar = endbar);
            finishind -= 1;
        }
        else if (endarrow == None && endbar == None)
        {
            draw(pic = pic, g[0], p = curp, arrow = beginarrow, bar = beginbar);
            startind;
        }
        else if (g.length > 1)
        {
            draw(pic = pic, g[0], p = curp, arrow = beginarrow, bar = beginbar);
            draw(pic = pic, g[g.length-1], p = curp, arrow = endarrow, bar = endbar);
            startind += 1;
            finishind -= 1;
        }
        else if (length(g[0]) < 2)
        {
            draw(pic = pic, subpath(g[0], 0, length(g[0])*.5), p = p, arrow = beginarrow, bar = beginbar);
            draw(pic = pic, subpath(g[0], length(g[0])*.5, length(g[0])), p = p, arrow = beginarrow, bar = beginbar);
            return;
        }
        else
        {
            int node = ceil(length(g[0])*.5);
            draw(pic = pic, subpath(g[0], 0, node), p = p, arrow = beginarrow, bar = beginbar);
            draw(pic = pic, subpath(g[0], node, length(g[0])), p = p, arrow = endarrow, bar = endbar);
            return;
        }

        for (int j = startind; j <= finishind; ++j)
        {
            draw(pic = pic, g[j], p = curp);
        }
    }

    for (int i = 0; i < currentdrawn.length; ++i)
    {
        auxdraw(currentdrawn[i]);
    }
}

void savecache ()
{
    currentsaved = new pathinfo[];
    for (int i = 0; i < currentdrawn.length; ++i)
    { currentsaved.push(currentdrawn[i]); }
}
void restorecache ()
{
    currentdrawn = new pathinfo[];
    for (int i = 0; i < currentsaved.length; ++i)
    { currentdrawn.push(currentsaved[i]); }
}
void flushcache ()
{ currentdrawn = new pathinfo[]; }

// -- Redefining functions to execute `drawcache` and `flushcache` at call -- //

void plainshipout (string prefix=defaultfilename, picture pic=currentpicture,
	     orientation orientation=orientation,
	     string format="", bool wait=false, bool view=true,
	     string options="", string script="",
	     light light=currentlight, projection P=currentprojection) = shipout;
shipout = new void (string prefix=defaultfilename, picture pic=currentpicture,
	     orientation orientation=orientation,
	     string format="", bool wait=false, bool view=true,
	     string options="", string script="",
	     light light=currentlight, projection P=currentprojection)
{
    drawcache(pic);
    plainshipout(prefix, pic, orientation, format, wait, view, options, script, light, P);
};

void plainerase (picture pic = currentpicture) = erase;
erase = new void (picture pic = currentpicture)
{
    flushcache();
    plainerase(pic);
};
