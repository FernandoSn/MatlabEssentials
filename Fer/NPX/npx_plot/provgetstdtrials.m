function STDcell = provgetstdtrials(Raster,trialblock)


TotalTrials = length(Raster{1,1,1});

if mod(TotalTrials,trialblock) ~= 0
    
    error('incorrect trialblock')
    
end


plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;
plotparams.Err = 4;
plotparams.VOI = 1:size(Raster,1);

%s = cell(TotalTrials/trialblock,1);


STDcell = cell(size(Raster,1),1);

for ii = 1:size(STDcell,1)
   
    STDcell{ii} = zeros(size(Raster,3),TotalTrials/trialblock);
    
end

n = 1;

for ii = 1:trialblock:TotalTrials
   
    plotparams.TrialVec = ii:ii+trialblock-1;
    
    s = NPX_RasterPSTHPlotter(Raster,[],plotparams);
    
    for kk = 1:size(Raster,1)
        
        for jj = 1:size(Raster,3)
            
           
            STDcell{kk}(jj,n) = mean(s.KDFe{kk,jj});
            
        end
        
    end
    
    n = n+1;
end

