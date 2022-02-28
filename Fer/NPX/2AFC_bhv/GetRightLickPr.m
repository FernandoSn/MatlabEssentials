function RLP = GetRightLickPr(OlfacMat)

OlfacMat = OlfacMat(OlfacMat(:,3) ~= 0,:);

RLP = [];
Odors = unique(OlfacMat(:,2));

for ii = 1:numel(Odors)
    
    isRight = OlfacMat(OlfacMat(:,2) == Odors(ii),3) == 2;
    
    RLP = [RLP, sum(isRight) / length(isRight)];
    
end