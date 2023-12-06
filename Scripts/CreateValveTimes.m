function [ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs,tWarpLinear)

%% CreateValveTimesFV (FVO,VLOs)

% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

if ~isempty(FVOpens)
    
    % VL Opens and number of valves (NV)
    [VLOpens, NV] = VLSwitchFinder (VLOs,t);
    
    if numel(VLOpens) == 0
        VLOpens{1} = FVOpens-.1;
    end
    
    
    % VLOpens =  VLOpens(~cellfun(@isempty, VLOpens));   %%%Added this line to account for empty valves not used during experiment.
    % Assign Final Valve SwitchTimes to their associated ValveLink Switches.
    % This fills in FVSwitchTimes that were not close to VLSwitches
    [ValveTimes.FVSwitchTimesOn, ValveTimes.FVSwitchTimesOff] = FVValveAssigner (FVOpens, FVCloses, VLOpens, NV);
    
    %% CreateValveTimesR (ValveTimes.FVSwitchTimesOn,PREX)
    
    % Assign PREX times (i.e. inhalation starts) to FVOpenings
    [ValveTimes.PREXIndex,ValveTimes.PREXTimes,ValveTimes.PREXTimesWarp,ValveTimes.FVTimeWarp] = PREXAssigner (ValveTimes.FVSwitchTimesOn,PREX,tWarpLinear,Fs);

    % Added Nick's fix of isempty to remove all empty cells in case not all
    % valves are used
    ValveTimes.FVSwitchTimesOn =  ValveTimes.FVSwitchTimesOn(~cellfun(@isempty, ValveTimes.FVSwitchTimesOn));
    ValveTimes.FVSwitchTimesOff = ValveTimes.FVSwitchTimesOff(~cellfun(@isempty, ValveTimes.FVSwitchTimesOff));
    ValveTimes.PREXIndex = ValveTimes.PREXIndex(~cellfun(@isempty, ValveTimes.PREXIndex));
    ValveTimes.PREXTimes = ValveTimes.PREXTimes(~cellfun(@isempty, ValveTimes.PREXTimes));
    ValveTimes.PREXTimesWarp = ValveTimes.PREXTimesWarp(~cellfun(@isempty, ValveTimes.PREXTimesWarp));
    ValveTimes.FVTimeWarp = ValveTimes.FVTimeWarp(~cellfun(@isempty, ValveTimes.FVTimeWarp));   
else
    
    ValveTimes = 'NoValve';

end