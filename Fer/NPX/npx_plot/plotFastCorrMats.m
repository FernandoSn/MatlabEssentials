function [ltd,td,TACorrMat, rho, proj] = plotFastCorrMats(Raster,Trials,PST,isPlot,OM, cond)

if nargin > 4
   
    idx1 = find(OM(:,1) == Trials(1),1,'first');
    idx2 = find(OM(:,1) == Trials(end),1,'last');
    [ltd,bc] = NPX_GetTrialIdx(OM(idx1:idx2,:),cond,9);
    [~, td] = NPX_GetTD(Raster, PST,PST(2) - PST(1),Trials);
    ltd = ltd(bc);
    td = td(bc,:);
    
    [ltd,ti] = sort(ltd);
    td = td(ti,:);
    
else
   
    [ltd, td] = NPX_GetTD(Raster, PST,PST(2) - PST(1),Trials);
    %[~, ptd] = NPX_GetTD(Raster, [-2,-1],1,Trials);
   
end

if isPlot
    %td = (td - mean(ptd))./std(ptd);
    td = zscore(td);
    %td = td./max(td);
end



% [~, prtd] = NPX_GetTD(Raster, [-1.5, -0.5],1,Trials);
% td = (td - mean(prtd,1)) ./ std(prtd);
% td = td(:,~isnan(td(1,:)));

% NPXMCSR = NPX_GetMultiCycleSpikeRate(Raster,Trials,PST);
% NPXMCSRPr = NPX_GetMultiCycleSpikeRate(Raster,Trials,[-1.5,-0.5]);
% Scores = NPX_SCOmakerPreInh(NPXMCSR,NPXMCSRPr);
% BoolExc = (Scores.auROC > 0.5 ) & (Scores.AURp < 0.05);
% BoolExc = sum(BoolExc) > 0;
% td = td(:,BoolExc);





metric = 'corr';


rho = NPX_GetSimMatrix(td, metric);
rhoD = 1-rho;
if isPlot; prettyMat(rho); end

TACorrMat = NPX_GetTrialAveragedVecSimMat(td,ltd,metric);
TACorrMatD = 1-TACorrMat;
if isPlot; prettyMat(TACorrMat); end


proj = NPX_EigenProjection(rho,1:3);
if isPlot
    %NPX_ScatterPlot(proj,length(Trials),false,false,winter)
    plotProj(proj,ltd,winter)
    xticks([])
    yticks([])
    makepretty;
end
    
end

function prettyMat(matrix)

    figure
    imagesc(matrix)
    colorbar
    xticks([])
    yticks([])
    caxis([-0.5,0.5]);
    
    %colormap(flipud(parula))%for distance
    %caxis([0.5 1.5]);
    
    makepretty;
    
end

function plotProj(proj,ltd,cm)

    figure
    hold on
    ultd = unique(ltd);
    n = numel(ultd);
    Colors = cm;
    Colors = Colors(1:floor(256./(n-1)):end,:);
    
    for ii = 1:n
        color = Colors(ii,:);
        idx = ultd(ii) == ltd;
        scatter3(proj(idx,1),proj(idx,2),proj(idx,3),'MarkerFaceColor',color,'MarkerEdgeColor',color,'SizeData',50)
    end


end
