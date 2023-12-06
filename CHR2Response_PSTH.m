clearvars
close all
clc

%% Pick out recording files and put each in one cell

Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_LOpairing.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

%% Experiment-specific information

numPulse = 1;
preTrials = 15;
postTrials = 15;

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimesKK(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker(KWIKfiles{R},'bhv');
end

%% Identify CHR2+ cells (primary) and synaptically connected (secondary)
% CHR2+ primary if ranksum p <.05, auROC > .7, spike latency after first 
% pulse < 5msec, spike probability to first pulse > .8
% CHR2+ secondary if ranksum p <.05, auROC > .7

for R = 1:length(KWIKfiles)
    [~,~,TypeIdx{R,1},TypeIdx{R,2}] = CHR2Picker(KWIKfiles{R},numPulse);
    TypeStack{R} = cat(2,TypeIdx{R,1},TypeIdx{R,2});  % stack CHR2+ and synaptic within an experiment, each cell is one experiment
end

%% Make trial blocks and get some odor response characteristics by blocks 
% Break odor trials into pre-laser and post-laser blocks
% Get Z-score and auROC values for odor response by trial blocks

for R = 1:length(KWIKfiles)
    [Blocks{R},PV{R},UV{R}] = BlockMaker(KWIKfiles{R},preTrials,postTrials);
    Scores{R} = ScoreMaker(Blocks{R});
end

%% Laser responsive cells paired and unpaired odor response during pairing trials

for R = 1:length(KWIKfiles)
    [KDF_PO{R}, ~, KDFt_PO{R}, KDFe_PO{R}] = KDFmaker(Blocks{R}.Raster.Paired(:,TypeStack{R}), [-1 2], 0.01);
    [KDF_UO{R}, ~, KDFt_UO{R}, KDFe_UO{R}] = KDFmaker(Blocks{R}.Raster.Unpaired(:,TypeStack{R}), [-1 2], 0.01);
end

figure; 
for R = 1:length(KWIKfiles)
    subplot(5,2,R); hold on
    plot(KDFt_PO{R},mean(cell2mat(KDF_PO{R}'),1),'k');
    plot(KDFt_UO{R},mean(cell2mat(KDF_UO{R}'),1),'r');
end

%% Mean CHR2+ paired and unpaired odor response during pre- and post-pairing trials

for R = 1:length(KWIKfiles)
    if ~isempty(TypeIdx{R,1})
    [KDF_PO_pre{R}, ~, KDFt_PO_pre{R}, KDFe_PO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(PV{R},TypeIdx{R,1}), [-1 2], 0.01);
    [KDF_UO_pre{R}, ~, KDFt_UO_pre{R}, KDFe_UO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(UV{R},TypeIdx{R,1}), [-1 2], 0.01);
    [KDF_PO_post{R}, ~, KDFt_PO_post{R}, KDFe_PO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(PV{R},TypeIdx{R,1}), [-1 2], 0.01);
    [KDF_UO_post{R}, ~, KDFt_UO_post{R}, KDFe_UO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(UV{R},TypeIdx{R,1}), [-1 2], 0.01);
    end
end

figure; 
subplot(2,2,1); hold on
ax = gca;
ax.YAxis.Limits = [0 15];
ax.YLabel.String = 'Hz';
title({'Paired Odor';'n=11'})

plot(KDFt_PO_pre{R},mean(cell2mat(cat(2,KDF_PO_pre{:,:})'),1),'k');
plot(KDFt_PO_post{R},mean(cell2mat(cat(2,KDF_PO_post{:,:})'),1),'r');

subplot(2,2,2); hold on
title({'Unpaired Odor';'LR'})

plot(KDFt_UO_pre{R},mean(cell2mat(cat(2,KDF_UO_pre{:,:})'),1),'k');
plot(KDFt_UO_post{R},mean(cell2mat(cat(2,KDF_UO_post{:,:})'),1),'r');

%% Mean paired and unpaired odor response during pre- and post-pairing trials

for R = 1:length(KWIKfiles)
    [KDF_PO_pre{R}, ~, KDFt_PO_pre{R}, KDFe_PO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(PV{R},2:end), [-1 2], 0.01);
    [KDF_UO_pre{R}, ~, KDFt_UO_pre{R}, KDFe_UO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(UV{R},2:end), [-1 2], 0.01);
    [KDF_PO_post{R}, ~, KDFt_PO_post{R}, KDFe_PO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(PV{R},2:end), [-1 2], 0.01);
    [KDF_UO_post{R}, ~, KDFt_UO_post{R}, KDFe_UO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(UV{R},2:end), [-1 2], 0.01);
    [KDF_RO_pre{R}, ~, KDFt_RO_pre{R}, KDFe_RO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(size(Blocks{R}.Raster.Pre,1),2:end), [-1 2], 0.01);
    [KDF_RO_post{R}, ~, KDFt_RO_post{R}, KDFe_RO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(size(Blocks{R}.Raster.Pre,1),2:end), [-1 2], 0.01);
end


figure; 
subplot(2,2,1); hold on
ax = gca;
ax.YAxis.Limits = [0 6];
ax.YLabel.String = 'Hz';
title({'Paired Odor';'n=367'})

plot(KDFt_PO_pre{R},mean(cell2mat(cat(2,KDF_PO_pre{:,:})'),1),'k');
plot(KDFt_PO_post{R},mean(cell2mat(cat(2,KDF_PO_post{:,:})'),1),'r');
xlim([-1 2]);

subplot(2,2,2); hold on
ax = gca;
ax.YAxis.Limits = [0 6];
ax.YLabel.String = 'Hz';
title({'Unpaired Odor';'n=367'})

plot(KDFt_UO_pre{R},mean(cell2mat(cat(2,KDF_UO_pre{:,:})'),1),'k');
plot(KDFt_UO_post{R},mean(cell2mat(cat(2,KDF_UO_post{:,:})'),1),'r');
xlim([-1 2]);

subplot(2,2,3); hold on
ax = gca;
ax.YAxis.Limits = [0 6];
ax.YLabel.String = 'Hz';
title({'Panel Odor';'n=367'})

plot(KDFt_RO_pre{R},mean(cell2mat(cat(2,KDF_RO_pre{:,:})'),1),'k');
plot(KDFt_RO_post{R},mean(cell2mat(cat(2,KDF_RO_post{:,:})'),1),'r');
xlim([-1 2]);


%% Individual CHR2+ paired and unpaired odor response during pre- and post-pairing trials

KDF_PO_pre = cell2mat(cat(2,KDF_PO_pre{:,:})');
KDF_PO_post = cell2mat(cat(2,KDF_PO_post{:,:})');
KDF_UO_pre = cell2mat(cat(2,KDF_UO_pre{:,:})');
KDF_UO_post = cell2mat(cat(2,KDF_UO_post{:,:})');

numPlots = size(KDF_PO_pre,1);
numFigs = ceil(numPlots/10);

for i = 1:numFigs
    figure;
%     figure('units','normalized','outerposition',[0 0 1 1])
    for j = 1:10
        plotNum = j + 10*(i-1);
        if plotNum <= numPlots
            subplot(5,2,j); hold on
            plot(KDFt_PO_pre{1,1},KDF_PO_pre(plotNum,:),'k')
            plot(KDFt_PO_post{1,1},KDF_PO_post(plotNum,:),'r')
        end
    end
    filename = sprintf('PSTH_LRC_PO_%d.pdf', i);
    h=gcf;
    set(h,'PaperOrientation','landscape');
    saveas(h,filename)
end

for i = 1:numFigs
    figure('units','normalized','outerposition',[0 0 1 1])
    for j = 1:10
        plotNum = j + 10*(i-1);
        if plotNum < numPlots
            subplot(5,2,j); hold on
            plot(KDFt_UO_pre{1,1},KDF_UO_pre(plotNum,:),'k')
            plot(KDFt_UO_post{1,1},KDF_UO_post(plotNum,:),'r')
        end
    end
    filename = sprintf('PSTH_LRC_UO_%d.pdf', i);
    h=gcf;
    set(h,'PaperOrientation','landscape');
    saveas(h,filename)
end

% %% Individual ~LRC paired and unpaired odor response during pre- and post-pairing trials
% 
% clearvars -regexp ^KDF
% 
% for R = 1:length(KWIKfiles)
%     numUnit{R} = 1:size(Blocks{R}.Raster.Pre,2);
%     normCell_idx{R} = ~ismember(numUnit{R},TypeStack{R});
%     normCell_val{R} = numUnit{R}(normCell_idx{R});
%     [KDF_PO_pre{R}, ~, KDFt_PO_pre{R}, KDFe_PO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(PV{R},normCell_val{R}), [-1 2], 0.01);
%     [KDF_UO_pre{R}, ~, KDFt_UO_pre{R}, KDFe_UO_pre{R}] = KDFmaker(Blocks{R}.Raster.Pre(UV{R},normCell_val{R}), [-1 2], 0.01);
%     [KDF_PO_post{R}, ~, KDFt_PO_post{R}, KDFe_PO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(PV{R},normCell_val{R}), [-1 2], 0.01);
%     [KDF_UO_post{R}, ~, KDFt_UO_post{R}, KDFe_UO_post{R}] = KDFmaker(Blocks{R}.Raster.Post(UV{R},normCell_val{R}), [-1 2], 0.01);
% end
% 
% KDF_PO_pre = cell2mat(cat(2,KDF_PO_pre{:,:})');
% KDF_PO_post = cell2mat(cat(2,KDF_PO_post{:,:})');
% KDF_UO_pre = cell2mat(cat(2,KDF_UO_pre{:,:})');
% KDF_UO_post = cell2mat(cat(2,KDF_UO_post{:,:})');
% 
% numPlots = size(KDF_PO_pre,1);
% numFigs = ceil(numPlots/10);
% 
% for i = 1:numFigs
%     figure('units','normalized','outerposition',[0 0 1 1])
%     for j = 1:10
%         plotNum = j + 10*(i-1);
%         if plotNum < numPlots
%             subplot(5,2,j); hold on
%             plot(KDFt_PO_pre{1,1},KDF_PO_pre(plotNum,:),'k')
%             plot(KDFt_PO_post{1,1},KDF_PO_post(plotNum,:),'g')
%         end
%     end
%     filename = sprintf('PSTH_NC_PO_%d.pdf', i);
%     h=gcf;
%     set(h,'PaperOrientation','landscape');
%     saveas(h,filename)
% end
% 
% for i = 1:numFigs
%     figure('units','normalized','outerposition',[0 0 1 1])
%     for j = 1:10
%         plotNum = j + 10*(i-1);
%         if plotNum < numPlots
%             subplot(5,2,j); hold on
%             plot(KDFt_UO_pre{1,1},KDF_UO_pre(plotNum,:),'k')
%             plot(KDFt_UO_post{1,1},KDF_UO_post(plotNum,:),'g')
%         end
%     end
%     filename = sprintf('PSTH_NC_UO_%d.pdf', i);
%     h=gcf;
%     set(h,'PaperOrientation','landscape');
%     saveas(h,filename)
% end

