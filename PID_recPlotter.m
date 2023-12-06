FilesKK = FindFilesKK(KWIKfile);

% Unpack the NS3 file
openNSx(FilesKK.AIP);

% Define Sampling Frequency
Fs = NS3.MetaTags.SamplingFreq;

% AIPs from BlackRock System: AIP 1-16 = ChannelID 129-144
ChannelID = NS3.MetaTags.ChannelID;
PID = double(NS3.Data(ChannelID==130,:));

