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

for R = 1:length(KWIKfiles)
    for unit = 1:size(efd(R).ValveSpikes.RasterAlign,3)
        for conc = 1:size(efd(R).ValveSpikes.RasterAlign,2)
            for valve = 1:size(efd(R).ValveSpikes.RasterAlign,1)
                OLraster{R}{valve,conc,unit} = efd(R).ValveSpikes.RasterAlign{valve,conc,unit}(OLset);
                Oraster{R}{valve,conc,unit} = efd(R).ValveSpikes.RasterAlign{valve,conc,unit}(Oset);
            end
        end
    end
end

%%

for R = 1:length(KWIKfiles)
    rankP_nLR_O{R} = Scores{R}.AURp(VOI,1,LR_idx{R,2},1,1);
    rankP_nLR_OL{R} = Scores{R}.AURp(VOI,1,LR_idx{R,2},1,2);
    aur_nLR_O{R} = Scores{R}.auROC(VOI,1,LR_idx{R,2},1,1);
    aur_nLR_OL{R} = Scores{R}.auROC(VOI,1,LR_idx{R,2},1,2);
end

auROC_O = cat(3,aur_nLR_O{:,:});
auROC_OL = cat(3,aur_nLR_OL{:,:});

AURp_O = cat(3,rankP_nLR_O{:,:});
AURp_OL = cat(3,rankP_nLR_OL{:,:});

%% Duration

for R = 1:length(KWIKfiles)
    [KDF_O{R}, ~, KDFt_O, KDFe_O{R}] = KDFmaker_Beast(Oraster{R}(VOI,1,LR_idx{R,2}), PST, 0.01);
    [KDF_OL{R}, ~, KDFt_OL, KDFe_OL{R}] = KDFmaker_Beast(OLraster{R}(VOI,1,LR_idx{R,2}), PST, 0.01);
end

O = cat(3,KDF_O{:,:});
OL = cat(3,KDF_OL{:,:});

for m = 1:size(O,1)
    for n = 1:size(O,3)
        if AURp_O(m,n) < .05 && auROC_O(m,n) > 0.5
            DurO(m,n) = FWHM(KDFt_O,cell2mat(O(m,n)),.5);
        else
            DurO(m,n) = 0;
        end
    end
end

for m = 1:size(OL,1)
    for n = 1:size(OL,3)
        if AURp_OL(m,n) < .05 && auROC_OL(m,n) > 0.5
            DurOL(m,n) = FWHM(KDFt_OL,cell2mat(OL(m,n)),.5);
        else
            DurOL(m,n) = 0;
        end
    end
end

%% Plot distribution

Dur_O = DurO(DurO ~= 0);
Dur_OL = DurOL(DurOL ~= 0);

edges = 0:.005:.5;
figure; hold on
histogram(Dur_O,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(Dur_OL,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

[N_LR,edges] = histcounts(Dur_O,edges);
[N_nLR,edges] = histcounts(Dur_OL,edges);

cdf_LR = cumsum(N_LR)/sum(N_LR);
cdf_nLR = cumsum(N_nLR)/sum(N_nLR);

figure; hold on
plot(edges(1:end-1),cdf_LR,'r')
plot(edges(1:end-1),cdf_nLR,'k')

%% Plot means

err_DurO = std(Dur_O)/sqrt(length(Dur_O));
err_DurOL = std(Dur_OL)/sqrt(length(Dur_OL));
means = [mean(Dur_O), mean(Dur_OL)];
err = [err_DurO, err_DurOL];

figure; hold on

x = 1:2;

scatter((repmat(x(1),length(Dur_O),1)),Dur_O,'ro','jitter','on','jitterAmount',.1)
scatter((repmat(x(2),length(Dur_OL),1)),Dur_OL,'ko','jitter','on','jitterAmount',.1)

errorbar(means,err,'gx')

ax = gca;
ax.YAxis.Limits = [0 .15];
