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

%% Params

VOI = 2:11;
PST = [0 .5];
Conc = 2;
KS = 0.005;

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
        DurLR(m,n) = FWHM(KDFt_LR,cell2mat(LR(m,n)),.5);
    end
end

for m = 1:size(nLR,1)
    for n = 1:size(nLR,3)
        DurnLR(m,n) = FWHM(KDFt_nLR,cell2mat(nLR(m,n)),.5);
    end
end

%% Find active cells using binned ROC

for R = 1:length(KWIKfiles)
    [bROC_LR{R}, bROCp_LR{R}] = BinROCMaker_Beast(efd(R).ValveSpikes.RasterAlign(1:11,2,LR_idx{R,1}), [0 .5], .06);
    [bROC_nLR{R}, bROCp_nLR{R}] = BinROCMaker_Beast(efd(R).ValveSpikes.RasterAlign(1:11,2,LR_idx{R,2}), [0 .5], .06);
%     bROC_LR{R} = reshape(bROC_LR{R},size(bROC_LR{R},1),size(bROC_LR{R},3),size(bROC_LR{R},2));
%     bROCp_LR{R} = reshape(bROCp_LR{R},size(bROCp_LR{R},1),size(bROCp_LR{R},3),size(bROCp_LR{R},2));
%     bROC_nLR{R} = reshape(bROC_nLR{R},size(bROC_nLR{R},1),size(bROC_nLR{R},3),size(bROC_nLR{R},2));
%     bROCp_nLR{R} = reshape(bROCp_nLR{R},size(bROCp_nLR{R},1),size(bROCp_nLR{R},3),size(bROCp_nLR{R},2));
end

binROCLR = cat(2,bROC_LR{:,:});
binPLR = cat(2,bROCp_LR{:,:});

for m = 1:size(DurLR,1)
    for n = 1:size(DurLR,2)
        isActive = find(binPLR(m+1,n,:) < .05 & binROCLR(m+1,n,:) > .5);
        if isempty(isActive)
            activeUnit_LR(m,n) = 0;
        else
            activeUnit_LR(m,n) = DurLR(m,n);
        end
    end
end

binROCnLR = cat(2,bROC_nLR{:,:});
binPnLR = cat(2,bROCp_nLR{:,:});

for m = 1:size(DurnLR,1)
    for n = 1:size(DurnLR,2)
        isActive = find(binPnLR(m+1,n,:) < .05 & binROCnLR(m+1,n,:) > .5);
        if isempty(isActive)
            activeUnit_nLR(m,n) = 0;
        else
            activeUnit_nLR(m,n) = DurnLR(m,n);
        end
    end
end

%% Plot distribution

Dur_LR = activeUnit_LR(activeUnit_LR ~= 0);
Dur_nLR = activeUnit_nLR(activeUnit_nLR ~= 0);

edges = 0:.01:.5;
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
