clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = {'SL'};
Catalog = 'B:\Expt_Sets\catalog\ExperimentCatalog_SL.txt';
T = readtable(Catalog, 'Delimiter', ' ');

for grps = 1:length(ROI)
    ROIfiles{grps} = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI(grps)));
end

%% Params

VOI = 2:11;
Conc = 2;
Cycle = 2;
TOI = {1:15};

%% Lifetime sparseness

for grps = 1:length(ROIfiles)
    for R = 1:length(ROIfiles{grps})
        clear SparseVar
        clear LRcells
        [efd] = EFDmaker_Beast(ROIfiles{grps}{R},'bhv');
        Scores = SCOmaker_Beast(ROIfiles{grps}{R},TOI);
        spRate = Scores.RawRate(VOI,Conc,:,Cycle);
        SparseVar = squeeze(spRate);
        [SL,~] = Sparseness(SparseVar);
        LRcells = LRcellPicker_chgPt(ROIfiles{grps}{R},[-.1 .1]);
        LR_idx{1} = LRcells.primLR;
        if numel(fieldnames(LRcells)) > 2
            LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
        else
            LR_idx{2} = LRcells.nonLR;
        end
        
        SL_LR{grps}{R} = SL(:,LR_idx{1});
        SL_nLR{grps}{R} = SL(:,LR_idx{2});
    end
end

%% Plotting distributions

edges = 0:.03:1;
figure; hold on
colors = {rgb('DarkGoldenRod'),rgb('ForestGreen')};

for grps = 1:length(ROIfiles)
    subplot(2,2,grps); hold on
    meanLR = nanmean(cell2mat(SL_LR{grps})); 
    meanNLR = nanmean(cell2mat(SL_nLR{grps}));
    plot(meanLR,.2,'bx'); plot(meanNLR,.2,'kx');
    histogram(cell2mat(SL_LR{grps}),edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor',colors{grps},'LineWidth',1);
    histogram(cell2mat(SL_nLR{grps}),edges,'Normalization','probability','FaceColor',rgb('Gray'),'FaceAlpha',.6,'EdgeColor','none');
    ax = gca; axis square; box off;
    ax.YAxis.Limits = [0 .15];
    ax.XTick = [min(edges) 0.5 max(edges)];
    ax.YTick = [0 .15];
    ax.XTickLabel = {'0', '0.5', '1'};
    ax.XLabel.String = 'lifetime sparseness';
    ax.YLabel.String = ['fraction' ' ' ROI{grps}];
end

%% Plotting means and variance

% mean by experiment
for grps = 1:length(ROIfiles)
    for R = 1:length(ROIfiles{grps})
        mean_LR{grps}{R} = nanmean(SL_LR{grps}{R});
        mean_nLR{grps}{R} = nanmean(SL_nLR{grps}{R});
    end
end

% sem by experiment
for grps = 1:length(ROIfiles)
    sem_LR(grps) = sem(cell2mat(mean_LR{grps})');
    sem_nLR(grps) = sem(cell2mat(mean_nLR{grps})');
end

figure; hold on
for grps = 1:length(ROIfiles)
    subplot(2,2,grps); hold on
    x = 1:2;
    scatter((repmat(x(1),length(mean_LR{grps}),1)),cell2mat(mean_LR{grps}),'MarkerEdgeColor','none','MarkerFaceColor',colors{grps},'jitter','on','jitterAmount',.1)
    scatter((repmat(x(2),length(mean_nLR{grps}),1)),cell2mat(mean_nLR{grps}),'MarkerEdgeColor','none','MarkerFaceColor',rgb('Gray'),'jitter','on','jitterAmount',.1)
    errorbar([mean(cell2mat(mean_LR{grps})); mean(cell2mat(mean_nLR{grps}))],[sem_LR(grps); sem_nLR(grps)],'kx');
    ylim([0 1])
    set(gca,'YTick',ylim)
    ylabel('lifetime sparseness')
    ax = gca; box off; axis square;
    ax.XTick = [1 2 3 4 5 6];
    ax.XAxis.Limits = [.5 length(x)+.5];
    ax.XTickLabel = [ROI{grps}];
end

%% Plotting CDF

edges = 0:.05:1;

for grps = 1:length(ROIfiles)
    SL_cdf{grps} = cat(2,SL_LR{grps}{:});
    SLnLR_cdf{grps} = cat(2,SL_nLR{grps}{:});
end

for grps = 1:length(ROIfiles)
    [NLS,edges] = histcounts(SL_cdf{grps},edges);
    [NLS_nLR,edges] = histcounts(SLnLR_cdf{grps},edges);
    cdf{grps} = cumsum(NLS)/sum(NLS);
    cdf_nLR{grps} = cumsum(NLS_nLR)/sum(NLS_nLR);
end
    
colors = {rgb('ForestGreen'),rgb('DarkGoldenrod')};
figure; hold on

for grps = 1:length(ROIfiles)
    subplot(2,2,grps); hold on
    plot(edges(1:end-1),cdf{grps},'Color',colors{grps})
    plot(edges(1:end-1),cdf_nLR{grps},'Color',rgb('Gray'))    
    xlim([0 1])
    ylim([0 1])
    set(gca,'XTick',xlim)
    set(gca,'YTick',ylim)
    xlabel('lifetime sparseness')
    ylabel(ROI{grps})
end