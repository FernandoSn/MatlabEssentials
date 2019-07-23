function RasterPSTHPlotter_concentration(KWIKfile,plotparams)
% KWIKfile = path to KWIK file with all necessary files in same folder
%
% Fields of plotparams structure:
%
% .PlotsPerFigure = Number
% .VOI = valves of interest (Ex: [1,2,4,8]), default all valves if null
% vector: []
% .COI = cluster numbers (cells of interest) to analyze (Ex: [133,250,280]), 
% default all clusters if null vector: []
% .MarkedCells = unmarked cells are black, while marked cells are blue
% .Trials = trials, duh
% .Subplots = ['P','R'], plot PSTH or Raster or both
% .PSTHparams.PST
% .PSTHparams.KernelSize
% .PSTHparams.Axes
% .PSTHparams.ylimlist
% .Rparams.Shading
% .Rparams.Axes

concentration = 1;

% get raster / spike times
if isfield(plotparams,'behavior')
    efd = EFDmaker(KWIKfile,'bhv');
else
    efd = EFDmaker(KWIKfile);
end

% get clusternumbers (hidden in SpikeTimes.Units)
[SpikeTimes] = SpikeTimesKK(FindFilesKK(KWIKfile),'Good');

% COI; cells of interest (plotparams.COI)
if isfield(plotparams, 'COItype')
    COItype = plotparams.COItype;
else
    COItype = 'index';
end

if strcmp(COItype,'cluster');
    if isfield(plotparams, 'COI')
        [~,index] = ismember(plotparams.COI,cell2mat(SpikeTimes.units)');
        if any(ismember(0,index))
            error('One or more cells you have input is/are not a good cluster');
        end
        COIIndex = sort(index);
    else
        COIIndex = 2:length(SpikeTimes.units);
    end
elseif strcmp(COItype,'index');
    if isfield(plotparams, 'COI')
        [~,index] = ismember(plotparams.COI,((2:length(SpikeTimes.units)))');
        if any(ismember(0,index))
            error('One or more cells you have input is/are not a good cluster');
        end
        COIIndex = index+1;%sort(index);
    else
        COIIndex = 2:length(SpikeTimes.units);
    end
else
    error('COItype should be cluster or index');
end

%VOI valves of interest = [2:5,10:13];
if isfield(plotparams, 'VOI')
    VOI = plotparams.VOI;
else
    VOI = 1:size(efd.ValveTimes.FVSwitchTimesOn,2);
end


%Marked cells are blue
if isfield(plotparams, 'MarkedCells')
    MarkedCells = plotparams.MarkedCells;
else
    MarkedCells = [];
end

%Number of units/cells per figure
if isfield(plotparams, 'PlotsPerFigure')
    PlotsPerFigure = plotparams.PlotsPerFigure;
else
    PlotsPerFigure = 10; % default
end

% Column labels
VOILabels = arrayfun(@(x) {['Valve ' num2str(x)]},plotparams.VOI);
if isfield(plotparams, 'Labels')
    ColumnLabels = plotparams.Labels;
    if length(ColumnLabels) ~= length(VOILabels)
        disp('Wrong number of column labels. Using default')
        ColumnLabels = VOILabels;
    end
else
    ColumnLabels = VOILabels;
end

% Subplots (Raster and/or PSTH)
if isfield(plotparams, 'Subplots')
    Subplots = plotparams.Subplots;
else
    Subplots=['P','R'];% default
end

PlotsPerFigure = PlotsPerFigure*length(Subplots);

% PSTHparams
if ~isfield(plotparams, 'PSTHparams')
    PST = [-1,2];
    KernelSize = 0.02;
    P.Axes = 'off';
else
    if isfield(plotparams.PSTHparams, 'PST')
        PST = plotparams.PSTHparams.PST;
    else
        PST = [-1,2]; % default
    end
    
    if isfield(plotparams.PSTHparams, 'KernelSize')
        KernelSize = plotparams.PSTHparams.KernelSize;
    else
        KernelSize = 0.02; % default
    end
    
    if isfield(plotparams.PSTHparams, 'Axes')
        P.Axes = plotparams.PSTHparams.Axes;
    else
        P.Axes = 'off';
    end
    
    if isfield(plotparams.PSTHparams, 'RealBins')
        P.RealBins = plotparams.PSTHparams.RealBins;
    else
        P.RealBins = 'off';
    end
end

% deciding where to put xticks..
if range(PST)>2
    xticklist = ceil(PST(1)):floor(PST(2));
else
    xticklist = unique([0:-PST(2)/2:PST(1),0:PST(2)/2:PST(2)]);
end

% Raster params
if ~isfield(plotparams, 'R')
    R.Axes = 'off';
    R.Shading = 'off';
else
    if isfield(plotparams.R, 'Axes')
        R.Axes = plotparams.R.Axes;
    else
        R.Axes = 'off';
    end
    if isfield(plotparams.R, 'Shading')
        R.Shading = plotparams.R.Shading;
    else
        R.Shading = 'off';
    end
end

%%
if strcmp(VOI,'L')
    VOI = 1;
    Raster = efd.LaserSpikes.RasterAlign;
else
    Raster = efd.ValveSpikes.RasterAlign;
end

%VOI valves of interest = [2:5,10:13];
TrialsList = cell(1,length(VOI));
if isfield(plotparams, 'Trials')
%     TrialsList = plotparams.Trials;
    TrialsList = mat2cell(repmat(plotparams.Trials,length(VOI),1),ones(1,length(VOI)),length(plotparams.Trials));
else
numtrials = cellfun(@length,Raster(VOI,concentration,1));
    for v = 1:length(VOI)
        TrialsList{v} = 1:numtrials(v);
    end
end

if ismember('P',Subplots)
    if strcmp(P.RealBins,'off')
        [KDF, ~, KDFt, KDFe] = KDFmaker_Beast(Raster(VOI,concentration,COIIndex), PST, KernelSize,TrialsList{1});
        
        realPST = KDFt>=PST(1) & KDFt<=PST(2);
        % for PSTH plotting we want the ylimit to be the same across all valves and
        % for it to be a nice round number. for 1:10 it will round to nearest
        % integer.. for 11:100 it will round to the nearest 10.. etc..
        KDF(cellfun(@numel,KDF)==0) = {zeros(1,length(KDFt))};
        KDFe(cellfun(@numel,KDFe)==0) = {zeros(1,length(KDFt))};
        KDFstack = cell2mat(squeeze(KDF)') +cell2mat(squeeze(KDFe)');
        
    else
        [KDF, ~, KDFt] = PSTHmaker_Beast(Raster(VOI,concentration,COIIndex), PST, KernelSize,TrialsList{1});
        realPST = KDFt>=PST(1) & KDFt<=PST(2);

        KDFe = KDF;
        KDFstack = cell2mat(KDF');
        
    end
    
    a = max(KDFstack,[],2);
    if ~isfield(plotparams, 'PSTHparams')
        ylimlist = ceil(10*a./(10.^ceil(log10(a)))).*(10.^floor(log10(a)));
        ylimlist(a==0 | isnan(a)) = 1;
    else
        if ~isfield(plotparams.PSTHparams, 'ylimlist')
            ylimlist = ceil(10*a./(10.^ceil(log10(a)))).*(10.^floor(log10(a)));
            ylimlist(a==0 | isnan(a)) = 1;
        else
            if length(plotparams.PSTHparams.ylimlist) > 1
                ylimlist = plotparams.PSTHparams.ylimlist;
            else
                ylimlist = plotparams.PSTHparams.ylimlist*ones(size(a));
            end
        end
    end
end

%% Plotting
LineFormat.LineWidth = 0.1;

for Unit = 1:length(COIIndex)
    if mod((Unit-1)*length(Subplots),PlotsPerFigure)==0
        figure;
        printpos([300 100 length(VOI)*105 350*length(Subplots)]);
        
        % Labeling Columns
        for Valve = 1:length(VOI)
            subplotpos(length(VOI)+.3,PlotsPerFigure+1,Valve+.3,1,0.2);
            xlim([0 2]); ylim([0 2]); axis off;
            text(1,1,ColumnLabels{Valve},'HorizontalAlignment','center')
        end
    end
    for Valve = 1:length(VOI)
        Trials = TrialsList{Valve};
        
        % PSTH plotting
        if ismember('P',Subplots)
            if length(Subplots) < 2
                row = mod((Unit-1)*length(Subplots),PlotsPerFigure)+1;
            else
                row = mod((Unit-1)*length(Subplots),PlotsPerFigure)+1;
            end
            
            subplotpos(length(VOI)+.3,PlotsPerFigure+1,Valve+.3,row+1,0.2);
            hold on; axis off;            
            lineProps.width = .35;
            if ismember(COIIndex(Unit),MarkedCells)
                lineProps.col = {[.1 .5 .9]};
            else
                lineProps.col = {[.1 .15 .1]};
            end
            
            
            % Plot the kernel density function
            if numel(KDF{Valve,1,Unit})>0
                if strcmp(P.RealBins,'off')
                    mseb(KDFt(realPST),KDF{Valve,1,Unit}(realPST),KDFe{Valve,1,Unit}(realPST),lineProps);
                else
                    plot(KDFt(realPST),KDF{Valve,1,Unit}(realPST),'k');
                end
            end
            if strcmp(P.Axes,'on')
                % X and Y axes
                plot(PST,[0 0],'k')
                plot([0 0], [0 ylimlist(Unit)],'k');
                % X tick marks
                for tk = 1:length(xticklist)
                    plot([xticklist(tk),xticklist(tk)],[-ylimlist(Unit)/20 0],'k');
                end
                % Y tick mark
                plot([-range(PST)/50 0],[ylimlist(Unit) ylimlist(Unit)],'k')
            end
            
            % Limits
            xlim(PST); ylim([0 ylimlist(Unit)]); set(gca,'Clipping','off')
            
            % Labels
            if Valve == 1
                text(PST(1)-range(PST)/2.2,ylimlist(Unit)*5/9,['idx: ', num2str(COIIndex(Unit))],'FontSize',6);
                text(PST(1)-range(PST)/2.2,ylimlist(Unit)*8/9,['clu: ', num2str(SpikeTimes.units{COIIndex(Unit)})],'FontSize',6);
                text(0-range(PST)/22,ylimlist(Unit),(num2str(ylimlist(Unit))),'FontSize',6,'HorizontalAlignment','right');
            end
        end
        
        % Raster plotting
        if ismember('R',Subplots)
            if length(Subplots) < 2
                row = mod((Unit-1)*length(Subplots),PlotsPerFigure)+1;
            else
                row = mod((Unit-1)*length(Subplots),PlotsPerFigure)+2;
            end
            subplotpos(length(VOI)+.3,PlotsPerFigure+1,Valve+.3,row+1,0.2);
            
            if strcmp(R.Shading,'on')
                % patch plot FV boundaries
                FVtimes = efd.ValveTimes.FVSwitchTimesOn{VOI(Valve)}-efd.ValveTimes.PREXTimes{VOI(Valve)};
                FVtimes = FVtimes(Trials);
                patchy = [1:length(Trials); 1:length(Trials); 0:length(Trials)-1; 0:length(Trials)-1]+.5;
                patchx = [FVtimes; FVtimes+1; FVtimes+1; FVtimes];
                patch(patchx,patchy,[.85 .85 .85],'EdgeColor','none')
                hold on;
                
                % patch plot respiration boundaries
                RStimes1 = efd.PREX(efd.ValveTimes.PREXIndex{VOI(Valve)}+1)-efd.PREX(efd.ValveTimes.PREXIndex{VOI(Valve)});
                RStimes1 = RStimes1(Trials);
                patchy = [1:length(Trials); 1:length(Trials); 0:length(Trials)-1; 0:length(Trials)-1]+.5;
                patchx = [zeros(size(RStimes1)); RStimes1; RStimes1; zeros(size(RStimes1))];
                patch(patchx,patchy,[122/255 209/255 244/255],'EdgeColor','none')
                hold on;
            end
            
            % Plot Raster
            if ismember(COIIndex(Unit),MarkedCells)
                LineFormat.Color = [.1 .5 .9];
            else
                LineFormat.Color = [0 0 0];
            end
            plotSpikeRaster(Raster{VOI(Valve),concentration,COIIndex(Unit)}(Trials), 'LineFormat',LineFormat,'PlotType','vertline','XLimForCell',PST,'VertSpikeHeight',.5);
            axis off; box off; hold on;

            if strcmp(R.Axes,'on')
                % X and Y axes
                plot(PST,[length(Trials) length(Trials)]+.5,'k')
                plot([0 0], [0 length(Trials)]+.5,'k');
                % X tick marks
                for tk = 1:length(xticklist)
                    plot([xticklist(tk),xticklist(tk)],[length(Trials)/15+length(Trials) length(Trials)]+.5,'k');
                end
            end
            
            % Limit
            xlim(PST);
            
             % Labels if they weren't made on PSTH
            if Valve == 1 && ~ismember('P',Subplots)
                text(PST(1)-range(PST)/2.2,length(Trials)*4/9,['idx: ', num2str(COIIndex(Unit))],'FontSize',6);
                text(PST(1)-range(PST)/2.2,length(Trials)*1/9,['clu: ', num2str(SpikeTimes.units{COIIndex(Unit)})],'FontSize',6);
            end
        end
        
    end    
end
