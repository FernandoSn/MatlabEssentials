function efd = EfdForSpike(KWIKfile,ClusterNumber)


% [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
% [efd] = bhv_combiner_beast(KWIKfile,efd);
% 
% [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker_Beast(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
% efd.PREX = PREX;


%% Get File Names

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

[SpikeTimes] = CreateSpikeTimes(FilesKK,Fs,tWarpLinear);


%%
for Unit = 1:size(SpikeTimes.tsec,1)
    st = SpikeTimes.tsec{Unit};
    for Valve = 1%:size(ValveTimes.PREXTimes,1)
        for Conc = 1%:size(ValveTimes.PREXTimes,2)
            if ~isempty(SpikeTimes.tsec{ClusterNumber})
                [CEM,~,~] = CrossExamineMatrix(SpikeTimes.tsec{ClusterNumber}',st','hist');
                efd.ValveSpikes.RasterAlign{Valve,Conc,Unit} = num2cell(CEM,2);
                for k = 1:size(efd.ValveSpikes.RasterAlign{Valve,Conc,Unit},1)
                    efd.ValveSpikes.RasterAlign{Valve,Conc,Unit}{k} = efd.ValveSpikes.RasterAlign{Valve,Conc,Unit}{k}(efd.ValveSpikes.RasterAlign{Valve,Conc,Unit}{k}>-5 & efd.ValveSpikes.RasterAlign{Valve,Conc,Unit}{k} < 10);
                end
            end
        end
    end
    
end