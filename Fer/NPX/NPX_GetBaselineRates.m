function [MeanInstRate,MedianInstRate,Rate] = NPX_GetBaselineRates(SpikeTimes,Interval)

%SpikeTimes = struct obtained by calling NPX_GetBeastCompatSpikeTimes(NPXSpikes)

MeanInstRate = zeros(1,length(SpikeTimes.tsec));
MedianInstRate = zeros(1,length(SpikeTimes.tsec));
Rate = zeros(1,length(SpikeTimes.tsec));

if nargin<2
   Interval = [0, max(cell2mat(SpikeTimes.tsec))];
end

for unit = 1:length(SpikeTimes.tsec)
    
    Spikes = SpikeTimes.tsec{unit}(SpikeTimes.tsec{unit} >= Interval(1) & SpikeTimes.tsec{unit} <= Interval(2));
    
    InstRate = 1./diff(Spikes);
    
    MeanInstRate(unit) = mean(InstRate);
    MedianInstRate(unit) = median(InstRate);
    if length(Spikes)>1
        Rate(unit) = length(Spikes)./(Interval(2) - Interval(1));
    else
        Rate(unit) = 1;
    end
end