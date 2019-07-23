function [MultiCycleSpikeCount,MultiCycleSpikeRate,MultiCycleBreathPeriod,CycleList] = VSMultiCycleCount_Beast(ValveTimes,SpikeTimes,PREX,CyclestoCheck)
if ~iscell(CyclestoCheck) == 1
    CycleList = 1:CyclestoCheck;
else
    CycleList = cell2mat(CyclestoCheck);
    CyclestoCheck = length(CycleList);
end

MultiCycleSpikeCount = cell(size(ValveTimes.PREXIndex,1),size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1),CyclestoCheck);
MultiCycleSpikeRate = cell(size(ValveTimes.PREXIndex,1),size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1),CyclestoCheck);
MultiCycleBreathPeriod = cell(CyclestoCheck,1);

%%
for Valve = 1:size(ValveTimes.PREXIndex,1)
            for Conc = 1:size(ValveTimes.PREXIndex,2)
                a(Valve,Conc) = size(ValveTimes.PREXIndex{Valve,Conc},2);
            end
end
maxa = max(a(:));
%%

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    for Valve = 1:size(ValveTimes.PREXIndex,1)
        for Conc = 1:size(ValveTimes.PREXIndex,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                for Cycle = 1:length(CycleList)
                    if Valve == 15 && Conc == 4 && Cycle == 2
                        d = 1;
                    end
                    Adder = CycleList(Cycle)-1;
                    VT = ValveTimes.PREXIndex{Valve,Conc};
                    VT((ValveTimes.PREXIndex{Valve,Conc}(:)+1+Adder)>length(PREX)) = [];
                    Beginning = PREX(VT(:)+Adder);
                    EndofCycle = PREX(VT(:)+1+Adder);
                    MultiCycleBreathPeriod{Valve,Conc,Cycle} = EndofCycle-Beginning;
                    try
                        x = bsxfun(@gt,st,Beginning);
                        x2 = bsxfun(@lt,st,EndofCycle);
                        x3 = x+x2-1;
                        
                        MultiCycleSpikeCount{Valve,Conc,Unit,Cycle} = sum(x3==1);
                        %                         MultiCycleSpikeCount{Valve,Conc,Unit,Cycle}(maxa+(a(Valve,Conc)-maxa+1):maxa) = NaN;
                        MultiCycleSpikeCount{Valve,Conc,Unit,Cycle}(length(MultiCycleSpikeCount{Valve,Conc,Unit,Cycle})+1:maxa) = NaN;
                        Beginning(length(Beginning)+1:maxa) = NaN;
                        EndofCycle(length(EndofCycle)+1:maxa) = NaN;
                        MultiCycleSpikeRate{Valve,Conc,Unit,Cycle} = MultiCycleSpikeCount{Valve,Conc,Unit,Cycle}./(EndofCycle-Beginning);
                    catch
                        for Trial = 1:size(ValveTimes.PREXIndex{Valve,Conc},2);
                            % Loop through the trials and if the cycle is too far
                            % ... or just use PREX and CyclestoCheck to figure it
                            % out.. Then make those NaNs.
                            MultiCycleSpikeCount{Valve,Conc,Unit,Cycle}(Trial) = sum(st>Beginning(Trial) & st<EndofCycle(Trial));
                            MultiCycleSpikeRate{Valve,Conc,Unit,Cycle}(Trial) = sum(st>Beginning(Trial) & st<EndofCycle(Trial))/(EndofCycle(Trial)-Beginning(Trial));
                            
                        end
                        MultiCycleSpikeCount{Valve,Conc,Unit,Cycle}(maxa+(a(Valve,Conc)-maxa+1):maxa) = NaN;
                        MultiCycleSpikeRate{Valve,Conc,Unit,Cycle}(maxa+(a(Valve,Conc)-maxa+1):maxa) = NaN;
                        
                    end
                end
            end
        end
    end
    
    
end