function [PREXTimes,RespTraces,rhos] = NPX_GetSimilarOdorPREX(ValveTimes, Resp, Fs,PST,trials,PREX)

%PREX should not contain odor epochs.

[~,TrainResp] = NPX_GetTrainRespiration(ValveTimes, Resp, Fs,PST,trials);

wnd = PST(2) - PST(1);

PREXTimes = zeros(size(TrainResp,1)./length(trials),length(trials))';

AllRespMat = zeros(length(PREX),wnd.* Fs);
AllRespidc = zeros(length(PREX),1);

RespTraces = zeros(size(TrainResp,1),wnd.* Fs);
rhos = zeros(size(TrainResp,1),1);

for ii = 1:length(PREX)
   
    idx1 = round(PREX(ii).* Fs);
    idx2 = round((PREX(ii) + wnd) .* Fs) -1;
    
    AllRespMat(ii,:) = Resp(idx1:idx2);% - mean(Resp(idx1:idx2));
    AllRespidc(ii) = idx1;
    
end


AllRespMatBU = AllRespMat;
AllRespidcBU = AllRespidc;
      

for ii = 1:size(TrainResp,1)
    
   temp = corr([TrainResp(ii,:);AllRespMat]');
   
   temp = temp(2:end,1);
   
   
   [rho,idx] = max(temp);
   
   rhos(ii) = rho;
   RespTraces(ii,:) = AllRespMat(idx,:);
   PREXTimes(ii) = AllRespidc(idx);
   
   del = (AllRespidc > AllRespidc(idx) - wnd *Fs) & (AllRespidc < AllRespidc(idx) + wnd *Fs);
   
   
   AllRespMat(del,:) = [];
   AllRespidc(del) = [];
   
   if mod(ii,length(trials)) == 0
      
      AllRespMat = AllRespMatBU;
      AllRespidc = AllRespidcBU;
       
   end
   
    
end

PREXTimes = PREXTimes';
