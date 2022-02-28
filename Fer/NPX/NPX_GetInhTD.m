function [trainlabel,traindata] = NPX_GetInhTD(Raster,ValveTimes, PREX, POSTX, Trials,InhIdx)

PSTs = NPX_GetPSTs(ValveTimes, PREX, POSTX, Trials,InhIdx);

PSTHtrials = NPX_PSTHmaker(Raster, PSTs, Trials,false);

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
end
