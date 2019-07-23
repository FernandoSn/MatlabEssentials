clearvars
close all
clc

%% Pick out recording files and put each in one cell

Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_LOpairing.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

%% Experiment-specific information

numPulse = 5;
preTrials = 15;
postTrials = 15;

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimesKK(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker(KWIKfiles{R});
end

%% Identify CHR2+ cells (primary) and synaptically connected (secondary)
% CHR2+ primary if ranksum p <.05, auROC > .7, spike latency after first 
% pulse < 5msec, spike probability to first pulse > .8
% CHR2+ secondary if ranksum p <.05, auROC > .7

for R = 1:length(KWIKfiles)
    [~,~,TypeIdx{R,1},TypeIdx{R,2}] = CHR2Picker(KWIKfiles{R},numPulse);
end

% TypeStack{1} = cat(1,TypeIdx{:,1});
% TypeStack{2} = cat(1,TypeIdx{:,2});

%% Make trial blocks and get some odor response characteristics by blocks 
% Break odor trials into pre-laser and post-laser blocks
% Get Z-score and auROC values for odor response by trial blocks

for R = 1:length(KWIKfiles)
    [Blocks{R},PV{R},UV{R}] = BlockMaker(KWIKfiles{R},preTrials,postTrials);
    if R == 1;
        MO = 3;
    else MO = 1;
    end
    Scores{R} = ScoreMaker(Blocks{R});
end

%% Raw rate odor response of CHR2+ primary 

PV_rr_pre = [];
PV_rr_post = [];
Bl_rr_pre = [];
Bl_rr_post = [];

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,1})
        PV_rr_pre = [PV_rr_pre Scores{R}.RawRate.Pre(PV{R},TypeIdx{R,1}(unit))];
        PV_rr_post = [PV_rr_post Scores{R}.RawRate.Post(PV{R},TypeIdx{R,1}(unit))];
        Bl_rr_pre = [Bl_rr_pre Scores{R}.BlankRate.Pre(PV{R},TypeIdx{R,1}(unit))];
        Bl_rr_post = [Bl_rr_post Scores{R}.BlankRate.Post(PV{R},TypeIdx{R,1}(unit))];
    end
end

% Plot data

PV_rr = [PV_rr_pre; PV_rr_post]';
Bl_rr = [Bl_rr_pre; Bl_rr_post]';
LRprim_RawRate = [PV_rr_pre; PV_rr_post; Bl_rr_pre; Bl_rr_post]';
x = repmat(1:size(LRprim_RawRate,2),size(LRprim_RawRate,1),1);

figure
subplot(2,2,1)
title({'Putative CHR2+';['(n= ',num2str(size(PV_rr,1)),')']})
hold on
ax = gca;
% ax.YAxis.Limits = [0 50];
ax.YLabel.String = 'Raw Rate';

for i = 1:size(LRprim_RawRate,2)
    scatter(x(:,i),LRprim_RawRate(:,i),'ko')
end

% Connect dots
for p = 2:2:size(LRprim_RawRate,2)
    for q = 1:size(LRprim_RawRate,1)
        line([x(q,p-1),x(q,p)],[LRprim_RawRate(q,p-1),LRprim_RawRate(q,p)])
    end
end

%% Raw rate odor response of CHR2+ secondary

PV_rr_pre = [];
PV_rr_post = [];
Bl_rr_pre = [];
Bl_rr_post = [];

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,2})
        PV_rr_pre = [PV_rr_pre Scores{R}.RawRate.Pre(PV{R},TypeIdx{R,2}(unit))];
        PV_rr_post = [PV_rr_post Scores{R}.RawRate.Post(PV{R},TypeIdx{R,2}(unit))];
        Bl_rr_pre = [Bl_rr_pre Scores{R}.BlankRate.Pre(PV{R},TypeIdx{R,2}(unit))];
        Bl_rr_post = [Bl_rr_post Scores{R}.BlankRate.Post(PV{R},TypeIdx{R,2}(unit))];
    end
end

% Plot data

PV_rr = [PV_rr_pre; PV_rr_post]';
Bl_rr = [Bl_rr_pre; Bl_rr_post]';
LRsec_RawRate = [PV_rr_pre; PV_rr_post; Bl_rr_pre; Bl_rr_post]';
x = repmat(1:size(LRsec_RawRate,2),size(LRsec_RawRate,1),1);

subplot(2,2,2)
title({'Putative Synaptic';['(n= ',num2str(size(PV_rr,1)),')']})
hold on
ax = gca;
% ax.YAxis.Limits = [0 50];
ax.YLabel.String = 'Raw Rate';

for i = 1:size(LRsec_RawRate,2)
    scatter(x(:,i),LRsec_RawRate(:,i),'ko')
end

% Connect dots
for p = 2:2:size(LRsec_RawRate,2)
    for q = 1:size(LRsec_RawRate,1)
        line([x(q,p-1),x(q,p)],[LRsec_RawRate(q,p-1),LRsec_RawRate(q,p)])
    end
end

saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\RawRate_170821.pdf'])