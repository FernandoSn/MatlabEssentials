function NPXSpikes = NPX_GetOnlyGoodNPXSpikes(NPXSpikes)

%this funtion removes spike samples, times and templates that were not
%manually classified as good in phy2.

isGood = false(length(NPXSpikes.clu),1);

for unit = 1:length(NPXSpikes.cids)
    
   isGood = isGood | (NPXSpikes.clu == NPXSpikes.cids(unit));
    
end

NPXSpikes.ss = NPXSpikes.ss(isGood);
NPXSpikes.st = NPXSpikes.st(isGood);
NPXSpikes.clu = NPXSpikes.clu(isGood);
NPXSpikes.spikeTemplates = NPXSpikes.spikeTemplates(isGood);
NPXSpikes.tempScalingAmps = NPXSpikes.tempScalingAmps(isGood);