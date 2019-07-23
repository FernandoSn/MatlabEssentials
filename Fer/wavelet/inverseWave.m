function [w,vScale,freq] = waveletInvFourier(signal,Fs)

%vScale = 2*2.^((0:141)*0.0833);
%vScale = 2*2.^((0:89)*0.0833);
%vScale = 0.1:0.01:100;

vScale = waveletScales(1/32,signal);

fourierTr = fft(signal);  %Se trabaja en el espacio d fourier.

vLenSignal = 1:length(fourierTr);



w = zeros(length(vScale),length(fourierTr)); %aloca espacio
freq = zeros(1,length(vScale));




vFreq=0:(Fs/2)/(length(fourierTr)/2):Fs/2;


n=0;

for s = vScale

    n=n+1;
    
    [wFourierS, freq(n)] = waveletFourierSpace(s,vLenSignal,vFreq);
    
    w(n,:) = ifft(fourierTr.*wFourierS);  %.*sqrt(2*pi*s)
    
end