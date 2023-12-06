function [SpikesDuringOdor] = VSDuringTrial(ValveTimes,SpikeTimes,TrialWindow)

SpikesDuringOdor = cell(size(ValveTimes.PREXIndex,2),size(SpikeTimes.tsec,1));

for i = 1:size(ValveTimes.FVSwitchTimesOff,2)
    a(i) = size(ValveTimes.FVSwitchTimesOff{i},2);
end
maxa = max(a);


for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    for Valve = 1:size(ValveTimes.PREXIndex,2)
        if ~isempty(ValveTimes.PREXTimes{Valve})
            Opening = ValveTimes.FVSwitchTimesOn{Valve}(:);
            Closing = Opening + TrialWindow;
            fvl = min(length(Opening),length(Closing));
            Opening = Opening(1:fvl);
            Closing = Closing(1:fvl);
            
            
            x = bsxfun(@gt,st,Opening');
            x2 = bsxfun(@lt,st,Closing');
            x3 = x+x2-1;
            
            SpikesDuringOdor{Valve,Unit} = sum(x3==1);
            SpikesDuringOdor{Valve,Unit}(maxa+(a(Valve)-maxa+1):maxa) = NaN;
        end
    end
    
end