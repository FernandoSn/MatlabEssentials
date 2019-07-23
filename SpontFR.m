clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'COA';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_RP.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

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

%% Spontaneous FR

for R = 1:length(KWIKfiles)
    SpikeTimes = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    efd = EFDmaker_Beast(KWIKfiles{R},'bhv');

    FVon = reshape(efd.ValveTimes.FVSwitchTimesOn,[],1);
    FVall = cat(2,FVon{:});

    for unit = 1:length(SpikeTimes.tsec)
        for f = 1:length(FVall)
            st = SpikeTimes.tsec{unit}(SpikeTimes.tsec{unit}>min(FVall) & SpikeTimes.tsec{unit}<max(FVall));
            Toss = st>FVall(f)-2 & st<FVall(f)+4;
            st(Toss) = [];
        end
        TossTime = 6*sum(FVall>min(FVall) & FVall<max(FVall));   
        spontRate{R}(unit) = length(st)/(max(FVall)-min(FVall)-TossTime);   
    end
end


%% Group LR and nLR cells spontaneous FR and scatter plot

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,1})
        spontRate_LR{R}(unit) = spontRate{R}(LR_idx{R,1}(unit));
    end
end

LR = cat(2,spontRate_LR{:,:});

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,2})
        spontRate_nLR{R}(unit) = spontRate{R}(LR_idx{R,2}(unit));
    end
end

nLR = cat(2,spontRate_nLR{:,:});

% x = 1:2;
% figure; hold on 
% scatter((repmat(x(1),length(LR),1)),LR,'ro')
% scatter((repmat(x(2),length(nLR),1)),nLR,'ko')
% 
% means = [mean(LR), mean(nLR)];
% err = [std(LR)/sqrt(length(LR)), std(nLR)/sqrt(length(nLR))];
% errorbar(means,err,'gx')
% 
% ax = gca;
% ax.YAxis.Limits = [0 100];

%% Log spont FR

log_LR = log10(LR);
log_nLR = log10(nLR);

edges = -2:.1:2;

figure; hold on
histogram(log_LR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','r');
histogram(log_nLR,edges,'Normalization','probability','DisplayStyle','stairs','EdgeColor','k');

ax = gca;
ax.YAxis.Limits = [0 .15];




















