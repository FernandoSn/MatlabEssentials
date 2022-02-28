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
Conc = 3;
Cycle = 2;
TOI = {1:15};

%% Population sparseness

for R = 1:length(ROIfiles)
    clear SparseVar
    clear LRcells
    [efd] = EFDmaker_Beast(ROIfiles{R},'bhv');
    Scores = SCOmaker_Beast(ROIfiles{R},TOI);
    LRcells = LRcellPicker_chgPt(ROIfiles{R},[-.1 .1]);
    LR_idx{1} = LRcells.primLR;
    if numel(fieldnames(LRcells)) > 2
        LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    else
        LR_idx{2} = LRcells.nonLR;
    end
    
    for lset = 1:length(LR_idx)
        spRate{lset} = Scores.RawRate(VOI,Conc,LR_idx{lset},Cycle);
        SparseVar{lset} = squeeze(spRate{lset});
        [~,SP{lset}{R}] = Sparseness(SparseVar{lset});
    end
end

%% Plotting means

for lset = 1:length(LR_idx)
    popSp{lset} = cat(1,SP{lset}{:});
    meanPopSp{lset} = mean(popSp{lset},1);
end

%%

figure; subplot(2,2,1); hold on
for lset = 1:length(LR_idx)
    x = repmat(lset,1,size(meanPopSp{1},2));
    scatter(x,meanPopSp{lset},'jitter','on','jitterAmount',0.2,'MarkerFaceColor','k',...
        'MarkerEdgeColor','none')
    errorbar(mean(meanPopSp{lset}),sem(meanPopSp{lset}),'LineWidth',1);
    plot(mean(meanPopSp{lset}),'rx')
end

ylim([0 1])
xlim([0 3])
set(gca,'XTick',[0 1 2 3])
set(gca,'YTick',[0 0.5 1])
ylabel('population sparseness')
box off; axis square

