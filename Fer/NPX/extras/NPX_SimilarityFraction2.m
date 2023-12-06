function [SF, mSF] = NPX_SimilarityFraction2(Raster,PST,Kernelsize,trials)

[ltd, td] = NPX_GetTD(Raster, PST,0.1,trials,true,Kernelsize);
td = zscore(td);

TAPure1 = [];
TAPure2 = [];

% temp1 = td(1:length(trials),:);
% temp2 = td(end-length(trials)+1:end,:);

temp1 = td(ltd == 1,:);
temp2 = td(ltd == size(Raster,1),:);

for ii = 1:length(trials)
   
    idx = true(1,length(trials));
    idx(ii) = false;
    TAPure1 = [TAPure1;mean(temp1(idx,:),1)];
    TAPure2 = [TAPure2;mean(temp2(idx,:),1)];
    
end

TAPure1 = [TAPure1 ; repmat(mean(temp1,1),[(size(Raster,1) - 1) * length(trials),1])];
TAPure2 = [repmat(mean(temp2,1),[(size(Raster,1) - 1) * length(trials),1]) ; TAPure2];

SF = zeros(1,size(td,1));

for ii = 1:size(td,1)

    CosSim1 = dot(TAPure1(ii,:),td(ii,:))./(norm(TAPure1(ii,:))*norm(td(ii,:)));
    CosSim2 = dot(TAPure2(ii,:),td(ii,:))./(norm(TAPure2(ii,:))*norm(td(ii,:)));
    
    CosSim1 = (CosSim1 + 1);
    CosSim2 = (CosSim2 + 1);

    SF(ii) = CosSim1 ./ ( CosSim1 + CosSim2);
    
end


mSF = zeros(1,size(Raster,1));
n = 1;
for ii = 1:length(trials):size(SF,2)
   
    mSF(n) = mean(SF(ii:ii+length(trials)-1));
    
    n = n+1;
end