function [deltaCoH,deltaCross,tetaCoH,tetaCross,...
    alphaCoH,alphaCross,betaCoH,betaCross,gammaCoH,gammaCross,coH,crossSpectrum,freq,crossSpectrumVar,...
    deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar] = controlCoH(registro,channel1,channel2)        

%Inidicaciones, ajustar la variazna dependiendo si se normaliza con
%transformada compleja o espectro de potencia.

reg1 = registro(:,channel1);
reg2 = registro(:,channel2);


    fprintf('wavelet coherence spectrum\n');

[coH,crossSpectrum,freq,~,crossSpectrumVar] = waveletCoherence(reg1,reg2,1000,1/12);

%crossSpectrum = crossSpectrum.^2; %cross al cuadrado.
    fprintf('delta\n');
    
[deltaCoH,deltaCross,deltaCrossVar,ind] = avTimeCoHAnalysis(coH,crossSpectrum,crossSpectrumVar,freq,[1 4],[]);
%[deltaRel,deltaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[1 4],vScale,1/64,[]);

    
    deltaCoH = sum(deltaCoH);
    deltaCross = sum(deltaCross);
    deltaCrossVar = sum(deltaCrossVar);
    
    
    fprintf('teta\n');
    
[tetaCoH,tetaCross,tetaCrossVar,ind] = avTimeCoHAnalysis(coH,crossSpectrum,crossSpectrumVar,freq,[4 7],ind);
%[tetaRel,tetaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[4 7],vScale,1/64,ind);

    
    tetaCoH = sum(tetaCoH);
    tetaCross = sum(tetaCross);
    tetaCrossVar = sum(tetaCrossVar);
 

    fprintf('alpha\n');

[alphaCoH,alphaCross,alphaCrossVar,ind] = avTimeCoHAnalysis(coH,crossSpectrum,crossSpectrumVar,freq,[7 10],ind);
%[alphaRel,alphaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[7 10],vScale,1/64,ind);

    
    alphaCoH = sum(alphaCoH);
    alphaCross = sum(alphaCross);
    alphaCrossVar = sum(alphaCrossVar);
    
    
    fprintf('beta\n');

[betaCoH,betaCross,betaCrossVar,ind] = avTimeCoHAnalysis(coH,crossSpectrum,crossSpectrumVar,freq,[10 20],ind);
%[betaRel,betaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[10 20],vScale,1/64,ind);

    betaCoH = sum(betaCoH);
    betaCross = sum(betaCross);
    betaCrossVar = sum(betaCrossVar);
    
    fprintf('gamma\n');

[gammaCoH,gammaCross,gammaCrossVar,~] = avTimeCoHAnalysis(coH,crossSpectrum,crossSpectrumVar,freq,[20 50],ind);
%[gammaRel,gammaVar,~] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[20 50],vScale,1/64,ind);

    gammaCoH = sum(gammaCoH);
    gammaCross = sum(gammaCross);
    gammaCrossVar = sum(gammaCrossVar);