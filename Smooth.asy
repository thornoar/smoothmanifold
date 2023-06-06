// This is the main file in the library

import "Definitions.asy" as definitions;

void draw_sections (picture pic, pair[][] sections, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen, string mode)
{
    for (int k = 0; k < sections.length; ++k)
    {
        if(explain)
        {
            dot(pic, sections[k][0], blue+2.5*scale);
            dot(pic, sections[k][1], blue+2*scale);
            draw(pic, sections[k][0] -- sections[k][1], green + .4);
            draw(sections[k][0]-defaultSmEDL*scale*sections[k][2] -- sections[k][0]+defaultSmEDL*scale*sections[k][2], deepgreen+.4, arrow = Arrow(SimpleHead));
            draw(sections[k][1]-defaultSmEDL*scale*sections[k][3] -- sections[k][1]+defaultSmEDL*scale*sections[k][3], deepgreen+.4, arrow = Arrow(SimpleHead));
        }

        path[] section = tangent_section_ellipse(sections[k][0], sections[k][1], sections[k][2], sections[k][3], viewdir, (mode == "naive"));

        draw(pic, section[0], sectionpen);

        if (section.length > 1 && drawdashes)
        {
            draw(pic, section[1], dashpen+dashed);
        }

        if(explain) dot(pic, point(section[0], arctime(section[0], arclength(section[0])/2)), red+1.5);
    }
}

void draw_hole_sections (picture pic, hole hl, hole hlp, pair viewdir, bool drawdashes, bool explain, real scale, string mode = "naive", pen sectionpen, pen dashpen)
{
    if (!hl.drawsections_neigh || !hlp.drawsections_neigh) return;

    int n = dummynumber;
    if (hl.neighnumber == dummynumber && hlp.neighnumber == dummynumber) n = defaultNN;
    if (n == dummynumber && (hl.neighnumber == dummynumber || hlp.neighnumber == dummynumber))
    {
        n = max(hl.neighnumber, hlp.neighnumber);
    }
    if (n == dummynumber) n = min(hl.neighnumber, hlp.neighnumber);

    path curhlcontour = turn(hl.contour, hl.center, hl.center-hlp.center);
    path curhlpcontour = turn(reverse(hlp.contour), hlp.center, hlp.center-hl.center);

    pair hltimes = range(curhlcontour, hl.center, hlp.center-hl.center, defaultSAS);
    pair hlptimes = range(curhlpcontour, hlp.center, hl.center-hlp.center, defaultSAS, orientation = -1);

    if (explain)
    {
        draw(subpath(curhlcontour, hltimes.x, hltimes.y), lightred+1);
        draw(subpath(curhlpcontour, hlptimes.x, hlptimes.y), lightred+1);
        draw(pic, hl.center--point(curhlcontour, hltimes.x), yellow+.3);
        draw(pic, hl.center--point(curhlcontour, hltimes.y), yellow+.3);
        draw(pic, hlp.center--point(curhlpcontour, hlptimes.x), yellow+.3);
        draw(pic, hlp.center--point(curhlpcontour, hlptimes.y), yellow+.3);
        dot(pic, point(curhlcontour, hltimes.x), green+2);
        dot(pic, point(curhlcontour, hltimes.y), green+2);
        dot(pic, point(curhlpcontour, hlptimes.x), green+2);
        dot(pic, point(curhlpcontour, hlptimes.y), green+2);

        draw(arc(hl.center, hl.center + defaultSmAR * scale * unit(point(curhlcontour, hltimes.x) - hl.center), point(curhlcontour, hltimes.y), direction = CW), blue+.4);

        draw(arc(hlp.center, hlp.center + defaultSmAR * scale * unit(point(curhlpcontour, hlptimes.x) - hlp.center), point(curhlpcontour, hlptimes.y), direction = CCW), blue+.4);
    }

    pair[][] sections = new pair[][];
    
    if (mode == "free")
    {
        sections = free_sect_positions(curhlcontour, curhlpcontour, hltimes, hlptimes, n, defaultSR, defaultSP);
    }
    if (mode == "naive")
    {
        sections = naive_sect_positions(curhlcontour, subpath(curhlpcontour, hlptimes.x, hlptimes.y), hltimes, defaultSP*n, defaultSP);
    }

    draw_sections(pic, sections, viewdir, drawdashes, explain, scale, sectionpen, dashpen, mode);
}

void draw_horizontal_sections (picture pic, path[] g, real y, real ignore, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen)
{
    draw_sections(pic, h_cartsections(g, y, ignore), viewdir, drawdashes, explain, scale, sectionpen, dashpen, "naive");
}

void draw_vertical_sections (picture pic, path[] g, real x, real ignore, pair viewdir, bool drawdashes, bool explain, real scale, pen sectionpen, pen dashpen)
{
    draw_sections(pic, v_cartsections(g, x, ignore), viewdir, drawdashes, explain, scale, sectionpen, dashpen, "naive");
}

void draw (picture pic = currentpicture, smooth s, pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+opacity(.5), pair viewdir = (0,0), string mode = defaultSmMode, bool explain = defaultSmE, bool drawdashes = defaultSmDD, real margin = defaultSmM)
{
    viewdir = s.scale*defaultSmVS*viewdir;

    xaxis(min(s.contour).x-margin, max(s.contour).x+margin, invisible);
    yaxis(min(s.contour).y-margin, max(s.contour).y+margin, invisible);

    path[] contour = (s.contour ^^ sequence(new path(int i){
        return reverse(s.holes[i].contour);
    }, s.holes.length));

    filldraw(pic = pic, contour, fillpen = smoothpen, drawpen = contourpen);


    if(s.label != "") label(s.label, polar_intersection(s.contour, s.center, s.labeldir), align = (s.labelalign == dummypair) ? rotate(90)*dir(s.contour, polar_intersection_time(s.contour, s.center, s.labeldir)) : s.labelalign);

    if (mode == 'free' || mode == 'naive')
    {
        bool[][] holeConnected = new bool[s.holes.length][s.holes.length];

        for (int i = 0; i < s.holes.length; ++i)
        {
            for (int j = 0; j < s.holes.length; ++j)
            {
                holeConnected[i][j] = false;
            }

            holeConnected[i][i] = true;
        }

        for (int i = 0; i < s.holes.length; ++i)
        {
            hole hl = s.holes[i];

            if (!hl.drawsections) continue;

            if (hl.drawsections_smooth)
            {
                for (int j = 0; j < hl.sections.length; ++j)
                {
                    real[] data = hl.sections[j];
                    pair dir = (data[0], data[1]);
                    path curscontour = turn(s.contour, hl.center, -dir);
                    path curhlcontour = turn(hl.contour, hl.center, -dir);
                    real angle = data[2];
                    int n = ceil(data[3]);
                    real ratio = data[4];
                    int p = ceil(data[5]);

                    if (explain)
                    {
                        pair stimes = range(curscontour, hl.center, dir, angle);
                        pair hltimes = range(curhlcontour, hl.center, dir, angle);

                        draw(subpath(curscontour, stimes.x, stimes.y), lightred+1);    
                        draw(subpath(curhlcontour, hltimes.x, hltimes.y), lightred+1);

                        draw(pic = pic, hl.center -- point(curscontour, stimes.x), yellow + .3);
                        draw(pic = pic, hl.center -- point(curscontour, stimes.y), yellow + .3);

                        dot(pic, point(curhlcontour, range(curhlcontour, hl.center, dir, angle).x), green+2);
                        dot(pic, point(curhlcontour, range(curhlcontour, hl.center, dir, angle).y), green+2);
                        dot(pic, point(curscontour, range(curscontour, hl.center, dir, angle).x), green+2);
                        dot(pic, point(curscontour, range(curscontour, hl.center, dir, angle).y), green+2);

                        draw(arc(hl.center, hl.center + defaultSmAR * s.scale * unit(point(curhlcontour, range(curhlcontour, hl.center, dir, angle).x) - hl.center), point(curhlcontour, range(curhlcontour, hl.center, dir, angle).y), direction = CW), blue+.4);
                    }

                    pair[][] sections = new pair[][];
                    
                    if (mode == "free")
                    {
                        sections = free_sect_positions(curhlcontour, curscontour, range(curhlcontour, hl.center, dir, angle), range(curscontour, hl.center, dir, angle), n, ratio, p);
                    }
                    if (mode == "naive")
                    {
                        sections = naive_sect_positions(curhlcontour, curscontour, range(curhlcontour, hl.center, dir, angle), n*p, p);
                    }

                    draw_sections(pic, sections, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen, mode);
                }
            }
            else
            {
                write("yes");

                if(hl.drawsections_neigh)
                {   
                    for (int j = 0; j < s.holes.length; ++j)
                    {
                        if (j == i || holeConnected[i][j] || holeConnected[j][i]) continue;

                        draw_hole_sections(pic, hl, s.holes[j], viewdir, drawdashes, explain, s.scale, mode, sectionpen, dashpen);

                        holeConnected[i][j] = true;
                        holeConnected[j][i] = true;
                    }
                }

                continue;
            }

            if(!holeConnected[i][(i+1)%s.holes.length] && !holeConnected[(i+1)%s.holes.length][i])
            {
                draw_hole_sections(pic, hl, s.holes[(i+1)%s.holes.length], viewdir, drawdashes, explain, s.scale, mode, sectionpen, dashpen);
            }
        }
    }

    if (mode == 'cart')
    {
        for (int i = 0; i < s.hsectratios.length; ++i)
        {
            draw_horizontal_sections(pic, contour, s.hsectratios[i], defaultSmCI, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen);
        }

        for (int i = 0; i < s.vsectratios.length; ++i)
        {
            draw_vertical_sections(pic, contour, s.vsectratios[i], defaultSmCI, viewdir, drawdashes, explain, s.scale, sectionpen, dashpen);
        }
    }

    for (int i = 0; i < s.subsets.length; ++i)
    {
        subset sb = s.subsets[i];

        filldraw(pic = pic, sb.contour, fillpen = subsetpen, drawpen = subsetcontourpen);

        label(pic, sb.label, polar_intersection(sb.contour, sb.center, sb.labeldir), align = (sb.labelalign == dummypair) ? rotate(90)*dir(sb.contour, polar_intersection_time(sb.contour, sb.center, sb.labeldir)) : sb.labelalign);

        if(explain) dot(sb.center, red+3);
    }

    if(explain) draw(pic = pic, s.center -- s.center+unit(viewdir)*s.scale, purple+.5, arrow = Arrow(SimpleHead));
    
    if(explain)
    {
        dot(s.center, red+3);

        for (int i = 0; i < s.holes.length; ++i)
        {
            dot(s.holes[i].center, red+2.5);
        }
    }
}

void draw_arrow (picture pic = currentpicture, smooth s1, smooth s2, int ind1 = -1, int ind2 = -1, Label L = "", pen p = currentpen, real curve = 0, arrowbar arrow = Arrow(SimpleHead), bool overlap = false, real timemargin = defaultATM)
{
    path g1 = (ind1 == -1) ? s1.contour : s1.subsets[ind1].contour;
    path g2 = (ind2 == -1) ? s2.contour : s2.subsets[ind2].contour;

    path g = curved_path((ind1 == -1) ? s1.center : s1.subsets[ind1].center, (ind2 == -1) ? s2.center : s2.subsets[ind2].center, curve = curve);

    real[] intersect1 = intersect(g, g1);
    real[] intersect2 = intersect(g, g2);

    real time1 = (intersect1.length > 0) ? intersect1[0]+timemargin : timemargin;
    real time2 = (intersect2.length > 0) ? intersect2[0]-timemargin : length(g)-timemargin;

    path gs = subpath(g, time1, time2);

    if(overlap && intersect1.length > 0)
    {
        void draw_gap(path curpath)
        {
            real ovtime = intersect(gs, curpath)[1];

            real t1 = arctime(curpath, sub_arclength(curpath, 0, ovtime - defaultOL/2));
            real t2 = arctime(curpath, sub_arclength(curpath, 0, ovtime + defaultOL/2));

            draw(pic, subpath(curpath, t1, t2), white+(linewidth(p)+.3));
        }

        for (int i = 0; i < s1.subsets.length; ++i)
        {
            if (i == ind1) continue;

            path curpath = s1.subsets[i].contour;

            if (intersect(gs, curpath).length == 0) continue;

            draw_gap(curpath);
        }

        for (int i = 0; i < s2.subsets.length; ++i)
        {
            if (i == ind2) continue;

            path curpath = s2.subsets[i].contour;

            if (intersect(gs, curpath).length == 0) continue;

            draw_gap(curpath);
        }

        if (intersect(gs, s1.contour).length > 0)
        {
            draw_gap(s1.contour);
        }

        if (intersect(gs, s2.contour).length > 0)
        {
            draw_gap(s2.contour);
        }
    }

    draw(pic = pic, gs, p = p, arrow = arrow, L = L);
}

void compile (animation a, int seconds = 5, string format = "gif")
{
    int frames = a.pictures.length;

    if(format == "gif") a.movie(loops = 0, delay = 1000*seconds/frames);
    else a.pdf(delay = 1000*seconds/frames);
}

animation transform (smooth sm, string mode = "free", pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+opacity(.5), pair shift = (0,0), real scale = 1, real rotate = 0, bool drawdashes = defaultSmDD, bool explain = defaultSmE, real margin = defaultSmM, pair viewdir = (0,0), int frames = 10)
{
    animation a;

    smooth smp = sm.copy();

    int n = ceil(.5*frames);

    picture[] reverse;

    for (int i = 0; i < n; ++i)
    {
        save();
        smp.move(shift = shift/n, scale = scale^(1/n), rotate = rotate/n);
        draw(smp, mode = mode, contourpen = contourpen, smoothpen = smoothpen, subsetcontourpen = subsetcontourpen, subsetpen = subsetpen, sectionpen = sectionpen, dashpen = dashpen, viewdir = viewdir, drawdashes = drawdashes, explain = explain, margin = margin);
        a.add(currentpicture);
        reverse.push(currentpicture);
        restore();
    }

    while(reverse.length != 0) a.add(reverse.pop());

    return a;
}

animation turn_around (smooth sm, string mode = "free", pen contourpen = currentpen, pen smoothpen = defaultSmP, pen subsetcontourpen = contourpen, pen subsetpen = defaultSbP, pen sectionpen = defaultSmSP, pen dashpen = sectionpen+opacity(.5), bool drawdashes = defaultSmDD, bool explain = defaultSmE, real margin = defaultSmM, pair viewdir1 = dir(180 - defaultTAVAN), pair viewdir2 = dir(defaultTAVAN), real rotate = defaultTARN, int frames = 10)
{
    animation a;

    smooth smp = sm.copy();

    int n = ceil(.5*frames);

    picture[] reverse;

    if (degrees(viewdir1) < degrees(viewdir2)) rotate = -rotate;

    for (int i = 0; i < n; ++i)
    {
        save();
        smp.move(rotate = rotate/n);
        draw(smp, mode = mode, contourpen = contourpen, smoothpen = smoothpen, subsetcontourpen = subsetcontourpen, subsetpen = subsetpen, sectionpen = sectionpen, dashpen = dashpen, viewdir = ((n-i)/n*viewdir1 + i/n*viewdir2), drawdashes = drawdashes, explain = explain, margin = margin);
        a.add(currentpicture);
        reverse.push(currentpicture);
        restore();
    }

    while(reverse.length != 0) a.add(reverse.pop());

    return a;
}