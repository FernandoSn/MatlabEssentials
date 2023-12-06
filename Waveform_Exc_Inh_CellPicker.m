clearvars
close all
clc

%% Pick out recording files and put each in one cell

Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_RP.txt';
T = readtable(Catalog, 'Delimiter', ' ');
OBfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,'OB'));
OFCfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,'OFC'));
COAfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,'COA'));

%% Waveform peak-trough time and spont rate OFC

for R = 1:length(OFCfiles)
    clear efd
    clear SpikeTimes
    clear LRcells
    SpikeTimes = SpikeTimes_Beast(FindFilesKK(OFCfiles{R}));
    efd = EFDmaker_Beast(OFCfiles{R},'bhv');
    LRcells = LRcellFinalizer(OFCfiles{R});
    LR_idx{1} = LRcells.primLR;
    LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    
    % peak-trough time
    [ypos,pttime,asym,hfw,bigwave,ypos_real] = WaveStats_Beast(SpikeTimes.Wave);
    pttimeOFC{R} = pttime(LR_idx{1});
    pttimeNLR{R} = pttime(LR_idx{2});
    
    % spontaneous FR
    FVon = reshape(efd.ValveTimes.FVSwitchTimesOn,[],1);
    FVall = cat(2,FVon{:});
    for unit = 1:length(SpikeTimes.tsec)
        for f = 1:length(FVall)
            st = SpikeTimes.tsec{unit}(SpikeTimes.tsec{unit}>min(FVall) & SpikeTimes.tsec{unit}<max(FVall));
            Toss = st>FVall(f)-2 & st<FVall(f)+4;
            st(Toss) = [];
        end
        TossTime = 6*sum(FVall>min(FVall) & FVall<max(FVall));   
        spontRate_OFC{R}(unit) = length(st)/(max(FVall)-min(FVall)-TossTime);   
    end
end

ptnLR = cat(1,pttimeNLR{:,:});

%OFC
for R = 1:length(OFCfiles)
    clear LRcells
    LRcells = LRcellFinalizer(OFCfiles{R});
    LR_idx{1} = LRcells.primLR;
    LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    
    for unit = 1:length(LR_idx{2})
        spontRateOFC_nLR{R}(unit) = spontRate_OFC{R}(LR_idx{2}(unit));
    end
end

OFCnLR = cat(2,spontRateOFC_nLR{:,:})';
log_OFCnLR = log10(OFCnLR);

%% Plot spont FR vs. pttime

x = log_OFCnLR;
y = ptnLR;

figure;
scatter(x,y,'MarkerFaceColor','k','MarkerEdgeColor','none')

ax = gca;
ax.YAxis.Limits = [0 1];
ax.XAxis.Limits = [-2 2];






