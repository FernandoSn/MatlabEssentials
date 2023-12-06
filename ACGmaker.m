function [ACG, ACGt] = ACGmaker(SpikeTimes, BinWidth, HalfWidth)
%% ACG{m} -> Spikes of cell m relative to spikes of cell m.

ACGt = -HalfWidth:BinWidth:HalfWidth;

for m = 1:length(SpikeTimes.tsec)
    
            offsets = crosscorrelogram(SpikeTimes.tsec{m}', SpikeTimes.tsec{m}', [-HalfWidth HalfWidth]);
            [ACG{m},~] = hist(offsets,ACGt);
            ACG{m}([1,end]) = 0;
            ACG{m} = fliplr(ACG{m});
            
            % kill center
            ACG{m}(ceil(length(ACGt)/2)) = 0;
end


