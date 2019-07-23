function MACGetZTransforms(ReferenceSpikes, TargetSpikes, SigStruct, BinSize, epoch, Shuffles)

NoBins = (epoch / BinSize) .* 2;

ZLeadEx = zeros(size(SigStruct.LeadEx,1),NoBins);
ZLagEx = zeros(size(SigStruct.LagEx,1),NoBins);
ZBothEx = zeros(size(SigStruct.BothEx,1),NoBins);
ZLeadIn = zeros(size(SigStruct.LeadIn,1),NoBins);
ZLagIn = zeros(size(SigStruct.LagIn,1),NoBins);
ZBothIn = zeros(size(SigStruct.BothIn,1),NoBins);
ZExIn = zeros(size(SigStruct.ExIn,1),NoBins);


for ii = 1:size(SigStruct.LeadEx,1)
    
    fprintf('LeadEx correlation %u of %u\n',ii,size(SigStruct.LeadEx,1));
    
    RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.LeadEx(ii,1)}, TargetSpikes.tsec{SigStruct.LeadEx(ii,2)}, BinSize, epoch);

    [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.LeadEx(ii,1)}, TargetSpikes.tsec{SigStruct.LeadEx(ii,2)}, BinSize, Shuffles,epoch);

    ZLeadEx(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
    
end

for ii = 1:size(SigStruct.LagEx,1)
    
    fprintf('LagEx correlation %u of %u\n',ii,size(SigStruct.LagEx,1));
    
    RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.LagEx(ii,1)}, TargetSpikes.tsec{SigStruct.LagEx(ii,2)}, BinSize, epoch);

    [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.LagEx(ii,1)}, TargetSpikes.tsec{SigStruct.LagEx(ii,2)}, BinSize, Shuffles,epoch);

    ZLagEx(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
    
end

% for ii = 1:size(SigStruct.BothEx,1)
%     
%     fprintf('BothEx correlation %u of %u\n',ii,size(SigStruct.BothEx,1));
%     
%     RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.BothEx(ii,1)}, TargetSpikes.tsec{SigStruct.BothEx(ii,2)}, BinSize, epoch);
% 
%     [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.BothEx(ii,1)}, TargetSpikes.tsec{SigStruct.BothEx(ii,2)}, BinSize, Shuffles,epoch);
% 
%     ZBothEx(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
%     
% end

for ii = 1:size(SigStruct.LeadIn,1)
    
    fprintf('LeadIn correlation %u of %u\n',ii,size(SigStruct.LeadIn,1));
    
    RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.LeadIn(ii,1)}, TargetSpikes.tsec{SigStruct.LeadIn(ii,2)}, BinSize, epoch);

    [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.LeadIn(ii,1)}, TargetSpikes.tsec{SigStruct.LeadIn(ii,2)}, BinSize, Shuffles,epoch);

    ZLeadIn(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
    
end

for ii = 1:size(SigStruct.LagIn,1)
    
    fprintf('LagIn correlation %u of %u\n',ii,size(SigStruct.LagIn,1));
    
    RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.LagIn(ii,1)}, TargetSpikes.tsec{SigStruct.LagIn(ii,2)}, BinSize, epoch);

    [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.LagIn(ii,1)}, TargetSpikes.tsec{SigStruct.LagIn(ii,2)}, BinSize, Shuffles,epoch);

    ZLagIn(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
    
end

% for ii = 1:size(SigStruct.BothIn,1)
%     
%     fprintf('BothIn correlation %u of %u\n',ii,size(SigStruct.BothIn,1));
%     
%     RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.BothIn(ii,1)}, TargetSpikes.tsec{SigStruct.BothIn(ii,2)}, BinSize, epoch);
% 
%     [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.BothIn(ii,1)}, TargetSpikes.tsec{SigStruct.BothIn(ii,2)}, BinSize, Shuffles,epoch);
% 
%     ZBothIn(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
%     
% end

% for ii = 1:size(SigStruct.ExIn,1)
%     
%     fprintf('ExIn correlation %u of %u\n',ii,size(SigStruct.ExIn,1));
%     
%     RawCorr = SpikeCorr(ReferenceSpikes.tsec{SigStruct.ExIn(ii,1)}, TargetSpikes.tsec{SigStruct.ExIn(ii,2)}, BinSize, epoch);
% 
%     [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceSpikes.tsec{SigStruct.ExIn(ii,1)}, TargetSpikes.tsec{SigStruct.ExIn(ii,2)}, BinSize, Shuffles,epoch);
% 
%     ZExIn(ii,:) = (RawCorr - CorrVecShuffle)./mean(VecStd);
%     
% end

save('ZVecCorrsBase.mat','ZLeadEx','ZLagEx','ZBothEx','ZLeadIn','ZLagIn','ZBothIn','ZExIn');