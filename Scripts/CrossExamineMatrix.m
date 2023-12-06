function [CEM,AssignedValues,AssignIndex,AssignDist] = CrossExamineMatrix(AssignedTo,AssignedFrom,nextorprevious)
% if used for CCG the refspikes are the "Assigned To"
AFM = repmat(AssignedFrom,length(AssignedTo),1);
ATM = repmat(AssignedTo',1,length(AssignedFrom));

% There will be the same number of rows as AssignedTo variables
if strcmp(nextorprevious,'next')
    CEM = AFM-ATM;
    CEM(CEM<0) = inf;
    [AssignDist,AssignIndex] = min(CEM,[],2);
    AssignedValues = AssignedFrom(AssignIndex);
elseif strcmp(nextorprevious,'previous')
    CEM = ATM-AFM;
    CEM(CEM<0) = inf;
    [AssignDist,AssignIndex] = min(CEM,[],2);
    AssignedValues = AssignedFrom(AssignIndex);
elseif strcmp(nextorprevious,'hist')
     CEM = AFM-ATM;
     AssignIndex = NaN;
     AssignedValues = NaN;
     AssignDist = NaN;
end

end