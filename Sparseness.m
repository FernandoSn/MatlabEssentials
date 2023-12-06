function [SL, SP] = Sparseness(SparseVar)
Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
SL = squeeze(SparseTop./SparseBtm);

SparseVar = permute(SparseVar,[2,1,3]);
Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
SP = squeeze(SparseTop./SparseBtm);
end