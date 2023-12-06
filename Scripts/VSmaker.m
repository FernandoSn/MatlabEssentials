function [ValveSpikes,LaserSpikes,LVSpikes] = VSmaker(ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX)

%% Odor processing
if isfield(ValveTimes,'PREXTimes')
    %% Aligned Raster
    [ValveSpikes.RasterAlign] = VSRasterAlign(ValveTimes,SpikeTimes);
        [ValveSpikes.RasterFV] = VSRasterFV(ValveTimes,SpikeTimes);

    %% Spikes in Multi Cycles
    [ValveSpikes.MultiCycleSpikeCount,ValveSpikes.MultiCycleSpikeRate,ValveSpikes.MultiCycleBreathPeriod] = VSMultiCycleCount(ValveTimes,SpikeTimes,PREX,5);
    %% Spikes During Odor
    ValveSpikes.SpikesDuringOdor = VSDuringOdor(ValveTimes,SpikeTimes);
    %% Spikes During Trial
    TrialWindow = 5;
    ValveSpikes.SpikesDuringTrial = VSDuringTrial(ValveTimes,SpikeTimes,TrialWindow);
else
    ValveSpikes = [];
end

%% Laser processing
if isfield(LaserTimes,'LaserOn')
    %% Laser Aligned Raster
    [LaserSpikes.RasterAlign] = VSRasterAlignLaser(LaserTimes,SpikeTimes);
    %% Spikes During Laser
    [LaserSpikes.SpikesDuringLaser, LaserSpikes.SpikesBeforeLaser, LaserSpikes.SpikesDuringLaserLate] = LSDuringLaser(LaserTimes,SpikeTimes);
else
    LaserSpikes=[];
end

%% Odor and Laser processing together
% if ~isstr(LVTimes)
%     for LS = 1:2
%         %% Laser Aligned Raster
%         [LVSpikes{LS}.RasterAlign] = VSRasterAlign(LVTimes{LS},SpikeTimes);
%     end
% else
    LVSpikes = [];
% end

end
