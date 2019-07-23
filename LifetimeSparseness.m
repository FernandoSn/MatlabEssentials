clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = {'PCX'};
Catalog = 'Y:\public\BR_Microscope\ExperimentCatalog_PCX';
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

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% Lifetime sparseness at .2% concentration
% valve,conc,unit,cycle

VOI = [2:11];
n = length(VOI);

for R = 1:length(KWIKfiles)
    spRate{R} = Scores{R}.RawRate(:,2,:,1);
end

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,1})
        num_top{R,unit} = ((sum(spRate{R}(VOI,:,LR_idx{R,1}(unit))))/n)^2;
        num_bottom{R,unit} = sum((spRate{R}(VOI,:,LR_idx{R,1}(unit)).^2)./n);
        num{R,unit} = 1-(num_top{R,unit}/num_bottom{R,unit});
        LR_LS{R}{unit} = num{R,unit}/(1-(1/n));
    end
end

clearvars -regexp ^num

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,2})
        num_top{R,unit} = ((sum(spRate{R}(VOI,:,LR_idx{R,2}(unit))))/n)^2;
        num_bottom{R,unit} = sum((spRate{R}(VOI,:,LR_idx{R,2}(unit)).^2)./n);
        num{R,unit} = 1-(num_top{R,unit}/num_bottom{R,unit});
        nLR_LS{R}{unit} = num{R,unit}/(1-(1/n));
    end
end

%% Means by experiment

for R = 1:length(KWIKfiles)
    LR_LS_mean(R) = nanmean(cell2mat(LR_LS{R}(:)));
    nLR_LS_mean(R) = nanmean(cell2mat(nLR_LS{R}(:)));
    LR_LS_var(R) = nanvar(cell2mat(LR_LS{R}(:)));
    nLR_LS_var(R) = nanvar(cell2mat(nLR_LS{R}(:)));
end

figure; hold on
x = 1:2;
scatter((repmat(x(1),length(LR_LS_mean),1)),LR_LS_mean,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(nLR_LS_mean),1)),nLR_LS_mean,'ko','jitter','on','jitterAmount',.1)

means = [mean(LR_LS_mean), mean(nLR_LS_mean)];
err = [std(LR_LS_mean)/sqrt(length(LR_LS_mean)), std(nLR_LS_mean)/sqrt(length(nLR_LS_mean))];

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [0 1];

figure; hold on
x = 1:2;
scatter((repmat(x(1),length(LR_LS_var),1)),LR_LS_var,'rx')
scatter((repmat(x(2),length(nLR_LS_var),1)),nLR_LS_var,'kx')

ax = gca;
ax.YAxis.Limits = [0 .1];

%% Histogram

LR_LS_all = cell2mat(cat(2,LR_LS{:,:}));
nLR_LS_all = cell2mat(cat(2,nLR_LS{:,:}));

edges = 0:.1:1;
figure; hold on
histogram(LR_LS_all,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(nLR_LS_all,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');


%% Means by unit

% LR_LS_mean = nanmean(cat(2,LR_LS{:,:}));
% LR_LS_err = std(cat(2,LR_LS{:,:}))/sqrt(length(cat(2,LR_LS{:,:})));
% 
% nLR_LS_mean = nanmean(cat(2,nLR_LS{:,:}));
% nLR_LS_err = nanstd(cat(2,nLR_LS{:,:}))/sqrt(length(cat(2,nLR_LS{:,:})));
% 
% means = [LR_LS_mean nLR_LS_mean];
% err = [LR_LS_err nLR_LS_err];
% figure; errorbar(means,err,'kx')
% 
% ax = gca;
% ax.YAxis.Limits = [0 1];


    
    
    
    
    
