function [deltaRel,deltaVar,tetaRel,tetaVar,...
    alphaRel,alphaVar,betaRel,betaVar,gammaRel,gammaVar] = controlF(registro,channel,muestras)        

%Inidicaciones, ajustar la variazna dependiendo si se normaliza con
%transformada compleja o espectro de potencia.

reg = registro(:,channel);

if ~isempty(muestras); reg = reg(muestras(1):muestras(2)); end

    fprintf('wavelet transform\n');

[wav,vScale,freq] = waveletInvFourier(reg,1000,1/12);

    wav = abs(wav).^2;

    fprintf('delta\n');
    
[deltaRel,deltaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[1 4],vScale,1/12,[]);

    
    deltaVar = sum(deltaVar);
    deltaRel = sum(deltaRel);
    
    
    fprintf('teta\n');

[tetaRel,tetaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[4 7],vScale,1/12,ind);

    
    tetaVar = sum(tetaVar);
    tetaRel = sum(tetaRel);
 

    fprintf('alpha\n');
    
[alphaRel,alphaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[7 10],vScale,1/12,ind);

    
    alphaVar = sum(alphaVar);
    alphaRel = sum(alphaRel);
    
    
    fprintf('beta\n');

[betaRel,betaVar,ind] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[10 20],vScale,1/12,ind);

    betaVar = sum(betaVar);
    betaRel = sum(betaRel);
    
    fprintf('gamma\n');

[gammaRel,gammaVar,~] = avTimeWaveSpectralPowerForAnalysis(wav,freq,[20 50],vScale,1/12,ind);

    gammaVar = sum(gammaVar);
    gammaRel = sum(gammaRel);