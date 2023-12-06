function [PREXmatFV,NoLickBool,NumLicks] = PostBoldLicks(PREXall, events)

PREXmatFV = zeros(length(events),1);

NoLickBool = false(length(events),1);

NumLicks = zeros(length(events),1);

%figure
%hold on

for ii = 1:length(events)
    
    ind = find(PREXall > events(ii),5);
    
    if isempty(ind) || (PREXall(ind(1))>(events(ii)+4000))
        
        PREXmatFV(ii) = events(ii)+2000;
        NoLickBool(ii) = true;
        NumLicks(ii) = 0;
    elseif (length(ind) < 5) || (PREXall(ind(5))>(events(ii)+8000))
        
        NoLickBool(ii) = true;
        PREXmatFV(ii) = PREXall(ind(1));
        NumLicks(ii) = sum(PREXall(ind) <= (events(ii)+8000));
    else
        PREXmatFV(ii) = PREXall(ind(1));
        NumLicks(ii) = length(ind);
        %plot(diff(PREXall(ind)./2000))
    end
    
end