clearvars
% close all
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

% for R = 1:length(KWIKfiles)
%     [LR_idx{R,1},LR_idx{R,2}] = LRcellPicker(KWIKfiles{R});
%     TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
% end

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

VOI = 2:11;
PST = [0 .5];
Conc = 1;
KS = 0.005;

%% Find cell-odor pair that have aurOC > .5

for R = 1:length(KWIKfiles)
    auROC_LR{R} = Scores{R}.auROC(VOI,Conc,LR_idx{R,1},1);
    auROC_nLR{R} = Scores{R}.auROC(VOI,Conc,LR_idx{R,2},1);
    AURp_LR{R} = Scores{R}.AURp(VOI,Conc,LR_idx{R,1},1);
    AURp_nLR{R} = Scores{R}.AURp(VOI,Conc,LR_idx{R,2},1);
end

auROCLR = cat(3,auROC_LR{:,:});
auROCnLR = cat(3,auROC_nLR{:,:});

AURpLR = cat(3,AURp_LR{:,:});
AURpnLR = cat(3,AURp_nLR{:,:});

%% Latency to spike

for R = 1:length(KWIKfiles)
    [KDF_LR{R}, ~, KDFt_LR, KDFe_LR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,1}), PST, KS);
end

for R = 1:length(KWIKfiles)
    [KDF_nLR{R}, ~, KDFt_nLR, KDFe_nLR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,2}), PST, KS);
end

LR = cat(3,KDF_LR{:,:});
nonLR = cat(3,KDF_nLR{:,:});

for m = 1:size(LR,1)
    for n = 1:size(LR,3)
        if AURpLR(m,n) < .05 && auROCLR(m,n) > 0.5
            [val,idx] = max(LR{m,n});
            peakLatency_LR(m,n) = KDFt_LR(idx);
        else
            peakLatency_LR(m,n) = 0;
        end
    end
end

for m = 1:size(LR,1)
    for n = 1:size(LR,3)
        if peakLatency_LR(m,n) < 0.001
            peakLatency_LR(m,n) = 0;
        end
    end
end
            
for m = 1:size(nonLR,1)
    for n = 1:size(nonLR,3)
        if AURpnLR(m,n) < .05 && auROCnLR(m,n) > 0.5
            [val,idx] = max(nonLR{m,n});
            peakLatency_nLR(m,n) = KDFt_nLR(idx);
        else
            peakLatency_nLR(m,n) = 0;
        end
    end
end

for m = 1:size(nonLR,1)
    for n = 1:size(nonLR,3)
        if peakLatency_nLR(m,n) < 0.001
            peakLatency_nLR(m,n) = 0;
        end
    end
end

%% Latency to peak distributions of activated cell-odor pairs

% means_peakLatLR = nanmean(peakLatency_LR);
% means_peakLatnLR = nanmean(peakLatency_nLR);
% 
% peakLatLR = peakLatency_LR(peakLatency_LR ~= 0);
% peakLatnLR = peakLatency_nLR(peakLatency_nLR ~= 0);
% 
% edges = 0:.002:.15;
% 
% figure; hold on
% histogram(peakLatLR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
% histogram(peakLatnLR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

%% Latency to peak cdf of activated cell-odor pairs

edges = 0:.005:.5;

peakLatLR = peakLatency_LR(peakLatency_LR ~= 0);
peakLatnLR = peakLatency_nLR(peakLatency_nLR ~= 0);

[N_LR,edges] = histcounts(peakLatLR,edges);
[N_nLR,edges] = histcounts(peakLatnLR,edges);

cdf_LR = cumsum(N_LR)/sum(N_LR);
cdf_nLR = cumsum(N_nLR)/sum(N_nLR);

figure; hold on
plot(edges(1:end-1),cdf_LR,'r')
plot(edges(1:end-1),cdf_nLR,'k')

%% Plot means

% err_latLR = std(peakLatLR)/sqrt(length(peakLatLR));
% err_latnLR = std(peakLatnLR)/sqrt(length(peakLatnLR));
% means = [mean(peakLatLR), mean(peakLatnLR)];
% err = [err_latLR, err_latnLR];
% 
% figure; hold on
% 
% x = 1:2;
% 
% scatter((repmat(x(1),length(peakLatLR),1)),peakLatLR,'ro','jitter','on','jitterAmount',.1)
% scatter((repmat(x(2),length(peakLatnLR),1)),peakLatnLR,'ko','jitter','on','jitterAmount',.1)
% 
% errorbar(means,err,'gx')
% 
% ax = gca;
% ax.YAxis.Limits = [0 .5];

