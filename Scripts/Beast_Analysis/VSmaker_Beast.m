function [ValveSpikes,LaserSpikes,LVSpikes] = VSmaker_Beast(ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX)

%% Odor processing
if isfield(ValveTimes,'PREXTimes')
    %% Aligned Raster
    [ValveSpikes.RasterAlign] = VSRasterAlign_Beast(ValveTimes,SpikeTimes);
    [ValveSpikes.RasterFV] = VSRasterFV_Beast(ValveTimes,SpikeTimes);

    %% Spikes in Multi Cycles
    [ValveSpikes.MultiCycleSpikeCount,ValveSpikes.MultiCycleSpikeRate,ValveSpikes.MultiCycleBreathPeriod,ValveSpikes.Cycles] = VSMultiCycleCount_Beast(ValveTimes,SpikeTimes,PREX,2);
    %% Spikes During Odor
    ValveSpikes.SpikesDuringOdor = VSDuringOdor_Beast(ValveTimes,SpikeTimes);
    %% Spikes During Trial
    TrialWindow = 5;
    ValveSpikes.SpikesDuringTrial = VSDuringTrial_Beast(ValveTimes,SpikeTimes,TrialWindow);
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
if ~isstr(LVTimes)
    for LS = 1:2
        %% Aligned Raster
        [LVSpikes{LS}.RasterAlign] = VSRasterAlign_Beast(LVTimes{LS},SpikeTimes);
        
        %% Spikes in Multi Cycles
        [LVSpikes{LS}.MultiCycleSpikeCount,LVSpikes{LS}.MultiCycleSpikeRate,LVSpikes{LS}.MultiCycleBreathPeriod,LVSpikes{LS}.Cycles] = VSMultiCycleCount_Beast(ValveTimes,SpikeTimes,PREX,{0:2});
    end
else
    LVSpikes = [];
end

end
