function [LR_idx,nonLR_idx,auROC] = LRcellPicker(KWIKfile)

[efd] = EFDmaker_Beast(KWIKfile,'bhv');
SpikeTimes = SpikeTimes_Beast(FindFilesKK(KWIKfile));

%% Identify LR and nonLR cells

for unit = 1:size(efd.ValveTimes,1)
    Control = efd.ValveTimes.SpikesBeforeLaser{unit};
    Stimulus = efd.ValveTimes.SpikesDuringLaser{unit};
    [auROC(unit), p] = RankSumROC(Control, Stimulus); % ranksum select laser responsive cells
    Rate(unit) = (mean(Control));
    LR(unit) =  auROC(unit) > 0 & p > 0;
end

LR_idx = find(LR == 1);


 
