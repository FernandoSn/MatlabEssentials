function [RIB, RIP] = BinnedMapper(KWIKfile, mapparams)
%

% control valve. can't yet imagine why this wouldn't be 1
ControlValve = 1;

% get raster / spike times
efd = EFDmaker(KWIKfile);
Raster = efd.ValveSpikes.RasterAlign;

% get waveform DV positions (0 is probe bottom)
[SpikeTimes] = SpikeTimesPro(FindFilesKK(KWIKfile),'Good');
DV = cell2mat(SpikeTimes.Wave.Position(2:end)');
DV = DV(:,2);
[~, DVdex] = sort(DV); % goes from bottom to top of probe

% Maptype ([R]aw Rate, Rate [D]ifference, Response [I]ndex, [T]hresholded Response Index)
if isfield(mapparams, 'Maptype')
    Maptype = mapparams.Maptype;
else
    Maptype='I';% default
end

% PST
if isfield(mapparams, 'PST')
    PST = mapparams.PST;
else
    PST = [-.5 1];
end

% BinSize
if isfield(mapparams, 'BinSize')
    BinSize = mapparams.BinSize;
else
    BinSize = 0.03;
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

% Get control data
[~, blankPSTHtrials, ~] = PSTHmaker(Raster(ControlValve,2:end), PST, BinSize, SharedTrials);

% throw out uninteresting valves and MUA)
Raster = Raster(VOI,2:end);

%% Plotting
figure;
printpos([100 200 length(VOI)*220 550]);

for V = 1:length(VOI)
    subplotpos(length(VOI)+.3,1,V+.3,1,0.2);
    ax{V} = gca;
    ax{V}.Position(4) = ax{V}.Position(4)*plotheight;
    ax{V}.Position(2) = ax{V}.Position(2)+.02;
    
    switch Maptype
        case 'R'
            rawrate_plot(V)
        case 'D'
            ratedifference_plot(V)
        case 'I'
            responseindex_plot(V)
        case 'T'
            thresholded_plot(V)
    end
end


%% Plotting subfunctions

    function rawrate_plot(V)
        [PSTH, ~, PSTHt] = PSTHmaker(Raster, PST, BinSize, SharedTrials);
        FRB = cellcat3d(PSTH);
        FRB = FRB/length(SharedTrials)/BinSize;
        % RateLimit - color axis limits for rate plots
        if isfield(mapparams, 'RateLimit')
            RateLimit = mapparams.RateLimit;
        else
            temp = sort(FRB(:),'descend');
            RateLimit = ceil(temp(2));
        end
       
        FRBv = squeeze(FRB(V,DVdex,:));
        imagesc(PSTHt,[],FRBv); axis xy;
        caxis([0 RateLimit]);
        
        % coloration
        HT = hot(32);
        HT = HT(1:end-4,:);
        colormap(ax{V},HT)
        
        if V == length(VOI)
            h = colorbar('southoutside');
            h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
            set(gca,'YTick',[],'XTick',[]);
        end
        
        xticks = [PST(1):min(diff(sort([PST,0]))):PST(2)];
        xticklength = .02*length(DV)*ax{V}.Position(4);
        hold on
        for xt = 1:length(xticks)
            plot([xticks(xt) xticks(xt)], [.5-xticklength .5],'k', 'LineWidth', .5)
        end
        set(gca,'YTick',[],'XTick',xticks,'TickLength',[0 0],'Clipping','off');
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
%
    function responseindex_plot(V)
        [PSTH, PSTHtrials, PSTHt] = PSTHmaker(Raster(V,:), PST, BinSize, SharedTrials);
        ControlBins = reshape(cat(1,blankPSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        StimulusBins = reshape(cat(1,PSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        for unit = 1:size(ControlBins,1) % unit
            for bin = 1:size(ControlBins,3) % bin
                [bROC(V,unit,bin),bROCp(V,unit,bin)] = RankSumROC(ControlBins(unit,:,bin),StimulusBins(unit,:,bin));
            end
        end
        
        RIB = bROC(:,DVdex,:)*2-1; % aur of all units/bins
        RIP = bROCp(:,DVdex,:); % significance of all units/bins
        
        imagesc(PSTHt,[],squeeze(RIB(V,:,:))); axis xy;
        caxis([-1 1]);
        
        % coloration
        CT = flipud(cbrewer('div','RdBu',64));
        CT = CT(3:end-3,:);
        colormap(ax{V},CT);
        
        if V == length(VOI)
            h = colorbar('southoutside');
            h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
        end
        
        xticks = [PST(1):min(diff(sort([PST,0]))):PST(2)];
        xticklength = .02*length(DV)*ax{V}.Position(4);
        hold on
        for xt = 1:length(xticks)
            plot([xticks(xt) xticks(xt)], [.5-xticklength .5],'k', 'LineWidth', .5)
        end
        set(gca,'YTick',[],'XTick',xticks,'TickLength',[0 0],'Clipping','off');
    end

    function thresholded_plot(V)
        [~, PSTHtrials, PSTHt] = PSTHmaker(Raster(V,:), PST, BinSize, SharedTrials);
        ControlBins = reshape(cat(1,blankPSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        StimulusBins = reshape(cat(1,PSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        for unit = 1:size(ControlBins,1) % unit
            for bin = 1:size(ControlBins,3) % bin
                [bROC(V,unit,bin),bROCp(V,unit,bin)] = RankSumROC(ControlBins(unit,:,bin),StimulusBins(unit,:,bin));
            end
        end
        
        RIB = bROC(:,DVdex,:)*2-1; % aur of all units/bins
        RIP = bROCp(:,DVdex,:); % significance of all units/bins
        RIB(RIP>.05) = 0;
        
        imagesc(PSTHt,[],squeeze(RIB(V,:,:))); axis xy;
        caxis([-1 1]);
        
        % coloration
        CT = flipud(cbrewer('div','RdBu',64));
        CT = CT(3:end-3,:);
        colormap(ax{V},CT);
        
        if V == length(VOI)
            h = colorbar('southoutside');
            h.Position = [h.Position(1)+h.Position(3)/2, 0.05, h.Position(3)/2, 0.015];
        end
        
        xticks = [PST(1):min(diff(sort([PST,0]))):PST(2)];
        xticklength = .02*length(DV)*ax{V}.Position(4);
        hold on
        for xt = 1:length(xticks)
            plot([xticks(xt) xticks(xt)], [.5-xticklength .5],'k', 'LineWidth', .5)
        end
        set(gca,'YTick',[],'XTick',xticks,'TickLength',[0 0],'Clipping','off');
    end

end
