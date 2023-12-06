function [ltd,boolC] = NPX_GetTrialIdx(OM,Conditions,SameTrials)

OlfacMat = OM(:,[1,2,6,7]); 
OlfacMat(:,2) = sum((OM(:,2:3) .* OM(:,4:5))./max(sum(OM(:,4:5),2)),2);

boolIdx = false(size(OlfacMat,1),3);

ltd = zeros(size(OlfacMat,1),1);

for ii = 1:size(Conditions,1)
   
    for kk = 1:size(Conditions,2)
       
        if Conditions(ii,kk) == -1
            
            boolIdx(:,kk) = true;
            boolIdx(:,kk) = boolIdx(:,kk) & (OlfacMat(:,kk+1) ~= 0); %comment out to include no lick trials.
            
        else
            boolIdx(:,kk) = OlfacMat(:,kk+1) == Conditions(ii,kk); 
        end
        
    end
    
    boolIdx = sum(boolIdx,2);
    ltd(boolIdx == 3) = ii;
    boolIdx = false(size(OlfacMat,1),3); 
end

    ids = unique(ltd);
    ids = ids(ids~=0);
    counts = [];
    for ii = 1:length(ids)
        counts = [counts,sum(ltd == ids(ii))];
    end

if SameTrials == 1
   
    minc = min(counts);
    ids = ids(counts ~= minc);
    
    for ii = 1:length(ids)
        ti = find(ltd==ids(ii));
        ltd(ti(minc+1:end)) = 0;
    end
    
elseif SameTrials > 1
    
    ids = ids(counts > SameTrials);
    
    for ii = 1:length(ids)
        ti = find(ltd==ids(ii));
        ltd(ti(SameTrials+1:end)) = 0;
    end
    
end

[~,sidx] = sortrows(OlfacMat,[2,1]);
ltd = ltd(sidx);

% boolC = [];
% if min(ltd) == 0
%    ltd = ltd + 1;
%    boolC = ltd>1;
% end

boolC = ltd>0;

