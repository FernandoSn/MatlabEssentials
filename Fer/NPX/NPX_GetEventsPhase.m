function [EventsPhase,RandomPh] = NPX_GetEventsPhase(HilPhase, EventsTimes,Fs,Rand)

%INCOMPLETE

%Get the Events phase.
%input HilPhase : The phase of a signal, could be LFP, Respiration etc.
%The phase should be obtained wth the hilbert transform.

EventsSamples = round(EventsTimes .* Fs);

EventsPhase = HilPhase(EventsSamples);

if ~Rand; return; end

RandomPh = [];

for ii = 1:length(EventsPhase)
   
   LL = floor(EventsPhase(ii)*10)./10;

   UL = ceil(EventsPhase(ii)*10)./10;
   
   Locs = ((HilPhase >= LL) & (HilPhase <=UL)); %Find locations of similar phases.
   
   Locs(HilPhase == EventsPhase(ii)) = 0; %Exclude the orginal phase.
   
   Locs = find(Locs);
   
   RandSample = Locs(randperm(length(Locs),1)); %Get the random sample.
   
   RandomPh = [RandomPh,RandSample];
    
end

RandomPh = sort(RandomPh / Fs); %Get Times not samples. Assuming Resp sampling rate is 2kHz.