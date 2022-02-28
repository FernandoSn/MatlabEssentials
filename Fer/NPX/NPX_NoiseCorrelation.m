function [MeanNoiseCorr, NoiseCorr] = NPX_NoiseCorrelation(Raster,PST,BinSize,Trials)

% Params
[~, traindata, ~] = BinRearranger(Raster, PST, BinSize, Trials);


NoTrials = length(Trials);

NoStimuli = size(traindata,1) / NoTrials;

MeanNoiseCorr = zeros(1,NoStimuli);

NoiseCorr = [];


for Stim = 1:NoStimuli
    
    idx1 = (Stim - 1) * NoTrials + 1;
    idx2 = Stim*NoTrials;
    
    data = zscore(traindata(idx1:idx2,:));
%     data = traindata(idx1:idx2,:) - mean(traindata(idx1:idx2,:));
    
    rho = corr(data);
    
    provCorr = [];

    for ii = 2:size(rho,1)

       provCorr = [provCorr,rho(ii,1:ii-1)];

    end
    
    NoiseCorr = [NoiseCorr;provCorr];
    
    MeanNoiseCorr(Stim) = nanmean(provCorr);

end
