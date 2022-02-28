function SpikeTimes = FakeSpikes(SpikeTimes)

for channel = 1:length(SpikeTimes.tsec)
   
    if isempty(SpikeTimes.tsec{channel})
        
        SpikeTimes.tsec{channel} = [0,0.5];
        
    end
    
end