function [PREXIndex,PREXTimes,PREXTimeWarp,FVTimeWarp] = PREXAssigner (FVSwitchTimesOn,PREX,tWarpLinear,Fs)

PREXTimeWarp = cell(size(FVSwitchTimesOn));
PREXTimes = cell(size(FVSwitchTimesOn));
PREXIndex = cell(size(FVSwitchTimesOn));

for i = 1:length(FVSwitchTimesOn)
    if ~isempty(FVSwitchTimesOn{i})
        [~,PREXTimes{i},PREXIndex{i}] = CrossExamineMatrix(FVSwitchTimesOn{i},PREX,'next');        
    end
PREXIndex{i} = PREXIndex{i}';    
PREXTimeWarp{i}  = tWarpLinear(round(PREXTimes{i}.*Fs));
FVTimeWarp{i} = tWarpLinear(round(FVSwitchTimesOn{i}.*Fs));
end

end