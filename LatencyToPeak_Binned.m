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
Conc = 3;
KS = 0.005;

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
        [val,idx] = max(LR{m,n});
        if KDFt_LR(idx) > .001            
            peakLatency_LR(m,n) = KDFt_LR(idx);
        else
            peakLatency_LR(m,n) = 0;
        end
    end
end
    
for m = 1:size(nonLR,1)
    for n = 1:size(nonLR,3)
        [val,idx] = max(nonLR{m,n});
        if KDFt_nLR(idx) > .001
            peakLatency_nLR(m,n) = KDFt_nLR(idx);
        else
            peakLatency_nLR(m,n) = 0;
        end
    end
end

%% Find active cells using binned ROC

for R = 1:length(KWIKfiles)
    [bROC_LR{R}, bROCp_LR{R}] = BinROCMaker_Beast(efd(R).ValveSpikes.RasterAlign(1:11,Conc,LR_idx{R,1}), [0 .5], .06);
    [bROC_nLR{R}, bROCp_nLR{R}] = BinROCMaker_Beast(efd(R).ValveSpikes.RasterAlign(1:11,Conc,LR_idx{R,2}), [0 .5], .06);
end

binROCLR = cat(2,bROC_LR{:,:});
binPLR = cat(2,bROCp_LR{:,:});

for m = 1:size(peakLatency_LR,1) % valves
    for n = 1:size(peakLatency_LR,2) % cells
        isActive = find(binPLR(m+1,n,:) < .05 & binROCLR(m+1,n,:) > .5);
        if isempty(isActive)
            activeUnit_LR(m,n) = 0;
        else
            activeUnit_LR(m,n) = peakLatency_LR(m,n);
        end
    end
end

binROCnLR = cat(2,bROC_nLR{:,:});
binPnLR = cat(2,bROCp_nLR{:,:});

for m = 1:size(peakLatency_nLR,1)
    for n = 1:size(peakLatency_nLR,2)
        isActive = find(binPnLR(m+1,n,:) < .05 & binROCnLR(m+1,n,:) > .5);
        if isempty(isActive)
            activeUnit_nLR(m,n) = 0;
        else
            activeUnit_nLR(m,n) = peakLatency_nLR(m,n);
        end
    end
end

%% Latency to peak cdf of activated cell-odor pairs

edges = 0:.01:.5;

% peakLatLR = activeUnit_LR(activeUnit_LR ~= 0);
% peakLatnLR = activeUnit_nLR(activeUnit_nLR ~= 0);

peakLatLR = peakLatency_LR(peakLatency_LR ~= 0);
peakLatnLR = peakLatency_nLR(peakLatency_nLR ~= 0);

[N_LR,edges] = histcounts(peakLatLR,edges);
[N_nLR,edges] = histcounts(peakLatnLR,edges);

cdf_LR = cumsum(N_LR)/sum(N_LR);
cdf_nLR = cumsum(N_nLR)/sum(N_nLR);

figure; hold on
plot(edges(1:end-1),cdf_LR,'r')
plot(edges(1:end-1),cdf_nLR,'k')




