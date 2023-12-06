clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'COA';
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
end

for R = 1:length(KWIKfiles)
    LR_idx{R,1} = LRcells{R}.primLR;
    LR_idx{R,2} = sort([LRcells{R}.nonLR,LRcells{R}.secLR]);
    TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
end

%% Scoremaker

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% Params

% conc = 2;
% 
% for R = 1:length(KWIKfiles)
%     rawR{R} = Scores{R}.RawRate(:,conc,:,1);
%     blankR{R} = Scores{R}.BlankRate(3,:,1);
%     diffR{R} = Scores{R}.RateChange(:,conc,:,1);
% end
% 
% diff_all = cat(3,diffR{:,:});
% raw_all = cat(3,rawR{:,:});
% blank_all = cat(2,blankR{:,:});

%% Rate change

VOI = 1:11;
neutral = [3,4,6,7,10,11];
appet = [2,5];
aver = [8,9];

for R = 1:length(KWIKfiles)
    for valve = 1:length(VOI)
        for unit = 1:length(LR_idx{R,1})
            diff_LR{R}(valve,unit) = Scores{R}.ZScore(valve,2,LR_idx{R,1}(unit),1);
        end
        
        for unit = 1:length(LR_idx{R,2})
            diff_nLR{R}(valve,unit) = Scores{R}.ZScore(valve,2,LR_idx{R,2}(unit),1);
        end
    end
end

diff_all_LR = cat(2,diff_LR{:,:});
diff_all_nLR = cat(2,diff_nLR{:,:});

% neutral rate change

for valve = 1:length(neutral)
    for unit = 1:size(diff_all_LR,2)
        neutral_diff_LR(valve,unit) = diff_all_LR(neutral(valve),unit);
    end
    
    for unit = 1:size(diff_all_nLR,2)
        neutral_diff_nLR(valve,unit) = diff_all_nLR(neutral(valve),unit);
    end
end
    
% appetitive rate change

for valve = 1:length(appet)
    for unit = 1:size(diff_all_LR,2)
        appet_diff_LR(valve,unit) = diff_all_LR(appet(valve),unit);
    end
    
    for unit = 1:size(diff_all_nLR,2)
        appet_diff_nLR(valve,unit) = diff_all_nLR(appet(valve),unit);
    end
end

% aversive rate change

for valve = 1:length(aver)
    for unit = 1:size(diff_all_LR,2)
        aver_diff_LR(valve,unit) = diff_all_LR(aver(valve),unit);
    end
    
    for unit = 1:size(diff_all_nLR,2)
        aver_diff_nLR(valve,unit) = diff_all_nLR(aver(valve),unit);
    end
end

mean_neut_lr = nanmean(neutral_diff_LR,1);
mean_neut_nlr = nanmean(neutral_diff_nLR,1);

mean_appet_lr = nanmean(appet_diff_LR,1);
mean_appet_nlr = nanmean(appet_diff_nLR,1);

mean_aver_lr = nanmean(aver_diff_LR,1);
mean_aver_nlr = nanmean(aver_diff_nLR,1);



%% Plot

figure; hold on

x = 1:6;

scatter((repmat(x(1),length(mean_neut_lr),1)),mean_neut_lr,'ro')
scatter((repmat(x(2),length(mean_neut_nlr),1)),mean_neut_nlr,'ko')

scatter((repmat(x(3),length(mean_appet_lr),1)),mean_appet_lr,'ro')
scatter((repmat(x(4),length(mean_appet_nlr),1)),mean_appet_nlr,'ko')

scatter((repmat(x(5),length(mean_aver_lr),1)),mean_aver_lr,'ro')
scatter((repmat(x(6),length(mean_aver_nlr),1)),mean_aver_nlr,'ko')

means = [nanmean(mean_neut_lr), nanmean(mean_neut_nlr), nanmean(mean_appet_lr), nanmean(mean_appet_nlr), nanmean(mean_aver_lr), nanmean(mean_aver_nlr)];
err = [nanstd(mean_neut_lr)/sqrt(length(mean_neut_lr)), nanstd(mean_neut_nlr)/sqrt(length(mean_neut_nlr)), nanstd(mean_appet_lr)/sqrt(length(mean_appet_lr)), ...
    nanstd(mean_appet_nlr)/sqrt(length(mean_appet_nlr)), nanstd(mean_aver_lr)/sqrt(length(mean_aver_lr)), nanstd(mean_aver_nlr)/sqrt(length(mean_aver_nlr))];

errorbar(means,err,'gx')
 
ax = gca;
ax.YAxis.Limits = [-2 3];
%% all odors normalized rate to blank (1%)

% for valve = 1:size(diff_all_LR,1)
%     for unit = 1:size(diff_all_LR,3)
%         norm_all(valve,unit) = sqrt((diff_all_LR(valve,unit)^2))/blank_all(unit);
%         if norm_all(valve,unit) == inf 
%             norm_all(valve,unit) = nan;
%         end
%     end
% end
