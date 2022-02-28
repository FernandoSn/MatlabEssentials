function CosDistMat = NPX_GetCosineDistMatrix(traindata)

%deprecated
EucliDistMat = vecnorm(traindata);

EucliDistMat = EucliDistMat' * EucliDistMat;

% traindata = ((traindata - mean(traindata,1))./ std(traindata));
% traindata = traindata ./ (sqrt(sum(traindata.^2)));

DotMat = traindata' * traindata;

CosDistMat = DotMat ./ EucliDistMat; 
%CosDistMat = EucliDistMat ./ DotMat; 
