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
    LR_idx{R,2} = sort([LR{R}.nonLR,LR{R}.secLR]);
    TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
end

%% Scoremaker

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% Params

VOI = 2:11;
Conc = 2;

%% Z-score in first breath cycle

for R = 1:length(KWIKfiles)
    zsc_LR{R} = Scores{R}.ZScore(VOI,Conc,LR_idx{R,1},1);
    zsc_nLR{R} = Scores{R}.ZScore(VOI,Conc,LR_idx{R,2},1);
    auROC_LR{R} = Scores{R}.auROC(VOI,Conc,LR_idx{R,1},1);
    auROC_nLR{R} = Scores{R}.auROC(VOI,Conc,LR_idx{R,2},1);
    AURp_LR{R} = Scores{R}.AURp(VOI,Conc,LR_idx{R,1},1);
    AURp_nLR{R} = Scores{R}.AURp(VOI,Conc,LR_idx{R,2},1);
end

zscLR = cat(3,zsc_LR{:,:});
zscnLR = cat(3,zsc_nLR{:,:});

auROCLR = cat(3,auROC_LR{:,:});
auROCnLR = cat(3,auROC_nLR{:,:});

AURpLR = cat(3,AURp_LR{:,:});
AURpnLR = cat(3,AURp_nLR{:,:});

%% 

for m = 1:size(zscLR,1)
    for n = 1:size(zscLR,3)
        if AURpLR(m,n) < .05 && auROCLR(m,n) > 0.5
            zscLR_active(m,n) = zscLR(m,n);
        else
            zscLR_active(m,n) = 0;
        end
    end
end

zscLR_conc1 = reshape(zscLR(:,1,:),[],1);
zscLR_conc2 = reshape(zscLR(:,2,:),[],1);
zscLR_conc3 = reshape(zscLR(:,3,:),[],1);

zscnLR_conc1 = reshape(zscnLR(:,1,:),[],1);
zscnLR_conc2 = reshape(zscnLR(:,2,:),[],1);
zscnLR_conc3 = reshape(zscnLR(:,3,:),[],1);

%% Plot means

for conc = 1:length(Conc)
    err1_ZLR = nanstd(zscLR_conc1)/sqrt(size(zscLR_conc1,3));
    err2_ZLR = nanstd(zscLR_conc2)/sqrt(size(zscLR_conc2,3));
    err3_ZLR = nanstd(zscLR_conc3)/sqrt(size(zscLR_conc3,3));
    err1_ZnLR = nanstd(zscnLR_conc1)/sqrt(size(zscnLR_conc1,3));
    err2_ZnLR = nanstd(zscnLR_conc2)/sqrt(size(zscnLR_conc2,3));
    err3_ZnLR = nanstd(zscnLR_conc3)/sqrt(size(zscnLR_conc3,3));
end

means = [nanmean(zscLR_conc1), nanmean(zscLR_conc2), nanmean(zscLR_conc3), nanmean(zscnLR_conc1), nanmean(zscnLR_conc2), nanmean(zscnLR_conc3),];
err = [err1_ZLR, err2_ZLR, err3_ZLR, err1_ZnLR, err2_ZnLR, err3_ZnLR];

figure; hold on

x = 1:6;

scatter((repmat(x(1),length(zscLR_conc1),1)),zscLR_conc1,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(zscLR_conc2),1)),zscLR_conc2,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(3),length(zscLR_conc3),1)),zscLR_conc3,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(4),length(zscnLR_conc1),1)),zscnLR_conc1,'ko','jitter','on','jitterAmount',.1)
scatter((repmat(x(5),length(zscnLR_conc2),1)),zscnLR_conc2,'ko','jitter','on','jitterAmount',.1)
scatter((repmat(x(6),length(zscnLR_conc3),1)),zscnLR_conc3,'ko','jitter','on','jitterAmount',.1)

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [-5 10];




