function NPX_PlotSUDepthPSTH(Raster,window,CluDepth)

timeBinSize = 0.01; % seconds
psthType = 'norm'; % show the normalized version
eventName = 'stimulus onset'; % for figure labeling

%[~, ~,allP,~,timeBins] = NPX_GetTD(Raster, window, timeBinSize,[]);

[~, allP,~,~,timeBins] = NPX_GetTD(Raster, window, timeBinSize,[]);
allP = mean(allP,1);

idxB = (timeBins<0);

allP = reshape(allP,[length(timeBins), size(Raster,3)])';
allP = (allP - mean(allP(:,idxB),2))./ std( allP(:,idxB),[],2 );
allP(isnan(allP)) = 0;

depthBins = CluDepth;

figure;
plotPSTHbyDepth(timeBins, depthBins, allP, eventName, psthType);