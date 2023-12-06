function [eventsMCC,LFP] = NPX_SynchStreams(eventsMCC, eventsNPX,StMCC, StNPX, LFP)

%function to synch MCC and NPX events

%FS is hardcoded.
FsMCC = 2000;
FsNPX = 30000;

teventsMCC = eventsMCC(StMCC==-1 | StMCC==1); %temp
teventsNPX = eventsNPX(StNPX==-1 | StNPX==1);

teventsNPX = teventsNPX(1:length(teventsMCC)); %This is to avoid the problem of fewer MCC events due to sound ttls

c = polyfit(teventsMCC,teventsMCC - teventsNPX/(FsNPX/FsMCC),1);

coeff = round(1/c(1));

UpB = coeff; %interval
LowB = 0;
Count = 0;
while UpB <= eventsMCC(end)
    
    eventsMCC((LowB < eventsMCC) & (UpB >= eventsMCC)) = eventsMCC((LowB < eventsMCC) & (UpB >= eventsMCC)) - Count;
    LowB = UpB;
    UpB = UpB + coeff;
    Count = Count + 1;
    
end
eventsMCC(LowB < eventsMCC) = eventsMCC(LowB < eventsMCC) - Count;


%offset = round(mean(eventsMCC(StMCC==-1 | StMCC==1) - eventsNPX(StNPX==-1 | StNPX==1)/(FsNPX/FsMCC)));
offset = round(mean(eventsMCC(StMCC==-1 | StMCC==1) - teventsNPX/(FsNPX/FsMCC)));

eventsMCC = eventsMCC - offset;




%It seems that every 14 sec an extra "milisecond" is added to the LFP data
%by the MCC board. For example if we are recording at 2kHz every 7 sec and
%extra sample will be appended to the data. This func deletes that sample.

Idx = ones(1,length(LFP(1,:)));

ii = coeff:coeff:length(LFP(1,:));
Idx(ii) = 0;

LFP = LFP(:,Idx == 1);

for ch = 1:size(LFP,1)
    



    isValid = LFP(ch,:)~=0;
    t = 1 : numel( LFP(ch,:) ) ;
    LFP(ch,:) = interp1( t(isValid), LFP(ch,isValid), t ) ;

    %LFP(LFP == 0) = mean(LFP); %%"Correct" bad samples;

    LFP(ch,:) = LFP(ch,:) - mean(LFP(ch,:)); %%remove DC

end

LFP = LFP(:,offset:end);