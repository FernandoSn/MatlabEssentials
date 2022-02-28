function PseudoMat = NPX_GetAveTrajMat(traindata, NoIntervals, trials,TotalTrials)

%Deprecated, this func is included in NPX_GetNeuralTrajectoryMat2

PseudoMat = [];

NoStimuli = size(traindata,1) / NoIntervals / TotalTrials;

TempCell = cell(1,NoStimuli);

for ii = 1:NoIntervals
    for kk = 1:NoStimuli

            TempCell{kk} = [TempCell{kk}; mean(traindata(trials+(kk-1)*TotalTrials...
                +(ii-1)*(TotalTrials * NoStimuli),:),1)];

    end
end



for kk = 1:NoStimuli
    
    PseudoMat = [PseudoMat;TempCell{kk}];
    
end