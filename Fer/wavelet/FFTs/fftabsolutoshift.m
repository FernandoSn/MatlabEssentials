function [y,freq]=fftabsolutoshift(reg,sampling,resolution,window,overlap)


%Parametros convencionales
%resolution 0.1, window 1 s.

res=sampling/resolution;

window = window * sampling;

y=zeros(res,2);
n=1;

shift = overlap*window;

for ii = 1:shift:length(reg)-window
    
    if n==1
        
        w=hann(length(reg(ii:window+ii)));
        
        y(:,1)=((abs(fft(reg(ii:window+ii).*w,res))).^2)/res;
    
    else
        
        w=hann(length(reg(ii:window+ii)));
        
        y(:,2)=((abs(fft(reg(ii:window+ii).*w,res))).^2)/res;
        y(:,1)=mean(y,2);
        
    end
    
    n=n+1;
    
end

%y=(mean(y,2).^2);

y=y(:,1);


freq=0:(sampling/2)/(length(y)/2):sampling/2;

figure; plot(freq,y(1:length(freq)))
xlabel 'Frecuencia'
ylabel 'Potencia'
title 'Espectro de potencia'

y=y(1:length(freq));
freq=freq';