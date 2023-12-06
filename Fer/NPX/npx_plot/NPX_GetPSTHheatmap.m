function [PSTHMat,SortedIdx,t] = NPX_GetPSTHheatmap(Raster,Trials,option)


%option = -1. CrossValidation per valve/
%option = 0. Raw
%option > 0. Valve number for CV reference.


PSTHMats = cell(1,size(Raster,1));
SortedIdxs = cell(1,size(Raster,1));


plotparams.PSTHparams.PST = [-1,2];
plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;
plotparams.VOI = 1:size(Raster,1);
Valves = plotparams.VOI;
PST = [0,1];

% if option == -1 %CrossValidation
%     
%     plotparams.TrialVec = Trials(1:2:end);
%     PSTHstruct = NPX_RasterPSTHPlotter(Raster,[],plotparams);
%     plotparams.TrialVec = Trials(2:2:end);
%     PSTHstructCV = NPX_RasterPSTHPlotter(Raster,[],plotparams);
%        
% else
%     
%     plotparams.TrialVec = Trials;
%     PSTHstruct = NPX_RasterPSTHPlotter(Raster,[],plotparams);
%     
% end


plotparams.TrialVec = Trials(1:2:end);
PSTHstruct = NPX_RasterPSTHPlotter(Raster,[],plotparams);
plotparams.TrialVec = Trials(2:2:end);
PSTHstructCV = NPX_RasterPSTHPlotter(Raster,[],plotparams);




t = PSTHstruct.KDFt(PSTHstruct.realPST);

for valve = Valves
    
    if option == -1
        
        [~,SortedIdx] = GetZscoredPSTHmat(PSTHstructCV,valve,PST);
        [PSTHMat,~] = GetZscoredPSTHmat(PSTHstruct,valve,PST);
        
    elseif option == 0
        
        [PSTHMat,SortedIdx] = GetZscoredPSTHmat(PSTHstruct,valve,PST);
        
    else
        
        %[~,SortedIdx] = GetZscoredPSTHmat(PSTHstruct,option,PST);
        [~,SortedIdx] = GetZscoredPSTHmat(PSTHstructCV,option,PST);
        [PSTHMat,~] = GetZscoredPSTHmat(PSTHstruct,valve,PST);
        
    end
    
    
    PSTHMats{valve} = PSTHMat;
    SortedIdxs{valve} = SortedIdx;
    
    figure('Renderer', 'painters', 'Position', [10 170 250 500]);
    %imagesc(PSTHMat);
    imagesc(t,[],PSTHMat(SortedIdx,:))
    colormap(flipud(pink))
    caxis([-4,4]);
    xlim([PST(1),PST(2)]);
    xlabel('time(s)')
    makepretty;
    
end

end


function [PSTHMat,SortedIdx,t,PeakRatePos,PeakRate] = GetZscoredPSTHmat(PSTHstruct,valve,PST)


    units = length(PSTHstruct.KDF(1,:));

    RealPST = repmat(PSTHstruct.realPST,[1,units]);

    t = PSTHstruct.KDFt(PSTHstruct.realPST);

    t0idx = find(t>PST(1),1);
    t1idx = find(t>PST(2),1);

    PSTHMat = cell2mat(PSTHstruct.KDF(valve,:));

    PSTHMat = PSTHMat(RealPST);

    PSTHMat = reshape(PSTHMat,[length(PSTHMat)./units,units]);
    
    PSTHMat = zscore(PSTHMat)';
    
    [PeakRate,maxidx] = max(PSTHMat(:,t0idx:t1idx),[],2);
    
    PeakRatePos = maxidx + t0idx - 1;

    [~,SortedIdx] = sort(PeakRatePos);

end