function [label, TrainRespiration] = NPX_GetTrainRespiration(ValveTimes, Resp, Fs,PST,trials)


if size(Resp,1) > size(Resp,2)
   
    Resp = Resp';
    
end

TrainRespiration = zeros(size(ValveTimes.PREXTimes,1) * length(trials), (PST(2) - PST(1)).* Fs);
label = zeros(size(ValveTimes.PREXTimes,1) * length(trials), 1);

n = 1;

for Valve = 1:size(ValveTimes.PREXTimes,1)
    %for Conc = 1:size(ValveTimes.PREXTimes,2)
    if ~isempty(ValveTimes.PREXTimes{Valve})

        for Trial = trials
            
            idx1 = round((PST(1) + ValveTimes.PREXTimes{Valve}(Trial) ).* Fs);
            idx2 = round((PST(2) + ValveTimes.PREXTimes{Valve}(Trial) ).* Fs)-1;
            
            TrainRespiration(n,:) = Resp(idx1:idx2);% - mean(Resp(idx1:idx2));
            label(n) = Valve;
            n = n+1;
            
         
        end


    end
end