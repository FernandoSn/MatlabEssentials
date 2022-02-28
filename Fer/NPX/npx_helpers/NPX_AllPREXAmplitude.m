function PREXAmplitude = NPX_AllPREXAmplitude(Resp,PREX, POSTX, Fs)

Basesub = false;

if Basesub

    PreWnd = 5;
    ini = find(PREX>PreWnd,1);

else
    
    ini = 1;
    
end


PREXAmplitude = zeros(1,length(PREX));
for ii = ini:length(PREX)
    
   idxPREX = round(PREX(ii).*Fs);
   idxPOSTX = round(POSTX(ii).*Fs);
    
   
   RespChunk = Resp(idxPREX:idxPOSTX);
   PREXAmplitude(ii) = min(RespChunk);
   
   if Basesub
       Base = mean(Resp(idxPREX-Fs*PreWnd:idxPREX));
       PREXAmplitude(ii) = Base - PREXAmplitude(ii);    
   else
       
       PREXAmplitude(ii) = PREXAmplitude(ii) * -1;
   end
    
    
end