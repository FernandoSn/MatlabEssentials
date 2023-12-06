function ave = avTimeWaveSpectralPower(wav,freq,freqD,vScale,deltaJ)

if ~isempty(freqD)

    ind1 = find(freq >= freqD(1),1,'last');
    ind2 = find(freq >= freqD(2),1,'last');

else
    
    ind1 = length(freq);
    ind2 = 1;
end


%power = wav; %para coherencia.
power=abs(wav).^2; %para potencia
%power = sqrt((real(wav).^2)+(imag(wav).^2));

ave = (sum(power,2)./size(wav,2))';


ave=ave/varWavelet(power,vScale,deltaJ); %Normalizacion con varianza.
%ave=ave/sum(ave); %Activar para potencia relativa.


figure;plot(freq,ave);

ave = ave(ind2:ind1);

%Para usar esta funcion es necesaro normalizar la matriz compleja de
%wavelets. Ver funcion walevtInvFourier.