function variance = varWavelet(wav,vScale,deltaJ)

vScale = vScale';

lenSignal = size(wav,2);

variance = 0;

for ii = 1:size(wav,2)
    
    %varP = sum(((abs(wav(:,ii))).^2)./vScale); %Normalizacion con transformada compleja.
    varP = sum((((wav(:,ii))))./vScale); %Normalizacion con espectro de potencia.
    
    variance = variance + varP;
    
end


variance = (((deltaJ)*sqrt(1))/(0.776*lenSignal))*variance;

%Varianza elevada a la segunda potencia del espectro de wavelets.