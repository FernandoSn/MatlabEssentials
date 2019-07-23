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

%% auROC heatmaps for CHR2+ primary

for R = 1:length(KWIKfiles)
    VOI = [PV{R}, UV{R}, size(Scores{R}.auROC.Pre,1)-2, size(Scores{R}.auROC.Pre,1)];
    for unit = 1:length(TypeIdx{R,1})
        for valve = 1:length(VOI)
            auROC_pre{R}(valve,unit) = Scores{R}.auROC.Pre(VOI(valve),TypeIdx{R,1}(unit));
            auROC_post{R}(valve,unit) = Scores{R}.auROC.Post(VOI(valve),TypeIdx{R,1}(unit));
        end
    end
end

auROC_pre = cell2mat(auROC_pre);
auROC_post = cell2mat(auROC_post);

% Plot data

colorLim = [0 1];

HeatMapper(auROC_pre','Pre-pairing','Putative CHR2+',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\auROC_pre_prim_170821.pdf'])

HeatMapper(auROC_post','Post-pairing','Putative CHR2+',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\auROC_post_prim_170821.pdf'])

%% auROC heatmaps for CHR2+ secondary

clear auROC_pre
clear auROC_post

for R = 1:length(KWIKfiles)
    VOI = [PV{R}, UV{R}, size(Scores{R}.auROC.Pre,1)-2, size(Scores{R}.auROC.Pre,1)];
    for unit = 1:length(TypeIdx{R,2})
        for valve = 1:length(VOI)
            auROC_pre{R}(valve,unit) = Scores{R}.auROC.Pre(VOI(valve),TypeIdx{R,2}(unit));
            auROC_post{R}(valve,unit) = Scores{R}.auROC.Post(VOI(valve),TypeIdx{R,2}(unit));
        end
    end
end

auROC_pre = cell2mat(auROC_pre);
auROC_post = cell2mat(auROC_post);

% Plot data

HeatMapper(auROC_pre','Pre-pairing','Putative synaptic',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\auROC_pre_sec_170821.pdf'])

HeatMapper(auROC_post','Post-pairing','Putative synaptic',colorLim)
saveas(gcf,[pwd '\Light-odor pairing data and figures\Recording\auROC_post_sec_170821.pdf'])
