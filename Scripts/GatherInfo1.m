function [ValveTimes,LaserTimes,LVTimes,SpikeTimes,PREX,Fs,t,BreathStats,tWarp,warpFmatrix,tFmatrix] = GatherInfo1(KWIKfile,varargin)

%% Get File Names
if isempty(varargin)
    FilesKK = FindFilesKK(KWIKfile);
else
    FilesKK.AIP = KWIKfile;
end

%% Get Analog Input Info
[Fs,t,VLOs,FVO,resp,LASER] = NS3Unpacker(FilesKK.AIP);

%% Have to get Final Valve Times to clean up respiration trace
% FV Opens and FV Closes
[FVOpens, FVCloses] = FVSwitchFinder(FVO,t);

%% BreathProcessing (resp,Fs,t)

% Find respiration cycles.
[InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(resp,Fs,t,FVOpens,FVCloses,FilesKK);

% Warp respiration cycles according to zerocrossings using ZXwarp.
% tWarp is necessary for warpingspikes
[tWarp,tWarpLinear,BreathStats.AvgPeriod] = ZXwarp(InhTimes,PREX,POSTX,t,Fs);
BreathStats.AvgRate = 1/BreathStats.AvgPeriod;
BreathStats.CV = std(diff(InhTimes))/BreathStats.AvgPeriod;
BreathStats.BbyB = BbyB;

% % Get Warped breath example
% [warpFmatrix,tFmatrix] = BreathWarpMatrix(RRR,InhTimes,PREX,POSTX,Fs);

%% SpikeProcessing (FilesKK)
% SpikeTimes is a structure with three fields: tsec, stwarped, and units. units contains
% the cluster number from Klustaviewa so you can go back and reference the
% Klustaviewa display. tsec obviously contains the spiketimes for each unit
% in seconds. SpikeTimes.tsec{1} is the combined spike train of all
% identified units. stwarped warps all the spike times in breath cycles
% according to zero-crossings.
if isempty(varargin)
[SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear);
end

%% Create ValveTimes
% ValveTimes is a structure with five fields: FVSwitchTimesOn,
% FVSwitchTimesOff, PREXIndex, PREXTimes, PREXTimeWarp.
% These are each 1xNumberofValves cells. For instance, PREXIndex{1} contains
% the index number of the PreInhalation zero crossing (i.e. the start of
% inhalation) for the respiration cycle that immediately follows all of the
% Final Valve Switches associated with selection of Valve 1. This should
% be the Number of Trials in length.

% 10/22/14 - It's possible I want to analyze spikes on their own or
% with respect to Laser when no Valves were switched. Modify CreateValveTimes to
% allow GatherInfo1 to continue if there are no FV switches.
[ValveTimes] = CreateValveTimes(FVO,VLOs,PREX,t,Fs,tWarpLinear);

% 5/14/15 - Finally admitting that automated detection of breath cycles may
% not be worth it. A new step will check for a "manual" file in
% the RESPfiles folder. If it does not exist we will run a function that
% displays all trial-associated respiration traces and allows the user to
% edit the onset of the first and second inhalations after FV switching.

% manualfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'manual.mat'];
% RESPfile = ['Z:\RESPfiles\',FilesKK.AIP(17:31),'.mat'];
% if exist(manualfile,'file')
%     load(manualfile)
% else
%     [ValveTimes,PREX] = BreathAdjustGUI(ValveTimes,PREX,RRR);
%     save(manualfile,'ValveTimes')
%     save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')
% end

    

%% Create StateIndex
% if ~ischar(ValveTimes)
%     for Valve = 1:length(ValveTimes.PREXIndex)
%         for Trial = 1:length(ValveTimes.PREXIndex{Valve})
%             PreBreathH = BbyB.Height(ValveTimes.PREXIndex{Valve}(Trial)-5:min(ValveTimes.PREXIndex{Valve}(Trial)+10,length(ValveTimes.PREXIndex{Valve})));
%             ValveTimes.StateIndex{Valve}(Trial) = std(PreBreathH)/abs(mean(PreBreathH));
%             ThreeAfter = BbyB.Width(ValveTimes.PREXIndex{Valve}(Trial):ValveTimes.PREXIndex{Valve}(Trial)+2);
%             SixBefore = BbyB.Width(ValveTimes.PREXIndex{Valve}(Trial)-1:ValveTimes.PREXIndex{Valve}(Trial)-1);
%             ValveTimes.Sniff{Valve}(Trial) = 1/mean(ThreeAfter);
%             ValveTimes.SniffDiff{Valve}(Trial) = 1/(mean(ThreeAfter))-1/mean(SixBefore);
%         end
%     end
% end
%% Create LaserTimes
% LaserTimes only needs to be created in optogenetic experiments.
% First, try to find Laser on and off times. If there are no pulses
% make LaserTimes 'NoLaser'.
[LaserTimes] = CreateLaserTimes(LASER,PREX,t,tWarpLinear,Fs);

% [LaserOn,LaserOff] = LaserPulseFinder(LASER,t);
%
% if ~isempty(LaserOn)
%
%     % Absolute Laser on and off times in the recording
%     LaserTimes.LaserOn = LaserOn;
%     LaserTimes.LaserOff = LaserOff;
%     LaserTimes.LaserTimeWarpOn  = tWarpLinear(round(LaserTimes.LaserOn.*Fs));
%     LaserTimes.LaserTimeWarpOff  = tWarpLinear(round(LaserTimes.LaserOff.*Fs));
%     [~,LaserTimes.PREXTimes,LaserTimes.PREXIndex] = CrossExamineMatrix(LaserTimes.LaserOn,PREX,'next');
%     LaserTimes.PREXTimeWarp  = tWarpLinear(round(LaserTimes.PREXTimes.*Fs));
%

%% Create LVTimes
% If there are laser and valve pulses then we want to label valve switches
% by their laser status. I will embed a LaserStat attribute, but really the
% system is: LVTimes{1} is the ValveTimes with the laser off. and
% LVTimes{2} is when the laser is on.
if ~ischar(ValveTimes) && ~ischar(LaserTimes)
    [LVTimes] = CreateLVTimes(LaserTimes,ValveTimes);
else
    LVTimes = 'NoLVTimes';
end

end