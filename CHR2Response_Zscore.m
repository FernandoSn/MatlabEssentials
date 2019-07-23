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

%% Z-scored odor response of CHR2+ primary 

PV_zSc_pre = [];
PV_zSc_post = [];
UV_zSc_pre = [];
UV_zSc_post = [];

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,1})
        PV_zSc_pre = [PV_zSc_pre Scores{R}.zScore.Pre(PV{R},TypeIdx{R,1}(unit))];
        PV_zSc_post = [PV_zSc_post Scores{R}.zScore.Post(PV{R},TypeIdx{R,1}(unit))];
        UV_zSc_pre = [UV_zSc_pre Scores{R}.zScore.Pre(UV{R},TypeIdx{R,1}(unit))];
        UV_zSc_post = [UV_zSc_post Scores{R}.zScore.Post(UV{R},TypeIdx{R,1}(unit))];
    end
end

% Plot data

PV_zSc = [PV_zSc_pre; PV_zSc_post]';
UV_zSc = [UV_zSc_pre; UV_zSc_post]';
LRprim_ZScores = abs([PV_zSc_pre; PV_zSc_post; UV_zSc_pre; UV_zSc_post]');
% LRprim_Z_Up = [PV_zSc_pre(PV_zSc_pre>=0); PV_zSc_post(PV_zSc_post>=0); UV_zSc_pre(UV_zSc_pre>=0); UV_zSc_post(UV_zSc_post>=0)]';
x = repmat(1:size(LRprim_ZScores,2),size(LRprim_ZScores,1),1);
% PO_UPidx = find(LRprim_ZScores(:,1) >=0);
% UO_UPidx = find(LRprim_ZScores(:,3) >=0);

for k = 1:size(LRprim_ZScores,2)
    means(k) = mean(LRprim_ZScores(:,k));
    err(k) = std(LRprim_ZScores(:,k)/sqrt(length(LRprim_ZScores(:,k))));
end

% for k = 1:size(PV_zSc,2)
%     mean_UP_PV(k) = mean(LRprim_ZScores(PO_UPidx,k));
%     mean_UP_UV(k) = mean(LRprim_ZScores(UO_UPidx,k));
% end

figure
subplot(2,2,1)
title({'Putative CHR2+';['(n= ',num2str(size(PV_zSc,1)),')']})
hold on
ax = gca;
ax.YAxis.Limits = [0 10];
ax.YLabel.String = 'Z-score';

% Plot data points
for i = 1:size(LRprim_ZScores,2)
    scatter(x(:,i),LRprim_ZScores(:,i),'ko')
end

% Plot mean and errorbar
errorbar(means,err,'rx')

% Connect dots
for p = 2:2:size(LRprim_ZScores,2)
    for q = 1:size(LRprim_ZScores,1)
        line([x(q,p-1),x(q,p)],[LRprim_ZScores(q,p-1),LRprim_ZScores(q,p)])
    end
end

%% Z-scored odor response of CHR2+ secondary

PV_zSc_pre = [];
PV_zSc_post = [];
UV_zSc_pre = [];
UV_zSc_post = [];
clear means
clear err

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,2})
        PV_zSc_pre = [PV_zSc_pre Scores{R}.zScore.Pre(PV{R},TypeIdx{R,2}(unit))];
        PV_zSc_post = [PV_zSc_post Scores{R}.zScore.Post(PV{R},TypeIdx{R,2}(unit))];
        UV_zSc_pre = [UV_zSc_pre Scores{R}.zScore.Pre(UV{R},TypeIdx{R,2}(unit))];
        UV_zSc_post = [UV_zSc_post Scores{R}.zScore.Post(UV{R},TypeIdx{R,2}(unit))];
    end
end

% Plot data

PV_zSc = [PV_zSc_pre; PV_zSc_post]';
UV_zSc = [UV_zSc_pre; UV_zSc_post]';
LRsec_ZScores = abs([PV_zSc_pre; PV_zSc_post; UV_zSc_pre; UV_zSc_post]');
x = repmat(1:size(LRsec_ZScores,2),size(LRsec_ZScores,1),1);

for k = 1:size(LRprim_ZScores,2)
    means(k) = mean(LRsec_ZScores(:,k));
    err(k) = std(LRsec_ZScores(:,k)/sqrt(length(LRsec_ZScores(:,k))));
end

subplot(2,2,2)
title({'Putative Synaptic';['(n= ',num2str(size(PV_zSc,1)),')']})
hold on
ax = gca;
% ax.XAxis.TickValues = [1 2];
% ax.XAxis.TickLabels = {'Pre-pairing','Post-pairing'};
ax.YAxis.Limits = [-5 10];
ax.YLabel.String = 'Z-score';

% Plot data points
for i = 1:size(LRsec_ZScores,2)
    scatter(x(:,i),LRsec_ZScores(:,i),'ko')
end

% Plot mean and errorbar
errorbar(means,err,'rx')

% Connect dots
for p = 2:2:size(LRsec_ZScores,2)
    for q = 1:size(LRsec_ZScores,1)
        line([x(q,p-1),x(q,p)],[LRsec_ZScores(q,p-1),LRsec_ZScores(q,p)])
    end
end

saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\ZScore_170821.pdf'])

%% ZScore heatmaps for CHR2+ primary

for R = 1:length(KWIKfiles)
    VOI = [PV{R}, UV{R}, size(Scores{R}.zScore.Pre,1)-2, size(Scores{R}.zScore.Pre,1)];
    for unit = 1:length(TypeIdx{R,1})
        for valve = 1:length(VOI)
            zScore_pre{R}(valve,unit) = Scores{R}.zScore.Pre(VOI(valve),TypeIdx{R,1}(unit));
            zScore_post{R}(valve,unit) = Scores{R}.zScore.Post(VOI(valve),TypeIdx{R,1}(unit));
        end
    end
end

zScore_pre = cell2mat(zScore_pre);
zScore_post = cell2mat(zScore_post);

% Plot data
colorLim = [-5 5];

HeatMapper(zScore_pre','Pre-pairing','Putative CHR2+',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\ZScore_pre_prim_170821.pdf'])

HeatMapper(zScore_post','Post-pairing','Putative CHR2+',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\ZScore_post_prim_170821.pdf'])

%% %% ZScore heatmaps for CHR2+ secondary

clear zScore_pre
clear zScore_post

for R = 1:length(KWIKfiles)
    VOI = [PV{R}, UV{R}, size(Scores{R}.zScore.Pre,1)-2, size(Scores{R}.zScore.Pre,1)];
    for unit = 1:length(TypeIdx{R,2})
        for valve = 1:length(VOI)
            zScore_pre{R}(valve,unit) = Scores{R}.zScore.Pre(VOI(valve),TypeIdx{R,2}(unit));
            zScore_post{R}(valve,unit) = Scores{R}.zScore.Post(VOI(valve),TypeIdx{R,2}(unit));
        end
    end
end

zScore_pre = cell2mat(zScore_pre);
zScore_post = cell2mat(zScore_post);

% Plot data

HeatMapper(zScore_pre','Pre-pairing','Putative synaptic',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\ZScore_pre_sec_170821.pdf'])

HeatMapper(zScore_post','Post-pairing','Putative synaptic',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\ZScore_post_sec_170821.pdf'])

