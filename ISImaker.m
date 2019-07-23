function [ISI, ISIt] = ISImaker(SpikeTimes,maxISI)

ISIt = 0:0.001:maxISI;

for m = 1:length(SpikeTimes.tsec)
    ISIs = diff(SpikeTimes.tsec{m});
    [ISI{m},~] = hist(ISIs,ISIt);
    ISI{m} = ISI{m}(1:end-1);
end


