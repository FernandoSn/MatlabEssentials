function [RawCorr,CorrVecShuffle,VecStd] = MACEvaluateCorrProv(Reference,Target,BinSize,epoch,shuffles)


%% Spontaneous
RawCorr = SpikeCorr(Reference, Target, BinSize, epoch);

[CorrVecShuffle, VecStd] = SpikeShuffle(Reference, Target, BinSize, shuffles,epoch);




%% Odor




% Histcorr(SpikeCorr(Reference, Target, BinSize, 1000),BinSize,1000);

% Histcorr(RawCorr,BinSize,epoch);

% Histcorr((RawCorr - CorrVecShuffle)./mean(VecStd),BinSize,epoch);

