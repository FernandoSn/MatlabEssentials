function plotWCCDriver(WCrossCorrA, freq, Fs)


LengthCross = ((size(WCrossCorrA,2)-1) / 2);

CrossDriverA = WCrossCorrA(:,end - LengthCross : end);

plotWaveletSpectrum((CrossDriverA),freq,Fs);
