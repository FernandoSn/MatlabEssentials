function [Scores] = SparsenessScores(Scores)

%% Miura's way
SparseVar = abs(squeeze(Scores.ZScore(:,:,1,:)));

Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
Scores.mSparseL = squeeze(SparseTop./SparseBtm);

SparseVar = permute(SparseVar,[2,1,3]);
Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
Scores.mSparseP = squeeze(SparseTop./SparseBtm);

%% Vinje's way
SparseVar = (squeeze(Scores.RawRate(:,:,1,:)));

Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
Scores.vSparseL = squeeze(SparseTop./SparseBtm);

SparseVar = permute(SparseVar,[2,1,3]);
Top1 = (nansum(bsxfun(@rdivide,SparseVar, sum(~isnan(SparseVar))))).^2;
Top2 = nansum(bsxfun(@rdivide,SparseVar.^2,sum(~isnan(SparseVar))));
SparseTop = 1-Top1./Top2;
SparseBtm = 1-(1./sum(~isnan(SparseVar)));
Scores.vSparseP = squeeze(SparseTop./SparseBtm);
end