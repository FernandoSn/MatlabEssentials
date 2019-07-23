clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'SL';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_KX_Ntng.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Params

VOI = 2:11;
PST = [-1 2];
Conc = 1;
KS = 0.01;
TOI = 1:10;

%% OFC population PSTH to conc series

for R = 1:length(KWIKfiles)
    clear efd
    clear LRcells
    efd = EFDmaker_Beast(KWIKfiles{R},'bhv');
    LRcells = LRcellFinalizer(KWIKfiles{R});
    LR_idx{1} = LRcells.primLR;
    LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    [KDF_LR{R}, ~, KDFt_LR, ~] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,LR_idx{1}), PST, KS, TOI);
    [KDF_nLR{R}, ~, KDFt_nLR, ~] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,LR_idx{2}), PST, KS, TOI);
end

for R = 1:length(KWIKfiles)
    nLR{R} = reshape(KDF_nLR{R},size(KDF_nLR{R},2),size(KDF_nLR{R},3),size(KDF_nLR{R},1));
    KDFstack_nLR{R} = cat(1,nLR{R}(:,:));
end

for R = 1:length(KWIKfiles)
    LR{R} = reshape(KDF_LR{R},size(KDF_LR{R},2),size(KDF_LR{R},3),size(KDF_LR{R},1));
    KDFstack_LR{R} = cat(1,LR{R}(:,:));
end

%% Plot by experiment

figure; hold on
for R = 1:length(KWIKfiles)
    subplot(4,3,R); hold on
    colors = [.86 .08 .22; 0 0 0];%+.8-.2*conc;
    grays = [0 0 0; 0 0 0];%+.8-.2*conc;
    nLRstack = cell2mat(KDFstack_nLR{R}(1,:)');
    boundedline(KDFt_nLR,mean(nLRstack),sem(nLRstack),'cmap',grays);
    ax = gca; box off; ax.XAxis.Limits = PST; ax.YAxis.Limits = [0 8]; 
end

figure; hold on
for R = 1:length(KWIKfiles)
    subplot(4,3,R); hold on
    colors = [.86 .08 .22; 0 0 0];%+.8-.2*conc;
    grays = [0 0 0; 0 0 0];%+.8-.2*conc;
    LRstack = cell2mat(KDFstack_LR{R}(1,:)');
    boundedline(KDFt_LR,mean(LRstack),sem(LRstack),'cmap',colors);
    ax = gca; box off; ax.XAxis.Limits = PST; ax.YAxis.Limits = [0 8]; 
end









