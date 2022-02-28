function SimMatrix = NPX_GetSimMatrix(td, metric)

%traindata = matrix of trials/odors x units.
%metric = 'ss','cos','cov','corr'


badcell = any(isinf(td) | isnan(td));
%fprintf('Badcells: %d \n', sum(badcell))
td(:,badcell) = [];

td = td';

if strcmp('ss',metric)
    
    SimMatrix = td' * td;
    
elseif strcmp('cos',metric)
    
    td = td ./ sqrt(sum(td.^2));
    SimMatrix = td' * td;
    
    
elseif strcmp('cov',metric)
    
    td = td - mean(td);
    SimMatrix = (td'*td)./(size(td,1)-1);
    
elseif strcmp('corr',metric)
    
    td = zscore(td);
    %td = zscore(td')';
    SimMatrix = (td'*td)./(size(td,1)-1);
    
end


