function [efd] = bhv_combiner(KWIKfile,efd)

% get a list of behavior files
[a,b] = fileparts(KWIKfile);
D = dir(fullfile(a,'\bhv\*.csv'));
[Y,I] = sort([D.datenum]);
D = D(I);
rOdors = zeros(1,length(efd.ValveTimes.FVSwitchTimesOn{1}));
PrevTrials = 0;

for bf = 1:length(D)
    bfile = fullfile(a,'\bhv\',D(bf).name);
    disp(bfile)
    
    bT = readtable(bfile,'HeaderLines',1,'ReadVariableNames',0);
    fv_on_idx = strcmp(bT.Var2,'FVOnTime');
    bFVOdors = bT.Var1(fv_on_idx);
    bFVConcs = bT.Var4(fv_on_idx);
    bFVOpens = bT.Var3(fv_on_idx)/1000;
    
    FVidx_offset = 1+PrevTrials
    rOdors(FVidx_offset:FVidx_offset+length(bFVOpens)-1) = bFVOdors;
%     rConcs(FVidx_offset:FVidx_offset+length(bFVOpens)-1) = bFVConcs;

    PrevTrials = length(bFVOpens) + PrevTrials;

end

%%
for od = unique(rOdors)
    if od > 0
%         for co = 1:length(unique(rConcs))
            efd.ValveTimes.FVSwitchTimesOn{od} = [];
            efd.ValveTimes.FVSwitchTimesOff{od} = [];
            efd.ValveTimes.PREXIndex{od} = [];
            efd.ValveTimes.PREXTimes{od} = [];
            efd.ValveTimes.PREXTimesWarp{od} = [];
            efd.ValveTimes.FVTimeWarp{od} = [];
%         end
    end
end

%%
for k = 1:length(efd.ValveTimes.FVSwitchTimesOn{1})
    if rOdors(k) ~= 0
        if isempty(efd.ValveTimes.FVSwitchTimesOn{rOdors(k)}) % putting the first trial of an odor into its cell
            efd.ValveTimes.FVSwitchTimesOn{rOdors(k)} = efd.ValveTimes.FVSwitchTimesOn{1}(k);
            efd.ValveTimes.FVSwitchTimesOff{rOdors(k)} = efd.ValveTimes.FVSwitchTimesOff{1}(k);
            efd.ValveTimes.PREXIndex{rOdors(k)} = efd.ValveTimes.PREXIndex{1}(k);
            efd.ValveTimes.PREXTimes{rOdors(k)} = efd.ValveTimes.PREXTimes{1}(k);
            efd.ValveTimes.PREXTimesWarp{rOdors(k)} = efd.ValveTimes.PREXTimesWarp{1}(k);
            efd.ValveTimes.FVTimeWarp{rOdors(k)} = efd.ValveTimes.FVTimeWarp{1}(k);
        else
            n = numel(efd.ValveTimes.FVSwitchTimesOn{rOdors(k)}); % putting subsequent trials in
            efd.ValveTimes.FVSwitchTimesOn{rOdors(k)}(n+1) = efd.ValveTimes.FVSwitchTimesOn{1}(k);
            efd.ValveTimes.FVSwitchTimesOff{rOdors(k)}(n+1) = efd.ValveTimes.FVSwitchTimesOff{1}(k);
            efd.ValveTimes.PREXIndex{rOdors(k)}(n+1) = efd.ValveTimes.PREXIndex{1}(k);
            efd.ValveTimes.PREXTimes{rOdors(k)}(n+1) = efd.ValveTimes.PREXTimes{1}(k);
            efd.ValveTimes.PREXTimesWarp{rOdors(k)}(n+1) = efd.ValveTimes.PREXTimesWarp{1}(k);
            efd.ValveTimes.FVTimeWarp{rOdors(k)}(n+1) = efd.ValveTimes.FVTimeWarp{1}(k);
        end
    end
end

%% move valve 5 stuff to valve 1
efd.ValveTimes.FVSwitchTimesOn{1} = efd.ValveTimes.FVSwitchTimesOn{5};
efd.ValveTimes.FVSwitchTimesOff{1} = efd.ValveTimes.FVSwitchTimesOff{5};
efd.ValveTimes.PREXIndex{1} = efd.ValveTimes.PREXIndex{5};
efd.ValveTimes.PREXTimes{1} = efd.ValveTimes.PREXTimes{5};
efd.ValveTimes.PREXTimesWarp{1} = efd.ValveTimes.PREXTimesWarp{5};
efd.ValveTimes.FVTimeWarp{1} = efd.ValveTimes.FVTimeWarp{5};
