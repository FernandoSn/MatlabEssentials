clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = {'AON'};
Catalog = 'Y:\public\BR_Microscope\ExperimentCatalog_AON';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker_Beast(KWIKfiles{R},'bhv');
end

%% Identify LR and nonLR cells 

for R = 1:length(KWIKfiles)
    [LR_idx{R,1}] = LRcellPicker(KWIKfiles{R});
    TypeStack{R} = cat(2,LR_idx{R,1});  % stack all cells within an experiment, each cell is one experiment
end


for R = 1:length(KWIKfiles)
    TypeStack{R} = cat(2,:,:);  % stack all cells within an experiment, each cell is one experiment
end

%% Spike count by conc

VOI = 2:11;
Conc = 1:3;

for R = 1:length(KWIKfiles)
    spikeCount_LR{R} = efd(R).ValveSpikes.MultiCycleSpikeCount(VOI,Conc,:,1);
end
    
SC_LR = cat(3,spikeCount_LR{:,:});

for valve = 1:size(SC_LR,1)
    for conc = 1:size(SC_LR,2)
        for unit = 1:size(SC_LR,3)
            spikelr(valve,conc,unit) = mean(cell2mat(SC_LR(valve,conc,unit)));
        end
    end
end

%% Plot

for conc = 1:size(spikelr,2)
    mean_a = nanmean(a);
    mean_aa = nanmean(mean_a);
end

means = [nanmean(spikelr(:,1,:)), nanmean(spikelr(:,2,:)),nanmean(spikelr(:,3,:))];
err = [nanstd(f_lr)/sqrt(length(f_lr)), nanstd(f_nlr)/sqrt(length(f_nlr))];

errorbar(means,err,'gx')

ax = gca; 
ax.YAxis.Limits = [0 10];



