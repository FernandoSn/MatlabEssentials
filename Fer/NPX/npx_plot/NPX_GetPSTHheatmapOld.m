function [PSTHMat,SortedIdx,t,PeakRatePos,PeakRate] = NPX_GetPSTHheatmapOld(PSTHstruct,Valve,PlotOpts)

%PSTHstrut, struct returned by NPX_RasterPSTHPlotter

units = length(PSTHstruct.KDF(1,:));

PSTHMat = cell2mat(PSTHstruct.KDF(Valve,:));

RealPST = repmat(PSTHstruct.realPST,[1,units]);

PSTHMat = PSTHMat(RealPST);

PSTHMat = reshape(PSTHMat,[length(PSTHMat)./units,units])';

t = PSTHstruct.KDFt(PSTHstruct.realPST);

t0idx = find(t>0,1);
t1idx = find(t>1,1);

 [PeakRate,maxidx] = max(PSTHMat(:,t0idx:t1idx),[],2);
%PeakRate = max(PSTHMat(:,t0idx:end),[],2);

PeakRatePos = maxidx + t0idx - 1;

% PeakRateIdx = [];
% 
% for ii = 1:size(PSTHMat,1)
%    
%     PeakRateIdx = [PeakRateIdx;find(PSTHMat(ii,:)==PeakRate(ii),1)];
%        
% end

% PSTHMat = [PeakRateIdx,PSTHMat];
% 
% PSTHMat = sortrows(PSTHMat,1);
% 
% PSTHMat = PSTHMat(:,2:end);

[~,SortedIdx] = sort(PeakRatePos);

PSTHMatSorted = PSTHMat(SortedIdx,:);

if PlotOpts == 0
    
    return;

elseif PlotOpts == 1
    
    %imagesc(PSTHMat);
    imagesc(t,[],PSTHMatSorted)
    colormap(flipud(pink))
    caxis([-4,4]);
    xlim([0 1]);
    %xlabel('time(s)')

elseif PlotOpts == 2

    figure('Renderer', 'painters', 'Position', [10 170 250 500]);
    %imagesc(PSTHMat);
    imagesc(t,[],PSTHMatSorted)
    colormap(flipud(pink))
    caxis([-4,4]);
    xlim([0 1]);
    xlabel('time(s)')

end