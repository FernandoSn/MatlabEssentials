function plotWaveletSpectrum(specWav,freq,t)

t=0:1/t:(size(specWav,2)/t)-(1/t);

indT1 = length(freq);
indT2 = 1;

indT1 = find(freq >= 1,1,'last');     %desmarcar para margen, marcar para omitir margen %0.5
indT2 = find(freq >= 128,1,'last');

freq = freq(indT2:indT1);
specWav = specWav(indT2:indT1,:);

%specWav = specWav/size(specWav,2); %Se obtiene la densidad. Unidades V^2/Hz

Ymarcas = 2.^(fix(log2(min(freq))) : fix(log2(max(freq))));


figure;imagesc([],log2(freq),specWav);

set(gca,'YDir','normal','YTick',log2(Ymarcas), ...
        'YTickLabel',num2str(Ymarcas'))

colormap('parula')

%caxis([0 .01])  %Funcion de matlab para cambiar el color "ganancia".



%pasos para graficar
%1.- Desmarcar la funcion en main. plotWaveletSpectrum.
%2.- Asignar 1 a deltaT en main.
%3.- Retirar el factor de normalización cuando se calcula la transformada
%   wavelets en main.
%4.- En la funcion wavelet scales desmarcar lo correspondiente. 