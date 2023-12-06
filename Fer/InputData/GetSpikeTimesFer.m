function SpikeTimes = GetSpikeTimesFer(KWIKfile)


FilesKK = FindFilesKK(KWIKfile);


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

[SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear);