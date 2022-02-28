function PseudoMat = NPX_GetNeuralTrajectoryMat(Raster, NoIntervals, trials,Zscore)

%Raster =  cell array from VSRasterAlign_Beast
%NoIntervals = number of divisions for the 1 sec epoch
%trials = vector with the trial numbers
%Zscore, true or false

PseudoMat = [];

epochs = 0:1/NoIntervals:1;

if Zscore
  NoStimuli = size(Raster,1) - 1;
else
  NoStimuli = size(Raster,1);  
end

FirstTrial = 6;

TotalTrials = FirstTrial:size(Raster{1,1,1},1);

trials = trials-(FirstTrial-1);

TempCell = cell(1,NoStimuli);

for ii = 1:NoIntervals
   
    [~, traindata] = BinRearranger(Raster, [epochs(ii) epochs(ii+1)], 1/NoIntervals, TotalTrials);
        
    if Zscore
       traindata = NPX_GetZScoredPseudoMat(traindata',length(TotalTrials))'; 
    end
    
    for kk = 1:NoStimuli
       
        TempCell{kk} = [TempCell{kk}; mean(traindata(trials+(kk-1)*length(TotalTrials),:),1)];
        
    end
    
end

for kk = 1:NoStimuli
    
    PseudoMat = [PseudoMat;TempCell{kk}];
    
end