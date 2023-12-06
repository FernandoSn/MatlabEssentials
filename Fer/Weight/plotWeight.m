function [mWeight,counts] = plotWeight(data,daysMean)

%data(:,1) = data(:,1) - data(1,1) + 1;
mWeight = [];
counts = [];

for ii = data(:,1):daysMean:data(end,1)
   
    idx = (data(:,1) >= ii) & (data(:,1) < ii+daysMean);
    counts = [counts,sum(idx)];
    
    if sum(idx) == 0
        mWeight = [mWeight, 0];
    else
        mWeight = [mWeight, mean(data(idx,2))];
    end
    ii+daysMean;
end

scatter(1:length(mWeight),mWeight)
%plot(mWeight)

%plot(mWeight(mWeight~=0))