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

%% Average CHR2+ FR across trials 

preTrials_PO = [];
postTrials_PO = [];
preTrials_UO = [];
postTrials_UO = [];
pairingTrials_PO = [];
pairingTrials_UO = [];

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,1})
        preTrials_PO = [preTrials_PO Blocks{R}.FR.Pre(PV{R},TypeIdx{R,1}(unit))];
        postTrials_PO = [postTrials_PO Blocks{R}.FR.Post(PV{R},TypeIdx{R,1}(unit))];
        preTrials_UO = [preTrials_UO Blocks{R}.FR.Pre(UV{R},TypeIdx{R,1}(unit))];
        postTrials_UO = [postTrials_UO Blocks{R}.FR.Post(UV{R},TypeIdx{R,1}(unit))];
        pairingTrials_PO = [pairingTrials_PO Blocks{R}.FR.Paired(:,TypeIdx{R,1}(unit))];
        pairingTrials_UO = [pairingTrials_UO Blocks{R}.FR.Unpaired(:,TypeIdx{R,1}(unit))];
    end
end

[minPO] = min(cellfun('size', pairingTrials_PO, 2));
[minUO] = min(cellfun('size', pairingTrials_UO, 2));

for i = 1:length(pairingTrials_PO)
    pairingTrials_PO{i} = pairingTrials_PO{i}(1:minPO);
    pairingTrials_UO{i} = pairingTrials_UO{i}(1:minUO);
end

preTrials_PO = cell2mat(preTrials_PO');
err_pre_PO = (std(preTrials_PO)/sqrt(size(preTrials_PO,1)))';
postTrials_PO = cell2mat(postTrials_PO');
err_post_PO = (std(postTrials_PO)/sqrt(size(postTrials_PO,1)))';

preTrials_UO = cell2mat(preTrials_UO');
err_pre_UO = (std(preTrials_UO)/sqrt(size(preTrials_UO,1)))';
postTrials_UO = cell2mat(postTrials_UO');
err_post_UO = (std(postTrials_UO)/sqrt(size(postTrials_UO,1)))';

pairingTrials_PO = cell2mat(pairingTrials_PO');
err_pair_PO = (std(pairingTrials_PO)/sqrt(size(pairingTrials_PO,1)))';
pairingTrials_UO = cell2mat(pairingTrials_UO');
err_pair_UO = (std(pairingTrials_UO)/sqrt(size(pairingTrials_UO,1)))';

x = (1:size(preTrials_PO,2))';
x_pair = (1:size(pairingTrials_PO,2))';

PO_pre = mean(preTrials_PO)';
PO_post = mean(postTrials_PO)';
UO_pre = mean(preTrials_UO)';
UO_post = mean(postTrials_UO)';
PO_pair = mean(pairingTrials_PO)';
UO_pair = mean(pairingTrials_UO)';

figure;

subplot(2,2,1); hold on
ax = gca;
ax.YAxis.Limits = [0 40];
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Pre-trial';
title({'Paired Odor';'n=11'})
fill([x;flipud(x)],[PO_pre-err_pre_PO;flipud(PO_pre+err_pre_PO)],[.9 .9 .9],'linestyle','none');
line(x,PO_pre,'Color','k')

subplot(2,2,2); hold on
ax = gca;
ax.YAxis.Limits = [0 40];
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Post-trial';
fill([x;flipud(x)],[PO_post-err_post_PO;flipud(PO_post+err_post_PO)],[.9 .9 .9],'linestyle','none');
line(x,PO_post,'Color','r')

subplot(2,2,3); hold on
ax = gca;
ax.YAxis.Limits = [0 40];
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Pre-trial';
title({'Unpaired Odor';'n=11'})
fill([x;flipud(x)],[UO_pre-err_pre_UO;flipud(UO_pre+err_pre_UO)],[.9 .9 .9],'linestyle','none');
line(x,UO_pre,'Color','k')

subplot(2,2,4); hold on
ax = gca;
ax.YAxis.Limits = [0 40];
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Post-trial';
fill([x;flipud(x)],[UO_post-err_post_UO;flipud(UO_post+err_post_UO)],[.9 .9 .9],'linestyle','none');
line(x,UO_post,'Color','r')


figure

subplot(2,1,1); hold on
ax = gca;
ax.YAxis.Limits = [0 60];
title({'Paired Odor';'n=11'})
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Pairing-trial';
fill([x_pair;flipud(x_pair)],[PO_pair-err_pair_PO;flipud(PO_pair+err_pair_PO)],[.9 .9 .9],'linestyle','none');
line(x_pair,PO_pair,'Color','k')

subplot(2,1,2); hold on
ax = gca;
ax.YAxis.Limits = [0 60];
title({'Unpaired Odor';'n=11'})
ax.YLabel.String = 'Hz';
ax.XLabel.String = 'Pairing-trial';
fill([x_pair;flipud(x_pair)],[UO_pair-err_pair_UO;flipud(UO_pair+err_pair_UO)],[.9 .9 .9],'linestyle','none');
line(x_pair,UO_pair,'Color','k')

