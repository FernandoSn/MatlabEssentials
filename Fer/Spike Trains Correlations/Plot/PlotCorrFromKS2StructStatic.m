function PlotCorrFromKS2StructStatic(NPXSpikes,RefUnit,TarUnit,TimeRange)

%NPXSpikes is the output struct of loadKSdirGoodUnits. Steinmetz lib.
% This plots XCorr without SpikeTrainAnalysis Matrix
%Ref and TarUnit are the clu label. KS2 index.

%eventsNPX are FVO and FVC detected y NPX chassis in seconds.
%Valve is a 2 element vecto. first: valve to include
%second: total valves

%Get the spikes of the desired units



if nargin == 4
    
    Idx = (NPXSpikes.st > TimeRange(1) & NPXSpikes.st < TimeRange(2));
    
    NPXSpikes.st = NPXSpikes.st(Idx);
    NPXSpikes.ss = NPXSpikes.ss(Idx);
    NPXSpikes.spikeTemplates = NPXSpikes.spikeTemplates(Idx);
    NPXSpikes.clu = NPXSpikes.clu(Idx);
    NPXSpikes.tempScalingAmps = NPXSpikes.tempScalingAmps(Idx);
    
end

RefTrain = NPXSpikes.st(NPXSpikes.clu == RefUnit);
TarTrain = NPXSpikes.st(NPXSpikes.clu == TarUnit);

%RefTrain = RefTrain(1:2:end);
%TarTrain = TarTrain(2:2:end);

CorrVec = SpikeCorr(RefTrain, TarTrain, 1,30);

figure;
bar(CorrVec,'histc');
% ylim([0 max(CorrVec,[],'all')]);