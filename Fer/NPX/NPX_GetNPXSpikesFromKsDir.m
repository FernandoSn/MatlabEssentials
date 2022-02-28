function NPXSpikes = NPX_GetNPXSpikesFromKsDir(spikeTimes,spikeDepths)

% call [spikeTimes, ~, spikeDepths, ~] = ksDriftmap(myKsDir);

% spikeTimes = spikeTimes(~isnan(spikeDepths));
% spikeDepths = spikeDepths(~isnan(spikeDepths));


depthBins = min(spikeDepths):10:max(spikeDepths); nD = length(depthBins)-1;

NPXSpikes.SpikeTimes.tsec = cell(nD,1);
NPXSpikes.SpikeTimes.units = num2cell((1:nD)');
NPXSpikes.SpikeTimes.depth = depthBins(1:nD)';

for depth = 1:nD
    
    theseSp = spikeDepths>=depthBins(depth) & spikeDepths<depthBins(depth+1);
    
    NPXSpikes.SpikeTimes.tsec{depth} = spikeTimes(theseSp);
    
end

