%Old declaration
% function ValveTimes = NPX_GetBeastCompatValveTimes(PREXmat,Valves)

%Function to get a compatible subset of the fields in the struct
%efd.ValveTimes (specifically efd.ValveTimes.PREXTimes).

%Trials = length(PREXmat)/Valves;

%This commented chunk of code was only useful for my very first NPX
%recordings.
% for valve = 1:Valves
% 
%     ValveTimes.PREXTimes{valve,1} = PREXmat(valve:Valves:(length(PREXmat)),1)';
%         
% end
% Odor1Times = PREX3(1:7:end);
% Odor2Times = PREX3(2:7:end);
% Odor3Times = PREX3(3:7:end);
% Odor4Times = PREX3(4:7:end);
% Odor5Times = PREX3(5:7:end);
% Odor6Times = PREX3(6:7:end);
% Odor7Times = PREX3(7:7:end);

function ValveTimes = NPX_GetBeastCompatValveTimes(PREXOdorTimes)


%PREXOdorTimes is the output of PREX2Odor.

for valve = 1:size(PREXOdorTimes,1)

    %ValveTimes.PREXTimes{valve,1} = PREXOdorTimes(valve,:)./2000;
    ValveTimes.PREXTimes{valve,1} = PREXOdorTimes{valve}'./2000;
    %2000 is the sampling rate. Since Respiration SHOULD be always recorded
    %at 2kHz this is fixed. My PREXOdorsTimes are always on samples.
        
end
