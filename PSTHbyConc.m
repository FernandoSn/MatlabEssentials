clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'OFC';
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
PST = [-1 2];
Conc = 1:3;
KS = 0.01;

%% Population PSTH to conc series

for R = 1:length(KWIKfiles)
    [KDF{R}, ~, KDFt, KDFe{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,TypeStack{R}), PST, KS);
end

all = cat(3,KDF{:,:});
% allE = cat(3,KDFe{:,:});

% average all odors
for unit = 1:size(all,3)
    for conc = 1:size(all,2)
        all_rnd1{unit,conc} = mean(cell2mat(all(:,conc,unit)));
%         allE_rnd1{unit,conc} = mean(cell2mat(allE(:,conc,unit)),3);
    end
end

% average all units
for conc = 1:size(all,2)
    all_rnd2{conc} = mean(cell2mat(all_rnd1(:,conc)));
%     allE_rnd2{conc} = mean(cell2mat(allE_rnd1(:,conc)));
end

figure; subplot(1,3,1); hold on
plot(KDFt, cell2mat(all_rnd2(1)),'Color',[0.8 0.8 0.8]);
plot(KDFt, cell2mat(all_rnd2(2)),'Color',[0.6 0.6 0.6]);
plot(KDFt, cell2mat(all_rnd2(3)),'Color',[0 0 0]);

ax = gca;
ax.XAxis.Limits = PST;
ax.YAxis.Limits = [0 6]; 
ax.Title.String = {'all cells'; ['(n=',num2str(size(all,3)),')']};

%% LR population PSTH to conc series

for R = 1:length(KWIKfiles)
    [KDF_LR{R}, ~, KDFt_LR, KDFe_LR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,1}), PST, KS);
end

LR = cat(3,KDF_LR{:,:});
% LRe = cat(3,KDFe_LR{:,:});

for unit = 1:size(LR,3)
    for conc = 1:size(LR,2)
        LR_rnd1{unit,conc} = mean(cell2mat(LR(:,conc,unit)));
%         LRe_rnd1{unit,conc} = mean(cell2mat(LRe(:,conc,unit)));
    end
end

for conc = 1:size(LR,2)
    LR_rnd2{conc} = mean(cell2mat(LR_rnd1(:,conc)));
%     LRe_rnd2{conc} = mean(cell2mat(LRe_rnd1(:,conc)));
end

subplot(1,3,2); hold on
plot(KDFt_LR, cell2mat(LR_rnd2(1)),'Color',[0.8 0.8 0.8]);
plot(KDFt_LR, cell2mat(LR_rnd2(2)),'Color',[0.6 0.6 0.6]);
plot(KDFt_LR, cell2mat(LR_rnd2(3)),'Color',[0 0 0]);

ax = gca;
ax.XAxis.Limits = PST;
ax.YAxis.Limits = [0 6]; 
ax.Title.String = {[ROI '-proj']; ['(n=',num2str(size(LR,3)),')']};

%% 

for R = 1:length(KWIKfiles)
    [KDF_nLR{R}, ~, KDFt_nLR, KDFe_nLR{R}] = KDFmaker_Beast(efd(R).ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,2}), PST, KS);
end

nLR = cat(3,KDF_nLR{:,:});
% nLRe = cat(3,KDF_nLR{:,:});

for unit = 1:size(nLR,3)
    for conc = 1:size(nLR,2)
        nLR_rnd1{unit,conc} = mean(cell2mat(nLR(:,conc,unit)));
%         nLRe_rnd1{unit,conc} = mean(cell2mat(nLRe(:,conc,unit)));
    end
end

for conc = 1:size(nLR,2)
    nLR_rnd2{conc} = mean(cell2mat(nLR_rnd1(:,conc)));
%     nLRe_rnd2{conc} = mean(cell2mat(nLRe_rnd1(:,conc)));
end

subplot(1,3,3); hold on
plot(KDFt_nLR, cell2mat(nLR_rnd2(1)),'Color',[0.8 0.8 0.8]);
plot(KDFt_nLR, cell2mat(nLR_rnd2(2)),'Color',[0.6 0.6 0.6]);
plot(KDFt_nLR, cell2mat(nLR_rnd2(3)),'Color',[0 0 0]);

ax = gca;
ax.XAxis.Limits = PST;
ax.YAxis.Limits = [0 6]; 
ax.Title.String = {'arch-'; ['(n=',num2str(size(nLR,3)),')']};
