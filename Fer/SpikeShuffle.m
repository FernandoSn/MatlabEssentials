function [CorrVecShuffle, VecStd] = SpikeShuffle(ReferenceShuff, Target, BinSize, Shuffles,epoch)

error('Deprecated function, please select the folder with the updated fun.' );

NoBins = (epoch / BinSize) .* 2;

CorrVecShuffle = zeros(Shuffles,NoBins);

for ii = 1:Shuffles

    IndShuff = randi(length(ReferenceShuff)-1)+1;
    
%     IndShuff = 1;
    
    MinShuff = min(ReferenceShuff);
    MaxShuff = max(ReferenceShuff);
    
    ReferenceShuff(1:IndShuff-1) = ReferenceShuff(1:IndShuff-1) + (MaxShuff - ReferenceShuff(IndShuff));
    
    ReferenceShuff(IndShuff:end) = ReferenceShuff(IndShuff:end) - (ReferenceShuff(IndShuff)- MinShuff);

    ReferenceShuff = sort(ReferenceShuff);

    CorrVecShuffle(ii,:) = SpikeCorr(ReferenceShuff, Target, BinSize, epoch);
    
end

VecStd = std(CorrVecShuffle,1);
CorrVecShuffle = mean(CorrVecShuffle,1);