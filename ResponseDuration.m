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

%% Params

VOI = 2:11;
PST = [0 .5];
Conc = 2;
KS = 0.005;

%% To find cell-odor pairs that are activated (ranksum p<.05 and aurOC>.5)

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

%% Response duration for activated cell-odor pairs

for R = 1:length(KWIKfiles)
    [KDF_LR{R}, ~, KDFt_LR, KDFe_LR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,1}), PST, KS);
end

for R = 1:length(KWIKfiles)
    [KDF_nLR{R}, ~, KDFt_nLR, KDFe_nLR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,2}), PST, KS);
end

LR = cat(3,KDF_LR{:,:});
nLR = cat(3,KDF_nLR{:,:});

for m = 1:size(LR,1)
    for n = 1:size(LR,3)
        if AURpLR(m,n) < .05 && auROCLR(m,n) > 0.5
            DurLR(m,n) = FWHM(KDFt_LR,cell2mat(LR(m,n)),.5);
        else
            DurLR(m,n) = 0;
        end
    end
end

for m = 1:size(nLR,1)
    for n = 1:size(nLR,3)
        if AURpnLR(m,n) < .05 && auROCnLR(m,n) > 0.5
            DurnLR(m,n) = FWHM(KDFt_nLR,cell2mat(nLR(m,n)),.5);
        else
            DurnLR(m,n) = 0;
        end
    end
end

%% Plot distribution

Dur_LR = DurLR(DurLR ~= 0);
Dur_nLR = DurnLR(DurnLR ~= 0);

edges = 0:.005:.5;
figure; hold on
histogram(Dur_LR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(Dur_nLR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

[N_LR,edges] = histcounts(Dur_LR,edges);
[N_nLR,edges] = histcounts(Dur_nLR,edges);

cdf_LR = cumsum(N_LR)/sum(N_LR);
cdf_nLR = cumsum(N_nLR)/sum(N_nLR);

figure; hold on
plot(edges(1:end-1),cdf_LR,'r')
plot(edges(1:end-1),cdf_nLR,'k')

%% Plot means

err_DurLR = std(Dur_LR)/sqrt(length(Dur_LR));
err_DurnLR = std(Dur_nLR)/sqrt(length(Dur_nLR));
means = [mean(Dur_LR), mean(Dur_nLR)];
err = [err_DurLR, err_DurnLR];

figure; hold on

x = 1:2;

scatter((repmat(x(1),length(Dur_LR),1)),Dur_LR,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(Dur_nLR),1)),Dur_nLR,'ko','jitter','on','jitterAmount',.1)

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [0 .15];
