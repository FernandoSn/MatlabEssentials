function [MultiCycleSpikeCount,MultiCycleSpikeRate,MultiCycleBreathPeriod] = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,CyclestoCheck)
if ~iscell(CyclestoCheck) == 1
    CycleList = 1:CyclestoCheck;
else
    CycleList = cell2mat(CyclestoCheck);
    CyclestoCheck = length(CycleList);
end

MultiCycleSpikeCount = cell(size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1),CyclestoCheck);
MultiCycleSpikeRate = cell(size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1),CyclestoCheck);
MultiCycleBreathPeriod = cell(CyclestoCheck,1);

for i = 1:size(ValveTimes.PREXIndex,2)
    a(i) = size(ValveTimes.PREXIndex{i},2);
end
maxa = max(a);

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    for Valve = 1:size(ValveTimes.PREXIndex,2)
        if ~isempty(ValveTimes.PREXTimes{Valve})
            for Cycle = 1:length(CycleList)
                Adder = CycleList(Cycle)-1;
                ValveTimes.PREXIndex{Valve}(((ValveTimes.PREXIndex{Valve}(:)+1)+Adder)>length(PREX)) = [];
                Beginning = PREX(ValveTimes.PREXIndex{Valve}(:)+Adder);
                EndofCycle = PREX(ValveTimes.PREXIndex{Valve}(:)+1+Adder);
                MultiCycleBreathPeriod{Valve,Cycle} = EndofCycle-Beginning;
                try
                    ux = bsxfun(@gt,st,Beginning);
                    x2 = bsxfun(@lt,st,EndofCycle);
                    x3 = x+x2-1;
                    
                    MultiCycleSpikeCount{Valve,Unit,Cycle} = sum(x3==1);
                    MultiCycleSpikeCount{Valve,Unit,Cycle}(maxa+(a(Valve)-maxa+1):maxa) = NaN;
                    MultiCycleSpikeRate{Valve,Unit,Cycle} = MultiCycleSpikeCount{Valve,Unit,Cycle}./(EndofCycle-Beginning);
                catch
                    for Trial = 1:size(ValveTimes.PREXIndex{Valve},2);
                        % Loop through the trials and if the cycle is too far
                        % ... or just use PREX and CyclestoCheck to figure it
                        % out.. Then make those NaNs.
                        MultiCycleSpikeCount{Valve,Unit,Cycle}(Trial) = sum(st>Beginning(Trial) & st<EndofCycle(Trial));
                        MultiCycleSpikeRate{Valve,Unit,Cycle}(Trial) = sum(st>Beginning(Trial) & st<EndofCycle(Trial))/(EndofCycle(Trial)-Beginning(Trial));
                        
                    end
                    MultiCycleSpikeCount{Valve,Unit,Cycle}(maxa+(a(Valve)-maxa+1):maxa) = NaN;
                    MultiCycleSpikeRate{Valve,Unit,Cycle}(maxa+(a(Valve)-maxa+1):maxa) = NaN;
                    
                end
            end
            
        end
    end
    
    
end