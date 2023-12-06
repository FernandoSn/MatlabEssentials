clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = {'AON'};
Catalog = 'Z:\AON\Expt_Sets\catalog\ExperimentCatalog_AON';
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

%% Scoremaker

OLset = [2:2:20];
Oset = [1:2:20];

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% Heatmap of Z-score and auROC in first breath
% valve,conc,unit,cycle

VOI = [1:11];

for R = 1:length(KWIKfiles)
    zScore{R} = Scores{R}.ZScore(VOI,2,:,1);
    auROC{R} = Scores{R}.auROC(VOI,2,:,1);
end

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,1})
        LR_zSc{R,unit} = auROC{R}(:,:,LR_idx{R,1}(unit));
    end
end

LR_z = cat(3,LR_zSc{:,:});
LR_z = (LR_z*2)-1; % change scale
LR_z = reshape(LR_z,[],size(LR_z,3),1)';

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,2})
        nLR_zSc{R,unit} = auROC{R}(:,:,LR_idx{R,2}(unit));
    end
end

nLR_z = cat(3,nLR_zSc{:,:});
nLR_z = (nLR_z*2)-1; % change scale
nLR_z = reshape(nLR_z,[],size(nLR_z,3),1)';

colorLim = [-1 1];
HeatMapper(LR_z,'All Odors, All Conc','arch+',colorLim)
HeatMapper(nLR_z,'All Odors, All Conc','arch-',colorLim)

%% Tuning curves

VOI = [2:11];

for R = 1:length(KWIKfiles)
        rankP_LR{R} = Scores{R}.AURp(VOI,2,LR_idx{R,1},1);
end

rankp_LR = cat(3,rankP_LR{:,:});

for unit = 1:size(rankp_LR,3)
    tun_lr(unit) = sum(rankp_LR(:,unit) < .05);
end

for R = 1:length(KWIKfiles)
        rankP_nLR{R} = Scores{R}.AURp(VOI,2,LR_idx{R,2},1);
end

rankp_nLR = cat(3,rankP_nLR{:,:});

for unit = 1:size(rankp_nLR,3)
    tun_nlr(unit) = sum(rankp_nLR(:,unit) < .05);
end

%% Plot tuning cdf

figure; hold on
edges = 0:1:10;
histogram(tun_lr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(tun_nlr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');
ax = gca;
ax.YAxis.Limits = [0 1];






