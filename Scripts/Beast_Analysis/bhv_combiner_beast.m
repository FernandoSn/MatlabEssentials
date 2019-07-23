function [efd] = bhv_combiner_beast(KWIKfile,efd)

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
    odor_on_idx = strcmp(bT.Var2,'odorOnTime');
    bFVOdors = bT.Var1(odor_on_idx);
    bFVConcs = bT.Var4(odor_on_idx);
    bFVOpens = bT.Var3(odor_on_idx)/1000;
    
    FVidx_offset = 1+PrevTrials
    rOdors(FVidx_offset:FVidx_offset+length(bFVOpens)-1) = bFVOdors;
    rConcs(FVidx_offset:FVidx_offset+length(bFVOpens)-1) = bFVConcs;
%     realConcs(FVidx_offset:FVidx_offset+length(bFVOpens)-1) = bT.Var4(odor_on_idx);

    PrevTrials = length(bFVOpens) + PrevTrials;

end

%%

            FVSwitchTimesOn{1} = efd.ValveTimes.FVSwitchTimesOn{1};
            FVSwitchTimesOff{1} = efd.ValveTimes.FVSwitchTimesOff{1};
            PREXIndex{1} = efd.ValveTimes.PREXIndex{1};
            PREXTimes{1} = efd.ValveTimes.PREXTimes{1};
            PREXTimesWarp{1} = efd.ValveTimes.PREXTimesWarp{1};
            FVTimeWarp{1} = efd.ValveTimes.FVTimeWarp{1};


%%
ridx = rOdors ~= 0;
new_rOdors = rOdors(ridx);
new_rConcs = rConcs(ridx);

% new_rConcs = realConcs';

olist = unique(new_rOdors);
clist = unique(new_rConcs);

recordedtrials = 1:length(ridx) <= length(FVSwitchTimesOn{1});
%recordedtrials = 1:720 <= length(FVSwitchTimesOn{1});


for o = 1:length(olist)
    for c = 1:length(clist)
        efd.ValveTimes.FVSwitchTimesOn{o,c} = FVSwitchTimesOn{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
        efd.ValveTimes.FVSwitchTimesOff{o,c} = FVSwitchTimesOff{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
        efd.ValveTimes.PREXIndex{o,c} = PREXIndex{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
        efd.ValveTimes.PREXTimes{o,c} = PREXTimes{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
        efd.ValveTimes.PREXTimesWarp{o,c} = PREXTimesWarp{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
        efd.ValveTimes.FVTimeWarp{o,c} = FVTimeWarp{1}(new_rOdors == olist(o) & new_rConcs == clist(c) & recordedtrials);
    end
end

%% Remove mfcVals that are not actual concentrations and delete empty columns
% 
% notEmpty = find(~(cellfun(@isempty,efd.ValveTimes.FVSwitchTimesOn)),1);
% 
% efd.ValveTimes.FVSwitchTimesOn(notEmpty:end,:) = fliplr(efd.ValveTimes.FVSwitchTimesOn(notEmpty:end,:));
% efd.ValveTimes.FVSwitchTimesOff(notEmpty:end,:) = fliplr(efd.ValveTimes.FVSwitchTimesOff(notEmpty:end,:));
% efd.ValveTimes.PREXIndex(notEmpty:end,:) = fliplr(efd.ValveTimes.PREXIndex(notEmpty:end,:));
% efd.ValveTimes.PREXTimes(notEmpty:end,:) = fliplr(efd.ValveTimes.PREXTimes(notEmpty:end,:));
% efd.ValveTimes.PREXTimesWarp(notEmpty:end,:) = fliplr(efd.ValveTimes.PREXTimesWarp(notEmpty:end,:));
% efd.ValveTimes.FVTimeWarp(notEmpty:end,:) = fliplr(efd.ValveTimes.FVTimeWarp(notEmpty:end,:));
% 
% efd.ValveTimes.FVSwitchTimesOn(:,any(cellfun(@isempty,efd.ValveTimes.FVSwitchTimesOn),1)) = [];
% efd.ValveTimes.FVSwitchTimesOff(:,any(cellfun(@isempty,efd.ValveTimes.FVSwitchTimesOff),1)) = [];
% efd.ValveTimes.PREXIndex(:,any(cellfun(@isempty,efd.ValveTimes.PREXIndex),1)) = [];
% efd.ValveTimes.PREXTimes(:,any(cellfun(@isempty,efd.ValveTimes.PREXTimes),1)) = [];
% efd.ValveTimes.PREXTimesWarp(:,any(cellfun(@isempty,efd.ValveTimes.PREXTimesWarp),1)) = [];
% efd.ValveTimes.FVTimeWarp(:,any(cellfun(@isempty,efd.ValveTimes.FVTimeWarp),1)) = [];

%%
% 
% for k = 1:length(efd.ValveTimes.FVSwitchTimesOn{1})
%     if rOdors(k) ~= 0
%         conc_index = find(unique(rConcs)==rConcs(k));
%         if isempty(efd.ValveTimes.FVSwitchTimesOn{rOdors(k),conc_index}) % putting the first trial of an odor into its cell
%             efd.ValveTimes.FVSwitchTimesOn{rOdors(k)} = efd.ValveTimes.FVSwitchTimesOn{1}(k);
%             efd.ValveTimes.FVSwitchTimesOff{rOdors(k)} = efd.ValveTimes.FVSwitchTimesOff{1}(k);
%             efd.ValveTimes.PREXIndex{rOdors(k)} = efd.ValveTimes.PREXIndex{1}(k);
%             efd.ValveTimes.PREXTimes{rOdors(k)} = efd.ValveTimes.PREXTimes{1}(k);
%             efd.ValveTimes.PREXTimesWarp{rOdors(k)} = efd.ValveTimes.PREXTimesWarp{1}(k);
%             efd.ValveTimes.FVTimeWarp{rOdors(k)} = efd.ValveTimes.FVTimeWarp{1}(k);
%         else
%             n = numel(efd.ValveTimes.FVSwitchTimesOn{rOdors(k)}); % putting subsequent trials in
%             efd.ValveTimes.FVSwitchTimesOn{rOdors(k)}(n+1) = efd.ValveTimes.FVSwitchTimesOn{1}(k);
%             efd.ValveTimes.FVSwitchTimesOff{rOdors(k)}(n+1) = efd.ValveTimes.FVSwitchTimesOff{1}(k);
%             efd.ValveTimes.PREXIndex{rOdors(k)}(n+1) = efd.ValveTimes.PREXIndex{1}(k);
%             efd.ValveTimes.PREXTimes{rOdors(k)}(n+1) = efd.ValveTimes.PREXTimes{1}(k);
%             efd.ValveTimes.PREXTimesWarp{rOdors(k)}(n+1) = efd.ValveTimes.PREXTimesWarp{1}(k);
%             efd.ValveTimes.FVTimeWarp{rOdors(k)}(n+1) = efd.ValveTimes.FVTimeWarp{1}(k);
%         end
%     end
% end

%% move valve 5 stuff to valve 1
% efd.ValveTimes.FVSwitchTimesOn{1} = efd.ValveTimes.FVSwitchTimesOn{5};
% efd.ValveTimes.FVSwitchTimesOff{1} = efd.ValveTimes.FVSwitchTimesOff{5};
% efd.ValveTimes.PREXIndex{1} = efd.ValveTimes.PREXIndex{5};
% efd.ValveTimes.PREXTimes{1} = efd.ValveTimes.PREXTimes{5};
% efd.ValveTimes.PREXTimesWarp{1} = efd.ValveTimes.PREXTimesWarp{5};
% efd.ValveTimes.FVTimeWarp{1} = efd.ValveTimes.FVTimeWarp{5};
