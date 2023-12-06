clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'SL';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_SL.txt';
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
    BreathStats = efd.BreathStats;
    CycleEdges = 0:10:360; % plot from inhale to inhale

    FVon = reshape(efd.ValveTimes.FVSwitchTimesOn,[],1);
    FVall = cat(2,FVon{:});
    
    stwarped_select = SpikeTimes.stwarped(LR_idx{R,1});

    for unit = 1:length(stwarped_select)
        for f = 1:length(FVall)
            stwarped = stwarped_select{unit}(stwarped_select{unit}>min(FVall) & stwarped_select{unit}<max(FVall));
            Toss = stwarped>FVall(f)-2 & stwarped<FVall(f)+4;
            stwarped(Toss) = [];
        end
        TossTime = 6*sum(FVall>min(FVall) & FVall<max(FVall));   
        spontRate{R}(unit) = length(stwarped)/(max(FVall)-min(FVall)-TossTime);
        
        
        Awarp = (360*mod(stwarped,BreathStats.AvgPeriod)/BreathStats.AvgPeriod); 
        awrp{R}{unit} = Awarp;
        [PhaseDist{R}{unit},~] = histc(awrp{R}{unit},CycleEdges);
        PhaseDist{R}{unit} = PhaseDist{R}{unit}/sum(PhaseDist{R}{unit}); % normalize phase distributions
        Kappa{R}(unit) = circ_kappa(deg2rad(awrp{R}{unit}));
        Rate{R}(unit) = length(awrp{R}{unit})/(max(FVall)-min(FVall)-TossTime);
        cmean{R}(unit) = circ_mean(deg2rad(awrp{R}{unit}));
        cmean{R}(unit) = rad2deg(cmean{R}(unit));
        Resultant{R}(unit) = circ_r(deg2rad(awrp{R}{unit}));
        PhaseTest{R}(unit) = circ_rtest(deg2rad(awrp{R}{unit}));
        PhaseTest{R}(unit) = PhaseTest{R}(unit)<.05;
    end
end

%% Heatmap

figure;
x = cat(2,PhaseDist{:});
xx = cat(2,x{1,:});
[Y,I] = max(xx);
[YY,II] = sort(I);
imagesc(CycleEdges(1:end-1)+5,1:size(xx,2),xx(1:end-1,II)')
colormap(flipud(pink))
caxis([0 0.1])
axis square
hold on 
set(gca,'YTick',[])
colorbar






