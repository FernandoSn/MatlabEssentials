function PSTs = NPX_GetPSTs(ValveTimes, PREX, POSTX, Trials,InhIdx)

PSTs = cell(size(ValveTimes.PREXTimes,1), length(Trials));

for Valve = 1:size(ValveTimes.PREXTimes,1)
    %for Conc = 1:size(ValveTimes.PREXTimes,2)
    if ~isempty(ValveTimes.PREXTimes{Valve})

        for Trial = 1:length(Trials)
        
%             idx = ((PREX >= ValveTimes.PREXTimes{Valve}(Trial))...
%                 & (InhTimes < 1 + ValveTimes.PREXTimes{Valve}(Trial)));
            
            idx = find(PREX >= ValveTimes.PREXTimes{Valve}(Trials(Trial)),1);
            
            
            %PSTs(Valve,Trial) = (PREX(idx+1) - PREX(idx));
            PSTs{Valve,Trial} = [PREX(idx + InhIdx(1)) , PREX(idx + InhIdx(2))] - ValveTimes.PREXTimes{Valve}(Trials(Trial));
            PSTs{Valve,Trial}(1) = PSTs{Valve,Trial}(1) + 0.00;
            %PSTs{Valve,Trial} = [PREX(idx) , POSTX(idx)] - ValveTimes.PREXTimes{Valve}(Trials(Trial));
  
        end


    end
    %end
end