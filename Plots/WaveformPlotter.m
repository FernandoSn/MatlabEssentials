function WaveformPlotter(KWIKfile,plotparams)
%function RasterPSTHPlotter(KWIKfile,VOI,COI,MarkedCells,PlotsPerFigure,Subplots,PSTHparams)
%
% KWIKfile = path to KWIK file with all necessary files in same folder
%
% Fields of plotparams structure:
%
% .PlotsPerFigure = Number
% .VOI = valves of interest (Ex: [1,2,4,8]), default all valves if null
% vector: []
% .COI = cluster numbers (cells of interest) to analyze (Ex: [133,250,280]),
% default all clusters if null vector: []
% .COItype = 'index' if you want to specify cells by where they are in the
% efd matrix.. or 'cluster' if you want to specify by their cluster numbers
% .MarkedCells = unmarked cells are black, while marked cells are blue

% get DAT file
[a,b] = fileparts(KWIKfile);
DATfile = fullfile(a,[b,'.dat']);

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
        [~,index] = ismember(plotparams.COI,((2:length(SpikeTimes.units))-1)');
        if any(ismember(0,index))
            error('One or more cells you have input is/are not a good cluster');
        end
        COIIndex = index;%sort(index);
    else
        COIIndex = 2:length(SpikeTimes.units);
    end
else
    error('COItype should be cluster or index');
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

%% Plotting
wavelim = [-1000 1000];
for Unit = 1:length(COIIndex)
    if mod((Unit-1),PlotsPerFigure)==0
        figure;
        printpos([300 100 105 700]);
    end
    % Waveform plotting
    row = mod((Unit-1),PlotsPerFigure)+1;
    subplotpos(1+.3,PlotsPerFigure,1+.3,row,0.2);
    
    % Mark cells
    if ismember(COIIndex(Unit),MarkedCells)
        LineFormat.Color = [.1 .5 .9];
    else
        LineFormat.Color = [0 0 0];
    end
    
    wfsubsample = 20;
    RawChannelCount = double(h5readatt(KWIKfile, '/application_data/spikedetekt','n_channels'));
    Fs = 30000;
    [B,A] = butter(3,500/(Fs/2),'high');
    clear WFx
    fdata = fopen(DATfile);
    subspks = SpikeTimes.tsec{COIIndex(Unit)}(randperm(length(SpikeTimes.tsec{COIIndex(Unit)}),min(wfsubsample,length(SpikeTimes.tsec{COIIndex(Unit)}))));
    WFx{Unit} = zeros(RawChannelCount,48,length(subspks));
    for spk = 1:length(subspks)
        fseek(fdata,round((subspks(spk)*Fs)-24)*RawChannelCount*2,'bof');
        WFdata = fread(fdata,48*RawChannelCount,'*int16');
        WFdata = reshape(WFdata,RawChannelCount,[]);
        fWF = filtfilt(B,A,double(WFdata'));
        WFx{Unit}(:,:,spk) = fWF';
    end
    fclose(fdata);
    
    % Find the biggest channel
    clear bigwv
    x = SpikeTimes.Wave.AverageWaveform{COIIndex(Unit)};
    [~,b] = max(peak2peak(x'));
    bigwv = x(b,:);
    
    plot(squeeze(WFx{Unit}(b,:,:)),'Color',(LineFormat.Color+1)/2)
    hold on
    
    plot(bigwv,'Color',LineFormat.Color)
    ylim(wavelim)
    axis off; box off; hold on;
    set(gca,'Clipping','off')
    
    % Get them wavestats, bruh
    relative_ypos = WaveStats(SpikeTimes.Wave);
    
    % Labels if they weren't made on PSTH
    text(1-size(bigwv,2)/2.2,wavelim(1)*1/3,['idx: ', num2str(COIIndex(Unit))],'FontSize',6);
    text(1-size(bigwv,2)/2.2,wavelim(2)*1/3,['clu: ', num2str(SpikeTimes.units{COIIndex(Unit)})],'FontSize',6);
    text(1-size(bigwv,2)/2.2,wavelim(2),['y-pos: ', num2str(relative_ypos(COIIndex(Unit)-1),'%.0f')],'FontSize',6);
end
end
