function TraceMat = NPX_MeanUnitTrace(NPXSpikes,Unit,TarTrace,Fs)

Epoch = 0.004; %In seconds

Epoch = Epoch * Fs;

SpikeTrain = double(NPXSpikes.ss(NPXSpikes.clu == Unit));
TraceMat = zeros(size(SpikeTrain,1), Epoch );

for ii = 1:length(SpikeTrain)
    
    Sample = SpikeTrain(ii);%+ Latency;
    %Sample = round(SpikeTrain(ii) / 12);
    
    TraceMat(ii,:) = TarTrace(Sample-(Epoch/2-1):Sample+(Epoch/2));
    %TraceMat(ii,:) = TarTrace(Sample:Sample+149);
   
end