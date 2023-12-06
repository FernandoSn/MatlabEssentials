function ResponseMapper(KWIKfile,mapparams)

% get raster / spike times
efd = EFDmaker(KWIKfile);
Raster = efd.ValveSpikes.RasterAlign;

% get waveform DV positions (0 is probe bottom)
[SpikeTimes] = SpikeTimesKK(FindFilesKK(KWIKfile),'Good');
DV = cell2mat(SpikeTimes.Wave.Position(2:end)');
DV = DV(:,2);
[~, DVdex] = sort(DV); % goes from bottom to top of probe

% Subplots ([R]aw Rate, Rate [D]ifference, Response [I]ndex, [T]hresholded Response Index)
if isfield(mapparams, 'Subplots')
    Subplots = mapparams.Subplots;
else
    Subplots=['R','D','I','T'];% default
end

% Always move Raw Rate to the first plotting slot because it has special
% requirements
if strfind(Subplots,'R')
    Subplots = ['R',setdiff(Subplots,'R')];
end

% VOI valves of interest = [2:5,10:13];
if isfield(mapparams, 'VOI')
    VOI = mapparams.VOI;
else
    VOI = 1:size(efd.ValveTimes.FVSwitchTimesOn,2);
end

% VOI valves of interest = [2:5,10:13];
if isfield(mapparams, 'Scale')
    Scale = mapparams.Scale == 'y';
else
    Scale = 1;
end

if Scale
    plotheight = length(DV)/75;
else
    plotheight = 1;
end

% Which trials are we analyzing
TrialsList = cell(1,length(VOI));
if isfield(mapparams, 'Trials')
    TrialsList = mat2cell(repmat(mapparams.Trials,length(VOI),1),ones(1,length(VOI)),length(mapparams.Trials));
else
    numtrials = cellfun(@length,Raster(VOI,1));
    for v = 1:length(VOI)
        TrialsList{v} = 1:numtrials(v);
    end
end

% In case valves have different number of trials. SCOmaker only takes one
% set for each 'condition'.
[~,LeastTrials] = min(cellfun(@length,TrialsList));
[~,MostTrials] = max(cellfun(@length,TrialsList));
SharedTrials = intersect(TrialsList{LeastTrials},TrialsList{MostTrials});

Scores = SCOmaker(KWIKfile,{SharedTrials});

% RateLimit - color axis limits for rate plots
if isfield(mapparams, 'RateLimit')
    RateLimit = mapparams.RateLimit;
else
    temp = Scores.RawRate(VOI,2:end,1);
    temp = sort(temp(:),'descend');
    RateLimit = ceil(temp(2));
end
    
% ZLimit - threshold limits for zscore plots
if isfield(mapparams, 'ZLimit')
    ZLimit = mapparams.ZLimit;
else
    ZLimit = 1;
end


%% Plotting
figure;
printpos([300 200 length(Subplots)*140 550]);

for sp = 1:length(Subplots)
    subplotpos(length(Subplots)+.3,1,sp+.3,1,0.2);
    ax{sp} = gca;
    ax{sp}.Position(4) = ax{sp}.Position(4)*plotheight;
    switch Subplots(sp)
        case 'R'
            rawrate_plot(Scores)
        case 'D'
            ratedifference_plot(Scores)
        case 'I'
            responseindex_plot(Scores)
        case 'T'
            thresholded_plot(Scores)
        case 'Z'
            zscore_plot(Scores)
    end
    set(gca,'YTick',[],'XTick',[])
end

%% Plotting subfunctions

    function rawrate_plot(Scores)
        RD = Scores.RawRate(VOI,2:end,1)*2-1;
        RD = RD(:,DVdex)';
        imagesc(RD); axis xy;
        caxis([0 RateLimit]);
        
        % coloration
        HT = hot(32);
        HT = HT(1:end-4,:);
        colormap(ax{sp},HT)
        h = colorbar('southoutside');
        h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
        set(gca,'YTick',[],'XTick',[]);
        drawnow;
        
        % baseline rate plotting
        temp = ax{sp}.Position;
        temp = [temp(1)-temp(3)*2/length(VOI) temp(2) temp(3)/length(VOI) temp(4)];
        BRax = axes('position',temp);
        BR = Scores.BlankRate(2:end,1);
        BR = BR(DVdex);
        imagesc(BR); axis xy; caxis([0 RateLimit]);
        colormap(BRax,HT);
        set(gca,'YTick',[],'XTick',[]);
        
        % return gca to ax{sp}
        axes(ax{sp});
    end

    function ratedifference_plot(Scores)
        RD = Scores.RateChange(VOI,2:end,1)*2-1;
        RD = RD(:,DVdex)';
        imagesc(RD); axis xy;
        caxis([-RateLimit RateLimit]);
        
        % coloration
        HT = [rot90(hot(32),2);(hot(32))];
        HT = HT(5:end-4,:);
        colormap(ax{sp},HT)
        h{sp} = colorbar('southoutside');
        h{sp}.Position = [h{sp}.Position(1)+h{sp}.Position(3)/2, 0.05, h{sp}.Position(3)/2, 0.015];
    end

    function responseindex_plot(Scores)
        RI = Scores.auROC(VOI,2:end,1)*2-1;
        RI = RI(:,DVdex)';
        imagesc(RI); axis xy;
        caxis([-1 1]);
        % coloration
        CT = flipud(cbrewer('div','RdBu',64));
        CT = CT(3:end-3,:);
        colormap(ax{sp},CT)
        h = colorbar('southoutside');
        h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
    end

    function thresholded_plot(Scores)
        RIT = Scores.auROC(VOI,2:end,1)*2-1;
        sigp = Scores.AURp(VOI,2:end,1)>.05;
        RIT(sigp) = 0;
        RIT = RIT(:,DVdex)';
        imagesc(RIT); axis xy;
        caxis([-1 1]);
        % coloration
        CT = flipud(cbrewer('div','RdBu',64));
        CT = CT(3:end-3,:);
        colormap(ax{sp},CT)
        h = colorbar('southoutside');
        h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
    end

    function zscore_plot(Scores)
        RD = Scores.ZScore(VOI,2:end,1)*2-1;
        RD = RD(:,DVdex)';
        RD(RD>ZLimit) = 4;
        RD(RD<ZLimit) = 0;
%         RD(RD<ZLimit & RD>-ZLimit) = 0;
%         RD(RD<-ZLimit) = -4;
        RD(isnan(RD)) = 0;
        
        imagesc(RD); axis xy;
        caxis([-2 2]);
        
        % coloration
        CT = flipud(cbrewer('div','RdBu',64));
        CT = CT(12:end-12,:);
        colormap(ax{sp},CT)
%         h{sp} = colorbar('southoutside');
%         h{sp}.Position = [h{sp}.Position(1)+h{sp}.Position(3)/2, 0.05, h{sp}.Position(3)/2, 0.015];
    end
end