function [PREXOdorTimes,Odors] = NPX_PREX2OdorDepre(PREXmat,OlfacMat,RespNum,Valves)

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



OlfacMat(:,1) = OlfacMat(:,1) - (OlfacMat(1) - 1); %Making sure the 1st element is 1.

OlfacMat(:,3) = 0; %replace with ones to ignore MFC data.

OlfacMat(:,2) = OlfacMat(:,3) * max(OlfacMat(:,2)) + OlfacMat(:,2);

NumOdors = sum(OlfacMat(:,1) == 1); %%Number of odors.

Odors = sort(OlfacMat(1:NumOdors,2)); %%Vector with odor numbers

Trials = size(OlfacMat,1) / NumOdors;

PREXOdorTimes = zeros(NumOdors ,Trials); %%allocating

PREX = PREXmat(:,RespNum); %Respiration Vec of all odors.

for ii = 1: length(Odors)
   
    PREXOdorTimes(ii,:) = PREX(OlfacMat(:,2) == Odors(ii));
    
end

