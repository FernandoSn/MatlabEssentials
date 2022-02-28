function [td,ltd] = NPX_GetTimeXUnitsMat(NPXSpikes,Events,BinSize,KernelSize,OlfacMat)

%Events, i.e. vector of final valve openings in seconds.
%KernelSize, std of the gaussian kernel in ms.

units = numel(NPXSpikes.cids);

nbins = (Events(end) - Events(1))/BinSize;

Events(end) = Events(end) - (nbins - floor(nbins)) * BinSize;

nbins = floor(nbins);

td = zeros(nbins,units);

tt = (Events(end) - Events(1));
kernel = gaussmf(linspace(-tt,tt,nbins),[KernelSize 0])';
kernel = kernel ./ sum(kernel);

for unit = 1:units
    
    st = NPXSpikes.st(NPXSpikes.clu == NPXSpikes.cids(unit));
    
    st = st( ( st>Events(1) ) &  ( st<Events(end) ) );
    
    td(:,unit) = histcounts(st,nbins);
    
    %td(:,unit) = zscore(td(:,unit));
    
    td(:,unit) = conv(td(:,unit),kernel,'same');

end

ltd = zeros(nbins,1);


EventChunks = diff(Events);
ind1 = 1;

for ii = 1:numel(EventChunks)
    
    ind2 = (ind1-1) + round(EventChunks(ii)/BinSize);
   
    ltd(ind1:ind2) = OlfacMat(ii,2);
    
    ind1 = ind2 + 1;
    
end

ltd = ltd(1:size(td,1));

% [ltd, idx] = sort(ltd);
% td = td(idx,:);



