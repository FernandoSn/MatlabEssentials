function [SpikeLatency,SpikeProb,LRprim_idx,LRsec_idx] = CHR2Picker(KWIKfile,numPulse)

[efd] = EFDmaker(KWIKfile);
SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfile));

%% Sustained spiking



%% Latency to spike to first pulse

firstPulse = efd.LaserTimes.LaserOn{1}(:)';
% firstSpike = zeros(size(LRindex,2), size(firstPulse,2));

for unit = 1:size(efd.LaserSpikes.SpikesBeforeLaser,2)
    spikeTime = SpikeTimes.tsec{unit};
    for trial = 1:size(firstPulse,2)
        idx = find(spikeTime > firstPulse(trial),1);
        if ~isempty(idx)
            firstSpike(unit,trial) = spikeTime(idx);
        else firstSpike(unit,trial) = NaN;
        end
    end
end

SpikeLatency = mean(bsxfun(@minus,firstSpike,firstPulse),2);

%% Probability of spiking to each pulse

timeWindow = 0.005; % is there a spike within 5 msec after first pulse
% spikeSum = zeros(size(LRindex,2));

for unit = 1:size(efd.LaserSpikes.SpikesBeforeLaser,2)
    spikeTime = SpikeTimes.tsec{unit};
    for pulse = 1:numPulse
        whichPulse = efd.LaserTimes.LaserOn{pulse}(:)';
        counter = 0;
        for trial = 1:size(firstPulse,2)
            idx = find(spikeTime > whichPulse(trial) & spikeTime < (whichPulse(trial)+timeWindow), 1);
            if ~isempty(idx)
                counter = counter + 1;
            end
        end
        spikeSum(unit,pulse) = counter;
    end
end

SpikeProb = spikeSum/size(firstPulse,2);

%% Indexing primary and secondary CHR2+ cells

for unit = 2:size(efd.LaserSpikes.SpikesBeforeLaser,2)
    Control = efd.LaserSpikes.SpikesBeforeLaser{unit};
    Stimulus = efd.LaserSpikes.SpikesDuringLaser{unit};
    [auROC, p] = RankSumROC(Stimulus, Control); % ranksum select laser responsive cells
    Rate(unit) = (mean(Control));
    LRprim(unit) = auROC>.7 & p<.05 & SpikeLatency(unit)<.005; % & SpikeProb(unit,1)>.8;
    LRsec(unit) = auROC>.7 & p<.05 & SpikeLatency(unit)>.005; % & SpikeProb(unit,1)>.3;
end

LRprim_idx = find(LRprim == 1);
LRsec_idx = find(LRsec == 1);
