clear all
close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\intensity\ExperimentCatalog_pcx_awk_intensity.txt';
% Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_GAD.txt';
% Catalog = 'Z:\expt_sets\tet_pcx_awake\ExperimentCatalog_tet_pcx_awk.txt';

T = readtable(Catalog, 'Delimiter', ' ');
% DorS = 'S';
% KWIKfiles = T.kwikfile(logical(T.include) & cell2mat(T.position) == DorS);
% FT = T.FT(logical(T.include) & cell2mat(T.position) == DorS);
% LT = T.LT(logical(T.include) & cell2mat(T.position) == DorS);

KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

%%
VOI = [1:5,10:13];
% VOI = [1:5];
PST = [0,0.5];

%%

for k = 1:length(KWIKfiles)
    TOI{1} = FT(k):LT(k);
    clear normPSTH
    efd(k) = EFDmaker(KWIKfiles{k});
    
    SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{k}));

    [WV.ypos{k},WV.pttime{k},WV.asym{k},WV.hfw{k},WV.bigwave{k}] = WaveStats(SpikeTimes.Wave);
    WV.ypos{k} = [double(WV.ypos{k}); double(WV.ypos{k})];
    
    % for finding peaks
    BinSize = 0.010;
    try
        [PSTH, ~, PSTHt, PSTHe] = KDFmaker(efd(k).ValveSpikes.RasterAlign(VOI,2:end), PST, BinSize, TOI{1});
    catch
        continue
    end
    for valve = 1:(size(PSTH,1)-1)
        for unit = 1:size(PSTH,2)
            if ~isempty(PSTH{valve+1,unit}) && ~isempty(PSTH{valve+1,unit})
                normPSTH(valve,unit,:) = PSTH{valve+1,unit}; % no BS
%                 normPSTH(valve,unit,:) = PSTH{valve+1,unit}-PSTH{1,unit}; % BS

            else
                normPSTH(valve,unit,:) = nan(1,length(PSTHt));
            end
        end
    end
    
    tsteps = mean(diff(PSTHt));
    realPST = PSTHt>=PST(1) & PSTHt<=PST(2);
    
    np = permute(normPSTH,[3,1,2]);
    npp = reshape(np,[size(np,1),size(np,2)/2,size(np,3)*2]);
    
    npp = npp(realPST,:,:);
    PSTHt = PSTHt(realPST);
    nps{k} = npp;
    
    [mx1,mxt1] = max(npp);
    mx{k} = squeeze(mx1);
    mxt{k} = PSTHt(squeeze(mxt1));
    
    [mn1,mnt1] = min(npp);
    mn{k} = squeeze(mn1);
    mnt{k} =  PSTHt(squeeze(mnt1));
end
%%
figure(202)
printpos([100 100 1000 300])
clf
CT = flipud(cbrewer('div','RdBu',64));

mxall = cat(2,mx{:});
mxtall = cat(2,mxt{:});
npall = cat(3,nps{:});

% getting rid of first bin peaks
NoPeak = min(mxtall)<=BinSize*2 | max(mxtall)>=PST(2)-.001;
% NoPeak = min(mxtall)<=BinSize*2 | max(mxtall)>=PST(2)-.001 | max(mxall)<=20;


mxall = mxall(:,~NoPeak);
mxtall = mxtall(:,~NoPeak);
npall = npall(:,:,~NoPeak);

for k = 1:4
    % activated plots
    subplotpos(4,1.1,k,1,.2)
    % sort by the latencies in response to concentration 3
    [Y,I] = sort(mxtall(3,:));
    npup = (squeeze(npall(:,k,:))');
    % plot the heatmap
    imagesc(PSTHt,[],npup(I,:))
    caxis([-50 50]); colormap(CT); xlim([0 .5]);
    set(gca,'XTick',[0:.1:.5],'YTick',[1 length(I)],'TickDir','out')
    hold on
    %putting dots on the peaks
    plot(mxtall(k,I),1:length(Y),'k.','markersize',3);
end


%% cdfs of peak timing
figure(11)
printpos([200 200 400 400])
clf
subplot(1,1,1)
% mxtup(mxtup>.5) = nan;
for k = 1:4
    [F,X] = ecdf(mxtall(k,:));
    plot(X,F,'Color',[1-k/10 0 0],'LineWidth',2*2.^(k-3));
    hold on
    axis square
    %     xlim([0 .5])
    box off
end
set(gca,'TickDir','out')
set(gca,'XTick',PST,'YTick',[0 1])

%%

figure(203)
printpos([100 100 1000 300])
clf
CT = flipud(cbrewer('div','RdBu',64));
for k = 1:4
    % activated plots
    subplotpos(4,1.1,k,1,.2)
    % sort by the latencies in response to concentration 3
    [Y,I] = sort(mxtall(3,:));
    npup = (squeeze(npall(:,k,:))');
    % plot the heatmap
    plot(mean(npup))
end

% [p,table,stats] = friedman([mxtall(1,:)',mxtall(2,:)',mxtall(3,:)',mxtall(4,:)']);
% c = multcompare(stats,'ctype','bonferroni','display','off')