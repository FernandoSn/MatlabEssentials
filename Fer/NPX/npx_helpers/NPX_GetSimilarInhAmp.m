function [PREXTimes,RespTraces,FInhAmp,distances] = NPX_GetSimilarInhAmp(ValveTimes, Resp, Fs,PST,trials,PREX,POSTX,InhTimes)

[InhAmplitude,~] = NPX_GetInhAmplitude(ValveTimes, Resp,InhTimes, PREX, POSTX, Fs,PST,trials);
%[~,InhAmplitude] = NPX_GetInhAmplitude(ValveTimes, Resp,InhTimes, PREX, POSTX, Fs,PST,trials);


%Hardcoded to eliminate odor sections. 900 are the length in seconds of the
%basline
PreWnd = 5;

% PREX = PREX(PREX<900);
% POSTX = POSTX(1:length(PREX));
% InhTimes = InhTimes(1:length(PREX));

Vtemp = cell2mat(ValveTimes.PREXTimes);

uplim = max(max(Vtemp)) + 80;

%lowlim = min(min(Vtemp)) - 1;
lowlim = 900;

PREXit = find((PREX>PreWnd) & (PREX<lowlim));
PREXit = [PREXit,find(PREX>uplim)];

%%%%%%%%%%%%%%%%%%%%%%%%



wnd = PST(2) - PST(1);

PREXTimes = zeros(size(InhAmplitude,1)./length(trials),length(trials))';

AllInhAmpMat = zeros(length(PREX),1);
AllRespidc = zeros(length(PREX),1);

RespTraces = zeros(size(InhAmplitude,1),wnd.* Fs);
distances = zeros(size(InhAmplitude,1),1);
FInhAmp = zeros(size(InhAmplitude,1),1);

%for ii = find(PREX>PreWnd,1):length(PREX)
for ii = PREXit
   
    
    
    idx = (PREX >= PREX(ii))...
    & (InhTimes < wnd + PREX(ii));

    %idxInh = round(InhTimes(idx).*Fs);
    idxPREX = round(PREX(idx).*Fs);
    idxPOSTX = round(POSTX(idx).*Fs);

    TrialBase = mean(Resp(idxPREX(1)-Fs*5:idxPREX(1)));

    TrialInhAmp = zeros(1,length(idxPREX));

    for kk = 1:length(idxPREX)

        RespChunk = Resp(idxPREX(kk):idxPOSTX(kk));

        TrialInhAmp(kk) = min(RespChunk);

        if TrialBase <= TrialInhAmp(kk)

           TrialInhAmp(kk) = [];

        end

    end
    TrialInhAmp = (TrialBase - TrialInhAmp);
    AllInhAmpMat(ii) = sum(abs(TrialInhAmp));
    %AllInhAmpMat(ii) = length(TrialInhAmp);
    AllRespidc(ii) = idxPREX(1);
    
end

AllInhAmpMatBU = AllInhAmpMat;
AllRespidcBU = AllRespidc;

for ii = 1:size(InhAmplitude,1)
    
   temp = abs(AllInhAmpMat - InhAmplitude(ii));
   
   
   [dist,idx] = min(temp);
   
   distances(ii) = dist;
   FInhAmp(ii) = AllInhAmpMat(idx);
   PREXTimes(ii) = AllRespidc(idx);
   
   if ii ==317
      a=10; 
   end
   
   RespTraces(ii,:) = Resp(AllRespidc(idx): AllRespidc(idx) + wnd*Fs -1);
   
   del = (AllRespidc > AllRespidc(idx) - wnd *Fs) & (AllRespidc < AllRespidc(idx) + wnd *Fs);
   
   
   AllInhAmpMat(del) = [];
   AllRespidc(del) = [];
   
   if mod(ii,length(trials)) == 0
      
      AllInhAmpMat = AllInhAmpMatBU;
      AllRespidc = AllRespidcBU;
       
   end
    
end

PREXTimes = PREXTimes';

%PREXTimes(PREXTimes==0) = 1;