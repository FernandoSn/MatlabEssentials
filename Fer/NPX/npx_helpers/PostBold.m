function [PREXmatFV,PREXmat1sPrior,PREXmatPreFV] = PostBold(PREXall, events)

%events = double(events(1:2:end));

PREXmatFV = zeros(length(events),3);

PREXmat1sPrior = zeros(length(events),1);

PREXmatPreFV = zeros(length(events),3);


for ii = 1:length(events)
    
    ind1 = find(PREXall > events(ii),3);
    
    PREXmatFV(ii,:) = PREXall(ind1);
    
    PREXmatPreFV(ii,:) = PREXall(ind1-2); %Inh before FV opens
    
    %ind2 = find(PREXall <= PREXmatFV(ii,1) + 2000,1,'last');
    
    %Inhalations = length(ind1(1):ind2);
    
    %indices = find(PREXall < PREXmatFV(ii,1),Inhalations,'last');
    %PREXmatPrior(ii) = PREXall(indices(1));
    
    ind2 = find(PREXall < events(ii) - 2000,1,'last'); %idx to the epoch before valve
    %ind2 = find(PREXall < PREXmatFV(ii,1) - 2000,1,'last'); %idx to the epoch before the first inh.
    
    PREXmat1sPrior(ii) = PREXall(ind2);
    
    
    
    
    %indices = indices - 2; %I only did this to get the respiration before
    %the valve opens.
    
end