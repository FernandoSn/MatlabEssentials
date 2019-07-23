clearvars
% close all
clc

%% Pick out recording files and put each in one cell

ROI = 'OB';
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_RP.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Gather datas

% for R = 1:length(KWIKfiles)
%     SpikeTimes{R} = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
%     efd(R) = EFDmaker_Beast(KWIKfiles{R},'bhv');
% end

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

%% Scoremaker

for R = 1:length(KWIKfiles)
    Scores{R} = SCOmaker_Beast(KWIKfiles{R});
end

%% Params

VOI = 1:11;
PST = [-.1 .6];
Conc = 3;
Bin = 0.01;

%% Response index

for R = 1:length(KWIKfiles)
    clear KDF
    clear efd
    efd = EFDmaker_Beast(KWIKfiles{R});
    
    [KDF, ~, KDFt, KDFe] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,LR_idx{R,2}), PST, Bin);
    
    realPST = KDFt>=PST(1) & KDFt<=PST(2);
    KDFt = KDFt(realPST);
    
    KDFtbase = KDFt>PST(1) & KDFt<0;
    TESTVAR = efd.ValveSpikes.MultiCycleSpikeRate(VOI,Conc,LR_idx{R,2},1);
    
    for valve = 1:size(KDF,1)
        for unit = 1:size(KDF,3)
            if ~isempty(KDF{valve,1,unit})
                KDF{valve,1,unit} = KDF{valve,1,unit}(realPST);
%                 DFR{R}{valve,unit} = KDF{valve,unit} - nanmean(KDF{valve,unit}(KDFtbase));
%                 Z{R}{valve,unit} = DFR{R}{valve,unit}./nanstd(KDF{valve,unit}(KDFtbase));                    
                DFR{R}{valve,unit} = KDF{valve,1,unit} - nanmean(TESTVAR{1,1,unit});
                Z{R}{valve,unit} = DFR{R}{valve,unit}./nanstd(TESTVAR{1,1,unit});                
            else
                KDF{valve,unit} = nan(1,sum(realPST));
                DFR{R}{valve,unit} = nan(1,sum(realPST));
                Z{R}{valve,unit} = nan(1,sum(realPST));
            end
        end
    end
end

%% Sorted heatmap

for R = 1:length(KWIKfiles)
    RI{R} = reshape(Scores{R}.auROC(2:11,Conc,LR_idx{R,2}),[],1);
    Rp{R} = reshape(Scores{R}.AURp(2:11,Conc,LR_idx{R,2}),[],1);
    DFRF{R} = reshape(Z{R}(2:11,:),[],1);
end

RI_all = cat(1,RI{:});
Rp_all = cat(1,Rp{:});
DFRF_all = cat(1,DFRF{:});

[RI_sort,I] = sort(RI_all,'descend');
DFRF_all = DFRF_all(I);
Rp_all = Rp_all(I);
    
DFRF_all = squeeze(cell2mat(DFRF_all));
DFRF_all(isinf(DFRF_all)) = 0;
DFRF_all(isnan(DFRF_all)) = 0;

figure;
imagesc(KDFt,[],DFRF_all);
box off; 
ylm = get(gca,'YLim'); xlm = get(gca,'XLim');
rectangle('Position',[xlm(1) ylm(1) range(xlm) range(ylm)])
hold on;
plot([0 0],ylm,'k:','linewidth',.9)

CT = flipud(cbrewer('div','RdBu',64));
CT = CT([round(linspace(2,32,16)),round(linspace(33,52,16))],:);
colormap(CT)
caxis([-4 4])
set(gca,'Clipping','off','YTick',[1 length(RI_all)],'XTick',[0 .5],'TickLength',[.01 .01])
set(gca,'TitleFontSizeMultiplier',1,'LabelFontSizeMultiplier',1.2)

ups = find(Rp_all<.05 & RI_sort>.5);
plot([(PST(2)+.05)*ones(size(ups)) (PST(2)+.06)*ones(size(ups)) nan(size(ups))]',[ups ups ups]','r','linewidth',.4)

downs = find(Rp_all<.05 & RI_sort<.5);
plot([(PST(2)+.05)*ones(size(downs)) (PST(2)+.06)*ones(size(downs)) nan(size(downs))]',[downs downs downs]','b','linewidth',.4)














