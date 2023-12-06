function [channelposlist, nchannels] = ChannelPositionExtractor(KWIKfile)
% if it's the default don't add anything to the filename.
% if it's something special add that title to the filename
    [a,b] = fileparts(KWIKfile);
    if length(strfind(KWIKfile,'.'))<2
        STfile = [a,filesep,b,'.st'];
    else
        STfile = [a,filesep,b(1:strfind(b,'.')),'st'];
    end

%% Check for Spyking-Circus files
if ~isempty(strfind(KWIKfile,'result'))
    
    %% Getting waveforms and positioning units
    % Get channel positions
    [a,b] = fileparts(KWIKfile);
    
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
    return;
end

%% Phy/Kwik-specific processing

% Collect channel numbers and associated positions.
realchannellist = double(h5readatt(KWIKfile, '/channel_groups/0/','channel_order'));
for ch = 1:length(realchannellist)
    channelposlist(ch,:) = h5readatt(KWIKfile, ['/channel_groups/0/channels/',num2str(realchannellist(ch)),'/'],'position');
end

try
    nchannels = h5readatt(KWIKfile,'/application_data/spikedetekt','n_channels');
catch
    nchannels = h5readatt(KWIKfile,'/application_data/spikedetekt','nchannels');
end

