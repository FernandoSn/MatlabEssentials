function ZscoreSorted = MACSortZScores(ZScoreCorr,StrCompare)

ZscoreSorted = zeros(size(ZScoreCorr,1),size(ZScoreCorr,2));
IndVec = zeros(1,size(ZScoreCorr,1));

if strcmp(StrCompare,'max')
    
%     RefVec = max(ZScoreCorr,[],2);

    RefVec = max(ZScoreCorr(:,36:44),[],2);
    
elseif strcmp(StrCompare,'min')
    
%     RefVec = min(ZScoreCorr,[],2);
    
    RefVec = min(ZScoreCorr(:,36:44),[],2);
    
else
    
    error('StrCompare should be max or min');
   
end

for ii = 1:size(ZScoreCorr,1)
   
    VecF = find(RefVec(ii)==ZScoreCorr(ii,:));
    
    IndVec(ii) = VecF(1);
    
end

[IndVec, PrevInd] = sort(IndVec);

for ii = 1:length(IndVec)
   
    ZscoreSorted(ii,:) = ZScoreCorr(PrevInd(ii),:);
    
end