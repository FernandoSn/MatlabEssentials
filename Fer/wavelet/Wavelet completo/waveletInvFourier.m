function [w,vScale,freq,deltaT] = waveletInvFourier(signal,Fs,deltaJ)


if size(signal,1) > size(signal,2); signal = signal'; end %Se asegura que la señal tenga las dimensiones adecuadas.

originalLength = length(signal);


signal = signal - mean(signal);%Quita DC


    %base2 = fix(log(originalLength)/log(2) + 0.4999);   % Pad con ceros.
	%signal = [signal,zeros(1,2^(base2+1)-originalLength)];
    
    %NOTA se quita el pad para trabajar con coherencia del experimento
    %AbNPS, para otros análisis volver a activar.


deltaT = 1; %intervalo de muestreo, para análisis convencional asignar 1.
%deltaJ = 1/64;%numero de suboctavas. para analisis

vScale = waveletScales(deltaJ,signal,deltaT);  %Se llama a waveletScale ara determina el numero de suboctavas y regresar un vector con las escalas

fourierTr = fft(signal);  %Se trabaja en el espacio d fourier.

lenSignal = length(fourierTr);
vLenSignal = 1:lenSignal;  %Agiliza y limipia codigo.



w = zeros(length(vScale),lenSignal); %asigna espacio
freq = zeros(1,length(vScale));




vFreq=0:(Fs/2)/(lenSignal/2):Fs/2;  %Vector con frecuencias.


n=0; %Contador. Codigo mal escrito, corregir a futuro.

for s = vScale  %En este loop se realiza la transformada de Wavelets en el espacio de Fourier.

    n=n+1;
    
    [wFourierS, freq(n)] = waveletFourierSpace(s,vLenSignal,vFreq,deltaT);
    
    w(n,:) = ifft(fourierTr.*wFourierS.*sqrt((2*pi*s)/(deltaT)));  % para normalizar .*sqrt((2*pi*s)/(deltaT))
    
end

    w = w(:,1:originalLength);
    %w = abs(w).^2;

%plotWaveletSpectrum(abs(w).^2,freq,Fs);  %Activar si se desea graficar.
