function [SpikesDuringLaser, SpikesBeforeLaser, SpikesDuringLaserLate] = LSDuringLaser(LaserTimes,SpikeTimes)

SpikesDuringLaser = cell(size(LaserTimes.LaserOff,2),size(SpikeTimes.tsec,1));

for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    
    Opening = LaserTimes.LaserOn{1}(:);
    Closing = LaserTimes.LaserOff{1}(:);
    fvl = min(length(Opening),length(Closing));
    Opening = Opening(1:fvl);
    Closing = Closing(1:fvl);
    PreOpening = Opening - mean(Closing-Opening);
    LateOpening = Opening + mean(Closing-Opening)/2;
    
    %% Count spikes during laser
    x = bsxfun(@gt,st,Opening'); % logical True spikes greater than On time 
    x2 = bsxfun(@lt,st,Closing'); % logical True spikes less than Off time 
    x3 = x+x2-1; % True + True -1 = 1; True + False -1 = 0;
    SpikesDuringLaser{Unit} = sum(x3==1);
    
    %% Count spikes during laser second half (because some cells only transiently activate)
    x = bsxfun(@gt,st,LateOpening'); % logical True spikes greater than On time 
    x2 = bsxfun(@lt,st,Closing'); % logical True spikes less than Off time 
    x3 = x+x2-1; % True + True -1 = 1; True + False -1 = 0;
    SpikesDuringLaserLate{Unit} = sum(x3==1);
    
    %% Count spikes before laser
    x = bsxfun(@gt,st,PreOpening'); % logical True spikes greater than On time 
    x2 = bsxfun(@lt,st,Opening'); % logical True spikes less than Off time 
    x3 = x+x2-1; % True + True -1 = 1; True + False -1 = 0;
    SpikesBeforeLaser{Unit} = sum(x3==1);

end