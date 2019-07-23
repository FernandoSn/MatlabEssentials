function [Fs,t,VLOs,FVO,resp,LASER,PID] = NS3Unpacker(AIPfile)

% Unpack the NS3 file
openNSx(AIPfile);

% Define Sampling Frequency
Fs = NS3.MetaTags.SamplingFreq;

% Blackrock starts recording the NS6 data 102 samples later than the NS3
% data.. So we are scootching the NS3 data to look like it got recorded a
% bit later..
% blackrockpad = repmat(NS3.Data(:,1),1,round(102/30000*Fs)); 
% NS3.Data = [blackrockpad, NS3.Data];
NS3.Data = NS3.Data(:,(round(102/30000*Fs)):length(NS3.Data));

for k = 1:size(NS3.Data,1)
    nud(k,:) = movingAverage(abs(double(NS3.Data(k,:))-mean(double(NS3.Data(k,:))))/std(double(NS3.Data(k,:))),3000);
end

artifact_threshold = 5; % z score of artifacts
nudz = mean(nud)-artifact_threshold;
SignSwitch = nudz(1:end-1).*nudz(2:end);
dNUD = diff(nudz);
if isempty(SignSwitch)||isempty(dNUD)
    O=[];
    C=[];
else
    O = find(dNUD>0 & SignSwitch<0);
    C = find(dNUD<0 & SignSwitch<0);
end

for a = 1:length(O)
   NS3.Data(:,O(a):C(a)) = nan; 
end

t = 0:1/Fs:length(NS3.Data)/Fs-1/Fs;

% AIPs from BlackRock System: AIP 1-16 = ChannelID 129-144
ChannelID = NS3.MetaTags.ChannelID;
VLO1 = double(NS3.Data(ChannelID==131,:));
VLO2 = double(NS3.Data(ChannelID==132,:));
VLOs = [VLO1;VLO2];
resp = double(NS3.Data(ChannelID==133,:));
LASER = double(NS3.Data(ChannelID==135,:));
FVO = double(NS3.Data(ChannelID==136,:));
PID = double(NS3.Data(ChannelID==130,:));
end