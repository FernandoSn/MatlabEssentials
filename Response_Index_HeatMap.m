clearvars
close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_bulb_awk_kx_update.txt';
% Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_pcx_awk_kx_update.txt';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
Kindex = find(T.include);

specialparams.FRlim = 1/300;
specialparams.UVlim = 50;
specialparams.DFRlim = 100;

[TypeIdx, TypeStack] = CellTyper (Catalog, 'Stable', specialparams);

%%
PST = [-.1, 0.6];

for k = 1:length(KWIKfiles)
    clear KDF
    efd(k) = EFDmaker(KWIKfiles{k});
    
    if strcmp(T.VOI(Kindex(k)),'A')
        VOI = [4,7,8,12,15,16];
    elseif strcmp(T.VOI(Kindex(k)),'B')
        VOI = [2,3,4,5,7,8];
    elseif strcmp(T.VOI(Kindex(k)),'C')
        VOI = [6,7,8,10,11,12];
    end
    
    TOI{1} = T.FTa(Kindex(k)):T.LTa(Kindex(k));
    TOI{2} = T.FTk(Kindex(k)):T.LTk(Kindex(k));
    
    for tset = 1:2
        % for finding peaks
        BinSize = 0.010;
        %         [KDF, KDFtrials, KDFt, KDFe] = KDFmaker(efd(k).ValveSpikes.RasterAlign(VOI,2:end), PST, BinSize, TOI{tset});
        [KDF, KDFtrials, KDFt, KDFe] = KDFmaker(efd(k).ValveSpikes.RasterAlign(VOI,TypeIdx{k,1}), PST, BinSize, TOI{tset});
        
        realPST = KDFt>=PST(1) & KDFt<=PST(2);
        KDFt = KDFt(realPST);
        
%         TESTVAR = efd(k).ValveSpikes.MultiCycleSpikeRate([1 VOI],2:end,1);
                TESTVAR = efd(k).ValveSpikes.MultiCycleSpikeRate([1 VOI],TypeIdx{k,1},1);

        
        for valve = 1:(size(KDF,1))
            for unit = 1:size(KDF,2)
                % First Cycle
                % auROC and p-value for ranksum test
                [Scores.auROC{k}(valve,unit,tset), Scores.AURp{k}(valve,unit,tset)] = RankSumROC(TESTVAR{1,unit,1}(TOI{tset}),TESTVAR{valve+1,unit,1}(TOI{tset}));
                
                if ~isempty(KDF{valve,unit}) && ~isempty(KDF{valve,unit})
                    KDF{valve,unit} = KDF{valve,unit}(realPST);
                    kt = squeeze(cell2mat(KDFtrials(valve,unit,:)));
                    kt = kt(realPST,:);
%                     for bin = 1:size(kt,1)
%                         RIF{k}{valve,unit,tset}(bin) = RankSumROC(TESTVAR{1,unit,1}(TOI{tset}),kt(bin,:));
%                     end
                    DFR{k}{valve,unit,tset} = KDF{valve,unit} - nanmean(TESTVAR{1,unit,1}(TOI{tset}));
                    Z{k}{valve,unit,tset} = DFR{k}{valve,unit,tset}./nanstd(TESTVAR{1,unit,1}(TOI{tset}));
                else
                    KDF{valve,unit} = nan(1,sum(realPST));
%                     RIF{k}{valve,unit,tset} = nan(1,sum(realPST));
                    DFR{k}{valve,unit,tset} = nan(1,sum(realPST));
                    Z{k}{valve,unit,tset} = nan(1,sum(realPST));
                end
            end
        end
    end
end
%%
figure(2)
% printpos([200 200 400 400])
printpos([200 200 180 289])
clf

for tset = 1:2
    for k = 1:length(KWIKfiles)
        RI{k,tset} = reshape(Scores.auROC{k}(:,:,tset),[],1);
        Rp{k,tset} = reshape(Scores.AURp{k}(:,:,tset),[],1);
        DFRF{k,tset} = reshape(Z{k}(:,:,tset),[],1);
    end
    
    RI_all = cat(1,RI{:,tset});
    Rp_all = cat(1,Rp{:,tset});
    DFRF_all = cat(1,DFRF{:,tset});
    
    [RI_sort,I] = sort(RI_all,'descend');
    DFRF_all = DFRF_all(I);
    Rp_all = Rp_all(I);
    
%     subplot(1,2,tset)
    subplotpos(2.3,1,tset+.3,1,.3)

    DFRF_all = squeeze(cell2mat(DFRF_all));
    DFRF_all(isnan(DFRF_all)) = 0;
    DFRF_all(isinf(DFRF_all)) = 0;
    
    
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

    if tset == 2
        set(gca,'YTick',[])
    else
        yl = ylabel('cell-odor pairs');
        yl.Position(1) = -.2;
    end
    hold on
    
    ups = find(Rp_all<.05 & RI_sort>.5);
    plot([(PST(2)+.05)*ones(size(ups)) (PST(2)+.06)*ones(size(ups)) nan(size(ups))]',[ups ups ups]','r','linewidth',.4)
    
    downs = find(Rp_all<.05 & RI_sort<.5);
    plot([(PST(2)+.05)*ones(size(downs)) (PST(2)+.06)*ones(size(downs)) nan(size(downs))]',[downs downs downs]','b','linewidth',.4)
end
% colorbar
