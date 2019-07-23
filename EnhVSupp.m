clearvars
close all
clc

%% Pick out recording files and put each in one cell

ROI = 'OB';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_RP.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker_Beast(KWIKfiles{R},'bhv');
end

%% Identify LR and nonLR cells 

for R = 1:length(KWIKfiles)
    LRcells{R} = LRcellFinalizer(KWIKfiles{R});
    LR_idx{R,1} = LRcells{R}.primLR;
    LR_idx{R,2} = sort([LRcells{R}.nonLR,LRcells{R}.secLR]);
end

%% Scoremaker

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% auROC and p-value of ranksum in first breath
% valve,conc,unit,cycle

VOI = 2:11;

for R = 1:length(KWIKfiles)
    AURp{R} = Scores{R}.AURp(VOI,2,:,1);
    auROC{R} = Scores{R}.auROC(VOI,2,:,1);
end

%% LR cells activated or suppressed

for R = 1:length(KWIKfiles)
    for valve = 1:length(VOI)
        for unit = 1:length(LR_idx{R,1})
            LR_enh_idx{R}(valve,unit) = AURp{R}(valve,LR_idx{R,1}(unit)) < .05 && auROC{R}(valve,LR_idx{R,1}(unit)) > .5;
            LR_supp_idx{R}(valve,unit) = AURp{R}(valve,LR_idx{R,1}(unit)) < .05 && auROC{R}(valve,LR_idx{R,1}(unit)) < .5;
        end
    end
end

for R = 1:length(KWIKfiles)
    LR_enh_sum{R} = find(LR_enh_idx{R} == 1);
    LR_supp_sum{R} = find(LR_supp_idx{R} == 1);
    totalCO_LR(R) = size(LR_enh_idx{R},1)*size(LR_enh_idx{R},2);
end

%% nLR cells activated or suppressed

for R = 1:length(KWIKfiles)
    for valve = 1:length(VOI)
        for unit = 1:length(LR_idx{R,2})
            nLR_enh_idx{R}(valve,unit) = AURp{R}(valve,LR_idx{R,2}(unit)) < .05 && auROC{R}(valve,LR_idx{R,2}(unit)) > .5;
            nLR_supp_idx{R}(valve,unit) = AURp{R}(valve,LR_idx{R,2}(unit)) < .05 && auROC{R}(valve,LR_idx{R,2}(unit)) < .5;
        end
    end
end

for R = 1:length(KWIKfiles)
    nLR_enh_sum{R} = find(nLR_enh_idx{R} == 1);
    nLR_supp_sum{R} = find(nLR_supp_idx{R} == 1);
    totalCO_nLR(R) = size(nLR_enh_idx{R},1)*size(nLR_enh_idx{R},2);
end

%% Percent cell-odor pairs activated or suppressed by experiment

for R = 1:length(KWIKfiles)
    LR_act(R) = (length(LR_enh_sum{R})/totalCO_LR(R))*100;
    LR_supp(R) = (length(LR_supp_sum{R})/totalCO_LR(R))*100;
    nLR_act(R) = (length(nLR_enh_sum{R})/totalCO_nLR(R))*100;
    nLR_supp(R) = (length(nLR_supp_sum{R})/totalCO_nLR(R))*100;
end

figure; hold on
x = 1:4;
scatter((repmat(x(1),length(LR_act),1)),LR_act,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(LR_supp),1)),LR_supp,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(3),length(nLR_act),1)),nLR_act,'ko','jitter','on','jitterAmount',.1)
scatter((repmat(x(4),length(nLR_supp),1)),nLR_supp,'ko','jitter','on','jitterAmount',.1)

means = [mean(LR_act), mean(LR_supp), mean(nLR_act), mean(nLR_supp)];
err = [std(LR_act)/sqrt(length(LR_act)), std(LR_supp)/sqrt(length(LR_supp)),...
    std(nLR_act)/sqrt(length(nLR_act)), std(nLR_supp)/sqrt(length(nLR_supp))];

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [0 20];

% LR_enh_frac = length(cat(1,LR_enh_sum{:,:}))/sum(totalCO_LR)*100;
% LR_supp_frac = length(cat(1,LR_supp_sum{:,:}))/sum(totalCO_LR)*100;
% 
% nLR_enh_frac = length(cat(1,nLR_enh_sum{:,:}))/sum(totalCO_nLR)*100;
% nLR_supp_frac = length(cat(1,nLR_supp_sum{:,:}))/sum(totalCO_nLR)*100;

% figure; hold on
% x = [1,2,3,4];
% plot(x(1),LR_enh_frac,'ro')
% plot(x(2),LR_supp_frac,'ro')
% plot(x(3),nLR_enh_frac,'ko')
% plot(x(4),nLR_supp_frac,'ko')
% 
% ax = gca;
% ax.YAxis.Limits = [0 10];

%% CDF

VOI = [2:11];

for R = 1:length(KWIKfiles)
    rankP_LR{R} = Scores{R}.AURp(VOI,2,LR_idx{R,1},1);
    auROC_LR{R} = Scores{R}.auROC(VOI,2,LR_idx{R,1},1);
end

rankp_LR = cat(3,rankP_LR{:,:});
aur_LR = cat(3,auROC_LR{:,:});

for unit = 1:size(rankp_LR,3)
    act_lr(unit) = sum(rankp_LR(:,unit) < .05 & aur_LR(:,unit) > .5);
    supp_lr(unit) = sum(rankp_LR(:,unit) < .05 & aur_LR(:,unit) < .5);
end

for R = 1:length(KWIKfiles)
    rankP_nLR{R} = Scores{R}.AURp(VOI,2,LR_idx{R,2},1);
    auROC_nLR{R} = Scores{R}.auROC(VOI,2,LR_idx{R,2},1);
end

rankp_nLR = cat(3,rankP_nLR{:,:});
aur_nLR = cat(3,auROC_nLR{:,:});

for unit = 1:size(rankp_nLR,3)
    act_nlr(unit) = sum(rankp_nLR(:,unit) < .05 & aur_nLR(:,unit) > .5);
    supp_nlr(unit) = sum(rankp_nLR(:,unit) < .05 & aur_nLR(:,unit) < .5);
end

%%

% edges = -1:1:10;
% 
% % act_LR = act_lr(act_lr ~= 0);
% % act_nLR = act_nlr(act_nlr ~= 0);
% 
% [N_LR,edges] = histcounts(act_lr,edges);
% [N_nLR,edges] = histcounts(act_nlr,edges);
% 
% cdf_LR = cumsum(N_LR)/sum(N_LR);
% cdf_nLR = cumsum(N_nLR)/sum(N_nLR);
% 
% figure; hold on
% plot(edges(1:end-1),cdf_LR,'r')
% plot(edges(1:end-1),cdf_nLR,'k')

%%

figure; hold on
edges = 0:1:10;
histogram(act_lr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(act_nlr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

ax = gca;
ax.YAxis.Limits = [0 1];

figure; hold on
edges = 0:1:10;
histogram(supp_lr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(supp_nlr,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

ax = gca;
ax.YAxis.Limits = [0 1];




