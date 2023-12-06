function [SpikeTimes] = SpikeTimesKK(FilesKK, SpikeType)
% SpikeTimesKK will return a structure called SpikeTimes with tsec, chans, and
% units. SpikeTimes{1} is the sum of all sorted Units.

if nargin < 2 || strcmp(SpikeType,'Good')
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
else
    
    
    
    %%
    if nargin < 2 || strcmp(SpikeType,'Good')
        %% Find out if this is a new or old school KWIK file
        KWXinfo = h5info(FilesKK.KWX, ['/channel_groups/0/']);
        KWXdatasets = {KWXinfo.Datasets.Name};
        % If it's old school then it has waveforms in the KWX.
        haswaveforms = sum(~cellfun(@isempty,strfind(KWXdatasets,'waveforms_filtered')));
        
        spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/time_samples']));
        clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/clusters/main']));
        
        % Collect channel numbers and associated positions.
        realchannellist = double(h5readatt(FilesKK.KWIK, '/channel_groups/0/','channel_order'));
        for ch = 1:length(realchannellist)
            channelposlist(ch,:) = h5readatt(FilesKK.KWIK, ['/channel_groups/0/channels/',num2str(realchannellist(ch)),'/'],'position');
        end
        
        % What are the identifiers for all of the clusters
        unitlist = unique(clusternumbers);
        
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
        %%
        
        if haswaveforms % if this was sorted by klustakwik, not phy
            % allwaveforms has this format: Nchannels x Nsamples x Nwaveforms
            allwaveforms = hdf5read(FilesKK.KWX, ['/channel_groups/0/waveforms_filtered']);
        else % if this was sorted by phy, not klustakwik
            if isfield(FilesKK,'DAT')
                fprintf('DAT received')
            else
                [path, kwikfile] = fileparts(FilesKK.KWIK);
                Candidats = subdir([path,filesep,kwikfile,'*.dat']);
                [~,I] = sort({Candidats.date});
                FilesKK.DAT = Candidats(I(end)).name;
            end
        end
        
        %%
        wfsubsample = 100; % the number of waveforms to work with for position and average
        % we have to filter the waveforms too before we average them
        Fs = 30000;
        [B,A] = butter(3,500/(Fs/2),'high');
        for unit = 1:length(GoodClusters)
            if haswaveforms
                unitwaveforms = allwaveforms(:,:, clusternumbers==GoodClusters(unit));
                WFx = unitwaveforms(:,:,(randperm(length(TSECS{unit+1}),min(wfsubsample,length(TSECS{unit+1})))));
                avgwaveform{unit+1} = mean(WFx,3);
                %                 avgwaveform{unit+1} = avgwaveform{unit+1}';
                position{unit+1} = WFpositioner(avgwaveform{unit+1},channelposlist);
            else
                % allwaveforms has this format: Nchannels x Nsamples x Nwaveforms
                RawChannelCount = double(h5readatt(FilesKK.KWIK, '/application_data/spikedetekt','n_channels'));
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
        end
        
        
        %%
        
        tsec = TSECS(:);
        SpikeTimes.tsec = tsec;
        
        % this is where all the spikes go back into MUA for unit 1.
        tsecmat = sort(cell2mat(SpikeTimes.tsec(2:end)));
        SpikeTimes.tsec{1} = tsecmat;
        
        units = Units(:);
        SpikeTimes.units = units;
        SpikeTimes.units{1} = 0;
        
        SpikeTimes.Wave.AverageWaveform=avgwaveform;
        SpikeTimes.Wave.Position=position;
        
    else
        spiketimes = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/time_samples']));
        clusternumbers = double(hdf5read(FilesKK.KWIK, ['/channel_groups/0/spikes/clusters/main']));
        % What are the identifiers for all of the clusters
        unitlist = unique(clusternumbers);
        
        if strcmp(SpikeType,'All')
            SpikeTimes.tsec{1} = spiketimes/30000;
            SpikeTimes.units{1} = 0;
        else
            
            if strcmp(SpikeType,'Real')
                % Which clustergroup is each unit in
                for count=1:length(unitlist)
                    str=['/channel_groups/0/clusters/main/',num2str(unitlist(count))];
                    clustergroups(count) = double(h5readatt(FilesKK.KWIK,str,'cluster_group'));
                end
                
                % For only sorted MUA
                RealClusters=unitlist(clustergroups>=1);
                if(isempty(RealClusters))
                    error('No good clusters.')
                end
                
                % We have to get the spiketimes before the waveforms so that we can go
                % retrieve waveforms from the data file based on the spiketimes.
                for unit = 1:length(RealClusters)
                    TSECS{unit+1} = spiketimes(clusternumbers==RealClusters(unit))/30000;
                    Units{unit+1} = RealClusters(unit);
                end
                
                tsec = TSECS(:);
                SpikeTimes.tsec = tsec;
                
                % this is where all the spikes go back into MUA for unit 1.
                tsecmat = sort(cell2mat(SpikeTimes.tsec(2:end)));
                SpikeTimes.tsec{1} = tsecmat;
                
                units = Units(:);
                SpikeTimes.units = units;
                SpikeTimes.units{1} = 0;
            end
            
            
        end
        
    end
    
    %%
    save(STfile,'SpikeTimes','-v7.3')
end
%%
    function [position] = WFpositioner(avgwaveform,channelposlist)
        % position [x,y] is the average electrode position weighted by the wave
        % size
        wavesize = peak2peak(avgwaveform'); % Measure the peak to peak size of the wave on each channel
        wavesize = wavesize.^10; % Bias the wavesizes so that big waves are weighted way stronger than small
        wavesize = bsxfun(@rdivide,wavesize,sum(wavesize)); % Normalize the wavesizes to add up to 1
        weightedx = sum(wavesize*channelposlist(:,1)); % Weighted average position.
        weightedy = sum(wavesize*channelposlist(:,2));
        position = [weightedx, weightedy];
    end

end



