function [wav,freq] = waveletFourierSpace(scale,freqshift,vFreq,deltaT)

%Morlet en el espacio de fourier.

N=length(freqshift); %Longitud de la señal.

freqshift(freqshift>N/2) = freqshift(freqshift>N/2).*-1; %Vector con coeficientes de fourier. se toma la mitad.

wangular= (2*pi*freqshift)./(N*deltaT); %Frecuencia angular.

x=scale.*wangular;  %Frecuencia final de morlet.

wo = 6; %Frecuencia de wavelet morlet.



heavisd = freqshift>0; %funcion heaviside.

wav = pi.^(-0.25) .* heavisd .* exp((-1.*(x-wo).^2)/2); %Morlet en espacio de fourier.



freq = vFreq(wav==max(wav)); %Frecuencia de fourier.





%freq2 = (4*pi)/(wo + sqrt(2 + wo^2)); % Scale-->Fourier [Sec.3h]
%coi = freq/sqrt(2); 


%Lineas adicionales, sirvieron para evaluar integrales durante la
%construccion del algoritmo.

%wav = wav .* exp(1i.*wangular.*freqshift);

%fun = @(x) abs(pi.^(-1/4) .* heavisd .* exp((-1.*(x-wo).^2)/2)).^2;

%q = integral(fun,-inf,inf);