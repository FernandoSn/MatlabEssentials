function Raster = NPX_GetLickAlignedRaster(Licks,Events,NPXSpikes,OlfacMat)

NPXSpikes.SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikes);
[PREXmatFV,nolick,NumLicks] = PostBoldLicks(Licks, Events);


%Only for plotting puposes. Comment out dfor analysis.
% idx = (OlfacMat(:,3) == 2) & (OlfacMat(:,3) ~= OlfacMat(:,4));
% idx = (OlfacMat(:,3) == 3) & ~nolick;
% OlfacMat = OlfacMat(idx,:);
% PREXmatFV = PREXmatFV(idx);
%%%%%%%%%%%%%%%%%%%%
% OlfacMat(:,2) = OlfacMat(:,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PREXOdorTimes = NPX_PREX2Odor(PREXmatFV,OlfacMat,1);

ValveTimes = NPX_GetBeastCompatValveTimes(PREXOdorTimes);

Raster = NPX_RasterAlign(ValveTimes,NPXSpikes.SpikeTimes);

%Raster = NPX_RasterPhaseAlign(ValveTimes,NPXSpikes.SpikeTimes,Licks./2000);