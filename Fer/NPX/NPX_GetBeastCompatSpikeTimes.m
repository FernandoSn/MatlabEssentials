function SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikes)

% Important: NPXSpikes must be sorted by depth. loadKSdirGoodUnits do this by default.
%Function to convert kilosort2 output into a struct compatible with Beast
%functions. NPXSpikes is the output struct of loadKSdirGoodUnits from the
%modified Spikes Steinmetz library.

%depthclu, unsorted output of NPX_GetClusterDepth.

%Units = length(NPXSpikes.cids);

%if nargin == 2
   %%depthclu = sortrows(depthclu,2);
   %%NPXSpikes.cids = depthclu(:,1)';
%end

for unit = 1:length(NPXSpikes.cids)
    
    SpikeTimes.tsec{unit,1} = NPXSpikes.st(NPXSpikes.clu == NPXSpikes.cids(unit));
    SpikeTimes.units{unit,1} = NPXSpikes.cids(unit);
    
    SpikeTimes.depth = NPXSpikes.CluDepth';
    
end