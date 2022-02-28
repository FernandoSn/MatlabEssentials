function [FVEvents ,ToneEvents] = SplitToneandFVevents(events,TotalOlfacMat)

%events = the corrected and substracted vector of MCC events.
%Must include tone and valve events

%TotalOlfacMat = The concatenation of all the Olfactometer Matrices.

%Ignore these vars:
%ToneStart and ToneEnd = arbitrary sample to start spliting and ending.

ToneLogicVec = TotalOlfacMat(:,3);

FVEvents = [];
ToneEvents = [];

kk = 1;
ii = 1;
while ii <=  length(events)
    
    if ToneLogicVec(kk)
    
       ToneEvents = [ToneEvents;events(ii);events(ii+1)];

       FVEvents = [FVEvents;events(ii+2);events(ii+3)];
       
       ii = ii + 4;
       
    else
        
        FVEvents = [FVEvents;events(ii);events(ii+1)];
        
        ii = ii + 2;
   
    end
    
    kk = kk + 1;
    
end



% FVEvents = events(events < ToneStart);
% ToneEvents = [];
% 
% 
% CombinedEvents = events(events >= ToneStart & events <= ToneEnd);
% 
% for ii = 1:4:length(CombinedEvents)
%     
%    ToneEvents = [ToneEvents;CombinedEvents(ii);CombinedEvents(ii+1)];
%    
%    FVEvents = [FVEvents;CombinedEvents(ii+2);CombinedEvents(ii+3)];
%     
% end
% 
% FVEvents = [FVEvents;events(events > ToneEnd)];

