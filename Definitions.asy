// This is where all the constants and structures are defined.

int dummynumber = -100;
pair dummypair = (dummynumber, dummynumber);
int prohibitednumber = -200;
real defaultSAB = 220;
real defaultSAS = 30;
int defaultSN = 7;
real defaultSR = .8;
int defaultSP = 50;
int defaultNN = 2;
real defaultOL = .06;
real defaultATM = .04;
real defaultTAVAN = 25;
real defaultTARN = 15;
pen defaultSmP = lightgrey;
pen defaultSbP = grey;
pen defaultSmSP = currentpen+linewidth(.3);
real defaultSmM = .5;
real defaultSmAR = .1;
real defaultSmVS = .2;
string defaultSmMode = "free";
bool defaultSmE = false;
real defaultSmEDL = .2;
bool defaultSmDD = true;
real defaultSmCI = .05;
real defaultSmCSD = .05;
int defaultSmCSN = 15;
real defaultSmCSTL = .5;

import "Paths.asy" as paths;

import animate;
import animation;
import graph;

struct hole
{
    path contour;
    
    pair center;

    bool drawsections;
    bool drawsections_neigh;
    bool drawsections_smooth;

    real[][] sections;

    int neighnumber;

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), bool drawsections = true, bool drawsections_neigh = true, bool drawsections_smooth = true, real[][] sections = {}, int neighnumber = dummynumber, pair cartsectratios = dummypair, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        transform t = shift(shift)*srap(scale, rotate, center);

        path pseudocontour = t*contour;
        pair pseudocenter = path_middle(pseudocontour);

        this.contour = (windingnumber(pseudocontour, pseudocenter) > 0) ? reverse(pseudocontour) : pseudocontour;

        this.center = shift(shift)*center;

        this.drawsections = drawsections;
        this.drawsections_neigh = drawsections_neigh;
        this.drawsections_smooth = drawsections_smooth;

        this.sections = new real[][];
        for (int i = 0; i < sections.length; ++i)
        {
            real[] arr = sections[i];

            while(arr.length < 6) {arr.push(dummynumber);}

            this.sections.push(arr);
        }

        this.neighnumber = neighnumber;
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
    hole adjust (pair shift, real scale, real rotate, pair point)
    {
        this.contour = srap(scale, rotate, point)*shift(shift)*this.contour;

        this.center = srap(scale, rotate, point)*shift(shift)*this.center;

        for (int i = 0; i < this.sections.length; ++i)
        {
            pair sectdir = (this.sections[i][0], this.sections[i][1]);

            this.sections[i][0] = xpart(rotate(rotate)*sectdir);
            this.sections[i][1] = ypart(rotate(rotate)*sectdir);
        }
        
        return this;
    }

    hole copy ()
    {
        return hole(this.contour, this.center, this.drawsections, this.drawsections_neigh, this.drawsections_smooth, this.sections, this.neighnumber);
    }
}

struct subset
{
    path contour;

    pair center;

    string label;
    pair labeldir;
    pair labelalign;

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), string label = "$U$", pair labeldir = E, pair labelalign = dummypair, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        transform t = shift(shift)*srap(scale, rotate, center);

        path pseudocontour = t*contour;
        pair pseudocenter = path_middle(pseudocontour);

        this.contour = (windingnumber(pseudocontour, pseudocenter) > 0) ? reverse(pseudocontour) : pseudocontour;

        this.center = shift(shift)*center;

        this.label = label;
        this.labeldir = labeldir;
        this.labelalign = labelalign;
    }

    subset set_label (string label, pair labeldir = this.labeldir)
    {
        this.label = label;
        this.labeldir = labeldir;
        
        return this;
    }
    subset move (pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.center)
    {
        this.contour = shift(shift)*srap(scale, rotate, point)*this.contour;

        this.center = shift(shift)*srap(scale, rotate, point)*this.center;
        
        return this;
    }
    subset adjust (pair shift, real scale, real rotate, pair point)
    {
        this.contour = srap(scale, rotate, point)*shift(shift)*this.contour;

        this.center = srap(scale, rotate, point)*shift(shift)*this.center;
        
        return this;
    }

    subset copy ()
    {
        return subset(this.contour, this.center, this.label, this.labeldir, this.labelalign);
    }
}

struct smooth
{
    path contour;

    pair center;

    string label;
    pair labeldir;
    pair labelalign;

    hole[] holes;

    subset[] subsets;

    real[] hsectratios;
    real[] vsectratios;

    pair shift;
    real scale;
    real rotate;

    smooth set_contour (path contour, bool unit = true)
    {
        this.contour = unit ? srap(this.scale, this.rotate, this.center)*shift(this.shift)*contour : contour;
        
        return this;
    }
    smooth set_center (pair center = path_middle(this.contour), bool unit = true)
    {
        this.center = unit ? shift(this.shift)*center : center;
        
        return this;
    }
    smooth set_label (string label = this.label, pair labeldir = this.labeldir)
    {
        this.label = label;
        this.labeldir = labeldir;
        
        return this;
    }
    real get_ratio_y_point (real y)
    {
        return (y - ypart(min(this.contour)))/(ypart(max(this.contour)) - ypart(min(this.contour)));
    }
    real get_ratio_x_point (real x)
    {
        return (x - xpart(min(this.contour)))/(xpart(max(this.contour)) - xpart(min(this.contour)));
    }
    real get_point_y_ratio (real y)
    {
        y = y - floor(y);
        return (ypart(min(this.contour))*(1-y) + ypart(max(this.contour))*y);
    }
    real get_point_x_ratio (real x)
    {
        x = x - floor(x);
        return (xpart(min(this.contour))*(1-x) + xpart(max(this.contour))*x);
    }
    void revise_hsectratios ()
    {
        real ymin = ypart(min(this.contour));
        real ymax = ypart(max(this.contour));
        real height = ymax-ymin;
        real xmin = xpart(min(this.contour));
        real xmax = xpart(max(this.contour));
        real length = xmax-xmin;
        real yrealCI = defaultSmCI * height;
        real yrealSD = defaultSmCSD * height;

        path[] contour = (this.contour ^^ sequence(new path(int i){
            return this.holes[i].contour;
        }, this.holes.length));

        real[] yres;

        triple[] ycontour = sequence(new triple (int i){return (ypart(min(contour[i])), ypart(max(contour[i])), (i == 0) ? this.center.x : this.holes[i-1].center.x);}, contour.length);

        int count = 1;

        while (count*1.01*defaultSmCSD < 1)
        {
            yres.push(count*1.01*defaultSmCSD);
            count += 1;
        }

        for (int i = 0; i < yres.length; ++i)
        {
            pair[][] sections = h_cartsections(contour, yres[i], defaultSmCI);

            bool foundsection = false;
            real yreal = get_point_y_ratio(yres[i]);

            for (int j = 0; j < sections.length; ++j)
            {
                real x1 = sections[j][0].x;
                real x2 = sections[j][1].x;

                bool exlude = false;

                for (int k = 0; k < ycontour.length; ++k)
                {
                    if (!inside(x1, x2, ycontour[k].z)) continue;

                    if (abs(yreal - ycontour[k].x) < yrealCI || abs(yreal - ycontour[k].y) < yrealCI || x2-x1 > defaultSmCSTL*length)
                    {
                        exlude = true;
                        break;
                    }
                }

                if (exlude) yres[i] += 2^j;
                else foundsection = true; 
            }

            if (!foundsection)
            {
                yres.delete(i);
                i -= 1;
            }
        }

        this.hsectratios = yres;
    }
    void revise_vsectratios ()
    {
        real xmin = xpart(min(this.contour));
        real xmax = xpart(max(this.contour));
        real length = xmax-xmin;
        real ymin = ypart(min(this.contour));
        real ymax = ypart(max(this.contour));
        real height = ymax-ymin;
        real xrealCI = defaultSmCI * length;
        real xrealSD = defaultSmCSD * length;

        real[] xres;

        path[] contour = (this.contour ^^ sequence(new path(int i){
            return this.holes[i].contour;
        }, this.holes.length));

        triple[] xcontour = sequence(new triple (int i){return (xpart(min(contour[i])), xpart(max(contour[i])), (i == 0) ? this.center.y : this.holes[i-1].center.y);}, contour.length);

        int count = 1;

        while (count*1.01*defaultSmCSD < 1)
        {
            xres.push(count*1.01*defaultSmCSD);
            count += 1;
        }

        for (int i = 0; i < xres.length; ++i)
        {
            pair[][] sections = v_cartsections(contour, xres[i], defaultSmCI);

            bool foundsection = false;
            real xreal = get_point_x_ratio(xres[i]);

            for (int j = 0; j < sections.length; ++j)
            {
                real y1 = sections[j][0].y;
                real y2 = sections[j][1].y;

                bool exlude = false;

                for (int k = 0; k < xcontour.length; ++k)
                {
                    if (!inside(y1, y2, xcontour[k].z)) continue;

                    if (abs(xreal - xcontour[k].x) < xrealCI || abs(xreal - xcontour[k].y) < xrealCI || y2-y1 > defaultSmCSTL*height)
                    {
                        exlude = true;
                        break;
                    }
                }

                if (exlude) xres[i] += 2^j;
                else foundsection = true; 
            }

            if (!foundsection)
            {
                xres.delete(i);
                i -= 1;
            }
        }
        
        this.vsectratios = xres;
    }
    void revise_cartsectratios ()
    {
        this.revise_hsectratios();
        this.revise_vsectratios();
    }
    smooth add_hole (hole H, int ind = this.holes.length, bool unit = true, bool revisecart = true)
    {
        hole Hp = unit ? H.copy().adjust(this.shift, this.scale, this.rotate, this.center) : H;

        real[][] data = Hp.sections;
        real[][] newdata = new real[][];

        pair defaultdir = (Hp.center == this.center) ? (-1,0) : unit(Hp.center - this.center);

        if(data.length == 0) newdata.push(new real[] {defaultdir.x, defaultdir.y, defaultSAB, defaultSN, defaultSR, defaultSP});
        else
        {
            for (int i = 0; i < data.length; ++i)
            {
                newdata.push(new real[] {((data[i][0] == dummynumber) ? defaultdir.x : data[i][0]), ((data[i][1] == dummynumber) ? defaultdir.y : data[i][1]), ((data[i][2] == dummynumber || data[i][2] <= 0) ? defaultSAB : data[i][2]), ((data[i][3] == dummynumber || data[i][3] <= 0 || ceil(data[i][3]) != data[i][3]) ? defaultSN : ceil(data[i][3])), ((data[i][4] == dummynumber || data[i][4] <= 0 || data[i][4] > 1) ? defaultSR : data[i][4]), ((data[i][5] == dummynumber || data[i][5] <= 0 || ceil(data[i][5]) != data[i][5]) ? defaultSP : (int)data[i][5])});
            }
        }

        this.holes.insert(i = ind, hole(
            contour = Hp.contour,
            center = Hp.center,
            drawsections = Hp.drawsections,
            drawsections_neigh = Hp.drawsections_neigh,
            drawsections_smooth = Hp.drawsections_smooth,
            sections = newdata,
            neighnumber = Hp.neighnumber
        ));

        if (revisecart) this.revise_cartsectratios();
        
        return this;
    }
    smooth remove_hole(int ind)
    {
        this.holes.delete(ind);
        
        return this;
    }
    smooth add_hole_section (int ind, real[] section = {}, bool unit = false)
    {
        while(section.length < 6)
        {
            section.push(dummynumber);
        }

        if (unit && this.rotate != 0)
        {
            pair sectdir = (section[0], section[1]);
            section[0] = xpart(rotate(this.rotate)*sectdir);
            section[1] = ypart(rotate(this.rotate)*sectdir);
        }

        this.holes[ind].sections.push(section);
        
        return this;
    }
    smooth set_hole_section (int ind, int ind2 = 0, real[] section = {}, bool unit = false)
    {
        this.holes[ind].sections.delete(ind2);

        while(section.length < 6)
        {
            section.push(dummynumber);
        }

        if (unit && this.rotate != 0)
        {
            pair sectdir = (section[0], section[1]);
            section[0] = xpart(rotate(this.rotate)*sectdir);
            section[1] = ypart(rotate(this.rotate)*sectdir);
        }

        this.holes[ind].sections.insert(i = ind2, section);
        
        return this;
    }
    smooth remove_hole_section (int ind, int ind2 = 0)
    {
        this.holes[ind].sections.delete(ind2);
        
        return this;
    }
    smooth add_subset (subset s, int ind = this.subsets.length, bool unit = true, bool revisecart = true)
    {
        this.subsets.insert(i = ind, unit ? s.copy().adjust(this.shift, this.scale, this.rotate, this.center) : s.copy());
        
        if (revisecart) this.revise_cartsectratios();

        return this;
    }
    smooth remove_subset (int ind)
    {
        this.subsets.delete(ind);
        
        return this;
    }
    smooth set_vsectratios (real[] vsectratios)
    {
        this.vsectratios = vsectratios;
        
        return this;
    }
    smooth set_hsectratios (real[] hsectratios)
    {
        this.hsectratios = hsectratios;
        
        return this;
    }
    smooth move_hole (int ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.holes[ind].center, bool movesections = false)
    {
        this.holes[ind].move(shift, scale, rotate, point, movesections);
        this.revise_cartsectratios();
        
        return this;
    }
    smooth adjust_hole (int ind, pair shift = (0,0), real scale, real rotate)
    {
        this.holes[ind].adjust(shift, scale, rotate, this.center);
        this.revise_cartsectratios();
        
        return this;
    }
    smooth move_subset (int ind, pair shift = (0,0), real scale = 1, real rotate = 0, pair point = this.subsets[ind].center)
    {
        this.subsets[ind].move(shift, scale, rotate, point);
        
        return this;
    }
    smooth adjust_subset (int ind, pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        this.subsets[ind].adjust(shift, scale, rotate, this.center);
        
        return this;
    }
    smooth move (pair shift = (0,0), real scale = 1, real rotate = 0)
    {
        this.rotate += rotate;
        this.scale *= scale;
        this.shift += shift;

        this.contour = shift(shift)*srap(scale, rotate, this.center)*this.contour;
        this.center = shift(shift)*this.center;
        this.labeldir = rotate(rotate)*this.labeldir;

        for (int i = 0; i < this.holes.length; ++i)
        {
            this.adjust_hole(i, shift, scale, rotate);
        }

        for (int i = 0; i < this.subsets.length; ++i)
        {
            this.adjust_subset(i, shift, scale, rotate);
        }

        if (rotate != 0)
        {
            for (int i = 0; i < this.holes.length; ++i)
            {
                this.revise_cartsectratios();
            }
        }
        
        return this;
    }

    void operator init (path contour = reverse(unitcircle), pair center = path_middle(contour), string label = "$M$", pair labeldir = W+N, pair labelalign = dummypair, hole[] holes = {}, subset[] subsets = {}, real[] hsectratios = {}, real[] vsectratios = {}, pair shift = (0,0), real scale = 1, real rotate = 0, bool unit = true)
    {
        this.shift = shift;
        this.scale = scale;
        this.rotate = rotate;

        pair pseudocenter = path_middle(contour);

        this.contour = shift(shift)*srap(scale, rotate, center)*((windingnumber(contour, pseudocenter) > 0) ? reverse(contour) : contour);
        this.label = label;
        this.labeldir = labeldir;
        this.labelalign = labelalign;
        this.center = shift(shift)*center;

        this.holes = new hole[];

        for (int i = 0; i < holes.length; ++i)
        {
            this.add_hole(holes[i], unit, revisecart = false);
        }
        
        for (int i = 0; i < subsets.length; ++i)
        {
            this.add_subset(subsets[i], unit, revisecart = false);
        }

        this.hsectratios = hsectratios;

        if (hsectratios.length == 0) this.revise_hsectratios();

        this.vsectratios = vsectratios;

        if (vsectratios.length == 0) this.revise_vsectratios();
    }

    smooth copy ()
    {
        smooth sm = smooth();

        sm.contour = this.contour;
        sm.center = this.center;
        sm.label = this.label;
        sm.labeldir = this.labeldir;
        sm.labelalign = this.labelalign;

        for (int i = 0; i < this.holes.length; ++i)
        {
            sm.holes.push(this.holes[i].copy());
        }

        for (int i = 0; i < this.subsets.length; ++i)
        {
            sm.subsets.push(this.subsets[i].copy());
        }

        sm.hsectratios = this.hsectratios;
        sm.vsectratios = this.vsectratios;

        sm.shift = this.shift;
        sm.scale = this.scale;
        sm.rotate = this.rotate;

        return sm;
    }
}

smooth samplesmooth (int type = 0, int num = 0)
{
    if (type == 0)
    {
        if(num == 0)
        {
            return smooth(
                contour = roundsamplepath[0],
                hsectratios = new real[] {.5}
            );
        }
        if(num == 1)
        {
            return smooth(
                contour = beansamplepath[0],
                label = "",
                labeldir = dir(90)
            ); 
        }
        if(num == 2)
        {
            return smooth(
                contour = beansamplepath[2],
                label = "$M$",
                labeldir = dir(100),
                subsets = new subset[]{
                    subset(
                        contour = beansamplepath[3],
                        scale = .48,
                        shift = (.18, -.65),
                        labeldir = dir(140)
                    )
                },
                hsectratios = new real[]{.6, .83}
            );
        }
    }
    if (type == 1) 
    {
        if (num == 0)
        {
            return smooth(
                contour = roundsamplepath[1],
                labeldir = (-2,1),
                holes = new hole[]{
                    hole(
                        contour = roundsamplepath[2],
                        sections = new real[][]{
                            new real[] {dummynumber, dummynumber, 270, dummynumber, .35, dummynumber}
                        },
                        shift = (-.65, .25),
                        scale = .5
                    )
                },
                subsets = new subset[] {
                    subset(
                        contour = roundsamplepath[3],
                        labeldir = S,
                        shift = (.45,-.45),
                        scale = .43,
                        rotate = 110
                    )
                }
            );
        }
    }
    if(type == 2)
    {
        return smooth(
            contour = beansamplepath[4], label = "$N$",
            labeldir = (-2,8),
            holes = new hole[]{
                hole(
                    contour = roundsamplepath[4],
                    sections = new real[][]{
                        new real[]{-2,1.5, 60, 3},
                        new real[]{0, -1, 80, 4}
                    },
                    neighnumber = 1,
                    cartsectratios = (dummynumber, prohibitednumber),
                    shift = (-.5, -.15),
                    scale = .45,
                    rotate = 15
                ),
                hole(
                    contour = roundsamplepath[3],
                    sections = new real[][]{
                        new real[]{dummynumber, dummynumber, 230, 10}
                    },
                    cartsectratios = (dummynumber, .7),
                    shift = (.57,.48),
                    scale = .47,
                    rotate = 17
                )
            }
        );
    }
    if(type == 3)
    {
        return smooth(
            contour = beansamplepath[5],
            label = "",
            holes = new hole[]{
                hole(
                    contour = roundsamplepath[5],
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
                    shift = (-.1,.7),
                    scale = .25
                ),
                hole(
                    contour = beansamplepath[6],
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

    return smooth();
}

smooth rn (int n, pair labeldir = (1,1), pair shift = (0,0), real scale = 1, real rotate = 0)
{
    return smooth(contour = (-1,-1)--(-1,1)--(1,1)--(1,-1)--cycle, label = "$\mathrm{R}^" + ((n == -1) ? "n" : (string)n)  + "$", labeldir = (1,1), labelalign = (-1,-1.5), hsectratios = new real[]{.5}, vsectratios = new real[]{.5}, shift = shift, scale = scale, rotate = rotate);
}