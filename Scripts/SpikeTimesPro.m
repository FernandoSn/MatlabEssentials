function [SpikeTimes] = SpikeTimesPro(FilesKK, SpikeType)
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


if exist(STfile,'file')
    loadhelper.b = load(STfile,'-mat');
    SpikeTimes = loadhelper.b.SpikeTimes;
    return;
end

%% Check for Spyking-Circus files
if ~isempty(strfind(FilesKK.KWIK,'result'))
    % Do circus-specific processing
    a = h5info(FilesKK.KWIK,'/spiketimes');
    b = {a.Datasets.Name};
    
    %% We are adding 1 to the clusternumber here, which is risky,
    % but allows us to maintain the MUA as cluster 0.
    % Maybe we should really get rid of the MUA. But can't do that yet.
    for unit = 1:length(b)
        clusternumber{unit+1} = 1+str2num(b{unit}(findstr('_',b{unit})+1:end));
        tsecs{unit+1} = h5read(FilesKK.KWIK,['/spiketimes/',b{unit}])/30000;
        tsecs{unit+1} = double(tsecs{unit+1}(:));
    end
    tsecs{1} = cell2mat(tsecs');
    clusternumber{1} = 0;
    SpikeTimes.tsec = tsecs(:);
    clusternumber = clusternumber(:);
    SpikeTimes.units = clusternumber;
    
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
%     [B,A] = butter(3,1/(Fs/2),'high');
        [B,A] = butter(3,500/(Fs/2),'high');

    for unit = 1:length(SpikeTimes.units)-1
        % allwaveforms has this format: Nchannels x Nsamples x Nwaveforms
        RawChannelCount = size(channelposlist,1);
        fdata = fopen(FilesKK.DAT);
        subspks = SpikeTimes.tsec{unit+1}(randperm(length(SpikeTimes.tsec{unit+1}),min(wfsubsample,length(SpikeTimes.tsec{unit+1}))));
        subspks = SpikeTimes.tsec{unit+1}(randperm(length(SpikeTimes.tsec{unit+1}),min(wfsubsample,length(SpikeTimes.tsec{unit+1}))));
        
        WFx = zeros(RawChannelCount,48,length(subspks));
        for spk = 1:length(subspks)
            fseek(fdata,round((subspks(spk)*30000)-24)*RawChannelCount*2,'bof');
            WFdata = fread(fdata,48*RawChannelCount,'*int16');
            WFdata = reshape(WFdata,RawChannelCount,[]);
            fWF = filtfilt(B,A,double(WFdata'));
            WFx(:,:,spk) = fWF';
            
%             % experimental referencing bit
%             WFx(:,:,spk) = bsxfun(@minus,WFx(:,:,spk),mean(WFx(:,:,spk),2));
%             ab = range(WFx(:,:,spk)');
%             [Y,I] = sort(ab);
%             ref = mean(WFx(I(1:6),:,spk));
%             WFx(:,:,spk) = bsxfun(@minus,WFx(:,:,spk),ref);
            
        end
        fclose(fdata);
        
        avgwaveform{unit+1} = mean(WFx,3);
        position{unit+1} = WFpositioner(avgwaveform{unit+1},channelposlist);
    end
    %
    
    SpikeTimes.Wave.AverageWaveform = avgwaveform;
    SpikeTimes.Wave.Position = position;
    save(STfile,'SpikeTimes','-v7.3')
    return;
end


%% Phy/Kwik-specific processing

% Collect channel numbers and associated positions.
realchannellist = double(h5readatt(FilesKK.KWIK, '/channel_groups/0/','channel_order'));
for ch = 1:length(realchannellist)
    channelposlist(ch,:) = h5readatt(FilesKK.KWIK, ['/channel_groups/0/channels/',num2str(realchannellist(ch)),'/'],'position');
end

% Read spiketimes and cluster numbers from KWIKfile
spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/time_samples']));
clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/clusters/main']));

% What are the identifiers for all of the clusters
unitlist = unique(clusternumbers);

switch SpikeType
    case 'All'
        SpikeTimes.tsec{1} = spiketimes/30000;
        SpikeTimes.units{1} = 0;
    case 'Real'
        % Which clustergroup is each unit in
        for count=1:length(unitlist)
            str=['/channel_groups/0/clusters/main/',num2str(unitlist(count))];
            clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
        end
        
        % For only sorted MUA or Good
        RealClusters = unitlist(clustergroups>=1);
        if(isempty(RealClusters))
            error('No real clusters.')
        end
        
        % We have to get the spiketimes before the waveforms so that we can go
        % retrieve waveforms from the data file based on the spiketimes.
        for unit = 1:length(RealClusters)
            TSECS{unit+1} = spiketimes(clusternumbers==RealClusters(unit))/30000;
            Units{unit+1} = RealClusters(unit);
        end
        SpikeTimes.tsec = TSECS(:);
        
        % this is where all the spikes go back into MUA for unit 1.
        tsecmat = sort(cell2mat(SpikeTimes.tsec(2:end)));
        SpikeTimes.tsec{1} = tsecmat;
        
        units = Units(:);
        SpikeTimes.units = units;
        SpikeTimes.units{1} = 0;
        
    case 'Good'
        % Which clustergroup is each unit in
        for count=1:length(unitlist)
            str=['/channel_groups/0/clusters/main/',num2str(unitlist(count))];
            clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
        end
        
        % For only sorted MUA
        GoodClusters=unitlist(clustergroups==2);
        if(isempty(GoodClusters))
            error('No good clusters.')
        end
        
        % We have to get the spiketimes before the waveforms so that we can go
        % retrieve waveforms from the data file based on the spiketimes.
        for unit = 1:length(GoodClusters)
            TSECS{unit+1} = spiketimes(clusternumbers==GoodClusters(unit))/30000;
            Units{unit+1} = GoodClusters(unit);
        end
        
        % Getting waveforms
        if exist(FilesKK.DAT,'file')
            fprintf('DAT received\n')
        else
            [path, kwikfile] = fileparts(FilesKK.KWIK);
            Candidats = subdir([path,filesep,kwikfile,'*.dat']);
            [~,I] = sort({Candidats.date});
            FilesKK.DAT = Candidats(I(end)).name;
        end
        
        %% collect some waveforms from raw data and create an average waveform
        wfsubsample = 100; % the number of waveforms to work with for position and average
        % we have to filter the waveforms too before we average them
        Fs = 30000;
        [B,A] = butter(3,500/(Fs/2),'high');
        for unit = 1:length(GoodClusters)
            % allwaveforms has this format: Nchannels x Nsamples x Nwaveforms
            try
                RawChannelCount = double(h5readatt(FilesKK.KWIK, '/application_data/spikedetekt','n_channels'));
            catch
                RawChannelCount = double(h5readatt(FilesKK.KWIK, '/application_data/spikedetekt','nchannels'));
            end
            fdata=fopen(FilesKK.DAT);
            subspks = TSECS{unit+1}(randperm(length(TSECS{unit+1}),min(wfsubsample,length(TSECS{unit+1}))));
            WFx = zeros(RawChannelCount,48,length(subspks));
            for spk = 1:length(subspks)
                fseek(fdata,round((subspks(spk)*30000)-24)*RawChannelCount*2,'bof');
                WFdata = fread(fdata,48*RawChannelCount,'*int16');
                WFdata = reshape(WFdata,RawChannelCount,[]);
                fWF = filtfilt(B,A,double(WFdata'));
                WFx(:,:,spk) = fWF';
            end
            fclose(fdata);
            % To make extracted phy waveforms be like klustakwik waveforms
            % let's eliminate the ignored channels.
            WFx = WFx(realchannellist+1,:,:);
            avgwaveform{unit+1} = mean(WFx,3);
            position{unit+1} = WFpositioner(avgwaveform{unit+1},channelposlist);
        end
        
        
        tsec = TSECS(:);
        SpikeTimes.tsec = tsec;
        
        % this is where all the spikes go back into MUA for unit 1.
        tsecmat = sort(cell2mat(SpikeTimes.tsec(2:end)));
        SpikeTimes.tsec{1} = tsecmat;
        
        units = Units(:);
        SpikeTimes.units = units;
        SpikeTimes.units{1} = 0;
        
        SpikeTimes.Wave.AverageWaveform = avgwaveform;
        SpikeTimes.Wave.Position = position;
end

%%
save(STfile,'SpikeTimes','-v7.3')

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

end



