function [st,sd] = NPX_RemoveDuplicateSpikesMUA(st,sd,ThreshT,ThreshD)

%Call [st, ~, sd, ~] = ksDriftmap(myKsDir); to get spiketimes and
%spikedepths.

%First get samples not times.

% Fs = 30000;
% st = round(st*Fs);
% ThreshT = round(ThreshT*Fs);

st = st(~isnan(sd));
sd = sd(~isnan(sd));

Dst = diff(st);
Dsd = abs(diff(sd));

idx = ([Dst < ThreshT;false]) & ([Dsd < ThreshD;false]);

st = st(~idx);% ./ Fs;
sd = sd(~idx);

