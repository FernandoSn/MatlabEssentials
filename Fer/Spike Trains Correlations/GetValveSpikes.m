function ValveSpikes = GetValveSpikes(Spikes,efd, Target)

Valves = size(efd.ValveTimes.FVSwitchTimesOn,1);%Actually valves can be the number of different stimuli presented.
Trials = size(efd.ValveTimes.FVSwitchTimesOn{1},2);
Units = size(Spikes.tsec,1);
Concentrations = 1; %provisional

ValveSpikes = cell(Valves,Concentrations);
ValveTrials = cell(Trials,1);
TrialSpikes = cell(Units,1);


for ii = 1:Valves
    
    
   for jj = 1:Trials
       
      TBeg = efd.ValveTimes.FVSwitchTimesOn{ii}(jj);
       TEnd = efd.ValveTimes.FVSwitchTimesOff{ii}(jj);
%       TEnd = TBeg + 7;

%         TBeg = efd.ValveTimes.PREXTimes{ii}(jj);
%         TEnd = TBeg + 1;
       
      
      for k = 1:Units
      
        if Target  
            
%             TrialSpikes{k} = Spikes.tsec{k}(Spikes.tsec{k}>(TBeg - 0.1) & Spikes.tsec{k}<(TEnd + 0.1));
            TrialSpikes{k} = Spikes.tsec{k}(Spikes.tsec{k}>TBeg & Spikes.tsec{k}<TEnd);
            
        else
            
            TrialSpikes{k} = Spikes.tsec{k}(Spikes.tsec{k}>TBeg & Spikes.tsec{k}<TEnd);
            
        end
       
      end
      
       ValveTrials{jj} = TrialSpikes;
       
   end
   
   ValveSpikes{ii} = ValveTrials;
    
end