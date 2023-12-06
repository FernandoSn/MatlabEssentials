function [ ] = subplotpos( spwidth, spheight, spgridx, spgridy, totalmargin )
%SUBPLOTpos Summary of this function goes here
%   sppos = subplotpos( spwidth, spheight, spgridx, spgridy )
% also makes subplots 20% bigger

% margin = 0.05;
marginx=totalmargin/(spwidth+1);
marginy=totalmargin/(spheight+1);

plotsizex = (1-totalmargin)/spwidth;
plotsizey = (1-totalmargin)/spheight;

plotposx = marginx + (spgridx-1)*(plotsizex+marginx);
plotposy = marginy + (spheight-spgridy)*(plotsizey+marginy);

axes('position', [plotposx, plotposy, plotsizex, plotsizey]) 

end

