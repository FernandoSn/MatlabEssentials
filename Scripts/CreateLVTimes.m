function [LVTimes] = CreateLVTimes(LaserTimes,ValveTimes)
% If there are laser and valve pulses then we want to label valve switches
% by their laser status. I will embed a LaserStat attribute, but really the
% system is: LVTimes{1} is the ValveTimes with the laser off. and
% LVTimes{2} is when the laser is on. 

VT = ValveTimes;
FN = fieldnames(VT);

for i = 1:length(FN)
    
    for Valve = 1:length(ValveTimes.PREXTimes)
        [~,~,~,AssignDist] = CrossExamineMatrix(ValveTimes.PREXTimes{Valve},LaserTimes.LaserOn{1},'previous');
        TrialType{Valve} = AssignDist<5; % This is hardcoded at
        % 5 now, but should be flexible later. If distance between PREX and
        % previous LaserOn is less than some number it was a laser trial.
        LVTimes{1}.(FN{i}){Valve} = VT.(FN{i}){Valve}(TrialType{Valve}==0);
        LVTimes{2}.(FN{i}){Valve} = VT.(FN{i}){Valve}(TrialType{Valve}==1);
    end
    
end
