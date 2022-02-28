function [sortedTD,newlabel] = NPX_TDRespSorted(inhamp, traindata, label, toptrials)

Stimuli = unique(label);
sortedTD = [];
newlabel = [];

for ii = 1:length(Stimuli)
    
   idx = Stimuli(ii) == label;
   
   temp = flipud(sortrows([inhamp(idx),label(idx),traindata(dx,:)]));
   
   sortedTD = [sortedTD;temp(toptrials,3:end)];
   newlabel = [newlabel;temp(toptrials,2)];
       
end



