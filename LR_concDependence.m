clearvars
close all
clc

%% Pick out recording files and put each in one cell

ROI = 'OB';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_Projections.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker_Beast(KWIKfiles{R},'bhv');
end

%% Identify LR and nonLR cells 

for R = 1:length(KWIKfiles)
    [LR_idx{R,1},LR_idx{R,2}] = LRcellPicker(KWIKfiles{R});
    TypeStack{R} = cat(2,LR_idx{R,1},LR_idx{R,2});  % stack all cells within an experiment, each cell is one experiment
end

%% Scoremaker

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%%

% valve,conc,unit,cycle

VOI = [2 4 6 8];

for R = 1:length(KWIKfiles)
    ZScore_1{R} = Scores{R}.ZScore(VOI,:,:,1);
end

VOI = [3 5 7 9];

for R = 1:length(KWIKfiles)
    ZScore_2{R} = Scores{R}.ZScore(VOI,:,:,1);
end

for R = 1:length(KWIKfiles)
    ZScore{R} = [ZScore_1{R} ZScore_2{R}];
end

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,1})
        ZSc_LR{R,unit} = ZScore{R}(:,:,LR_idx{R,1}(unit));
    end
end

for R = 1:length(KWIKfiles)
    for unit = 1:length(LR_idx{R,2})
        ZSc_nLR{R,unit} = ZScore{R}(:,:,LR_idx{R,2}(unit));
    end
end
        
LR = cat(1,ZSc_LR{:,:});
nLR = cat(1,ZSc_nLR{:,:});
        
figure; hold on

grps = 1:6;

for k = 1:length(grps)
    plot(grps(k),nanmean(LR(:,k)),'kx')
end
     
for k = 1:length(grps)
    plot(grps(k),LR(:,k),'ro')
end


