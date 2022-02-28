function TASimMat = NPX_GetTrialAveragedSimMat(SimMat, label)

Stimuli = unique(label);

TASimMat = zeros(length(Stimuli),length(Stimuli));

for ii = 1:length(Stimuli)

    %idx1 = (ii-1) .* length(trials) + trials;
    idx1 = Stimuli(ii) == label;

   for kk = 1:length(Stimuli)

       %idx2 = (kk-1) .* length(trials) + trials;
       idx2 = Stimuli(kk) == label;
       temp = SimMat(idx1,idx2);

       if ii == kk

           temp(1:size(temp,1)+1:numel(temp)) = [];

       end

       TASimMat(ii,kk) = median(temp,'all');
       %TACorrMat(ii,kk) = mean(temp,'all')./std(temp,[],'all');

   end

end