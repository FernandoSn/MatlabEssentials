function CorrMat = NPX_GetTrialAveragedCorrMat2(traindata, trials ,traindataPr)

%Deprecatd

if nargin == 3
   
    traindata = NPX_GetZScoredPseudoMat(traindata',trials,false,traindataPr')';
    %traindata = NPX_GetZScoredPseudoMat(traindata',trials,false)';
    
end

odors = size(traindata,1) ./ trials;

avemat = [];
for ii =  1 : trials : size(traindata,1)
    avemat = [avemat;mean(traindata(ii:ii+trials-1,:))];
end

idx1 = (1:2:trials)';
idx2 = (2:2:trials)';

CorrMat = corr(avemat');

for odor = 1:odors
    
    c = (odor - 1) * trials;
    vec1 = mean(traindata(idx1 + c,:))';
    vec2 = mean(traindata(idx2 + c,:))';
   
    CorrMat(odor,odor) = corr(vec1,vec2);
    
end