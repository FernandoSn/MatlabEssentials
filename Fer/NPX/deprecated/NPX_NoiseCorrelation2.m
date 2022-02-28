function NoiseCorr = NPX_NoiseCorrelation2(Raster,PST,Kernelsize,Trials)


% Params Deprecated
SingleUnitCell = NPX_Raster2SingleUnitCell(Raster,PST,Kernelsize,Trials);

NoTrials = length(Trials);

NoStimuli = size(SingleUnitCell{1,1},1) / NoTrials;

NoBins = size(SingleUnitCell{1,1},2);

NoiseCorr = zeros(NoStimuli, NoBins);

for Bin = 1:NoBins
    
   for Stim = 1:NoStimuli
       
       ProvStim = [];
      
       for refunit = 1 : length(SingleUnitCell) - 1
            for tarunit = (refunit + 1) : length(SingleUnitCell)
                
                idx = (Stim - 1) * NoTrials + 1;
                
                nc = corr(SingleUnitCell{refunit}(idx:Stim*NoTrials,Bin),SingleUnitCell{tarunit}(idx:Stim*NoTrials,Bin));
                
                ProvStim = [ProvStim, nc];                

            end
       end
              
       
       NoiseCorr(Stim,Bin) = nanmean(ProvStim);
       
   end
    
end