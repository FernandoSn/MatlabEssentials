function [SpikeTimes] = SpikeTimes_Beast(FilesKK, SpikeType)
% SpikeTimesKK will return a structure called SpikeTimes with tsec, chans, and
% units. SpikeTimes{1} is the sum of all sorted Units.

% default spike type is 'Good'
if nargin < 2
    SpikeType = 'Good';
end

% if it's the default don't add anything to the filename.
% if it's something special add that title to the filename
if strcmp(SpikeType,'Good')
    [a,b] = fileparts(FilesKK.KWIK);
    if length(strfind(FilesKK.KWIK,'.'))<2
        STfile = [a,filesep,b,'.st'];
    else
        STfile = [a,filesep,b(1:strfind(b,'.')),'st'];
    end
else
    [a,b] = fileparts(FilesKK.KWIK);
    STfile = [a,filesep,b,'-',SpikeType,'.st'];
end

% load the spiketimes if they're already done
if exist(STfile,'file')
    loadhelper.b = load(STfile,'-mat');
    SpikeTimes = loadhelper.b.SpikeTimes;
    return;
end

%% Do Spyking-Circus processing

a = h5info(FilesKK.KWIK,'/spiketimes');
b = {a.Datasets.Name};

%% Get clusternumbers
for unit = 1:length(b)
    clusternumber{unit} = 1+str2num(b{unit}(findstr('_',b{unit})+1:end));
    tsecs{unit} = h5read(FilesKK.KWIK,['/spiketimes/',b{unit}])/30000;
    tsecs{unit} = double(tsecs{unit}(:));
end
SpikeTimes.tsec = tsecs(:);
SpikeTimes.units = clusternumber(:);

%% Getting waveforms and positioning units
% Get channel positions
[a,b] = fileparts(FilesKK.KWIK);

% Find the params file
temp = subdir(fullfile(a,'*.params'));

% Figure out which probe file to read
pfile = strtrim(GetProbeFile(temp.name));
pdata = importdata(pfile);
ch_line = strsplit(cell2mat(pdata(cellfun(@(IDX) ~isempty(IDX), strfind(pdata, 'total_nb_channels')))),'= ');
nchannels = str2num(ch_line{2});

% Extracting channel geometry
ch_info = nan(nchannels,3);
chinfo_lines = find(cellfun(@(IDX) ~isempty(IDX), strfind(pdata, ': (')));
for ch = 1:length(chinfo_lines)
    temp = strsplit(pdata{chinfo_lines(ch)}, {' ',':','(',')'});
    chIDX = str2num(temp{1})+1;
    ch_info(chIDX,1) = str2num(temp{1})+1;
    ch_info(chIDX,2) = str2num(temp{2});
    ch_info(chIDX,3) = str2num(temp{3});
end

channelposlist = ch_info(:,2:3);

% Getting waveforms
if exist(FilesKK.DAT,'file')
    fprintf('DAT received\n')
else
    [path, kwikfile] = fileparts(FilesKK.KWIK);
    Candidats = subdir([path,filesep,kwikfile,'*.dat']);
    [~,I] = sort({Candidats.date});
    FilesKK.DAT = Candidats(I(end)).name;
end

% collect some waveforms from raw data and create an average waveform
wfsubsample = 100; % the number of waveforms to work with for position and average
% we have to filter the waveforms too before we average them
Fs = 30000;
[B,A] = butter(3,500/(Fs/2),'high');
for unit = 1:length(SpikeTimes.units)
    % allwaveforms has this format: Nchannels x Nsamples x Nwaveforms
    RawChannelCount = size(channelposlist,1);
    fdata = fopen(FilesKK.DAT);
    subspks = SpikeTimes.tsec{unit}(randperm(length(SpikeTimes.tsec{unit}),min(wfsubsample,length(SpikeTimes.tsec{unit}))));
    subspks = SpikeTimes.tsec{unit}(randperm(length(SpikeTimes.tsec{unit}),min(wfsubsample,length(SpikeTimes.tsec{unit}))));
    
    WFx = zeros(RawChannelCount,48,length(subspks));
    for spk = 1:length(subspks)
        fseek(fdata,round((subspks(spk)*30000)-24)*RawChannelCount*2,'bof');
        WFdata = fread(fdata,48*RawChannelCount,'*int16');
        WFdata = reshape(WFdata,RawChannelCount,[]);
        fWF = filtfilt(B,A,double(WFdata'));
        WFx(:,:,spk) = fWF';
    end
    fclose(fdata);
    
    avgwaveform{unit} = mean(WFx,3);
    position{unit} = WFpositioner(avgwaveform{unit},channelposlist);
end
%

SpikeTimes.Wave.AverageWaveform = avgwaveform;
SpikeTimes.Wave.Position = position;
save(STfile,'SpikeTimes','-v7.3')
end

%%

%%
function [position] = WFpositioner(avgwaveform,channelposlist)
%%
% position [x,y] is the average electrode position weighted by the wave
% size
wavesize = peak2peak(avgwaveform'); % Measure the peak to peak size of the wave on each channel
wavesize = wavesize.^10; % Bias the wavesizes so that big waves are weighted way stronger than small
wavesize = bsxfun(@rdivide,wavesize,sum(wavesize)); % Normalize the wavesizes to add up to 1
weightedx = nansum(wavesize'.*channelposlist(:,1)); % Weighted average position.
weightedy = nansum(wavesize'.*channelposlist(:,2));
position = [weightedx, weightedy];
%%
end



