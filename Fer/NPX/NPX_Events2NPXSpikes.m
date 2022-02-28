function NPXSpikes = NPX_Events2NPXSpikes(events,states,targetStates)

%events = stimes x channels
%states = double(readNPY('channel_states.npy'));
%targetStates, vector with channel ids. ie [3,4]

nD = length(targetStates);
Fs = 2000; %this is the sampling rate of MCC.

NPXSpikes.SpikeTimes.tsec = cell(nD,1);
NPXSpikes.SpikeTimes.units = num2cell((1:nD)');
NPXSpikes.SpikeTimes.depth = (1:nD)';

for event = 1:nD
    
    NPXSpikes.SpikeTimes.tsec{event} = events(states == targetStates(event)) ./ Fs;
    
end
