function NPXSpikes = NPX_CombineNPXSpikes(NPXSpikes1,NPXSpikes2)


NPXSpikes.st = [NPXSpikes1.st;NPXSpikes2.st];
NPXSpikes.ss = [NPXSpikes1.ss;NPXSpikes2.ss];
NPXSpikes.spikeTemplates = [NPXSpikes1.spikeTemplates;NPXSpikes2.spikeTemplates];
NPXSpikes.clu = [NPXSpikes1.clu;NPXSpikes2.clu];
NPXSpikes.tempScalingAmps = [NPXSpikes1.tempScalingAmps;NPXSpikes2.tempScalingAmps];

