function TASimMat = NPX_GetTrialAveragedVecSimMat(td, label,metric)

if nargin < 3
   metric = 'corr'; 
end

badcell = any(isinf(td) | isnan(td));
%fprintf('Badcells: %d \n', sum(badcell))
td(:,badcell) = [];

la = unique(label,'stable');
ta = zeros(length(la), size(td,2));
for ii = 1:length(la)
    ta(ii,:) = nanmean(td(label == la(ii),:),1);
end

% ta = zscore(ta);
% td = zscore(td);

TASimMat = NPX_GetSimMatrix(ta, metric);


n = 1;
for diag = 1:length(TASimMat)+1:numel(TASimMat)

   tempmat = td(label == la(n),:);
   tempmat = [mean(tempmat(1:2:size(tempmat,1),:),1); mean(tempmat(2:2:size(tempmat,1),:),1)]; 
   tempsim = NPX_GetSimMatrix(tempmat, metric);

   TASimMat(diag) = tempsim(2,1);

   n = n+1;

end