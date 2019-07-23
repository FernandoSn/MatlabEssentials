function [SpikesDuringOdor] = VSDuringTrial_Beast(ValveTimes,SpikeTimes,TrialWindow)

SpikesDuringOdor = cell(size(ValveTimes.PREXTimes,1),size(ValveTimes.PREXTimes,2),size(SpikeTimes.tsec,1));

for Valve = 1:size(ValveTimes.PREXIndex,1)
    for Conc = 1:size(ValveTimes.PREXIndex,2)
        a(Valve,Conc) = size(ValveTimes.PREXIndex{Valve,Conc},2);
    end
end
maxa = max(a(:));


for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1:size(ValveTimes.PREXTimes,1) 
        for Conc = 1:size(ValveTimes.PREXTimes,2)
            if ~isempty(ValveTimes.PREXTimes{Valve,Conc})
                Opening = ValveTimes.FVSwitchTimesOn{Valve,Conc}(:);
                Closing = Opening + TrialWindow;
                fvl = min(length(Opening),length(Closing));
                Opening = Opening(1:fvl);
                Closing = Closing(1:fvl);

                x = bsxfun(@gt,st,Opening');
                x2 = bsxfun(@lt,st,Closing');
                x3 = x+x2-1;

                SpikesDuringOdor{Valve,Conc,Unit} = sum(x3==1);
                SpikesDuringOdor{Valve,Conc,Unit}(maxa+(a(Valve,Conc)-maxa+1):maxa) = NaN;
            end
        end
    end
end