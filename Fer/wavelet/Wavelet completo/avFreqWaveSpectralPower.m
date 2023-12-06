function ave = avFreqWaveSpectralPower(wav,vScale,deltaJ,freq,freqD)

if ~isempty(freqD)

   ind1 = find(freq >= freqD(1),1,'last');
    ind2 = find(freq >= freqD(2),1,'last');

else
    
    ind1 = length(vScale);
    ind2 = 1;
end

    vScaleT = vScale';

    power=(abs(wav(ind2:ind1,:)).^2)./(vScaleT(ind2:ind1,:));
    
    %power = power(ind2:ind1,:); Otra manera de seleccionar datos, ocupa
    %mas memoria.


ave = (sum(power,1));

ave = (deltaJ/0.776)*ave;

ave=ave/varWavelet(wav,vScale,deltaJ); %Normalizacion con varianza.
%ave=ave/sum(ave); %Activar para potencia relativa

figure;plot(ave);


%Para usar esta funcion es necesaro normalizar la matriz compleja de
%wavelets. Ver funcion walevtInvFourier.