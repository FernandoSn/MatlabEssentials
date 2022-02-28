function TraceMat = NPX_EvokedPotentials(NPXSpikes,RefUnit,TarUnit,Latency,TarTrace)
%Not useful. Deprecated function.


%In test: Get the evoked potentials of a given Target Neuron in relation
%with a Reference Neuron.


%Latency msut be in seconds.

TraceFs = 30000;
Epoch = 0.004; % In seconds.
Epoch = TraceFs * Epoch; %epoch times samples to get the epoch in samples.

Latency = Latency * TraceFs;

RefTrain = double(NPXSpikes.ss(NPXSpikes.clu == RefUnit)); %Using samples, not times.
TarTrain = double(NPXSpikes.ss(NPXSpikes.clu == TarUnit));

%TraceMat = zeros(size(RefTrain,1),Epoch );
TraceMat = [];

for ii = 1:length(RefTrain)
    
    Sample = RefTrain(ii);%+ Latency;
    %Sample = round(RefTrain(ii) / 12); %ForLFP
    
    %TraceMat = [TraceMat,TarTrace(Sample:Sample+Epoch-1)];
    if ~sum((TarTrain < (Sample + 90))&...
            (TarTrain >= Sample))
        
        Chunk = (TarTrace(Sample:Sample+Epoch-1));
        %TraceMat(ii,:) = TarTrace(Sample:Sample+Epoch-1);
        TraceMat = [TraceMat,Chunk];
    
    end
        
end

LTM = length(TraceMat)/(Epoch);
TraceMat = reshape(TraceMat,[Epoch,LTM])';