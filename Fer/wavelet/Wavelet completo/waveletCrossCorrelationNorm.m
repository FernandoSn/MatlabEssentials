function [WCrossCorrA, WCrossCorrR, freq, vScale] = waveletCrossCorrelationNorm(Driver,Target,Fs,deltaJ)


if length(Driver)~=length(Target)
    error('numero de muestras diferente');
end

[wave1,vScale,freq,~] = waveletInvFourier(Driver,Fs,deltaJ);
wave2 = waveletInvFourier(Target,Fs,deltaJ);

%crossSpectrum = abs(wave1.* conj(wave2)); 
%plotWaveletSpectrum(crossSpectrum,freq,Fs);

%wave1 = abs(wave1).^2;
%wave2 = abs(wave2).^2;

%WCrossCorr = xcorr2(wave1,wave2);

%plotWaveletSpectrum(WCrossCorr,freq,Fs);
%plotWaveletSpectrum(abs(WCrossCorr).^2,freq,Fs);


WCrossCorrA = zeros(size(wave1,1),size(wave1,2) * 2 - 1);
WCrossCorrR = zeros(size(wave1,1),size(wave1,2) * 2 - 1);

for ii = 1 : size(wave1,1)
    
    TempCorr = xcorr(wave2(ii,:),wave1(ii,:));
    
    WCrossCorrA(ii,:) = abs(TempCorr);
    WCrossCorrA(ii,:) = WCrossCorrA(ii,:) ./ ...
        sqrt((sum(abs(wave1(ii,:).^2)) .* sum(abs(wave2(ii,:).^2))));
    
   WCrossCorrR(ii,:) = real(TempCorr);
    WCrossCorrR(ii,:) = WCrossCorrR(ii,:) ./ ...
       sqrt((sum(abs(wave1(ii,:)).^2) .* sum(abs(wave2(ii,:)).^2)));


end

%plotWaveletSpectrum((WCrossCorrA),freq,Fs);
plotWCCDriver((WCrossCorrA),freq,Fs);

%plotWaveletSpectrum((WCrossCorrR),freq,Fs);

%LagDataA = fliplr(WCrossCorrA(:,1:(size(wave1,2)-1))) - WCrossCorrA(:,(size(wave1,2)+1):end);
%LagDataA = [WCrossCorrA(:,size(wave1,2)),LagDataA];

%LagDataR = fliplr(WCrossCorrR(:,1:(size(wave1,2)-1))) - WCrossCorrR(:,(size(wave1,2)+1):end);
%LagDataR = [WCrossCorrR(:,size(wave1,2)),LagDataR];

%plotWaveletSpectrum(LagDataA,freq,Fs);
%plotWaveletSpectrum(LagDataR,freq,Fs);

%LagData = sum(LagData,2);

%figure
%plot(freq,LagData);
