clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'OFC';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_RP.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Identify LR and nonLR cells 

% for R = 1:length(KWIKfiles)
%     [LR_idx{R,1},LR_idx{R,2}] = LRcellPicker(KWIKfiles{R});
%     TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
% end

for R = 1:length(KWIKfiles)
    LRcells{R} = LRcellFinalizer(KWIKfiles{R});
end

for R = 1:length(KWIKfiles)
    LR_idx{R,1} = LRcells{R}.primLR;
    LR_idx{R,2} = sort([LRcells{R}.nonLR,LRcells{R}.secLR]);
    TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
end

%% Params

VOI = 2:11;
Conc = 2;

%% Spike counts in first sniff

for R = 1:length(KWIKfiles)
    clearvars efd
    clearvars spikeCounts
    efd = EFDmaker_Beast(KWIKfiles{R},'bhv');
    spikeCounts = efd.ValveSpikes.MultiCycleSpikeCount(VOI,Conc,:,1);
    
    variance = nanvar(cell2mat(spikeCounts),1,2);
    mean = nanmean(cell2mat(spikeCounts),2);
    FF = variance./mean;
    
    FF_LR{R} = FF(:,:,LR_idx{R,1});
    FF_nLR{R} = FF(:,:,LR_idx{R,2});
end
    
%% Plots

fanoLR = cat(3,FF_LR{:,:});
fanonLR = cat(3,FF_nLR{:,:});

a = reshape(fanoLR,[],1);
b = reshape(fanonLR,[],1);

%% Distributions

f_lr = a(~isnan(a));
f_nlr = b(~isnan(b));

edges = 0:.1:5;

figure; hold on
histogram(f_lr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(f_nlr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

figure; hold on
x = 1:2;
scatter((repmat(x(1),length(f_lr),1)),f_lr,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(f_nlr),1)),f_nlr,'ko','jitter','on','jitterAmount',.1)

means = [nanmean(f_lr), nanmean(f_nlr)];
err = [nanstd(f_lr)/sqrt(length(f_lr)), nanstd(f_nlr)/sqrt(length(f_nlr))];

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [0 10];

