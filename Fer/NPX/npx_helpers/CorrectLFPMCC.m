function LFP = CorrectLFPMCC(LFP,Fs)

%It seems that every 14 sec an extra "milisecond" is added to the LFP data
%by the MCC board. For example if we are recording at 2kHz every 7 sec and
%extra sample will be appended to the data. This func deletes that sample.

Idx = ones(1,length(LFP(1,:)));

%Int = 7.135 * Fs; %Bank1
%Int = 7.522 * Fs; %Bank2

Int = length(LFP) * Fs; %Bank1

ii = Int:Int:length(LFP(1,:));
Idx(ii) = 0;

LFP = LFP(:,Idx == 1);

for ch = 1:size(LFP,1)
    



    isValid = LFP(ch,:)~=0;
    t = 1 : numel( LFP(ch,:) ) ;
    LFP(ch,:) = interp1( t(isValid), LFP(ch,isValid), t ) ;

    %LFP(LFP == 0) = mean(LFP); %%"Correct" bad samples;

    LFP(ch,:) = LFP(ch,:) - mean(LFP(ch,:)); %%remove DC

end

%% For NI board
% Int = 13.75 * Fs; %interval
% count = 0;
% 
% for ii = Int:Int:length(LFP)
%     
%     idx = ii + count;
%     
%     LFP = [LFP(1:idx) , mean(LFP(idx:idx+1)), LFP(idx+1:end)];
%     count = count +1;
% end
% 
% LFP(LFP == 0) = mean(LFP); %%"Correct" bad samples;
% 
% LFP = LFP - mean(LFP); %%remove DC