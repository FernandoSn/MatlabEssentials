function eventsMCC = CorrectMCCevents(eventsMCC,Fs)

%TimexFs = 13.75 * Fs; %National instrumets board

TimexFs = 7.135 * Fs; %Bank1
%TimexFs = 7.522 * Fs; %Bank2

%TimexFs = 7 * Fs;

UpB = TimexFs; %interval
LowB = 0;
Count = 0;
while UpB <= eventsMCC(end)
    
    eventsMCC((LowB < eventsMCC) & (UpB >= eventsMCC)) = eventsMCC((LowB < eventsMCC) & (UpB >= eventsMCC)) - Count;
    LowB = UpB;
    UpB = UpB + TimexFs;
    Count = Count + 1;
    
end

eventsMCC(LowB < eventsMCC) = eventsMCC(LowB < eventsMCC) - Count;

% Count = 0;
% PastIndex = 1;
% Int = 56/2;
% 
% for ii = Int:Int:length(eventsMCC)
%     
%    eventsMCC(PastIndex : ii) = eventsMCC(PastIndex : ii) - Count;
%    Count = Count + 1;
%    PastIndex = ii + 1;
%    
% end
% 
% eventsMCC(PastIndex : end) = eventsMCC(PastIndex : end) - Count;