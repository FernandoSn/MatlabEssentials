function [aveCoH,aveCross,aveCrossVar,ind2] = avTimeCoHAnalysis(coH,cross,crossSpectrumVar,freq,freqD,indice)

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


%Nota: La coherencia no se normaliza como "coherencia relativa". Solo se
%normaliza en funcion de la duracion de la señal.

aveCoH = (sum(coH,2)./size(coH,2))'; %Unica normalizacion de la señal.
aveCross = (sum(cross,2)./size(cross,2))';
%aveCrossVar = (sum(crossSpectrumVar,2))';
aveCrossVar = aveCross;

indT1 = find(freq >= 1,1,'last');
indT2 = find(freq >= 50,1,'last');

%aveSegmentoRelativaCoH = aveCoH(indT2:indT1); %Elimiar este comando.
aveSegmentoRelativaCross = aveCross(indT2:indT1);


%aveCoH=aveCoH./sum(aveSegmentoRelativaCoH); %Eliminar este comando.
aveCoH = aveCoH(ind2:ind1);

aveCross=aveCross./sum(aveSegmentoRelativaCross); %Activar para potencia relativa.
aveCross = aveCross(ind2:ind1);

aveCrossVar = aveCrossVar(ind2:ind1);

%figure;plot(aveCoH);
%figure;plot(aveCross);
%figure;plot(freq,aveCoH);
%figure;plot(freq,aveCross);

%Para usar esta funcion es necesaro normalizar la matriz compleja de
%wavelets. Ver funcion walevtInvFourier.