function [LS,PS] = NPX_LifetimeSparseness(Raster,PST,Trials,OM,cond)

if nargin > 3
   
    idx1 = find(OM(:,1) == Trials(1),1,'first');
    idx2 = find(OM(:,1) == Trials(end),1,'last');
    [ltd,bc] = NPX_GetTrialIdx(OM(idx1:idx2,:),cond,0);
    [~, td] = NPX_GetTD(Raster, PST,PST(2) - PST(1),Trials);
    ltd = ltd(bc);
    td = td(bc,:);
    
    [ltd,ti] = sort(ltd);
    td = td(ti,:);
    
else
   
    [ltd, td] = NPX_GetTD(Raster, PST,PST(2) - PST(1),Trials);
    [~, tdp] = NPX_GetTD(Raster, [-2,-1],1,Trials);
   
end




%[ltd, td] = NPX_GetTD(Raster, PST,PST(2)-PST(1),Trials);

%[~,tdp] = NPX_GetTD(Raster, PST - (PST(2)+1) ,BinSize,Trials);

%tdz = (td - mean(tdp));%./ std(tdp);
%tdz(tdz<0) = 0;
tdz = td;
%tdz = zscore(td);

labels = unique(ltd);

tdaz = zeros(numel(labels),size(td,2));
for ii = 1:numel(labels)
    tdaz(ii,:) = mean( tdz(ltd == labels(ii),:) );
end

%tdaz = tdz;

%tdaz(tdaz<0) = 0;
%tdaz = abs(tdaz);

LS = (1 - sum( tdaz./size(tdaz,1) ).^2 ./ sum( tdaz.^2./size(tdaz,1) )) ./ (1 - 1./size(tdaz,1));

tdaz = tdaz';

PS = (1 - sum( tdaz./size(tdaz,1) ).^2 ./ sum( tdaz.^2./size(tdaz,1) )) ./ (1 - 1./size(tdaz,1));