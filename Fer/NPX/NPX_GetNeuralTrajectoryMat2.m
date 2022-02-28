function PseudoMat = NPX_GetNeuralTrajectoryMat2(Raster,RasterPr, NoIntervals,Trials)

%Raster =  cell array from VSRasterAlign_Beast
%NoIntervals = number of divisions for the 1 sec epoch
%trials = vector with the trial numbers
%Zscore, true or false

traindata = [];

Edge1 = -0.2;
Edge2 = 1;

t = Edge2 - Edge1;

epochs = Edge1:t/NoIntervals:Edge2;

for ii = 1:NoIntervals
   
    [~, traindataTemp] = BinRearranger(Raster, [epochs(ii) epochs(ii+1)], t/NoIntervals, Trials);
    
        
    if ~isempty(RasterPr)
        
       [~, traindataPr] = BinRearranger(RasterPr, [epochs(ii) epochs(ii+1)], t/NoIntervals, Trials);
        
       traindataTemp = NPX_GetZScoredPseudoMat(traindataTemp',length(Trials),0,traindataPr')';
       
    end
    
    traindataTemp = traindataTemp(length(Trials)+1:end,:);
%     traindataTemp = traindataTemp(2:end,:);
    
    traindata = [traindata;traindataTemp];
    
end


Trials = 1:length(Trials);
% Trials = 1;

PseudoMat = [];

NoStimuli = size(traindata,1) / NoIntervals / length(Trials);

TempCell = cell(1,NoStimuli);

for ii = 1:NoIntervals
    for kk = 1:NoStimuli

            TempCell{kk} = [TempCell{kk}; mean(traindata(Trials+(kk-1)*length(Trials)...
                +(ii-1)*(length(Trials) * NoStimuli),:),1)];

    end
end



for kk = 1:NoStimuli
    
    PseudoMat = [PseudoMat;TempCell{kk}];
    
end