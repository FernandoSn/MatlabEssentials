function CSD = NPX_CSD(LFP)

%LFP is the matrix containing LFP data. (channels x samples)
%Deprecated. This is equivalent to calculating the second spatial
%derivative with (diff(diff(Mat))). Equation taken from Kaur,2005.

CSD = [];

for ii = 2:size(LFP,1) - 1
   
    CSD = [CSD; (LFP(ii-1,:) + LFP(ii+1,:) - 2*LFP(ii,:)) ./ (20.^2)];
    
end