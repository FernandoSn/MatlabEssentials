function NPX_PlotDepthPSTH(spikeTimes, spikeDepths,events,window)

%Warpper for the spikes library psthByDepth
% call [spikeTimes, ~, spikeDepths, ~] = ksDriftmap(myKsDir);

if size(events,1) > size(events,2); events = events'; end

if nargin < 4
    window = [-1 2];  
end

depthBinSize = 10; % in units of the channel coordinates, in this case µm
timeBinSize = 0.01; % seconds
%bslWin = [-0.2 -0.05]; % window in which to compute "baseline" rates for normalization
bslWin = [window(1) -0.05];
%bslWin = [];
psthType = 'norm'; % show the normalized version
eventName = 'stimulus onset'; % for figure labeling

for stim = 1:size(events,1)
    
    [timeBins, depthBins, allP, normVals] = psthByDepth(spikeTimes, spikeDepths, ...
    depthBinSize, timeBinSize, events(stim,:), window, bslWin);
    figure;
    plotPSTHbyDepth(timeBins, depthBins, allP, eventName, psthType);

end