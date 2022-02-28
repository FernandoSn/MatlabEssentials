function UniqueVec = GetUniqueCorrs(FirstMat,SecondMat)

%This func returns the unit ids of significant correlations that are
%exclusive of one of the two matrices.

FirstVec = [FirstMat(:,191),FirstMat(:,193)];
SecondVec = [SecondMat(:,191),SecondMat(:,193)];
UniqueVec = [];
% isUnique = true;

for ii = 1:size(FirstVec,1)
   
    isUnique = true;
    for kk = 1:size(SecondVec,1)
        
        a = sum(FirstVec(ii,:) == SecondVec(kk,:));
        
        b = sum(FirstVec(ii,:) == fliplr(SecondVec(kk,:)));
        
        if (a == 2 || b == 2)
           
            isUnique = false;
        end
        
    end
    
    if isUnique
       
        UniqueVec = [UniqueVec; FirstMat(ii,:)];
        
    end
    
end