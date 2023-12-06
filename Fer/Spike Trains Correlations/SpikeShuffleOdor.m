function CorrVecShuff = SpikeShuffleOdor(ReferenceShuff, Target, BinSize, Shuffles,epoch)

%if isempty(ReferenceShuff) || isempty(Target); return; end

NoBins = (epoch / BinSize) .* 2;

CorrVecShuff = zeros(1,NoBins);


for ii = 1:Shuffles

    if length(ReferenceShuff) == 1; IndShuff = 1;
    else
    IndShuff = randi(length(ReferenceShuff)-1)+1;
    end
    
%     IndShuff = 1;
    
    MinShuff = min(ReferenceShuff);
    MaxShuff = max(ReferenceShuff);
    
    ReferenceShuff(1:IndShuff-1) = ReferenceShuff(1:IndShuff-1) + (MaxShuff + MinShuff - ReferenceShuff(IndShuff));
    
    ReferenceShuff(IndShuff:end) = ReferenceShuff(IndShuff:end) - (ReferenceShuff(IndShuff)- MinShuff);

    ReferenceShuff = sort(ReferenceShuff);

   CorrVecShuff = CorrVecShuff + SpikeCorr(ReferenceShuff, Target, BinSize, epoch);
    
end

CorrVecShuff = CorrVecShuff ./ Shuffles;