function [trainlabel, traindata] = NPX_GetSingleInhTD(Raster,ValveTimes, PREX, InhIdx, trials)


%Deprecated

PSTs = NPX_GetPSTs(ValveTimes, PREX, [], trials,InhIdx);

PSTHtrials = NPX_PSTHmaker(Raster, PSTs, trials,false);

    A = cell2mat(PSTHtrials);

if ndims(A) == 3
    B = permute(A,[3,1,2]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,3),1);
    trainlabel = trainlabel(:);
    
else
    B = permute(A,[4,1,2,3]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,4),1);
    trainlabel = trainlabel(:);
    
end