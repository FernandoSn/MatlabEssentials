clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'SL';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_SL.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker_Beast(KWIKfiles{R},'bhv');
end

%% Identify LR and nonLR cells 

% for R = 1:length(KWIKfiles)
%     [LR_idx{R,1},LR_idx{R,2}] = LRcellPicker(KWIKfiles{R});
%     TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
% end

for R = 1:length(KWIKfiles)
    LR{R} = LRcellFinalizer(KWIKfiles{R});
end

for R = 1:length(KWIKfiles)
    LR_idx{R,1} = LR{R}.primLR;
    LR_idx{R,2} = [LR{R}.nonLR,LR{R}.secLR];
    TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
end

%% Params

VOI = [2:6];
PST = [-1 3];

%% Group laser on trials

Oset = [1:2:20];
OLset = [2:2:20];

TrialSets{1} = Oset;
TrialSets{2} = OLset;

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R},TrialSets);
end

%% zScores arch- 

for R = 1:length(KWIKfiles)
    ZSc_nLR_O{R} = Scores{R}.ZScore(VOI,1,LR_idx{R,2},1,1);
    ZSc_nLR_OL{R} = Scores{R}.ZScore(VOI,1,LR_idx{R,2},1,2);
end

zscoreO_nLR = cat(3,ZSc_nLR_O{:,:});
zscoreOL_nLR = cat(3,ZSc_nLR_OL{:,:});

yO = reshape(zscoreO_nLR,[],1);
yOL = reshape(zscoreOL_nLR,[],1);

figure; hold on
% x = 1:2;
% 
% scatter((repmat(x(1),length(yO),1)),yO,'ko','jitter','on','jitterAmount',.1)
% scatter((repmat(x(2),length(yOL),1)),yOL,'go','jitter','on','jitterAmount',.1)

err_zO = nanstd(yO)/sqrt(length(yO));
err_zOL = nanstd(yOL)/sqrt(length(yOL));
means = [nanmean(yO), nanmean(yOL)];
err = [err_zO, err_zOL];

errorbar(means,err,'rx')

ax = gca;
ax.YAxis.Limits = [-.2 .4];

%% Duration arch-

for R = 1:length(KWIKfiles)
    rankP_nLR_O{R} = Scores{R}.AURp(VOI,1,LR_idx{R,2},1,1);
    rankP_nLR_OL{R} = Scores{R}.AURp(VOI,1,LR_idx{R,2},1,2);
    aur_nLR_O{R} = Scores{R}.auROC(VOI,1,LR_idx{R,2},1,1);
    aur_nLR_OL{R} = Scores{R}.auROC(VOI,1,LR_idx{R,2},1,2);
end





