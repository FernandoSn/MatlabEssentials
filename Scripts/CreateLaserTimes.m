function [LaserTimes] = CreateLaserTimes(LASER,PREX,t,tWarpLinear,Fs)

%% Create LaserTimes
% LaserTimes only needs to be created in optogenetic experiments.
% First, try to find Laser on and off times. If there are no pulses
% leave LaserTimes empty. 
% [LaserTimes] = CreateLaserTimes(ValveTimes,LASER,t);
[LaserOn,LaserOff] = LaserPulseFinder(LASER,t);

if ~isempty(LaserOn)
    
    % Absolute Laser on and off times in the recording
    LaserTimes.LaserOn{1} = LaserOn;
    LaserTimes.LaserOff{1} = LaserOff;
    
    % In some experiments, laser is pulsed. We want to align trials to the
    % first pulse in a series, not all the pulses. 
    dLTon = diff(LaserTimes.LaserOn{1});
    SpacedTimesOn = [1 find(dLTon>4)+1];
    
    dLToff = diff(LaserTimes.LaserOn{1});
    SpacedTimesOff = [find(dLToff>4) length(LaserTimes.LaserOff{1})];
    
    LaserTimes.LaserOn{1} = LaserTimes.LaserOn{1}(SpacedTimesOn);
    LaserTimes.LaserOff{1} = LaserTimes.LaserOff{1}(SpacedTimesOff);
    
    % Assign PREX times (i.e. inhalation starts) to Laser pulses
    [LaserTimes.PREXIndex,LaserTimes.PREXTimes] = PREXAssigner(LaserTimes.LaserOn,PREX,tWarpLinear,Fs);
else
    LaserTimes = 'NoLaser';
end