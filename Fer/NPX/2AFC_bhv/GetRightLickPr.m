function [RLP,RLCount,TotalTrials] = GetRightLickPr(OlfacMat,isPlot,Trials)

if nargin > 2  
    OlfacMat = OlfacMat( (Trials(1)<=OlfacMat(:,1)) & (Trials(2)>=OlfacMat(:,1)) ,:);
end

Right = 2;

%OlfacMat = OlfacMat(OlfacMat(:,3) ~= 0,:);
OlfacMat = OlfacMat((OlfacMat(:,3) == 2) | (OlfacMat(:,3) == 3),:);


Odors = unique(OlfacMat(:,2));

RLCount = zeros(1,length(Odors));
TotalTrials = zeros(1,length(Odors));

for ii = 1:numel(Odors)
    
    isRight = OlfacMat(OlfacMat(:,2) == Odors(ii),3) == Right;
    
    RLCount(ii) = sum(isRight);
    TotalTrials(ii) = length(isRight);
    
end

RLP = RLCount ./ TotalTrials;

if isPlot
    figure
    %plot([0,1,3,5,7,9,10],RLP)
    plot(RLP)
    ylim([0,1]);
    ylabel('probability')
    xlabel('mixture');
    makepretty;
end