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

OLset = [2:2:20];
Oset = [1:2:20];

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

% align by laser on
% for R = 1:length(KWIKfiles)
%     for unit = 1:size(efd(R).LaserSpikes.RasterAlign,2)
%         OLraster{R}{unit} = efd(R).LaserSpikes.RasterAlign{unit}(OLset);
%         Oraster{R}{unit} = efd(R).LaserSpikes.RasterAlign{unit}(Oset);
%     end
% end

%% Population PSTH

for R = 1:length(KWIKfiles)
    [KDF_O{R}, ~, KDFt_O, KDFe_O{R}] = KDFmaker_Beast(Oraster{R}(VOI,1,:), PST, 0.01);
    [KDF_OL{R}, ~, KDFt_OL, KDFe_OL{R}] = KDFmaker_Beast(OLraster{R}(VOI,1,:), PST, 0.01);
end

% align by laser on
% for R = 1:length(KWIKfiles)
%     [KDF_O{R}, ~, KDFt_O, KDFe_O{R}] = KDFmaker_Beast(Oraster{R}(:,LR_idx{R,2}), PST, 0.01);
%     [KDF_OL{R}, ~, KDFt_OL, KDFe_OL{R}] = KDFmaker_Beast(OLraster{R}(:,LR_idx{R,2}), PST, 0.01);
% end

O = cat(3,KDF_O{:,:});
OL = cat(3,KDF_OL{:,:});

for unit = 1:size(O,3)
    O_rnd1{unit,conc} = mean(cell2mat(O(:,1,unit)));
    OL_rnd1{unit,conc} = mean(cell2mat(OL(:,1,unit)));
end

O_rnd2 = mean(cell2mat(O_rnd1(:,1)));
OL_rnd2 = mean(cell2mat(OL_rnd1(:,1)));

figure; hold on
plot(KDFt_O, O_rnd2,'k');
plot(KDFt_OL, OL_rnd2,'g');

ax = gca;
ax.XAxis.Limits = PST;
ax.YAxis.Limits = [0 12]; 
% ax.Title.String = {'arch-'; ['(n=',num2str(size(O,3)),')']};