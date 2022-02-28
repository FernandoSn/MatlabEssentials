function plotWaveNPX(specWav,freq,varargin)

%%Plotting wavelet coherence or wavelet power NPX.

indT1 = length(freq);
indT2 = 1;

indT1 = find(freq >= 1,1,'last');     %desmarcar para margen, marcar para omitir margen %0.5
indT2 = find(freq >= 128,1,'last');

freq = freq(indT2:indT1);
specWav = specWav(indT2:indT1,:);

if(~isempty(varargin))
   
  specWav =  specWav ./ max(specWav);
    
end

%specWav = specWav/size(specWav,2); %Se obtiene la densidad. Unidades V^2/Hz

Xmarcas = 2.^(fix(log2(min(freq))) : fix(log2(max(freq))));

specWav = specWav';
figure;imagesc(log2(freq),[],specWav);

set(gca,'XDir','normal','XTick',log2(Xmarcas), ...
        'XTickLabel',num2str(Xmarcas'))

colormap('parula')