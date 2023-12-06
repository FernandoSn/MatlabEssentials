function [CorrVec,Count] = SpikeCorrOdor(Reference, Target, BinSize,epoch,CorrVec,Count)

%%funcion auxiliar no usar por separado, comportamiento indefinido. 

if BinSize > epoch; error('BinSize should be less than 1000ms'); end


NoBins = (epoch / BinSize) .* 2;

%CorrVec= zeros(1,NoBins);

BinSize = BinSize/1000;

Count = Count + length(Reference);

for ii = 1:length(Reference)
    
  TargetSpikes = Target(Reference(ii) - epoch/1000 < Target &...
      Reference(ii) + epoch/1000 > Target);
  
  TimeSpk = Reference(ii) - epoch/1000;
  n = 1;
  
  for CurrentTime = TimeSpk:BinSize:TimeSpk + (BinSize * (NoBins - 1))
      
      SpikeCount = sum(TargetSpikes >= CurrentTime &...
          TargetSpikes < CurrentTime + BinSize);
      
      
      CorrVec(n) = CorrVec(n) + SpikeCount;
      
      
      n = n+1;
      
  end
      
    
end

 
  %Histcorr(CorrVec,BinSize*1000,epoch)
