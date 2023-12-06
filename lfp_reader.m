function [datmat] = lfp_reader(KWIKfile,EventTimes,PST,nchannels)

Fs = 1000;
% access raw data file
FilesKK = FindFilesKK(KWIKfile);
fdata = fopen(FilesKK.LFP);

if strcmp(PST,'All')
    EventTimes = 0;
    fseek(fdata, 0, 'eof'); % Seek to end of file
    PES = ftell(fdata)/2/nchannels;
    fseek(fdata, 0, 'bof'); % Return to beginning of file
    PST = [0 0];
else
    % perieventtime in samples
    PES = round(diff(PST)*Fs);
end

% preallocate for memory
datmat = zeros(nchannels,PES,length(EventTimes));

% extract data around a window for every event
for E = 1:length(EventTimes)
    fseek(fdata,round(EventTimes(E)*Fs+PST(1)*Fs)*nchannels*2,'bof');
    rawdata = fread(fdata,PES*nchannels,'*int16');
    datmat(:,:,E) = reshape(rawdata,nchannels,[]);
end

% close raw data file
fclose(fdata);