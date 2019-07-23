function [coH,crossSpectrum,freq,vScale,crossSpectrumVar] = waveletCoherence(signal1,signal2,Fs,deltaJ)

if length(signal1)~=length(signal2)
    error('numero de muestras diferente');
end

lenSignal = length(signal1);

[wave1,vScale,freq,deltaT] = waveletInvFourier(signal1,Fs,deltaJ);
wave2 = waveletInvFourier(signal2,Fs,deltaJ);


vScaleInv=1./(vScale');

sWave1=smoothwavelet(vScaleInv(:,ones(1,lenSignal)).*(abs(wave1).^2),deltaT... 
    ,[],deltaJ,vScale);

sWave2=smoothwavelet(vScaleInv(:,ones(1,lenSignal)).*(abs(wave2).^2),deltaT... 
    ,[],deltaJ,vScale);


crossSpectrum = wave1.* conj(wave2); 

sCrossSpectrum=smoothwavelet(vScaleInv(:,ones(1,lenSignal)).*crossSpectrum,deltaT...
    ,[],deltaJ,vScale);


coH=(abs(sCrossSpectrum).^2)./(sWave1.*sWave2);

crossSpectrum = abs(crossSpectrum);

%plotWaveletSpectrum(coH,freq,Fs);
%plotWaveletSpectrum(crossSpectrum,freq,Fs);

%%%%Hace crossSpectrum con Varianza%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

%var1=varWavelet((abs(wave1).^2),vScale,deltaJ);
%var2=varWavelet((abs(wave2).^2),vScale,deltaJ);

%wave1 = (wave1./size(wave1,2))./var1;
%wave2 = (wave2./size(wave2,2))./var2;

%wave1 = (wave1)./var1;
%wave2 = (wave2)./var2;

%crossSpectrumVar = abs(wave1.* conj(wave2)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

%crossSpectrumVar = (crossSpectrum./size(crossSpectrum,2));%./varWavelet(crossSpectrum,vScale,deltaJ));
crossSpectrumVar=[];


%avTimeWaveSpectralPower(coH,freq,[],vScale,deltaJ);