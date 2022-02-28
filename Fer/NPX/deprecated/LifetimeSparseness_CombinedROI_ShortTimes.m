clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = {'SL'};
Catalog = 'B:\Expt_Sets\catalog\ExperimentCatalog_SL.txt';
T = readtable(Catalog, 'Delimiter', ' ');
ROIfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Params

VOI = 2:11;
Conc = 2;
Cycle = 2;
TOI = {1:15};
PST = [0 .5];
BinSize = .025;
Bin = diff(PST);

%% Lifetime and population sparseness

for R = 1:length(ROIfiles)
    clear SparseVar
    clear LRcells
    efd = EFDmaker_Beast(ROIfiles{R},'bhv');
    [PSTH, ~, ~] = PSTHmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,:), PST, BinSize);
    PSTH = cell2mat(squeeze(PSTH));
    SparseVar = PSTH ./ (diff(PST)*1000);
    [SL,~] = Sparseness(SparseVar);
    
    LRcells = LRcellPicker_chgPt(ROIfiles{R},[-.1 .1]);
    LR_idx{1} = LRcells.primLR;
    if numel(fieldnames(LRcells)) > 2
        LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    else
        LR_idx{2} = LRcells.nonLR;
    end
    
    SL_LR{R} = SL(:,LR_idx{1});
    SL_nLR{R} = SL(:,LR_idx{2});
end

%% Plotting distributions

edges = 0:.03:1;
figure; hold on
colors = {rgb('DarkGoldenRod'),rgb('ForestGreen')};

subplot(2,2,1); hold on
meanLR = nanmean(cell2mat(SL_LR));
meanNLR = nanmean(cell2mat(SL_nLR));
plot(meanLR,.2,'bx'); plot(meanNLR,.2,'kx');
histogram(cell2mat(SL_LR),edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor',colors,'LineWidth',1);
histogram(cell2mat(SL_nLR),edges,'Normalization','probability','FaceColor',rgb('Gray'),'FaceAlpha',.6,'EdgeColor','none');
ax = gca;
ax.YAxis.Limits = [0 .2];
ax.XTick = [min(edges) 0.5 max(edges)];
ax.YTick = [0 .2];
ax.XTickLabel = {'0', '0.5', '1'};
ax.XLabel.String = 'lifetime sparseness';
ax.YLabel.String = ['fraction' ' ' ROI];

%% Plotting means and variance

% mean by experiment
for R = 1:length(ROIfiles)
    mean_LR{R} = nanmean(SL_LR{R});
    mean_nLR{R} = nanmean(SL_nLR{R});
end

% sem by experiment
sem_LR = sem(cell2mat(mean_LR)');
sem_nLR = sem(cell2mat(mean_nLR)');

figure; hold on

subplot(2,2,1); hold on
x = 1:2;
scatter((repmat(x(1),length(mean_LR),1)),cell2mat(mean_LR),'MarkerEdgeColor','none','MarkerFaceColor',colors{grps},'jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(mean_nLR),1)),cell2mat(mean_nLR),'MarkerEdgeColor','none','MarkerFaceColor',rgb('Gray'),'jitter','on','jitterAmount',.1)
errorbar([mean(cell2mat(mean_LR)); mean(cell2mat(mean_nLR))],[sem_LR; sem_nLR],'kx');
ylim([0 1])
set(gca,'YTick',ylim)
ylabel('lifetime sparseness')
ax = gca;
ax.XTick = [1 2 3 4 5 6];
ax.XAxis.Limits = [.5 length(x)+.5];
ax.XTickLabel = ROI;

%% Plotting CDF

% edges = 0:.05:1;
% 
% for grps = 1:length(ROIfiles)
%     SL_cdf{grps} = cat(2,SL_LR{grps}{:});
%     SLnLR_cdf{grps} = cat(2,SL_nLR{grps}{:});
% end
% 
% for grps = 1:length(ROIfiles)
%     [NLS,edges] = histcounts(SL_cdf{grps},edges);
%     [NLS_nLR,edges] = histcounts(SLnLR_cdf{grps},edges);
%     cdf{grps} = cumsum(NLS)/sum(NLS);
%     cdf_nLR{grps} = cumsum(NLS_nLR)/sum(NLS_nLR);
% end
%     
% colors = {rgb('ForestGreen'),rgb('DarkGoldenrod')};
% figure; hold on
% 
% for grps = 1:length(ROIfiles)
%     subplot(2,2,grps); hold on
%     plot(edges(1:end-1),cdf{grps},'Color',colors{grps})
%     plot(edges(1:end-1),cdf_nLR{grps},'Color',rgb('Gray'))    
%     xlim([0 1])
%     ylim([0 1])
%     set(gca,'XTick',xlim)
%     set(gca,'YTick',ylim)
%     xlabel('lifetime sparseness')
%     ylabel(ROI{grps})
% end