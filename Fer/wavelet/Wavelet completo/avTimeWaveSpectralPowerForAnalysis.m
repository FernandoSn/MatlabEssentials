function [ave,aveVar,ind2] = avTimeWaveSpectralPowerForAnalysis(wav,freq,freqD,vScale,deltaJ,indice)

if ~isempty(freqD)
    
    if ~isempty(indice)
        
        ind1 = indice-1;
        
    else
        
        ind1 = find(freq >= freqD(1),1,'last');
    
    end
    
    ind2 = find(freq >= freqD(2),1,'last');
    
else
    
    ind1 = length(freq);
    ind2 = 1;
end


%%%NOTA:
%No se usara varianza porque si importa la amplitud de la señal.
%Se recurre a usar potencia abosulta, tan solo normalizada por el tamaño
%la duracion de la señal. Se ajustaran las lineas base de todas las ratas.

power=wav;

ave = (sum(power,2)./size(wav,2))'; %Unica normalizacion por duracion.


aveVar=ave;%./varWavelet(wav,vScale,deltaJ); %Normalizacion con varianza.

aveVar = aveVar(ind2:ind1);

indT1 = find(freq >= 1,1,'last');
indT2 = find(freq >= 50,1,'last');

aveSegmentoRelativa = ave(indT2:indT1);

ave=ave./sum(aveSegmentoRelativa); %Activar para potencia relativa.

ave = ave(ind2:ind1);

%figure;plot(freq,aveVar);

%Para usar esta funcion es necesaro normalizar la matriz compleja de
%wavelets. Ver funcion walevtInvFourier.