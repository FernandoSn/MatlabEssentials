function [trainlabel,traindata,n_bins] = BinRearranger(Raster,PST,BinSize,Trials)

[~, PSTHtrials, PSTHt] = PSTHmaker_Beast(Raster, PST, BinSize, Trials);
%
% for V = 1:size(PSTHtrials,1)
%     for U = 1:size(PSTHtrials,2)
%         for T = 1:size(PSTHtrials,3)
%             PSTHtrials{V,U,T} = shake(PSTHtrials{V,U,T});
%         end
%     end
% end


%% for "temporal" code.  normalizing away all spike count changes.
% a = cellfun(@sum,PSTHtrials);
% aa = mat2cell(a,ones(size(a,1),1),ones(size(a,2),1),ones(size(a,3),1));
% b = cellfun(@rdivide,PSTHtrials,aa,'uni',0);
% pt = b;
% pt(a==0) = {ones(size(b{1,1,1}))/sum(ones(size(b{1,1,1})))};
% PSTHtrials = pt;

%%
    A = cell2mat(PSTHtrials);

if ndims(A) == 3
    B = permute(A,[3,1,2]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,3),1);
    trainlabel = trainlabel(:);
    
    n_bins = length(PSTHt);
else
    B = permute(A,[4,1,2,3]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,4),1);
    trainlabel = trainlabel(:);
    
    n_bins = length(PSTHt);
end
end

