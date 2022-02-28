function [trainlabel,traindata] = NPX_GetTAtraindata(Raster,PST,trials,PREX,POSTX)

if nargin == 3
    [trainlabel,traindata] = BinRearranger(Raster,PST,PST(2) - PST(1),trials);
elseif nargin == 5
    
    %PST should be a ValveTimes struct for this condition.
    
    [trainlabel, traindata] = NPX_GetSingleInhTD(Raster,PST, PREX, POSTX, trials);
end

TL = unique(trainlabel,'stable');
TA = zeros(length(TL), size(traindata,2));


for ii = 1:length(TL)

    TA(ii,:) = nanmean(traindata(trainlabel == TL(ii),:),1);
    
end

traindata = TA;
trainlabel = TL;
