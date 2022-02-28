function Sidx = NPX_GetInhSortedIdx(inhamp, label, toptrials)

Stimuli = unique(label);
Sidx = [];
n = 0;
for ii = 1:length(Stimuli)
    
   idx = Stimuli(ii) == label;
   
   [~,tempsidx] = sort(inhamp(idx));
   tempsidx = flip(tempsidx);
   Sidx = [Sidx;tempsidx(toptrials)+n];
   
   n = n+length(tempsidx);
end