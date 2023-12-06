function [LR_idx,nonLR_idx] = LRcellPicker2(KWIKfile)

[efd] = EFDmaker_Beast(KWIKfile,'bhv');
SpikeTimes = SpikeTimes_Beast(FindFilesKK(KWIKfile));

%% Poisson means

for unit = 1:size(efd.LaserSpikes.SpikesBeforeLaser,2)
    Control = efd.LaserSpikes.SpikesBeforeLaser{unit};
    Stimulus = efd.LaserSpikes.SpikesDuringLaser{unit};
    [W] = PoissonMean(Control,Stimulus); % poisson mean select laser responsive cells
    LR(unit) = W > 1.7; 
end

LR_idx = find(LR == 1);
nonLR_idx = find(LR == 0);