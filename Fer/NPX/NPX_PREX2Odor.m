function [PREXOdorTimes,Odors] = NPX_PREX2Odor(PREXmat,OlfacMat,RespNum,Valves)

%OlfacMat = Olfactometer matrix get by calling:
%OlfacMat = importdata('Olfactometer8548562');

%PREXmat, matrix get by PostBold.

%RespNum, the respiration number you want. 1,2 or 3.
 

if nargin > 3
   
    idx = OlfacMat(:,2) == Valves;
    
    idx = sum(idx,2) > 0;
    
    OlfacMat = OlfacMat(idx,:);
    
    PREXmat = PREXmat(idx,:);
    
end

Odors = unique(OlfacMat(:,2))';

PREXOdorTimes = cell(length(Odors),1);

for ii = 1:length(Odors)
   
    PREXOdorTimes{ii} = PREXmat(Odors(ii) == OlfacMat(:,2),RespNum);
    
end

