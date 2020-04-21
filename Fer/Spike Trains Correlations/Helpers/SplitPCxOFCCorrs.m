function [PosMat, NegMat] = SplitPCxOFCCorrs(Matrix,Range)

NoCorrs = size(Matrix,1);
PosMat = [];
NegMat = [];

for ii = 1:NoCorrs
    
   if(Matrix(ii,194) < Range(1) || Matrix(ii,194) >= Range(2))
       
       NegMat = [NegMat;Matrix(ii,:)];
       
   else
       
       PosMat = [PosMat;Matrix(ii,:)];
       
   end
    
end